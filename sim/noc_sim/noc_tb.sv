`timescale 1ns / 1ps

module noc_tb;

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
    
    // Image Dimensions
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
    logic start_i;

    // --- NOC Interface Signals ---
    
    // IFMAP (Unicast) Connections
    logic [0:NUM_IFMAP_INPUTS-1][DATA_WIDTH-1:0] noc_ifmap_i;
    logic [0:NUM_IFMAP_INPUTS-1] noc_ifmap_row_i;
    logic [0:NUM_IFMAP_INPUTS-1] noc_ifmap_empty_i;
    logic [0:NUM_IFMAP_INPUTS-1] noc_ifmap_rd_en_o;

    // WEIGHT (Broadcast) Connections
    logic [0:G_ARRAY_HEIGHT-1][DATA_WIDTH-1:0] noc_weight_i;
    logic noc_weight_empty_i;
    logic noc_weight_clr_i;
    logic noc_weight_rd_en_o;

    // PSUM (Output) Connections
    logic [0:G_ARRAY_WIDTH-1] noc_psum_rd_en_i;
    logic [0:G_ARRAY_WIDTH-1] noc_psum_empty_o;
    logic [0:G_ARRAY_WIDTH-1][DATA_WIDTH-1:0] noc_psum_o; // Adjusted width based on noc def

    // --- Testbench FIFO Control Signals ---

    // Weight FIFO (Wide FIFO to hold all rows at once)
    logic weight_fifo_wr_en;
    logic [(G_ARRAY_HEIGHT*DATA_WIDTH)-1:0] weight_fifo_din;
    logic [(G_ARRAY_HEIGHT*DATA_WIDTH)-1:0] weight_fifo_dout;
    logic weight_fifo_full;

    // Ifmap FIFOs (One per channel)
    logic [0:NUM_IFMAP_INPUTS-1] ifmap_fifo_wr_en;
    logic [0:NUM_IFMAP_INPUTS-1][DATA_WIDTH:0] ifmap_fifo_din; // +1 bit for row toggle
    logic [0:NUM_IFMAP_INPUTS-1][DATA_WIDTH:0] ifmap_fifo_dout;
    logic [0:NUM_IFMAP_INPUTS-1] ifmap_fifo_full;

    // --- Data Generation Buffers ---
    logic [DATA_WIDTH-1:0] input_buffers [0:NUM_IFMAP_INPUTS-1][0:NUM_ROWS-1][0:BUFFER_DEPTH-1];
    logic input_row_buffers [0:NUM_IFMAP_INPUTS-1][0:NUM_ROWS-1][0:BUFFER_DEPTH-1];
    
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
    // Clock Generation
    // -------------------------------------------------------------------------
    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i; 
    end

    // -------------------------------------------------------------------------
    // FIFO Instantiations
    // -------------------------------------------------------------------------

    // The NOC reads all weight rows simultaneously (Broadcast columns). 
    // [0:HEIGHT-1][DATA] is packed into one wide vector.
    fifo #(
        .FIFO_DATA_WIDTH ((G_ARRAY_HEIGHT * DATA_WIDTH)),
        .FIFO_BUFFER_SIZE (64) 
    ) weight_fifo_inst (
        .reset   (rst_i),
        .wr_clk  (clk_i),
        .wr_en   (weight_fifo_wr_en),
        .din     (weight_fifo_din),
        .full    (weight_fifo_full),
        .rd_clk  (clk_i),
        .rd_en   (noc_weight_rd_en_o),
        .dout    (weight_fifo_dout),
        .empty   (noc_weight_empty_i)
    );

    // Unpack Weight FIFO output to NOC input array
    genvar r;
    generate
        for (r = 0; r < G_ARRAY_HEIGHT; r++) begin : unpack_weights
            assign noc_weight_i[r] = weight_fifo_dout[((G_ARRAY_HEIGHT-1-r)*DATA_WIDTH) +: DATA_WIDTH];
        end
    endgenerate

    // One FIFO per input channel. Data width + 1 bit for ifmap_row signal.
    genvar g;
    generate
        for (g = 0; g < NUM_IFMAP_INPUTS; g++) begin : gen_ifmap_fifos
            fifo #(
                .FIFO_DATA_WIDTH (DATA_WIDTH + 1), // Data + Row Bit
                .FIFO_BUFFER_SIZE (1024)           // Deep enough for whole image strip
            ) ifmap_fifo_inst (
                .reset   (rst_i),
                .wr_clk  (clk_i),
                .wr_en   (ifmap_fifo_wr_en[g]),
                .din     (ifmap_fifo_din[g]),
                .full    (ifmap_fifo_full[g]),
                .rd_clk  (clk_i),
                .rd_en   (noc_ifmap_rd_en_o[g]),
                .dout    (ifmap_fifo_dout[g]),
                .empty   (noc_ifmap_empty_i[g])
            );

            // Connect FIFO output to NOC inputs
            // MSB is row toggle, LSBs are data
            assign noc_ifmap_row_i[g] = ifmap_fifo_dout[g][DATA_WIDTH];
            assign noc_ifmap_i[g]     = ifmap_fifo_dout[g][DATA_WIDTH-1:0];
        end
    endgenerate


    // -------------------------------------------------------------------------
    // DUT Instantiation (NOC)
    // -------------------------------------------------------------------------
    noc #(
        .G_ARRAY_HEIGHT   (G_ARRAY_HEIGHT),
        .G_ARRAY_WIDTH    (G_ARRAY_WIDTH),
        .G_BUF_ADDR_WIDTH (G_BUF_ADDR_WIDTH),
        .G_BUF_DATA_WIDTH (G_BUF_DATA_WIDTH),
        .G_TOP_BITS       (G_TOP_BITS),
        .G_BOT_BITS       (G_BOT_BITS),
        .G_KERNEL_SIZE    (G_KERNEL_SIZE),
        .G_IMAGE_HEIGHT   (G_IMAGE_HEIGHT),
        .G_IMAGE_WIDTH    (G_IMAGE_WIDTH)
    ) noc_inst (
        .clk_i          (clk_i),
        .rst_i          (rst_i),
        .start_i        (start_i),

        // Ifmaps
        .ifmap_i        (noc_ifmap_i),
        .ifmap_row_i    (noc_ifmap_row_i),
        .ifmap_empty_i  (noc_ifmap_empty_i),
        .ifmap_rd_en_o  (noc_ifmap_rd_en_o),

        // Weights
        .weight_i       (noc_weight_i),
        .weight_empty_i (noc_weight_empty_i),
        .weight_clr_i   (noc_weight_clr_i),
        .weight_rd_en_o (noc_weight_rd_en_o),

        // Outputs
        .psum_rd_en_i   (noc_psum_rd_en_i),
        .psum_empty_o   (noc_psum_empty_o),
        .psum_o         (noc_psum_o)
    );

    // -------------------------------------------------------------------------
    // Data Generation and Mapping
    // -------------------------------------------------------------------------
    initial begin
        // A. Generate Random Image and Kernel
        $display("Generating Image and Kernel...");
        for(int r=0; r<G_IMAGE_HEIGHT; r++) begin
            for(int c=0; c<G_IMAGE_WIDTH; c++) begin
                image[r][c] = (r+c) % 16; 
                // image[r][c] = c;
            end
        end

        for(int r=0; r<G_KERNEL_SIZE; r++) begin
            for(int c=0; c<G_KERNEL_SIZE; c++) begin
                // kernel[r][c] = (r==c) ? 1 : 0;
                kernel[r][c] = (r+c) % 5;
                // kernel[r][c] = 1;
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
            end
        end

        // D. Map Image Rows to Input Buffers
        $display("Mapping Image Rows to Buffers (Stride: %0d)...", ROW_MAPPING_STRIDE);
        for (int t = 0; t < NUM_ROWS; t++) begin
            for (int b = 0; b < NUM_IFMAP_INPUTS; b++) begin
                int r_idx;
                r_idx = b + (t * ROW_MAPPING_STRIDE);
                if (r_idx < G_IMAGE_HEIGHT) begin
                    for(int c=0; c<G_IMAGE_WIDTH; c++) begin
                        input_buffers[b][t][c] = image[r_idx][c];
                        input_row_buffers[b][t][c] = (t + 1) % 2; 
                    end
                end
            end
        end
    end

    // -------------------------------------------------------------------------
    // Main Control Process (Driver)
    // -------------------------------------------------------------------------
    logic current_row_toggle = 0; 
    int errors = 0;
    
    initial begin
        // 1. Initialization
        rst_i             = 1;
        start_i           = 0;
        noc_weight_clr_i  = 0;
        
        weight_fifo_wr_en = 0;
        weight_fifo_din   = 0;
        ifmap_fifo_wr_en  = 0;
        ifmap_fifo_din    = '{default:0};

        // Initialize output capture counters
        for(int i=0; i<G_ARRAY_WIDTH; i++) begin
            out_col_cnt[i] = 0;
            out_row_cnt[i] = 0;
        end

        // 2. Reset Sequence
        repeat (5) @(posedge clk_i);
        rst_i = 0;
        @(posedge clk_i); 

        // ------------------------------------------------------------
        // 3. Load Weight FIFO
        // ------------------------------------------------------------
        $display("[%0t] Loading Weight FIFOs...", $time);
        
        for (int k = 0; k < G_KERNEL_SIZE; k++) begin            
            logic [(G_ARRAY_HEIGHT*DATA_WIDTH)-1:0] current_weight_col;
            for (int r = 0; r < G_ARRAY_HEIGHT; r++) begin
                current_weight_col[((G_ARRAY_HEIGHT-1-r)*DATA_WIDTH) +: DATA_WIDTH] = kernel[r][k];
            end
            weight_fifo_din   = current_weight_col;
            weight_fifo_wr_en = 1;
            @(posedge clk_i);
        end
        
        weight_fifo_wr_en = 0;
        $display("[%0t] Weight Load Complete.", $time);

        // Loop through the mapped rows (tiles)
        for (int img_row_ptr = 0; img_row_ptr < NUM_ROWS; img_row_ptr++) begin
            // Loop through the pixels in the row
            for (int buf_ptr = 0; buf_ptr < BUFFER_DEPTH; buf_ptr++) begin
                // Loop through all channels to drive them in parallel
                for (int ch = 0; ch < NUM_IFMAP_INPUTS; ch++) begin
                    ifmap_fifo_din[ch] = {
                        input_row_buffers[ch][img_row_ptr][buf_ptr], // MSB: Row Toggle
                        input_buffers[ch][img_row_ptr][buf_ptr]      // LSB: Data
                    };
                    ifmap_fifo_wr_en[ch] = 1;

                    // Capture the toggle for the filling phase (channel 0 is representative)
                    if (ch == 0) current_row_toggle = input_row_buffers[ch][img_row_ptr][buf_ptr];
                end
                @(posedge clk_i);
            end
        end

        // // Fill up FIFOs with alternating rows to suppress incorrect output
        // // Flip the toggle bit every cycle until full
        // $display("[%0t] Padding Ifmap FIFOs...", $time);
        
        // while (!ifmap_fifo_full[0]) begin // Check if channel 0 is full (assuming all fill synchronously)
        //     current_row_toggle = ~current_row_toggle;
            
        //     for (int ch = 0; ch < NUM_IFMAP_INPUTS; ch++) begin
        //         ifmap_fifo_din[ch] = {
        //             current_row_toggle,   // MSB: Alternating Row Toggle
        //             {DATA_WIDTH{1'b0}}    // LSB: Data (Zero padding)
        //         };
        //         ifmap_fifo_wr_en[ch] = 1;
        //     end
        //     @(posedge clk_i);
        // end


        // Clear enable after loop (handled above for last channel, ensure all clear)
        ifmap_fifo_wr_en = 0; 
        @(posedge clk_i);
        $display("[%0t] Ifmap Load Complete.", $time);


        // ------------------------------------------------------------
        // 5. Start Execution
        // ------------------------------------------------------------
        repeat (10) @(posedge clk_i);
        $display("[%0t] Asserting Start...", $time);
        start_i = 1;
        @(posedge clk_i);
        start_i = 0;


        // ------------------------------------------------------------
        // 6. Wait for Completion
        // ------------------------------------------------------------
        // Wait until we have received all expected pixels
        // or a timeout occurs
        fork
            // begin
            //     wait (out_row_cnt[G_ARRAY_WIDTH-1] == NUM_ROWS+1 && 
            //           out_col_cnt[G_ARRAY_WIDTH-1] == 0); // Logic approximation for finish
            //     repeat(100) @(posedge clk_i); // Flush
            // end
            begin
                repeat (10000) @(posedge clk_i);
                // $display("TIMEOUT");
            end
        join_any

        $display("[%0t] Simulation Complete. Checking Results...", $time);
        
        // ------------------------------------------------------------
        // 7. Check Results
        // ------------------------------------------------------------
        for(int r=0; r<OUT_HEIGHT; r++) begin
            for(int c=0; c<OUT_WIDTH; c++) begin
                if (actual_result[r][c] !== expected_result[r][c]) begin
                    $display("ERROR at [%0d][%0d]: Expected %0d, Got %0d", 
                        r, c, expected_result[r][c], actual_result[r][c]);
                    errors++;
                end else begin
                    $display("CORRECT at [%0d][%0d]: %0d", r, c, actual_result[r][c]);
                end
            end
        end

        $display("=======================================================");
        if (errors == 0) begin
            $display(" VERIFICATION PASSED: All pixels match.");
        end else begin
            $display(" VERIFICATION FAILED: %0d Mismatches found.", errors);
        end
        $display("=======================================================\n");

        $finish;
    end

    // -------------------------------------------------------------------------
    // Capture Output Logic (Reading from NOC FIFOs)
    // -------------------------------------------------------------------------
    genvar c;
    generate
        for (c = 0; c < G_ARRAY_WIDTH; c++) begin : output_capture
            
            initial begin

                forever begin
                    // Logic to read from FIFO and capture
                    noc_psum_rd_en_i[c] = 0;

                    // If FIFO is not empty, valid data is on the line. Capture it and Pop.
                    if (!noc_psum_empty_o[c]) begin
                        noc_psum_rd_en_i[c] = 1; // Acknowledge/Pop current data for next cycle

                        // Capture Data Immediately
                        begin
                            int actual_row;
                            int actual_col;
                            
                            // Determine which row of the final image this is
                            actual_row = c + (out_row_cnt[c] * ROW_MAPPING_STRIDE);
                            actual_col = out_col_cnt[c];

                            // Store valid pixel
                            if (actual_row < OUT_HEIGHT && actual_col < OUT_WIDTH) begin
                                actual_result[actual_row][actual_col] = noc_psum_o[c];
                            end

                            // Increment Column Counter
                            if (out_col_cnt[c] == OUT_WIDTH - 1) begin
                                out_col_cnt[c] <= 0;
                                out_row_cnt[c] <= out_row_cnt[c] + 1;
                                $display("Time: %0t | Column: %0d | Finished Row Count: %0d", $time, c, out_row_cnt[c] + 1);
                            end else begin
                                out_col_cnt[c] <= out_col_cnt[c] + 1;
                            end
                        end
                    end
                    repeat (2) @(posedge clk_i);
                end
            end

        end
    endgenerate

endmodule