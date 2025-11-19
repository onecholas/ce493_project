module buf #(
    parameter G_BUF_ADDR_WIDTH = 10,
    parameter G_BUF_DATA_WIDTH = 8) 
(   
    input  logic clk_i,
    input  logic [G_BUF_ADDR_WIDTH-1:0] rd_addr_i,
    input  logic [G_BUF_ADDR_WIDTH-1:0] wr_addr_i,
    input  logic wr_en_i,
    input  logic [G_BUF_DATA_WIDTH-1:0] data_i, 
    output logic [G_BUF_DATA_WIDTH-1:0] data_o
);

    logic [2**G_BUF_ADDR_WIDTH-1:0][G_BUF_DATA_WIDTH-1:0] mem;
        
    always_ff @(posedge clk_i) begin
        if (wr_en_i) mem[wr_addr_i] <= data_i; 
        data_o <= mem[rd_addr_i];
    end

endmodule