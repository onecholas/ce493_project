`timescale 1ns / 1ps

module pe_array_tb;

    // -------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------
    parameter G_ARRAY_HEIGHT   = 5;
    parameter G_ARRAY_WIDTH    = 6;
    parameter G_BUF_ADDR_WIDTH = 10;
    parameter G_BUF_DATA_WIDTH = 8;
    parameter G_TOP_BITS       = 2;
    parameter G_BOT_BITS       = 14;
    parameter G_KERNEL_SIZE    = 5;
    
    // 1. New Generics for Image Dimensions
    parameter G_IMAGE_HEIGHT   = 28;
    parameter G_IMAGE_WIDTH    = 28;

    // Derived parameters
    localparam DATA_WIDTH = G_TOP_BITS + G_BOT_BITS;
    localparam NUM_IFMAP_INPUTS = G_ARRAY_HEIGHT + G_ARRAY_WIDTH - 1; 
    
    // Mapping Stride
    localparam ROW_MAPPING_STRIDE = NUM_IFMAP_INPUTS + 1 - G_KERNEL_SIZE;

    // Testbench Parameters
    localparam BUFFER_DEPTH = G_IMAGE_WIDTH;

    // Result Dimensions
    localparam OUT_HEIGHT = G_IMAGE_HEIGHT - G_KERNEL_SIZE + 1;
    localparam OUT_WIDTH  = G_IMAGE_WIDTH - G_KERNEL_SIZE + 1;

    // Calculate how many folded rows we need per buffer
    localparam NUM_ROWS = (OUT_HEIGHT + G_ARRAY_WIDTH - 1) / G_ARRAY_WIDTH;

    // -------------------------------------------------------------------------
    // Signals
    // -------------------------------------------------------------------------
    logic clk_i;
    logic rst_i;

    // Ifmap signals
    logic [0:NUM_IFMAP_INPUTS-1] ifmap_vld_i;
    logic [0:NUM_IFMAP_INPUTS-1] ifmap_row_i;
    logic [0:NUM_IFMAP_INPUTS-1][DATA_WIDTH-1:0] ifmap_i;

    // Weight signals
    logic weight_vld_i;
    logic [0:G_ARRAY_HEIGHT-1][DATA_WIDTH-1:0] weight_i; 
    logic weight_clr_i;

    // Output signals
    logic [0:G_ARRAY_WIDTH-1] psum_vld_o;
    logic [0:G_ARRAY_WIDTH-1][DATA_WIDTH-1:0] psum_o;

    // Testbench Control
    logic start_stimulus; 
    
    // Input Buffers
    logic [DATA_WIDTH-1:0] input_buffers [0:NUM_IFMAP_INPUTS-1][0:NUM_ROWS-1][0:BUFFER_DEPTH-1];
    logic input_row_buffers [0:NUM_IFMAP_INPUTS-1][0:NUM_ROWS-1][0:BUFFER_DEPTH-1];
    logic [0:NUM_IFMAP_INPUTS-1] alternating_row;

    // Generated Data
    logic [DATA_WIDTH-1:0] image  [0:G_IMAGE_HEIGHT-1][0:G_IMAGE_WIDTH-1];
    logic [DATA_WIDTH-1:0] kernel [0:G_KERNEL_SIZE-1][0:G_KERNEL_SIZE-1];
    
    // Results
    logic [31:0] expected_result [0:OUT_HEIGHT-1][0:OUT_WIDTH-1];
    logic [31:0] actual_result   [0:OUT_HEIGHT-1][0:OUT_WIDTH-1];

    // Counters for output capture
    int out_col_cnt [0:G_ARRAY_WIDTH-1];
    int out_row_cnt [0:G_ARRAY_WIDTH-1];

    // -------------------------------------------------------------------------
    // DUT Instantiation
    // -------------------------------------------------------------------------
    pe_array #(
        .G_ARRAY_HEIGHT   (G_ARRAY_HEIGHT),
        .G_ARRAY_WIDTH    (G_ARRAY_WIDTH),
        .G_BUF_ADDR_WIDTH (G_BUF_ADDR_WIDTH),
        .G_BUF_DATA_WIDTH (G_BUF_DATA_WIDTH),
        .G_TOP_BITS       (G_TOP_BITS),
        .G_BOT_BITS       (G_BOT_BITS),
        .G_KERNEL_SIZE    (G_KERNEL_SIZE),
        .G_IMAGE_HEIGHT   (G_IMAGE_HEIGHT),
        .G_IMAGE_WIDTH    (G_IMAGE_WIDTH)
    ) pe_array_inst (
        .clk_i        (clk_i),
        .rst_i        (rst_i),
        .ifmap_vld_i  (ifmap_vld_i),
        .ifmap_row_i  (ifmap_row_i),
        .ifmap_i      (ifmap_i),
        .weight_vld_i (weight_vld_i),
        .weight_i     (weight_i),    
        .weight_clr_i (weight_clr_i),
        .psum_vld_o   (psum_vld_o),
        .psum_o       (psum_o)
    );

    // -------------------------------------------------------------------------
    // Clock Generation
    // -------------------------------------------------------------------------
    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i; 
    end

    // -------------------------------------------------------------------------
    // Data Generation and Mapping
    // -------------------------------------------------------------------------
    initial begin
        // A. Generate Random Image and Kernel
        $display("Generating Image and Kernel...");
        for(int r=0; r<G_IMAGE_HEIGHT; r++) begin
            for(int c=0; c<G_IMAGE_WIDTH; c++) begin
                image[r][c] = (r+c) % 16; // Simple pattern for debug
            end
        end

        for(int r=0; r<G_KERNEL_SIZE; r++) begin
            for(int c=0; c<G_KERNEL_SIZE; c++) begin
                kernel[r][c] = (r==c) ? 1 : 0;
            end
        end

        // B. Precompute Expected 2D Convolution Result (Golden Model)
        for(int r=0; r<OUT_HEIGHT; r++) begin
            for(int c=0; c<OUT_WIDTH; c++) begin
                expected_result[r][c] = 0;
                for(int kr=0; kr<G_KERNEL_SIZE; kr++) begin
                    for(int kc=0; kc<G_KERNEL_SIZE; kc++) begin
                        expected_result[r][c] += image[r+kr][c+kc] * kernel[kr][kc];
                    end
                end
            end
        end

        // C. Initialize Buffers to 0
        for (int i = 0; i < NUM_IFMAP_INPUTS; i++) begin
            for (int j = 0; j < NUM_ROWS; j++) begin
                for (int k = 0; k < BUFFER_DEPTH; k++) begin
                    input_buffers[i][j][k]     = 0;
                    input_row_buffers[i][j][k] = 0;
                end
                alternating_row[i] = 0;
            end
        end

        // D. Map Image Rows to Input Buffers, Buffer[i] gets rows where (row % STRIDE) == i
        $display("Mapping Image Rows to Buffers (Stride: %0d)...", ROW_MAPPING_STRIDE);
        
        for (int t = 0; t < NUM_ROWS; t++) begin
            for (int b = 0; b < NUM_IFMAP_INPUTS; b++) begin
                int r_idx;
                r_idx = b + (t * ROW_MAPPING_STRIDE);

                if (r_idx < G_IMAGE_HEIGHT) begin
                    for(int c=0; c<G_IMAGE_WIDTH; c++) begin
                        input_buffers[b][t][c] = image[r_idx][c];
                        // Row toggle logic based on time slot
                        input_row_buffers[b][t][c] = (t + 1) % 2; 
                    end
                end
            end
        end
    end

    // -------------------------------------------------------------------------
    // Main Control Process
    // -------------------------------------------------------------------------
        
    // Array to store the count for each column
    int psum_vld_counts [0:G_ARRAY_WIDTH-1];
    int total_psum_vld_counts = 0;
    int errors = 0;
    
    initial begin
        // 1. Initialization
        rst_i        = 1;
        weight_vld_i = 0;
        weight_i     = '{default: '0};
        weight_clr_i = 0;
        start_stimulus = 0;

        // Initialize output capture counters
        for(int i=0; i<G_ARRAY_WIDTH; i++) begin
            out_col_cnt[i] = 0;
            out_row_cnt[i] = 0;
        end

        // 2. Reset Sequence
        repeat (5) @(posedge clk_i);
        rst_i = 0;
        @(posedge clk_i); 

        // 3. Load Weights 
        // We load columns of the kernel into the weight ports over time
        $display("[%0t] Starting Weight Load...", $time);
        
        weight_vld_i = 1;
        
        for (int k = 0; k < G_KERNEL_SIZE; k++) begin            
            for (int r = 0; r < G_ARRAY_HEIGHT; r++) begin
                // Map kernel rows to array rows
                // Map kernel columns to time (k)
                weight_i[r] = kernel[r][k]; 
            end
            @(posedge clk_i);
        end

        weight_vld_i = 0;
        weight_i     = '{default: '0};
        @(posedge clk_i);
        $display("[%0t] Weight Load Complete.", $time);

        repeat (2) @(posedge clk_i);

        // 4. Trigger Parallel Drivers
        start_stimulus = 1;

        // 5. Wait for sufficient time for 28x28 image processing
        // 28 cols + gap overhead * 5 rows + pipe delays
        repeat (2000) @(posedge clk_i);

        $display("[%0t] Simulation Complete. Checking Results...", $time);
        
        $display("\n=======================================================");
        $display(" PSUM VALID COUNT REPORT                  ");
        $display("=======================================================");
        for (int i = 0; i < G_ARRAY_WIDTH; i++) begin
            $display("COLUMN [%0d] TOTAL PSUM VALID PULSES: %0d", i, psum_vld_counts[i]);
            total_psum_vld_counts += psum_vld_counts[i];
        end
        if (total_psum_vld_counts == OUT_HEIGHT*OUT_WIDTH) begin
            $display("NUMBER OF PSUM VALID PULSES CORRECT: %0d", total_psum_vld_counts);
        end else begin
            $display("NUMBER OF PSUM VALID PULSES INCORRECT: %0d, EXPECTED: %0d", total_psum_vld_counts, OUT_HEIGHT*OUT_WIDTH);
        end
        $display("=======================================================\n");

        for(int r=0; r<OUT_HEIGHT; r++) begin
            for(int c=0; c<OUT_WIDTH; c++) begin
                if (actual_result[r][c] !== expected_result[r][c]) begin
                    $display("ERROR at [%0d][%0d]: Expected %0d, Got %0d", 
                        r, c, expected_result[r][c], actual_result[r][c]);
                    errors++;
                end else begin
                    $display("CORRECT at [%0d][%0d]: Expected %0d, Got %0d", 
                        r, c, expected_result[r][c], actual_result[r][c]);
                end
            end
        end

        $display("=======================================================");
        if (errors == 0) begin
            $display(" VERIFICATION PASSED: All 24x24 pixels match.");
        end else begin
            $display(" VERIFICATION FAILED: %0d Mismatches found.", errors);
        end
        $display("=======================================================\n");

        $finish;
    end

    // -------------------------------------------------------------------------
    // Capture Output Logic
    // -------------------------------------------------------------------------
    // Store psum_o into 24x24 array.
    // Logic: psum_o[0] carries rows 0, 6, 12... 
    //        psum_o[1] carries rows 1, 7, 13...
    genvar c;
    generate
        for (c = 0; c < G_ARRAY_WIDTH; c++) begin : output_capture
            always @(posedge clk_i) begin
                if (psum_vld_o[c]) begin
                    int actual_row;
                    int actual_col;
                    
                    // Determine which row of the final 24x24 image this is
                    // Base row (c) + (Cycle * Stride)
                    actual_row = c + (out_row_cnt[c] * ROW_MAPPING_STRIDE);
                    actual_col = out_col_cnt[c];

                    // Store valid pixel
                    if (actual_row < OUT_HEIGHT && actual_col < OUT_WIDTH) begin
                        actual_result[actual_row][actual_col] = psum_o[c];
                    end

                    // Increment Column Counter
                    if (out_col_cnt[c] == OUT_WIDTH - 1) begin
                        out_col_cnt[c] = 0;
                        out_row_cnt[c]++;
                    end else begin
                        out_col_cnt[c]++;
                    end
                end
            end
        end
    endgenerate

    // -------------------------------------------------------------------------
    // Parallel Drivers
    // -------------------------------------------------------------------------
    genvar g_idx;
    generate
        for (g_idx = 0; g_idx < NUM_IFMAP_INPUTS; g_idx++) begin : gen_drivers
            initial begin
                // Initialize channel outputs
                ifmap_vld_i[g_idx] = 0;
                ifmap_row_i[g_idx] = 0;
                ifmap_i[g_idx]     = 0;

                // Wait for start
                wait(start_stimulus);
                @(posedge clk_i);

                // Start Delay Calculation
                if (g_idx <= 4) begin
                    repeat (g_idx) @(posedge clk_i);
                end else begin
                    repeat (g_idx-5 + G_ARRAY_HEIGHT + G_ARRAY_HEIGHT*(G_KERNEL_SIZE+1) * (g_idx - 4)) @(posedge clk_i);
                end
                
                // Drive Buffer Data
                for (int img_row_ptr = 0; img_row_ptr < NUM_ROWS; img_row_ptr++) begin
                    for (int buf_ptr = 0; buf_ptr < BUFFER_DEPTH; buf_ptr++) begin
                        // Drive Valid
                        ifmap_vld_i[g_idx]     = 1'b1;
                        ifmap_row_i[g_idx]     = input_row_buffers[g_idx][img_row_ptr][buf_ptr];
                        ifmap_i[g_idx]         = input_buffers[g_idx][img_row_ptr][buf_ptr];
                        alternating_row[g_idx] = input_row_buffers[g_idx][img_row_ptr][buf_ptr];
                        
                        @(posedge clk_i);

                        // Drive Invalid (Gap)
                        ifmap_vld_i[g_idx] = 1'b0;

                        // Wait G_ARRAY_HEIGHT cycles (skipping mechanism)
                        repeat (G_ARRAY_HEIGHT) @(posedge clk_i);
                    end
                end
                
                // Drive Alternating Rows to Squash Future Outputs (Flush)
                forever begin
                    alternating_row[g_idx] = ~alternating_row[g_idx];
                    ifmap_vld_i[g_idx] = 1'b1;
                    ifmap_row_i[g_idx] = alternating_row[g_idx];
                    ifmap_i[g_idx]     = 0;
                    
                    @(posedge clk_i);

                    ifmap_vld_i[g_idx] = 1'b0;
                    repeat (G_ARRAY_HEIGHT) @(posedge clk_i);
                end
            end
        end
    endgenerate

    // -------------------------------------------------------------------------
    // PSUM Output Valid Counter
    // -------------------------------------------------------------------------

    // Initialize counts to 0
    initial begin
        for (int i = 0; i < G_ARRAY_WIDTH; i++) begin
            psum_vld_counts[i] = 0;
        end
    end

    // Monitor process
    always @(posedge clk_i) begin
        if (!rst_i) begin // Only count when not in reset
            for (int i = 0; i < G_ARRAY_WIDTH; i++) begin
                if (psum_vld_o[i] == 1'b1) begin
                    psum_vld_counts[i]++;
                end
            end
        end
    end

endmodule