module buf_array #(
    // Array Dimensions
    parameter G_ARRAY_HEIGHT   = 5, // Number of Rows
    parameter G_ARRAY_WIDTH    = 4, // Number of Columns

    // PE Parameters
    parameter G_WEIGHT_BUF_ADDR_WIDTH = 5,  // Max value is 5x5-1
    parameter G_IFMAP_BUF_ADDR_WIDTH = 10,   // Max value is 28x28-1
    parameter G_TOP_BITS       = 2,
    parameter G_BOT_BITS       = 14,
    parameter G_KERNEL_SIZE    = 5,
    parameter G_IMAGE_HEIGHT   = 28,
    parameter G_IMAGE_WIDTH    = 28
) (
    input  logic clk_i,
    input  logic rst_i,

    input  logic start_i,
    output logic done_o,

    // Ifmap inputs to BRAM
    input  logic [G_IFMAP_BUF_ADDR_WIDTH-1:0] ifmap_wr_addr_i,
    input  logic ifmap_wr_en_i,
    input  logic [G_TOP_BITS+G_BOT_BITS-1:0] ifmap_data_i,

    // Weight inputs to BRAM
    input  logic [G_WEIGHT_BUF_ADDR_WIDTH-1:0] weight_wr_addr_i,
    input  logic weight_wr_en_i,
    input  logic [G_TOP_BITS+G_BOT_BITS-1:0] weight_data_i,

    // Ifmap outputs 
    output logic [0:G_ARRAY_HEIGHT+G_ARRAY_WIDTH-2][G_TOP_BITS+G_BOT_BITS-1:0] ifmap_data_o,
    output logic [0:G_ARRAY_HEIGHT+G_ARRAY_WIDTH-2] ifmap_row_o,
    output logic [0:G_ARRAY_HEIGHT+G_ARRAY_WIDTH-2] ifmap_empty_o,
    input  logic [0:G_ARRAY_HEIGHT+G_ARRAY_WIDTH-2] ifmap_rd_en_i,

    // Weight outputs
    output logic [0:G_ARRAY_HEIGHT-1][G_TOP_BITS+G_BOT_BITS-1:0] weight_data_o,
    output logic weight_empty_o,
    output logic weight_clr_o,  // Deprecated
    input  logic weight_rd_en_i

);

    // Result Dimensions
    localparam OUT_HEIGHT_C = G_IMAGE_HEIGHT - G_KERNEL_SIZE + 1;
    localparam OUT_WIDTH_C  = G_IMAGE_WIDTH - G_KERNEL_SIZE + 1;

    // FIFO Depth
    localparam NUM_ROWS_C = (OUT_HEIGHT_C + G_ARRAY_WIDTH - 1) / G_ARRAY_WIDTH;
    localparam FIFO_DEPTH_C = (NUM_ROWS_C + 1) * G_IMAGE_WIDTH;

    // Derived Parameters
    localparam DATA_WIDTH_C = G_TOP_BITS + G_BOT_BITS;
    localparam NUM_IFMAP_INPUTS_C = G_ARRAY_HEIGHT + G_ARRAY_WIDTH - 1; 
    localparam ROW_MAPPING_STRIDE_C = NUM_IFMAP_INPUTS_C + 1 - G_KERNEL_SIZE;

    // Weight BUF Signals
    logic [$clog2(G_KERNEL_SIZE):0] weight_row_count_r;
    logic [$clog2(G_KERNEL_SIZE):0] weight_row_count_c;
    logic [$clog2(G_KERNEL_SIZE):0] weight_row_count_prev_r;
    logic [$clog2(G_KERNEL_SIZE):0] weight_col_count_r;
    logic [$clog2(G_KERNEL_SIZE):0] weight_col_count_c;
    logic [$clog2(G_KERNEL_SIZE):0] weight_col_count_prev_r;
    logic [G_WEIGHT_BUF_ADDR_WIDTH-1:0] weight_rd_addr_r;
    logic [G_WEIGHT_BUF_ADDR_WIDTH-1:0] weight_rd_addr_c;
    logic [G_KERNEL_SIZE-1:0][DATA_WIDTH_C-1:0] weight_shift_reg_r;
    logic [G_KERNEL_SIZE-1:0][DATA_WIDTH_C-1:0] weight_shift_reg_c;

    // Ifmap BUF Signals
    logic [$clog2(G_IMAGE_WIDTH):0] ifmap_row_count_r;
    logic [$clog2(G_IMAGE_WIDTH):0] ifmap_row_count_c;
    logic [$clog2(G_IMAGE_WIDTH):0] ifmap_row_count_prev_r;
    logic [$clog2(G_IMAGE_HEIGHT):0] ifmap_col_count_r;
    logic [$clog2(G_IMAGE_HEIGHT):0] ifmap_col_count_c;
    logic [$clog2(G_IMAGE_HEIGHT):0] ifmap_col_count_prev_r;
    logic [G_IFMAP_BUF_ADDR_WIDTH-1:0] ifmap_rd_addr_r;
    logic [G_IFMAP_BUF_ADDR_WIDTH-1:0] ifmap_rd_addr_c;
    logic [NUM_IFMAP_INPUTS_C-1:0][$clog2(G_IMAGE_HEIGHT):0] ifmap_target_row_r;
    logic [NUM_IFMAP_INPUTS_C-1:0][$clog2(G_IMAGE_HEIGHT):0] ifmap_target_row_c;
    logic [NUM_IFMAP_INPUTS_C-1:0] ifmap_row_r;
    logic [NUM_IFMAP_INPUTS_C-1:0] ifmap_row_c;

    // Weight FIFO Signals
    logic weight_wr_en_r;
    logic weight_wr_en_c;
    logic weight_wr_en_next_r;
    logic weight_wr_en_next_c;
    logic [DATA_WIDTH_C-1:0] weight_data_x;
    logic weight_full_x;

    // Ifmap FIFO Signals
    logic [0:NUM_IFMAP_INPUTS_C-1] ifmap_wr_en_r;
    logic [0:NUM_IFMAP_INPUTS_C-1] ifmap_wr_en_c;
    logic [DATA_WIDTH_C-1:0] ifmap_data_c;
    logic [0:NUM_IFMAP_INPUTS_C-1][DATA_WIDTH_C:0] ifmap_data_x;
    logic [0:NUM_IFMAP_INPUTS_C-1] ifmap_full_x;

    typedef enum {IDLE_S, WAIT_S, READ_S, DONE_S} state_t;
    state_t weight_state_r;
    state_t weight_state_c;
    state_t ifmap_state_r;
    state_t ifmap_state_c;

    assign weight_clr_o = 0;
    assign done_o = (ifmap_state_r == DONE_S) && (weight_state_r == DONE_S);

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            weight_state_r <= IDLE_S;
            weight_row_count_r <= 0;
            weight_col_count_r <= 0;
            weight_rd_addr_r <= 0;
            weight_shift_reg_r <= 0;
            weight_wr_en_r <= 0;
            weight_wr_en_next_r <= 0;
            weight_row_count_prev_r <= 0;
            weight_col_count_prev_r <= 0;
        end else begin
            weight_state_r <= weight_state_c;
            weight_row_count_r <= weight_row_count_c;
            weight_col_count_r <= weight_col_count_c;
            weight_rd_addr_r <= weight_rd_addr_c;
            weight_shift_reg_r <= weight_shift_reg_c;
            weight_wr_en_r <= weight_wr_en_c;
            weight_wr_en_next_r <= weight_wr_en_next_c;
            weight_row_count_prev_r <= weight_row_count_r;
            weight_col_count_prev_r <= weight_col_count_r;
        end
    end

    always_comb begin
        // Default signal assignment
        weight_state_c = weight_state_r;
        weight_row_count_c = weight_row_count_r;
        weight_col_count_c = weight_col_count_r;
        weight_rd_addr_c = weight_rd_addr_r;
        weight_shift_reg_c = weight_shift_reg_r;
        weight_wr_en_c = 0;
        weight_wr_en_next_c = weight_wr_en_r;

        case (weight_state_r)
            IDLE_S: begin
                weight_col_count_c = 0;
                weight_row_count_c = 0;
                weight_wr_en_c = 0;
                if (start_i) begin
                    weight_state_c = WAIT_S;
                end
            end
            WAIT_S: begin
                // Default state transition
                weight_state_c = READ_S;
                // Always increment column counter
                weight_row_count_c = weight_row_count_r + 1;
                // If all rows covered, move on to the next column
                if (weight_row_count_r == G_KERNEL_SIZE - 1) begin
                    weight_row_count_c = 0;
                    weight_col_count_c = weight_col_count_r + 1;
                end
            end
            READ_S : begin
                // Default state transition
                weight_state_c = WAIT_S;
                // Always calculate next read address
                weight_rd_addr_c = weight_row_count_r * G_KERNEL_SIZE + weight_col_count_r;
                // If entire column of weights has been completed
                if (weight_row_count_prev_r == G_KERNEL_SIZE - 1) begin
                    // Write complete shift register row into FIFO
                    weight_wr_en_c = 1;
                end
                if (weight_row_count_prev_r == G_KERNEL_SIZE - 1 && weight_col_count_prev_r == G_KERNEL_SIZE - 1) begin
                    weight_state_c = DONE_S;
                end
                // Shift in weight
                weight_shift_reg_c = {weight_shift_reg_r[G_KERNEL_SIZE:0], weight_data_x};
            end
            DONE_S : begin
                if (weight_state_r == DONE_S && ifmap_state_r == DONE_S) begin
                    weight_state_c = IDLE_S;
                end
            end
        endcase
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            ifmap_state_r <= IDLE_S;
            ifmap_row_count_r <= 0;
            ifmap_col_count_r <= 0;
            ifmap_rd_addr_r <= 0;
            ifmap_target_row_r <= 0;
            ifmap_wr_en_r <= 0;
            ifmap_row_r <= 0;
            ifmap_row_count_prev_r <= 0;
            ifmap_col_count_prev_r <= 0;
        end else begin
            ifmap_state_r <= ifmap_state_c;
            ifmap_row_count_r <= ifmap_row_count_c;
            ifmap_col_count_r <= ifmap_col_count_c;
            ifmap_rd_addr_r <= ifmap_rd_addr_c;
            ifmap_target_row_r <= ifmap_target_row_c;
            ifmap_wr_en_r <= ifmap_wr_en_c;
            ifmap_row_r <= ifmap_row_c;
            ifmap_row_count_prev_r <= ifmap_row_count_r;
            ifmap_col_count_prev_r <= ifmap_col_count_r;
        end
    end

    always_comb begin
        // Default signal assignment
        ifmap_state_c = ifmap_state_r;
        ifmap_row_count_c = ifmap_row_count_r;
        ifmap_col_count_c = ifmap_col_count_r;
        ifmap_rd_addr_c = ifmap_rd_addr_r;
        ifmap_target_row_c = ifmap_target_row_r;
        ifmap_wr_en_c = 0;
        ifmap_row_c = ifmap_row_r;

        case (ifmap_state_r)
            IDLE_S : begin
                ifmap_col_count_c = 0;
                ifmap_row_count_c = 0;
                ifmap_rd_addr_c = 0;
                // Row toggle
                ifmap_row_c = {NUM_IFMAP_INPUTS_C{1'b1}};
                if (start_i) begin
                    ifmap_state_c = WAIT_S;
                    for (int i = 0; i < NUM_IFMAP_INPUTS_C; i++) begin
                        // Determines which row should be written to a given FIFO
                        ifmap_target_row_c[i] = i;
                    end
                end
            end
            WAIT_S : begin
                // Default state transition
                ifmap_state_c = READ_S;
                // Always increment column counter
                ifmap_col_count_c = ifmap_col_count_r + 1;
                // If end of row reached, go to next row
                if (ifmap_col_count_r == G_IMAGE_WIDTH - 1) begin
                    ifmap_col_count_c = 0;
                    ifmap_row_count_c = ifmap_row_count_r + 1;
                end
            end
            READ_S : begin
                // Default state transition
                ifmap_state_c = WAIT_S;
                // Set Up Next BRAM Address
                ifmap_rd_addr_c = ifmap_row_count_r * G_IMAGE_WIDTH + ifmap_col_count_r;
                
                for (int i = 0; i < NUM_IFMAP_INPUTS_C; i++) begin
                    // If the current row matches a PE's target row
                    if (ifmap_target_row_r[i] == ifmap_row_count_prev_r) begin
                        // Write to the FIFO
                        ifmap_wr_en_c[i] = 1;
                    end
                    // If end of row and if this FIFO was just written to
                    if (ifmap_col_count_prev_r == G_IMAGE_WIDTH - 1 && ifmap_target_row_r[i] == ifmap_row_count_prev_r) begin
                        // Also if there are more rows to be read
                        if (ifmap_target_row_r[i] <= i + (NUM_ROWS_C - 1) * ROW_MAPPING_STRIDE_C) begin
                            // Increment to next relevant row to be targeted
                            ifmap_target_row_c[i] = ifmap_target_row_r[i] + ROW_MAPPING_STRIDE_C;
                            // Indicate new row
                            ifmap_row_c[i] = ~ifmap_row_r[i];
                        end
                    end
                end
                // If end of image reached, go to next state
                if (ifmap_col_count_prev_r == G_IMAGE_WIDTH - 1 && ifmap_row_count_prev_r == G_IMAGE_HEIGHT - 1) begin
                    ifmap_state_c = DONE_S;
                end
            end
            DONE_S : begin
                if (weight_state_r == DONE_S && ifmap_state_r == DONE_S) begin
                    ifmap_state_c = IDLE_S;
                end
            end
        endcase
    end

    // Weight BRAM
    buffer #(
        .G_BUF_ADDR_WIDTH(G_WEIGHT_BUF_ADDR_WIDTH),
        .G_BUF_DATA_WIDTH(DATA_WIDTH_C)
    ) weight_buffer_inst (
        .clk_i      (clk_i),
        .rd_addr_i  (weight_rd_addr_r),
        .wr_addr_i  (weight_wr_addr_i),
        .wr_en_i    (weight_wr_en_i),
        .data_i     (weight_data_i), 
        .data_o     (weight_data_x)
    );

    // Ifmap BRAM
    buffer #(
        .G_BUF_ADDR_WIDTH(G_IFMAP_BUF_ADDR_WIDTH),
        .G_BUF_DATA_WIDTH(DATA_WIDTH_C)
    ) ifmap_buffer_inst (
        .clk_i      (clk_i),
        .rd_addr_i  (ifmap_rd_addr_r),
        .wr_addr_i  (ifmap_wr_addr_i),
        .wr_en_i    (ifmap_wr_en_i),
        .data_i     (ifmap_data_i), 
        .data_o     (ifmap_data_c)
    );
    
    // Weight FIFO
    fifo #(
        .FIFO_DATA_WIDTH  ((G_ARRAY_HEIGHT*DATA_WIDTH_C)),  // All weights for a single column
        .FIFO_BUFFER_SIZE (G_KERNEL_SIZE+1)               // Deep enough for all weights for a given kernel
    ) weight_fifo_inst (
        .reset   (rst_i),
        .wr_clk  (clk_i),
        .wr_en   (weight_wr_en_next_c),
        .din     (weight_shift_reg_r),
        .full    (weight_full_x),
        .rd_clk  (clk_i),
        .rd_en   (weight_rd_en_i),
        .dout    (weight_data_o),
        .empty   (weight_empty_o)
    );

    // Ifmap FIFOs
    genvar i;
    generate
        for (i = 0; i < NUM_IFMAP_INPUTS_C; i++) begin
            fifo #(
                .FIFO_DATA_WIDTH  (DATA_WIDTH_C+1), // Data + Row Bit
                .FIFO_BUFFER_SIZE (FIFO_DEPTH_C)      // Deep enough for all inputs to a given edge PE
            ) ifmap_fifo_inst (
                .reset   (rst_i),
                .wr_clk  (clk_i),
                .wr_en   (ifmap_wr_en_c[i]),
                .din     ({ifmap_row_r[i], ifmap_data_c}),
                .full    (ifmap_full_x[i]),
                .rd_clk  (clk_i),
                .rd_en   (ifmap_rd_en_i[i]),
                .dout    (ifmap_data_x[i]),
                .empty   (ifmap_empty_o[i])
            );
            assign ifmap_data_o[i] = ifmap_data_x[i][DATA_WIDTH_C-1:0];
            assign ifmap_row_o[i]  = ifmap_data_x[i][DATA_WIDTH_C];
        end
    endgenerate

    
endmodule