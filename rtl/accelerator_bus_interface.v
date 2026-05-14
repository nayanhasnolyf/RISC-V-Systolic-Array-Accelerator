module accelerator_bus_interface (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    input  wire        wen,
    output reg  [31:0] rdata
);

    localparam ADDR_START    = 32'h00000000;
    localparam ADDR_MATRIX_A = 32'h00000004;
    localparam ADDR_MATRIX_B = 32'h00000008;
    localparam ADDR_DONE     = 32'h0000000C;
    localparam ADDR_RESULT_0 = 32'h00000010;
    localparam ADDR_RESULT_1 = 32'h00000014;
    localparam ADDR_RESULT_2 = 32'h00000018;
    localparam ADDR_RESULT_3 = 32'h0000001C;

    reg  [31:0] reg_matrix_a;
    reg  [31:0] reg_matrix_b;
    reg  [23:0] out_reg0;
    reg  [23:0] out_reg1;
    reg  [23:0] out_reg2;
    reg  [23:0] out_reg3;
    reg         start_pulse;
    wire [23:0] drain_out_0;
    wire [23:0] drain_out_1;
    wire [23:0] drain_out_2;
    wire [23:0] drain_out_3;
    wire        done_flag;
    wire [1:0]  state_from_top;

    always @(posedge clk) begin
        if (rst) begin
            reg_matrix_a <= 32'd0;
            reg_matrix_b <= 32'd0;
            out_reg0     <= 24'd0;
            out_reg1     <= 24'd0;
            out_reg2     <= 24'd0;
            out_reg3     <= 24'd0;
            start_pulse  <= 1'b0;
        end else begin
            start_pulse <= (wen && addr == ADDR_START && wdata[0]);

            if (state_from_top == 2'd2) begin
                if (drain_out_0 != 24'd0) begin
                    out_reg0 <= drain_out_0;
                end
                if (drain_out_1 != 24'd0) begin
                    out_reg1 <= drain_out_1;
                end
                if (drain_out_2 != 24'd0) begin
                    out_reg2 <= drain_out_2;
                end
                if (drain_out_3 != 24'd0) begin
                    out_reg3 <= drain_out_3;
                end
            end

            if (wen) begin
                case (addr)
                    ADDR_MATRIX_A: begin
                        reg_matrix_a <= wdata;
                    end

                    ADDR_MATRIX_B: begin
                        reg_matrix_b <= wdata;
                    end

                    default: begin
                    end
                endcase
            end
        end
    end

    always @(*) begin
        case (addr)
            ADDR_START: begin
                rdata = {31'd0, start_pulse};
            end

            ADDR_MATRIX_A: begin
                rdata = reg_matrix_a;
            end

            ADDR_MATRIX_B: begin
                rdata = reg_matrix_b;
            end

            ADDR_DONE: begin
                rdata = {31'd0, done_flag};
            end

            ADDR_RESULT_0: begin
                rdata = {8'd0, out_reg0};
            end

            ADDR_RESULT_1: begin
                rdata = {8'd0, out_reg1};
            end

            ADDR_RESULT_2: begin
                rdata = {8'd0, out_reg2};
            end

            ADDR_RESULT_3: begin
                rdata = {8'd0, out_reg3};
            end

            default: begin
                rdata = 32'd0;
            end
        endcase
    end

    accelerator_top accelerator_inst (
        .clk         (clk),
        .rst         (rst),
        .start       (start_pulse),
        .matrix_a_in (reg_matrix_a),
        .matrix_b_in (reg_matrix_b),
        .drain_out_0 (drain_out_0),
        .drain_out_1 (drain_out_1),
        .drain_out_2 (drain_out_2),
        .drain_out_3 (drain_out_3),
        .done_flag   (done_flag)
    );

    assign state_from_top = accelerator_inst.controller_inst.state;

endmodule
