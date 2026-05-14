module pe_output_stationary (
    input  wire        clk,
    input  wire        rst,
    input  wire        en,
    input  wire        shift_en,
    input  wire        clr_acc,
    input  wire [7:0]  a_in,
    input  wire [7:0]  b_in,
    input  wire [23:0] shift_in,
    output reg  [7:0]  a_out,
    output reg  [7:0]  b_out,
    output reg  [23:0] acc
);

    always @(posedge clk) begin
        if (rst) begin
            acc   <= 24'd0;
            a_out <= 8'd0;
            b_out <= 8'd0;
        end else begin
            a_out <= a_in;
            b_out <= b_in;

            if (clr_acc) begin
                acc <= 24'd0;
            end else if (shift_en) begin
                acc <= shift_in;
            end else if (en) begin
                acc <= acc + (a_in * b_in);
            end
        end
    end

endmodule
