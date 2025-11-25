`timescale 1ns / 1ps

module eyeriss_top_tb;

    // -------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------
    parameter G_ARRAY_HEIGHT   = 5;
    parameter G_ARRAY_WIDTH    = 6;
    
    // Address widths for the Internal BRAMs inside eyeriss_top
    parameter G_WEIGHT_BUF_ADDR_WIDTH = 10; 
    parameter G_IFMAP_BUF_ADDR_WIDTH  = 12; // 28*28 = 784, so 12 bits (4096) is sufficient

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

    // --- eyeriss_top Interface Signals ---
    
    // IFMAP BRAM Write Interface
    logic [G_IFMAP_BUF_ADDR_WIDTH-1:0]  ifmap_wr_addr_i;
    logic                               ifmap_wr_en_i;
    logic [DATA_WIDTH-1:0]              ifmap_data_i;

    // WEIGHT BRAM Write Interface
    logic [G_WEIGHT_BUF_ADDR_WIDTH-1:0] weight_wr_addr_i;
    logic                               weight_wr_en_i;
    logic [DATA_WIDTH-1:0]              weight_data_i;

    // PSUM (Output) Read Interface
    logic [0:G_ARRAY_WIDTH-1]               psum_rd_en_i;
    logic [0:G_ARRAY_WIDTH-1]               psum_empty_o;
    logic [0:G_ARRAY_WIDTH-1][DATA_WIDTH-1:0] psum_o;

    // --- Data Generation Buffers ---
    // REMOVED intermediate complex buffers (input_buffers, input_row_buffers)
    
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
    // DUT Instantiation
    // -------------------------------------------------------------------------
    eyeriss_top #(
        .G_ARRAY_HEIGHT         (G_ARRAY_HEIGHT),
        .G_ARRAY_WIDTH          (G_ARRAY_WIDTH),
        .G_WEIGHT_BUF_ADDR_WIDTH(G_WEIGHT_BUF_ADDR_WIDTH),
        .G_IFMAP_BUF_ADDR_WIDTH (G_IFMAP_BUF_ADDR_WIDTH),
        .G_TOP_BITS             (G_TOP_BITS),
        .G_BOT_BITS             (G_BOT_BITS),
        .G_KERNEL_SIZE          (G_KERNEL_SIZE),
        .G_IMAGE_HEIGHT         (G_IMAGE_HEIGHT),
        .G_IMAGE_WIDTH          (G_IMAGE_WIDTH)
    ) eyeriss_top_inst (
        .clk_i              (clk_i),
        .rst_i              (rst_i),
        .start_i            (start_i),

        // Ifmap loading interface
        .ifmap_wr_addr_i    (ifmap_wr_addr_i),
        .ifmap_wr_en_i      (ifmap_wr_en_i),
        .ifmap_data_i       (ifmap_data_i),

        // Weight loading interface
        .weight_wr_addr_i   (weight_wr_addr_i),
        .weight_wr_en_i     (weight_wr_en_i),
        .weight_data_i      (weight_data_i),

        // Result interface
        .psum_rd_en_i       (psum_rd_en_i),
        .psum_empty_o       (psum_empty_o),
        .psum_o             (psum_o)
    );

    // -------------------------------------------------------------------------
    // Data Generation
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
                // kernel[r][c] = r * G_KERNEL_SIZE + c;
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
        
        // Parts C and D removed as requested. Data is loaded directly in driver process.
    end

    // -------------------------------------------------------------------------
    // Main Control Process (Driver)
    // -------------------------------------------------------------------------
    int errors = 0;
    
    initial begin
        // 1. Initialization
        rst_i            = 1;
        start_i          = 0;
        
        ifmap_wr_en_i    = 0;
        ifmap_wr_addr_i  = 0;
        ifmap_data_i     = 0;

        weight_wr_en_i   = 0;
        weight_wr_addr_i = 0;
        weight_data_i    = 0;

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
        // 3. Load Weights into eyeriss_top BRAM
        // ------------------------------------------------------------
        $display("[%0t] Loading Weights into DUT...", $time);
        
        // Assuming linear addressing for weights in DUT or broadcast.
        // We write the 25 kernel values to addresses 0 to 24.
        begin
            int w_addr = 0;
            for (int r = 0; r < G_KERNEL_SIZE; r++) begin            
                for (int c = 0; c < G_KERNEL_SIZE; c++) begin
                    weight_wr_addr_i = w_addr;
                    // Pad top bits with 0, put data in bottom bits
                    weight_data_i    = { {G_TOP_BITS{1'b0}}, kernel[r][c][G_BOT_BITS-1:0] }; 
                    weight_wr_en_i   = 1;
                    @(posedge clk_i);
                    w_addr++;
                end
            end
        end
        
        weight_wr_en_i = 0;
        $display("[%0t] Weight Load Complete.", $time);


        // ------------------------------------------------------------
        // 4. Load Ifmaps into eyeriss_top BRAM
        // ------------------------------------------------------------
        $display("[%0t] Loading Ifmaps into DUT...", $time);
        
        // Simplified Logic: Iterate directly over the image array and write to BRAM
        // using linear addressing (row * width + col).
        begin
            int i_addr = 0;
            for (int r = 0; r < G_IMAGE_HEIGHT; r++) begin
                for (int c = 0; c < G_IMAGE_WIDTH; c++) begin
                    ifmap_wr_addr_i = i_addr;
                    
                    // Direct Pixel Data assignment (No row toggle bit construction)
                    ifmap_data_i = image[r][c];

                    ifmap_wr_en_i = 1;
                    @(posedge clk_i);
                    i_addr++;
                end
            end
        end

        ifmap_wr_en_i = 0; 
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
        // Wait until we have received all expected pixels or timeout
        fork
            begin
                // Wait condition: logic to check if all rows and cols are done
                wait (out_row_cnt[G_ARRAY_WIDTH-1] == OUT_HEIGHT && 
                      out_col_cnt[G_ARRAY_WIDTH-1] == 0); 
                repeat(100) @(posedge clk_i); // Flush logic
            end
            begin
                repeat (50000) @(posedge clk_i);
                $display("TIMEOUT: Simulation took too long.");
            end
        join_any

        $display("[%0t] Simulation Processing Complete. Checking Results...", $time);
        
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
    // Capture Output Logic (Reading from DUT Output Interface)
    // -------------------------------------------------------------------------
    genvar c;
    generate
        for (c = 0; c < G_ARRAY_WIDTH; c++) begin : output_capture
            
            initial begin
                forever begin
                    // Default Read Enable to 0
                    psum_rd_en_i[c] = 0;

                    // 1. Check if Data is available (Empty is low)
                    if (!psum_empty_o[c]) begin
                        // 2. Assert Read Enable to "Pop" the data from the DUT FIFO
                        psum_rd_en_i[c] = 1; 
                        
                        // 4. Capture Data
                        begin
                            int actual_row;
                            int actual_col;
                            
                            // Determine which row of the final image this is based on Array Column Index
                            actual_row = c + (out_row_cnt[c] * ROW_MAPPING_STRIDE);
                            actual_col = out_col_cnt[c];

                            // Store valid pixel
                            if (actual_row < OUT_HEIGHT && actual_col < OUT_WIDTH) begin
                                actual_result[actual_row][actual_col] = psum_o[c];
                            end

                            // Increment Counters
                            if (out_col_cnt[c] == OUT_WIDTH - 1) begin
                                out_col_cnt[c] <= 0;
                                out_row_cnt[c] <= out_row_cnt[c] + 1;
                                // Debug print per row completion
                                // $display("Time: %0t | Column: %0d | Finished Row Count: %0d", $time, c, out_row_cnt[c] + 1);
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