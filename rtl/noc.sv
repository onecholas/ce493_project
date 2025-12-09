module noc #(
    // Array Dimensions
    parameter G_ARRAY_HEIGHT   = 5, // Number of Rows
    parameter G_ARRAY_WIDTH    = 4, // Number of Columns

    // PE Parameters
    parameter G_BUF_ADDR_WIDTH = 10,
    parameter G_BUF_DATA_WIDTH = 8,
    parameter G_TOP_BITS       = 2,
    parameter G_BOT_BITS       = 14,
    parameter G_KERNEL_SIZE    = 5,
    parameter G_IMAGE_HEIGHT   = 28,
    parameter G_IMAGE_WIDTH    = 28
) (
    input  logic clk_i,
    input  logic rst_i,

    input  logic start_i,

    // Ifmap input unicast signals
    //  One input for each PE on the left and bottom edges of the array
    input  wire  [0:G_ARRAY_HEIGHT+G_ARRAY_WIDTH-2][G_TOP_BITS+G_BOT_BITS-1:0] ifmap_i,      // Defined as wire to clear warning in Modelsim
    input  logic [0:G_ARRAY_HEIGHT+G_ARRAY_WIDTH-2] ifmap_row_i,
    input  logic [0:G_ARRAY_HEIGHT+G_ARRAY_WIDTH-2] ifmap_empty_i,
    output logic [0:G_ARRAY_HEIGHT+G_ARRAY_WIDTH-2] ifmap_rd_en_o,  // FWFT FIFO

    // Input weight broadcast signals
    //  One input for each PE on the left edge of the array
    input  wire [0:G_ARRAY_HEIGHT-1][G_TOP_BITS+G_BOT_BITS-1:0] weight_i,                   // Defined as wire to clear warning in Modelsim
    input  logic weight_empty_i,
    input  logic weight_clr_i,
    output logic weight_rd_en_o,

    // Partial sum signals
    //  One output for each PE on the bottom edge of the array
    input  logic [0:G_ARRAY_WIDTH-1] psum_rd_en_i,
    output logic [0:G_ARRAY_WIDTH-1] psum_empty_o,
    output logic [0:G_ARRAY_WIDTH-1][G_TOP_BITS+G_BOT_BITS-1:0] psum_o
);

    // Result Dimensions
    localparam OUT_HEIGHT = G_IMAGE_HEIGHT - G_KERNEL_SIZE + 1;
    localparam OUT_WIDTH  = G_IMAGE_WIDTH - G_KERNEL_SIZE + 1;

    // FIFO Depth
    localparam FIFO_DEPTH_C = ((OUT_HEIGHT + G_ARRAY_WIDTH - 1) / G_ARRAY_WIDTH + 1) * G_IMAGE_WIDTH;

    // Derived Parameters
    localparam DATA_WIDTH_C = G_TOP_BITS + G_BOT_BITS;
    localparam NUM_IFMAP_INPUTS_C = G_ARRAY_HEIGHT + G_ARRAY_WIDTH - 1; 
    
    // Output PSUM signals
    logic [0:G_ARRAY_WIDTH-1] psum_wr_en_x;
    logic [0:G_ARRAY_WIDTH-1][DATA_WIDTH_C-1:0] psum_x;

    // Ifmap signals
    logic [0:G_ARRAY_HEIGHT+G_ARRAY_WIDTH-2][G_TOP_BITS+G_BOT_BITS-1:0] ifmap_r;
    logic [0:G_ARRAY_HEIGHT+G_ARRAY_WIDTH-2][G_TOP_BITS+G_BOT_BITS-1:0] ifmap_c;
    logic [0:G_ARRAY_HEIGHT+G_ARRAY_WIDTH-2] ifmap_row_r;
    logic [0:G_ARRAY_HEIGHT+G_ARRAY_WIDTH-2] ifmap_row_c;
    logic [0:G_ARRAY_HEIGHT+G_ARRAY_WIDTH-2] ifmap_vld_r;
    logic [0:G_ARRAY_HEIGHT+G_ARRAY_WIDTH-2] ifmap_vld_c;

    // Weight signals
    logic weight_vld_c;
    logic weight_vld_r;
    logic [0:G_ARRAY_HEIGHT-1][DATA_WIDTH_C-1:0] weight_c; 
    logic [0:G_ARRAY_HEIGHT-1][DATA_WIDTH_C-1:0] weight_r; 

    // State Machine signals
    typedef enum {IDLE_S, WEIGHTS_S, CALC_S} state_t;
    state_t state_r;
    state_t state_c;
    logic [10:0] count_r;
    logic [10:0] count_c;
    logic [NUM_IFMAP_INPUTS_C-1:0] start_r;
    logic [NUM_IFMAP_INPUTS_C-1:0] start_c;
    logic [NUM_IFMAP_INPUTS_C-1:0][$clog2(G_KERNEL_SIZE):0] wait_count_r;
    logic [NUM_IFMAP_INPUTS_C-1:0][$clog2(G_KERNEL_SIZE):0] wait_count_c;
    logic [NUM_IFMAP_INPUTS_C-1:0] stop_r;
    logic [NUM_IFMAP_INPUTS_C-1:0] stop_c;

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            state_r <= IDLE_S;
            weight_r <= 0;
            weight_vld_r <= 0;
            ifmap_r <= 0;
            ifmap_vld_r <= 0;
            ifmap_row_r <= 0;
            count_r <= 0;
            start_r <= 0;
            stop_r  <= 0;
            wait_count_r <= 0;
        end else begin
            state_r <= state_c;
            weight_r <= weight_c;
            weight_vld_r <= weight_vld_c;
            ifmap_r <= ifmap_c;
            ifmap_vld_r <= ifmap_vld_c;
            ifmap_row_r <= ifmap_row_c;
            count_r <= count_c;
            start_r <= start_c;
            stop_r  <= stop_c;
            wait_count_r <= wait_count_c;
        end
    end

    always_comb begin
        // Default signal assignments
        state_c = state_r;
        weight_c = weight_i;
        weight_vld_c = 0;
        count_c = count_r;
        start_c = start_r;
        stop_c = stop_r;
        wait_count_c = wait_count_r;
        ifmap_c = ifmap_i;
        ifmap_vld_c = 0;
        ifmap_row_c = ifmap_row_r;

        // Output signal assignments
        weight_rd_en_o = 0;
        ifmap_rd_en_o  = 0;

        case (state_r) 
            IDLE_S : begin
                count_c = 0;
                start_c = 0;
                stop_c = 0;
                wait_count_c = 0;
                if (start_i && ~weight_empty_i) begin
                    state_c = WEIGHTS_S;
                    weight_rd_en_o = 1;
                    weight_vld_c = 1;
                    count_c = count_r + 1;
                end
            end
            WEIGHTS_S : begin
                wait_count_c = 0;
                if (~weight_empty_i) begin
                    weight_rd_en_o = 1;
                    weight_vld_c = 1;
                    count_c = count_r + 1;
                end
                if (count_r == G_KERNEL_SIZE) begin
                    state_c = CALC_S;
                    count_c = 0;
                end
            end
            CALC_S : begin
                count_c = count_r + 1;
                for (int i = 0; i < NUM_IFMAP_INPUTS_C; i++) begin
                    // Start each ifmap to the PE on the correct cycle
                    if (i <= 4) begin
                        if (count_r == i) begin
                            start_c[i] = 1;
                        end
                    end else begin
                        if (count_r == i - 5 + G_ARRAY_HEIGHT + G_ARRAY_HEIGHT * (G_KERNEL_SIZE + 1) * (i - 4)) begin
                            start_c[i] = 1;
                        end
                    end
                    // Write each ifmap to the PE
                    if (start_r[i]) begin
                        wait_count_c[i] = wait_count_r[i] + 1;
                        // Cycle 0: Load in ifmap
                        if (wait_count_r[i] == 0 && !stop_c[i]) begin
                            // Ensure that FIFO is not empty. Waiting here would mess up the dataflow.
                            ifmap_rd_en_o[i] = 1;
                            ifmap_vld_c[i] = 1;
                            ifmap_row_c[i] = ifmap_row_i[i];
                        end
                        // If processing complete
                        if (wait_count_r[i] == G_KERNEL_SIZE) begin
                            // Reset counter to read in next ifmap
                            wait_count_c[i] = 0;
                            // If all ifmaps have been read, don't read in next ifmap and start alternating rows to squash future outputs
                            if (ifmap_empty_i[i] || stop_c[i]) begin
                                // Never read in new ifmaps
                                stop_c[i] = 1;
                                ifmap_vld_c[i] = 1;
                                ifmap_row_c[i] = ~ifmap_row_r[i];
                            end
                        end
                    end
                end
            end
        endcase
    end


    // PE Array Instantiation
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
        .ifmap_vld_i  (ifmap_vld_r),
        .ifmap_row_i  (ifmap_row_r),
        .ifmap_i      (ifmap_r),
        .weight_vld_i (weight_vld_r),
        .weight_i     (weight_r),
        .weight_clr_i (weight_clr_i),
        .psum_vld_o   (psum_wr_en_x),
        .psum_o       (psum_x)
    );

    // Output FIFOs
    genvar i;
    generate
        for (i = 0; i < G_ARRAY_WIDTH; i++) begin
            fifo #(
                .FIFO_DATA_WIDTH  (DATA_WIDTH_C),
                .FIFO_BUFFER_SIZE (FIFO_DEPTH_C)
            ) psum_fifo_inst (
                .reset  (rst_i),
                .wr_clk (clk_i),
                .wr_en  (psum_wr_en_x[i]),
                .din    (psum_x[i]),
                .full   (),                 // FIFO MUST not overflow
                .rd_clk (clk_i),
                .rd_en  (psum_rd_en_i[i]),
                .dout   (psum_o[i]),
                .empty  (psum_empty_o[i])
            );
        end
    endgenerate
    
endmodule