module pe #(
    parameter G_BUF_ADDR_WIDTH = 10,
    parameter G_BUF_DATA_WIDTH = 8,
    parameter G_TOP_BITS = 2,
    parameter G_BOT_BITS = 14,
    parameter G_KERNEL_SIZE = 5,
    parameter G_IMAGE_HEIGHT = 28,
    parameter G_IMAGE_WIDTH = 28
) (
    input  logic clk_i,
    input  logic rst_i,

    // Ifmap input unicast signals
    input  logic ifmap_vld_i,
    input  logic ifmap_row_i,
    input  logic [G_TOP_BITS+G_BOT_BITS-1:0] ifmap_i,

    // Input weight broadcast signals
    input  logic weight_vld_i,
    input  logic [G_TOP_BITS+G_BOT_BITS-1:0] weight_i,
    input  logic weight_clr_i,

    // Ifmap output unicast signals
    output logic ifmap_vld_o,
    output logic ifmap_row_o,
    output logic [G_TOP_BITS+G_BOT_BITS-1:0] ifmap_o,

    // Partial sum signals
    input  logic psum_vld_i,
    input  logic [G_TOP_BITS+G_BOT_BITS-1:0] psum_i,
    output logic psum_vld_o,
    output logic [G_TOP_BITS+G_BOT_BITS-1:0] psum_o
);

    localparam DATA_WIDTH_C = G_TOP_BITS + G_BOT_BITS;

    // Ifmap shift register definition
    logic [G_KERNEL_SIZE-1:0][DATA_WIDTH_C-1:0] ifmap_r = {G_KERNEL_SIZE{{DATA_WIDTH_C{1'b0}}}};
    // Ifmap row indicator, first input row will have values of 1, next input row will be 0, etc
    logic [G_KERNEL_SIZE-1:0] ifmap_row_r = {G_KERNEL_SIZE{1'b0}};

    // Ifmap and row shift register
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            ifmap_r <= {G_KERNEL_SIZE{{DATA_WIDTH_C{1'b0}}}};
            ifmap_row_r <= {G_KERNEL_SIZE{1'b0}};
        end else begin
            if (ifmap_vld_i) begin
                ifmap_r <= {ifmap_i, ifmap_r[G_KERNEL_SIZE-1:1]};
                ifmap_row_r <= {ifmap_row_i, ifmap_row_r[G_KERNEL_SIZE-1:1]};
            end
        end
    end

    // Ifmap output
    always_comb begin
        ifmap_o = ifmap_r[0];
        ifmap_row_o = ifmap_row_r[0];
        // Can potentially be the source of a long combinational path with multiple PEs
        if (ifmap_vld_i) begin
            ifmap_vld_o = 1'b1;
        end else begin
            ifmap_vld_o = 1'b0;
        end
    end

    // Input weight register definition
    logic [G_KERNEL_SIZE-1:0][DATA_WIDTH_C-1:0] weight_r;

    // Input weight registers
    always_ff @(posedge clk_i) begin
        if (rst_i || weight_clr_i) begin
            weight_r <= {G_KERNEL_SIZE{{DATA_WIDTH_C{1'b0}}}};
        end else begin
            if (weight_vld_i)
                weight_r <= {weight_i, weight_r[G_KERNEL_SIZE-1:1]};
        end
    end

    // Partial sum register definition
    logic signed [DATA_WIDTH_C*2-1:0] psum_r = 'b0;
    logic signed [DATA_WIDTH_C*2-1:0] psum_c;
    logic psum_vld_r = 'b0;
    logic psum_vld_c;
    // Counter to keep track of number of MAC operations
    logic [$clog2(G_KERNEL_SIZE)-1:0] count_r = 'b0;
    logic [$clog2(G_KERNEL_SIZE)-1:0] count_c;

    // State machine
    typedef enum {IDLE_S, CALC_S, ACUM_S, WAIT_S} state_t;
    state_t state_r;
    state_t state_c;

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            state_r <= IDLE_S;
            psum_r  <= 'b0;
            count_r <= 'b0;
            psum_vld_r <= 'b0;
        end else begin
            state_r <= state_c;
            psum_r  <= psum_c;
            count_r <= count_c;
            psum_vld_r <= psum_vld_c;
        end
    end

    always_comb begin
        // Default signal assignments
        state_c = state_r;
        psum_c = psum_r;
        count_c = count_r;
        psum_vld_c = 0;

        // Output signal assignments
        psum_o = psum_r >>> G_BOT_BITS;
        psum_vld_o = psum_vld_r;

        case (state_r)
            IDLE_S : begin
                psum_c = 0;
                count_c = 0;
                // Check if the first psum can be calculated yet
                if (&ifmap_row_r) begin
                    state_c = CALC_S;
                    psum_c = psum_r + $signed(ifmap_r[count_r]) * $signed(weight_r[count_r]);
                    count_c = count_r + 1;
                end
            end
            CALC_S : begin
                psum_c = psum_r + $signed(ifmap_r[count_r]) * $signed(weight_r[count_r]);
                count_c = count_r + 1;
                // If calculations complete, accumulate
                if (count_r == G_KERNEL_SIZE) begin
                    state_c = ACUM_S;
                    count_c = 0;
                    psum_vld_c = 1;
                    psum_c = psum_r + ($signed(psum_i) <<< G_BOT_BITS);
                end
            end
            ACUM_S : begin
                psum_c = $signed(ifmap_r[count_r]) * $signed(weight_r[count_r]);
                count_c = count_r + 1;
                if (&ifmap_row_r || ~|ifmap_row_r) begin
                    state_c = CALC_S;
                end else begin
                    state_c = WAIT_S;
                end
            end
            WAIT_S : begin
                psum_c = 0;
                count_c = count_r + 1;
                if (count_r == G_KERNEL_SIZE) begin
                    state_c = ACUM_S;
                    count_c = 0;
                end
            end 
        endcase
    end

    
endmodule