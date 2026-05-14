`timescale 1ns/1ps

module tb_accelerator;

    reg         clk;
    reg         rst;
    reg         start;
    reg  [31:0] matrix_a_in;
    reg  [31:0] matrix_b_in;
    wire [23:0] drain_out_0;
    wire [23:0] drain_out_1;
    wire [23:0] drain_out_2;
    wire [23:0] drain_out_3;
    /* verilator lint_off UNUSEDSIGNAL */
    wire        done_flag;
    /* verilator lint_on UNUSEDSIGNAL */

    integer cycle;

    accelerator_top dut (
        .clk         (clk),
        .rst         (rst),
        .start       (start),
        .matrix_a_in (matrix_a_in),
        .matrix_b_in (matrix_b_in),
        .drain_out_0 (drain_out_0),
        .drain_out_1 (drain_out_1),
        .drain_out_2 (drain_out_2),
        .drain_out_3 (drain_out_3),
        .done_flag   (done_flag)
    );

    always #5 clk = ~clk;

    always @(posedge clk) begin
        $display("Debug Buffers: Row0_out=%h, Row1_out=%h, Col0_out=%h, Col1_out=%h",
                 dut.skewed_row[0], dut.skewed_row[1],
                 dut.skewed_col[0], dut.skewed_col[1]);
        $display("Debug PE00: a_in=%h, b_in=%h, acc=%h",
                 dut.systolic_array_inst.pe_row[0].pe_col[0].row0.col0.pe_inst.a_in,
                 dut.systolic_array_inst.pe_row[0].pe_col[0].row0.col0.pe_inst.b_in,
                 dut.systolic_array_inst.pe_row[0].pe_col[0].row0.col0.pe_inst.acc);

        if (drain_out_0 > 0 || drain_out_1 > 0 ||
            drain_out_2 > 0 || drain_out_3 > 0) begin
            $display("Drain: %0d, %0d, %0d, %0d",
                     drain_out_0, drain_out_1, drain_out_2, drain_out_3);
        end
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_accelerator);

        clk = 1'b0;
        rst = 1'b1;
        start = 1'b0;
        matrix_a_in = 32'h0;
        matrix_b_in = 32'h0;

        #20;
        rst = 1'b0;

        @(posedge clk);
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;

        for (cycle = 0; cycle < 4; cycle = cycle + 1) begin
            matrix_a_in = 32'h02_02_02_02;
            matrix_b_in = 32'h03_03_03_03;
            @(posedge clk);
        end

        matrix_a_in = 32'h0;
        matrix_b_in = 32'h0;

        for (cycle = 0; cycle < 16; cycle = cycle + 1) begin
            @(posedge clk);
        end

        $finish;
    end

endmodule
