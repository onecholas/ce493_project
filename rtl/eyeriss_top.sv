module eyeriss_top #(
    // Array Dimensions
    parameter G_ARRAY_HEIGHT   = 5,
    parameter G_ARRAY_WIDTH    = 6,

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

    // Ifmap inputs to BRAM
    input  logic [G_IFMAP_BUF_ADDR_WIDTH-1:0] ifmap_wr_addr_i,
    input  logic ifmap_wr_en_i,
    input  logic [G_TOP_BITS+G_BOT_BITS-1:0] ifmap_data_i,

    // Weight inputs to BRAM
    input  logic [G_WEIGHT_BUF_ADDR_WIDTH-1:0] weight_wr_addr_i,
    input  logic weight_wr_en_i,
    input  logic [G_TOP_BITS+G_BOT_BITS-1:0] weight_data_i,

    // Partial outputs from FIFO
    input  logic [0:G_ARRAY_WIDTH-1] psum_rd_en_i,
    output logic [0:G_ARRAY_WIDTH-1] psum_empty_o,
    output logic [0:G_ARRAY_WIDTH-1][G_TOP_BITS+G_BOT_BITS-1:0] psum_o
);

    logic ready_x;

    logic [0:G_ARRAY_HEIGHT+G_ARRAY_WIDTH-2][G_TOP_BITS+G_BOT_BITS-1:0] ifmap_data_x;
    logic [0:G_ARRAY_HEIGHT+G_ARRAY_WIDTH-2] ifmap_row_x;
    logic [0:G_ARRAY_HEIGHT+G_ARRAY_WIDTH-2] ifmap_empty_x;
    logic [0:G_ARRAY_HEIGHT+G_ARRAY_WIDTH-2] ifmap_rd_en_x;
    logic [0:G_ARRAY_HEIGHT-1][G_TOP_BITS+G_BOT_BITS-1:0] weight_data_x;
    logic weight_empty_x;
    logic weight_clr_x;  // Deprecated
    logic weight_rd_en_x;

    buf_array #(
        .G_ARRAY_HEIGHT (G_ARRAY_HEIGHT),
        .G_ARRAY_WIDTH  (G_ARRAY_WIDTH),
        .G_WEIGHT_BUF_ADDR_WIDTH (G_WEIGHT_BUF_ADDR_WIDTH),
        .G_IFMAP_BUF_ADDR_WIDTH  (G_IFMAP_BUF_ADDR_WIDTH),
        .G_TOP_BITS              (G_TOP_BITS),
        .G_BOT_BITS              (G_BOT_BITS),
        .G_KERNEL_SIZE           (G_KERNEL_SIZE),
        .G_IMAGE_HEIGHT          (G_IMAGE_HEIGHT),
        .G_IMAGE_WIDTH           (G_IMAGE_WIDTH)
    ) buf_array_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .start_i(start_i),
        .done_o(ready_x),
        .ifmap_wr_addr_i(ifmap_wr_addr_i),
        .ifmap_wr_en_i(ifmap_wr_en_i),
        .ifmap_data_i(ifmap_data_i),
        .weight_wr_addr_i(weight_wr_addr_i),
        .weight_wr_en_i(weight_wr_en_i),
        .weight_data_i(weight_data_i),
        .ifmap_data_o(ifmap_data_x),
        .ifmap_row_o(ifmap_row_x),
        .ifmap_empty_o(ifmap_empty_x),
        .ifmap_rd_en_i(ifmap_rd_en_x),
        .weight_data_o(weight_data_x),
        .weight_empty_o(weight_empty_x),
        .weight_clr_o(weight_clr_x),        // Deprecated
        .weight_rd_en_i(weight_rd_en_x)
    );

    noc #(
        .G_ARRAY_HEIGHT (G_ARRAY_HEIGHT),
        .G_ARRAY_WIDTH  (G_ARRAY_WIDTH),
        .G_TOP_BITS     (G_TOP_BITS),
        .G_BOT_BITS     (G_BOT_BITS),
        .G_KERNEL_SIZE  (G_KERNEL_SIZE),
        .G_IMAGE_HEIGHT (G_IMAGE_HEIGHT),
        .G_IMAGE_WIDTH  (G_IMAGE_WIDTH)
    ) noc_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .start_i(ready_x),
        .ifmap_i(ifmap_data_x),
        .ifmap_row_i(ifmap_row_x),
        .ifmap_empty_i(ifmap_empty_x),
        .ifmap_rd_en_o(ifmap_rd_en_x),
        .weight_i(weight_data_x),
        .weight_empty_i(weight_empty_x),
        .weight_clr_i(weight_clr_x),
        .weight_rd_en_o(weight_rd_en_x),
        .psum_rd_en_i(psum_rd_en_i),
        .psum_empty_o(psum_empty_o),
        .psum_o(psum_o)
    );
    
    
endmodule