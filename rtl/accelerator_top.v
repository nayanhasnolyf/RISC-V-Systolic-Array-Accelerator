module accelerator_top (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire [31:0] matrix_a_in,
    input  wire [31:0] matrix_b_in,
    output wire [23:0] drain_out_0,
    output wire [23:0] drain_out_1,
    output wire [23:0] drain_out_2,
    output wire [23:0] drain_out_3,
    output wire        done_flag
);

    wire        en;
    wire        shift_en;
    wire        clr_acc;
    wire [7:0]  row_in      [0:3];
    wire [7:0]  col_in      [0:3];
    wire [7:0]  skewed_row  [0:3];
    wire [7:0]  skewed_col  [0:3];
    wire [23:0] drain_out   [0:3];

    assign row_in[0] = matrix_a_in[7:0];
    assign row_in[1] = matrix_a_in[15:8];
    assign row_in[2] = matrix_a_in[23:16];
    assign row_in[3] = matrix_a_in[31:24];

    assign col_in[0] = matrix_b_in[7:0];
    assign col_in[1] = matrix_b_in[15:8];
    assign col_in[2] = matrix_b_in[23:16];
    assign col_in[3] = matrix_b_in[31:24];

    assign drain_out_0 = drain_out[0];
    assign drain_out_1 = drain_out[1];
    assign drain_out_2 = drain_out[2];
    assign drain_out_3 = drain_out[3];

    array_controller controller_inst (
        .clk       (clk),
        .rst       (rst),
        .start     (start),
        .en        (en),
        .shift_en  (shift_en),
        .clr_acc   (clr_acc),
        .done_flag (done_flag)
    );

    data_skew_buffers skew_buffers_inst (
        .clk     (clk),
        .rst     (rst),
        .row_in  (row_in),
        .col_in  (col_in),
        .row_out (skewed_row),
        .col_out (skewed_col)
    );

    systolic_array_4x4 systolic_array_inst (
        .clk       (clk),
        .rst       (rst),
        .en        (en),
        .shift_en  (shift_en),
        .clr_acc   (clr_acc),
        .a_row     (skewed_row),
        .b_col     (skewed_col),
        .drain_out (drain_out)
    );

endmodule
