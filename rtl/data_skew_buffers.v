module data_skew_buffers (
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] row_in  [0:3],
    input  wire [7:0] col_in  [0:3],
    output wire [7:0] row_out [0:3],
    output wire [7:0] col_out [0:3]
);

    reg [7:0] r1_d1;

    reg [7:0] r2_d1;
    reg [7:0] r2_d2;

    reg [7:0] r3_d1;
    reg [7:0] r3_d2;
    reg [7:0] r3_d3;

    reg [7:0] c1_d1;

    reg [7:0] c2_d1;
    reg [7:0] c2_d2;

    reg [7:0] c3_d1;
    reg [7:0] c3_d2;
    reg [7:0] c3_d3;

    // Row 0 and column 0 have zero delay.
    assign row_out[0] = row_in[0];
    assign col_out[0] = col_in[0];

    // Rows 1-3 and columns 1-3 use explicit staircase pipelines.
    assign row_out[1] = r1_d1;
    assign row_out[2] = r2_d2;
    assign row_out[3] = r3_d3;

    assign col_out[1] = c1_d1;
    assign col_out[2] = c2_d2;
    assign col_out[3] = c3_d3;

    always @(posedge clk) begin
        if (rst) begin
            r1_d1 <= 8'h00;

            r2_d1 <= 8'h00;
            r2_d2 <= 8'h00;

            r3_d1 <= 8'h00;
            r3_d2 <= 8'h00;
            r3_d3 <= 8'h00;

            c1_d1 <= 8'h00;

            c2_d1 <= 8'h00;
            c2_d2 <= 8'h00;

            c3_d1 <= 8'h00;
            c3_d2 <= 8'h00;
            c3_d3 <= 8'h00;
        end else begin
            r1_d1 <= row_in[1];

            r2_d1 <= row_in[2];
            r2_d2 <= r2_d1;

            r3_d1 <= row_in[3];
            r3_d2 <= r3_d1;
            r3_d3 <= r3_d2;

            c1_d1 <= col_in[1];

            c2_d1 <= col_in[2];
            c2_d2 <= c2_d1;

            c3_d1 <= col_in[3];
            c3_d2 <= c3_d1;
            c3_d3 <= c3_d2;
        end
    end

endmodule
