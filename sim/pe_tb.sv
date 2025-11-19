`timescale 1ns / 1ps

module pe_tb;

    // -------------------------------------------------------
    // Parameters (Matching DUT)
    // -------------------------------------------------------
    parameter G_BUF_ADDR_WIDTH = 10;
    parameter G_BUF_DATA_WIDTH = 8;
    parameter G_TOP_BITS       = 2;
    parameter G_BOT_BITS       = 14;
    parameter G_KERNEL_SIZE    = 5;
    parameter G_IMAGE_HEIGHT   = 28;
    parameter G_IMAGE_WIDTH    = 28;
    
    localparam DATA_WIDTH = G_TOP_BITS + G_BOT_BITS;

    // -------------------------------------------------------
    // Signals
    // -------------------------------------------------------
    logic clk_i;
    logic rst_i;

    // Ifmap input
    logic ifmap_vld_i;
    logic ifmap_row_i;
    logic [DATA_WIDTH-1:0] ifmap_i;

    // Weight input
    logic weight_vld_i;
    logic [DATA_WIDTH-1:0] weight_i;
    logic weight_clr_i;

    // Ifmap output
    logic ifmap_vld_o;
    logic ifmap_row_o;
    logic [DATA_WIDTH-1:0] ifmap_o;

    // Psum signals
    logic psum_vld_i;
    logic [DATA_WIDTH-1:0] psum_i;
    logic psum_vld_o;
    logic [DATA_WIDTH-1:0] psum_o;

    // -------------------------------------------------------
    // Test Data Arrays
    // -------------------------------------------------------
    logic [DATA_WIDTH-1:0] weight_data [0:G_KERNEL_SIZE-1];
    logic [DATA_WIDTH-1:0] ifmap_data  [0:G_IMAGE_WIDTH-1];
    int expected_queue [$]; // Queue to store golden results
    int calc_psum;          // Temporary variable for calculation

    // -------------------------------------------------------
    // DUT Instantiation
    // -------------------------------------------------------
    pe #(
        .G_BUF_ADDR_WIDTH(G_BUF_ADDR_WIDTH),
        .G_BUF_DATA_WIDTH(G_BUF_DATA_WIDTH),
        .G_TOP_BITS(G_TOP_BITS),
        .G_BOT_BITS(G_BOT_BITS),
        .G_KERNEL_SIZE(G_KERNEL_SIZE),
        .G_IMAGE_HEIGHT(G_IMAGE_HEIGHT),
        .G_IMAGE_WIDTH(G_IMAGE_WIDTH)
    ) pe_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .ifmap_vld_i(ifmap_vld_i),
        .ifmap_row_i(ifmap_row_i),
        .ifmap_i(ifmap_i),
        .weight_vld_i(weight_vld_i),
        .weight_i(weight_i),
        .weight_clr_i(weight_clr_i),
        .ifmap_vld_o(ifmap_vld_o),
        .ifmap_row_o(ifmap_row_o),
        .ifmap_o(ifmap_o),
        .psum_vld_i(psum_vld_i),
        .psum_i(psum_i),
        .psum_vld_o(psum_vld_o),
        .psum_o(psum_o)
    );

    // -------------------------------------------------------
    // Clock Generation
    // -------------------------------------------------------
    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i; // 10ns period
    end

    // -------------------------------------------------------
    // Test Stimulus
    // -------------------------------------------------------
    initial begin
        // 1. Initialization
        rst_i = 1;
        ifmap_vld_i = 0;
        ifmap_row_i = 0;
        ifmap_i = 0;
        weight_vld_i = 0;
        weight_i = 0;
        weight_clr_i = 0;
        psum_vld_i = 0; 
        psum_i = 0; 

        // --- Populate Arrays with Data ---
        // Filling weight array (Example: 10, 20, 30, 40, 50)
        foreach(weight_data[i]) begin
            weight_data[i] = (i + 1) * 10;
        end

        // Filling ifmap array (Example: 1, 2, 3... 28)
        foreach(ifmap_data[i]) begin
            ifmap_data[i] = (i + 1);
        end

        // -------------------------------------------------------
        // Golden Model
        // -------------------------------------------------------

        for (int j = 0; j < 2; j++) begin
            for (int k = G_KERNEL_SIZE - 1; k < G_IMAGE_WIDTH; k++) begin
                calc_psum = 0;
                for (int w = 0; w < G_KERNEL_SIZE; w++) begin
                    calc_psum += weight_data[w] * ifmap_data[k - (G_KERNEL_SIZE - 1) + w];
                end
                // Push to queue
                expected_queue.push_back(calc_psum);
            end
        end

        // Wait for reset
        repeat (5) @(posedge clk_i);
        rst_i = 0;
        repeat (2) @(posedge clk_i);

        $display("--- Starting Simulation ---");

        // -------------------------------------------------------
        // 2. Load Weights (Reading from Array)
        // -------------------------------------------------------
        $display("[%t] Loading Weights...", $time);
        
        for (int w = 0; w < G_KERNEL_SIZE; w++) begin
            weight_vld_i = 1;
            weight_i     = weight_data[w];
            @(posedge clk_i);
        end

        // Stop loading
        weight_vld_i = 0;
        weight_i     = 0;
        @(posedge clk_i);

        // -------------------------------------------------------
        // 3. Load Ifmap (Reading from Array)
        // -------------------------------------------------------
        $display("[%t] Starting Ifmap stream...", $time);

        for (int k = 0; k < G_IMAGE_WIDTH; k++) begin
            // --- Valid Cycle ---
            ifmap_vld_i = 1;
            ifmap_row_i = 1; 
            ifmap_i     = ifmap_data[k]; 
            
            psum_vld_i  = 1; 
            psum_i      = 0; 
            @(posedge clk_i);

            // --- Invalid Cycles (Wait G_KERNEL_SIZE-1 cycles) ---
            ifmap_vld_i = 0;
            ifmap_row_i = 0;
            ifmap_i     = 0;
            
            psum_vld_i  = 0;
            psum_i      = 0;
            
            repeat (G_KERNEL_SIZE) @(posedge clk_i);
        end

        // New row of data, validate that previous row has been flushed before new psums pushed out
        for (int k = 0; k < G_IMAGE_WIDTH; k++) begin
            // --- Valid Cycle ---
            ifmap_vld_i = 1;
            ifmap_row_i = 0; 
            ifmap_i     = ifmap_data[k]; 
            
            psum_vld_i  = 1; 
            psum_i      = 0; 
            @(posedge clk_i);

            // --- Invalid Cycles (Wait G_KERNEL_SIZE-1 cycles) ---
            ifmap_vld_i = 0;
            ifmap_row_i = 0;
            ifmap_i     = 0;
            
            psum_vld_i  = 0;
            psum_i      = 0;
            
            repeat (G_KERNEL_SIZE) @(posedge clk_i);
        end

        repeat (20) @(posedge clk_i);
        
        $display("--- Simulation Finished ---");
        $finish;
    end

    // -------------------------------------------------------
    // Output Monitor
    // -------------------------------------------------------
    always @(posedge clk_i) begin
        if (psum_vld_o) begin
            int expected_val;
            // Check if we have expected values left
            if (expected_queue.size() == 0) begin
                // $error("[%t] ERROR: Unexpected Output! PSUM_O = %0d, but Queue is empty.", $time, psum_o);
            end else begin
                // Pop the front of the queue
                expected_val = expected_queue.pop_front();
                
                if (psum_o == expected_val) begin
                    $display("[%t] PASS: PSUM_O = %0d (Matches Expected)", $time, psum_o);
                end else begin
                    $error("[%t] FAIL: PSUM_O = %0d, Expected = %0d", $time, psum_o, expected_val);
                end
            end        
        end
    end

    // -------------------------------------------------------
    // Internal State Monitor
    // -------------------------------------------------------
    // Prints the value of the internal shift registers and psum every cycle
    always @(posedge clk_i) begin
        if (!rst_i) begin
            // Use $write to print horizontally on one line
            $write("[%t] ", $time);
            
            // Print Weight Register
            $write("Weight Reg: { ");
            foreach(pe_inst.weight_r[i]) begin
                $write("%0d ", pe_inst.weight_r[i]);
            end
            $write("} | ");

            // Print Ifmap Register
            $write("Ifmap Reg: { ");
            foreach(pe_inst.ifmap_r[i]) begin
                $write("%0d ", pe_inst.ifmap_r[i]);
            end
            $write("} | ");

            // Print Partial Sum Accumulator
            $write("Psum Reg: %0d", pe_inst.psum_r);
            
            // Newline at end of cycle print
            $write("\n");
        end
    end

endmodule