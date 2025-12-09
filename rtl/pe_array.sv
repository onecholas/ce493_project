module pe_array #(
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

    // Ifmap input unicast signals
    //  One input for each PE on the left and bottom edges of the array
    input  logic [0:G_ARRAY_HEIGHT+G_ARRAY_WIDTH-2] ifmap_vld_i,
    input  logic [0:G_ARRAY_HEIGHT+G_ARRAY_WIDTH-2] ifmap_row_i,
    input  wire [0:G_ARRAY_HEIGHT+G_ARRAY_WIDTH-2][G_TOP_BITS+G_BOT_BITS-1:0] ifmap_i,      // Defined as wire to clear warning in Modelsim

    // Input weight broadcast signals
    //  One input for each PE on the left edge of the array
    input  logic weight_vld_i,
    input  wire [0:G_ARRAY_HEIGHT-1][G_TOP_BITS+G_BOT_BITS-1:0] weight_i,                   // Defined as wire to clear warning in Modelsim
    input  logic weight_clr_i,

    // Partial sum signals
    //  One output for each PE on the bottom edge of the array
    output logic [0:G_ARRAY_WIDTH-1] psum_vld_o,
    output logic [0:G_ARRAY_WIDTH-1][G_TOP_BITS+G_BOT_BITS-1:0] psum_o
);

    localparam DATA_WIDTH_C = G_TOP_BITS + G_BOT_BITS;

    // Diagonal Ifmap Connections: [Column][Row] -> [Column+1][Row-1]
    // Here,
    //  - Index 0,0 represents signal from outside the array to element 0,0 
    //  - Index 1,0 represents signal from element 0,1 to element 1,0
    //  - Index 2,0 represents signal from element 1,1 to element 2,0
    //  - Index 0,1 represents signal from outside the array to element 0,1
    //  - Index 1,1 represents signal from element 0,2 to element 1,1
    //  - Index 2,1 represents signal from element 1,2 to element 2,1
    //  - Index 0,G_ARRAY_HEIGHT-1 represents signal from outside the array to element 0,G_ARRAY_HEIGHT-1
    //  - Index 1,G_ARRAY_HEIGHT-1 represents signal from outside the array to element 1,G_ARRAY_HEIGHT-1
    logic [0:G_ARRAY_WIDTH][0:G_ARRAY_HEIGHT]                   ifmap_vld_x;
    logic [0:G_ARRAY_WIDTH][0:G_ARRAY_HEIGHT]                   ifmap_row_x;
    logic [0:G_ARRAY_WIDTH][0:G_ARRAY_HEIGHT][DATA_WIDTH_C-1:0] ifmap_data_x;
    // If in row 0 (c,0) or column G_ARRAY_WIDTH-1, output should be set to open

    // Vertical Psum Connections: [Column][Row] -> [Column][Row+1]
    // Here,
    //  - Index 0 represents signal from outside the array to element 0
    //  - Index 1 represents signal from element 0 to element 1
    //  - Etc.
    logic [0:G_ARRAY_WIDTH-1][0:G_ARRAY_HEIGHT]                   psum_vld_x;
    logic [0:G_ARRAY_WIDTH-1][0:G_ARRAY_HEIGHT][DATA_WIDTH_C-1:0] psum_data_x;

    logic ifmap_vld_o_signal;
    logic ifmap_row_o_signal;
    logic [DATA_WIDTH_C-1:0] ifmap_data_o_signal;


    genvar r, c;
    generate
        // Connect Ifmap inputs to the left edge of the PE array
        for (r = 0; r < G_ARRAY_HEIGHT; r++) begin : ifmap_left_edge
            assign ifmap_vld_x[0][r]  = ifmap_vld_i[r];
            assign ifmap_row_x[0][r]  = ifmap_row_i[r];
            assign ifmap_data_x[0][r] = ifmap_i[r];
        end
        // Connect Ifmap inputs to the bottom edge of the PE array, skip bottom left corner
        for (c = 1; c < G_ARRAY_WIDTH; c++) begin : ifmap_bottom_edge
            assign ifmap_vld_x[c][G_ARRAY_HEIGHT-1]  = ifmap_vld_i[G_ARRAY_HEIGHT-1+c];
            assign ifmap_row_x[c][G_ARRAY_HEIGHT-1]  = ifmap_row_i[G_ARRAY_HEIGHT-1+c];
            assign ifmap_data_x[c][G_ARRAY_HEIGHT-1] = ifmap_i[G_ARRAY_HEIGHT-1+c];
        end

        // Connect PSUM inputs to the top edge of the PE array
        for (c = 0; c < G_ARRAY_WIDTH; c++) begin : psum_top_edge
            assign psum_vld_x[c][0]  = 1;
            assign psum_data_x[c][0] = 0;
        end

        

        // Instantiate PE Grid
        for (r = 0; r < G_ARRAY_HEIGHT; r++) begin : rows
            for (c = 0; c < G_ARRAY_WIDTH; c++) begin : cols
            
                assign ifmap_vld_o_signal = (r > 0) ? ifmap_vld_x[c+1][r-1] : ifmap_vld_x[c+1][r];
                assign ifmap_row_o_signal = (r > 0) ? ifmap_row_x[c+1][r-1] : ifmap_row_x[c+1][r];
                assign ifmap_data_o_signal = (r > 0) ? ifmap_data_x[c+1][r-1] : ifmap_data_x[c+1][r];

                pe #(
                    .G_BUF_ADDR_WIDTH (G_BUF_ADDR_WIDTH),   // Remove in future commit
                    .G_BUF_DATA_WIDTH (G_BUF_DATA_WIDTH),   // Remove in future commit
                    .G_TOP_BITS       (G_TOP_BITS),
                    .G_BOT_BITS       (G_BOT_BITS),
                    .G_KERNEL_SIZE    (G_KERNEL_SIZE),
                    .G_IMAGE_HEIGHT   (G_IMAGE_HEIGHT),
                    .G_IMAGE_WIDTH    (G_IMAGE_WIDTH)
                ) pe_inst (
                    .clk_i (clk_i),
                    .rst_i (rst_i),
                    .ifmap_vld_i  (ifmap_vld_x[c][r]),
                    .ifmap_row_i  (ifmap_row_x[c][r]),
                    .ifmap_i      (ifmap_data_x[c][r]),
                    .weight_vld_i (weight_vld_i),
                    .weight_i     (weight_i[r]),
                    .weight_clr_i (weight_clr_i),
                    .ifmap_vld_o  (ifmap_vld_o_signal),   // consider edge case if r==0
                    .ifmap_row_o  (ifmap_row_o_signal),
                    .ifmap_o      (ifmap_data_o_signal),
                    .psum_vld_i   (psum_vld_x[c][r]),
                    .psum_i       (psum_data_x[c][r]),
                    .psum_vld_o   (psum_vld_x[c][r+1]),
                    .psum_o       (psum_data_x[c][r+1])
                );
            end
        end

        // Connect PSUM outputs to the output
        for (c = 0; c < G_ARRAY_WIDTH; c++) begin : psum_bottom_edge
            assign psum_vld_o[c] = psum_vld_x[c][G_ARRAY_HEIGHT];
            assign psum_o[c]     = psum_data_x[c][G_ARRAY_HEIGHT];
        end
    endgenerate
endmodule