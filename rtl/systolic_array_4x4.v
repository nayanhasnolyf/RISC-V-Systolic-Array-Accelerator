module systolic_array_4x4 (
    input  wire        clk,
    input  wire        rst,
    input  wire        en,
    input  wire        shift_en,
    input  wire        clr_acc,
    input  wire [7:0]  a_row [0:3],
    input  wire [7:0]  b_col [0:3],
    output wire [23:0] drain_out [0:3]
);

    wire [7:0] a_row0 [0:4];
    wire [7:0] a_row1 [0:4];
    wire [7:0] a_row2 [0:4];
    wire [7:0] a_row3 [0:4];

    wire [7:0] b_col0 [0:4];
    wire [7:0] b_col1 [0:4];
    wire [7:0] b_col2 [0:4];
    wire [7:0] b_col3 [0:4];

    wire [23:0] acc_wire [1:4][0:3];

    genvar i;
    genvar j;

    assign a_row0[0] = a_row[0];
    assign a_row1[0] = a_row[1];
    assign a_row2[0] = a_row[2];
    assign a_row3[0] = a_row[3];

    assign b_col0[0] = b_col[0];
    assign b_col1[0] = b_col[1];
    assign b_col2[0] = b_col[2];
    assign b_col3[0] = b_col[3];

    assign drain_out[0] = acc_wire[4][0];
    assign drain_out[1] = acc_wire[4][1];
    assign drain_out[2] = acc_wire[4][2];
    assign drain_out[3] = acc_wire[4][3];

    generate
        // PE grid mapping:
        // PE[i][j] consumes A from a_rowi[j] and drives a_rowi[j+1].
        // PE[i][j] consumes B from b_colj[i] and drives b_colj[i+1].
        // Row 0 shift_in is tied to 24'h000000 for all four columns.
        // Rows 1-3 receive shift_in from the PE directly above.
        for (i = 0; i < 4; i = i + 1) begin : pe_row
            for (j = 0; j < 4; j = j + 1) begin : pe_col
                if (i == 0) begin : row0
                    if (j == 0) begin : col0
                        pe_output_stationary pe_inst (
                            .clk      (clk),
                            .rst      (rst),
                            .en       (en),
                            .shift_en (shift_en),
                            .clr_acc  (clr_acc),
                            .a_in     (a_row0[0]),
                            .b_in     (b_col0[0]),
                            .shift_in (24'h000000),
                            .a_out    (a_row0[1]),
                            .b_out    (b_col0[1]),
                            .acc      (acc_wire[1][0])
                        );
                    end else if (j == 1) begin : col1
                        pe_output_stationary pe_inst (
                            .clk      (clk),
                            .rst      (rst),
                            .en       (en),
                            .shift_en (shift_en),
                            .clr_acc  (clr_acc),
                            .a_in     (a_row0[1]),
                            .b_in     (b_col1[0]),
                            .shift_in (24'h000000),
                            .a_out    (a_row0[2]),
                            .b_out    (b_col1[1]),
                            .acc      (acc_wire[1][1])
                        );
                    end else if (j == 2) begin : col2
                        pe_output_stationary pe_inst (
                            .clk      (clk),
                            .rst      (rst),
                            .en       (en),
                            .shift_en (shift_en),
                            .clr_acc  (clr_acc),
                            .a_in     (a_row0[2]),
                            .b_in     (b_col2[0]),
                            .shift_in (24'h000000),
                            .a_out    (a_row0[3]),
                            .b_out    (b_col2[1]),
                            .acc      (acc_wire[1][2])
                        );
                    end else begin : col3
                        pe_output_stationary pe_inst (
                            .clk      (clk),
                            .rst      (rst),
                            .en       (en),
                            .shift_en (shift_en),
                            .clr_acc  (clr_acc),
                            .a_in     (a_row0[3]),
                            .b_in     (b_col3[0]),
                            .shift_in (24'h000000),
                            .a_out    (a_row0[4]),
                            .b_out    (b_col3[1]),
                            .acc      (acc_wire[1][3])
                        );
                    end
                end else if (i == 1) begin : row1
                    if (j == 0) begin : col0
                        pe_output_stationary pe_inst (
                            .clk      (clk),
                            .rst      (rst),
                            .en       (en),
                            .shift_en (shift_en),
                            .clr_acc  (clr_acc),
                            .a_in     (a_row1[0]),
                            .b_in     (b_col0[1]),
                            .shift_in (acc_wire[1][0]),
                            .a_out    (a_row1[1]),
                            .b_out    (b_col0[2]),
                            .acc      (acc_wire[2][0])
                        );
                    end else if (j == 1) begin : col1
                        pe_output_stationary pe_inst (
                            .clk      (clk),
                            .rst      (rst),
                            .en       (en),
                            .shift_en (shift_en),
                            .clr_acc  (clr_acc),
                            .a_in     (a_row1[1]),
                            .b_in     (b_col1[1]),
                            .shift_in (acc_wire[1][1]),
                            .a_out    (a_row1[2]),
                            .b_out    (b_col1[2]),
                            .acc      (acc_wire[2][1])
                        );
                    end else if (j == 2) begin : col2
                        pe_output_stationary pe_inst (
                            .clk      (clk),
                            .rst      (rst),
                            .en       (en),
                            .shift_en (shift_en),
                            .clr_acc  (clr_acc),
                            .a_in     (a_row1[2]),
                            .b_in     (b_col2[1]),
                            .shift_in (acc_wire[1][2]),
                            .a_out    (a_row1[3]),
                            .b_out    (b_col2[2]),
                            .acc      (acc_wire[2][2])
                        );
                    end else begin : col3
                        pe_output_stationary pe_inst (
                            .clk      (clk),
                            .rst      (rst),
                            .en       (en),
                            .shift_en (shift_en),
                            .clr_acc  (clr_acc),
                            .a_in     (a_row1[3]),
                            .b_in     (b_col3[1]),
                            .shift_in (acc_wire[1][3]),
                            .a_out    (a_row1[4]),
                            .b_out    (b_col3[2]),
                            .acc      (acc_wire[2][3])
                        );
                    end
                end else if (i == 2) begin : row2
                    if (j == 0) begin : col0
                        pe_output_stationary pe_inst (
                            .clk      (clk),
                            .rst      (rst),
                            .en       (en),
                            .shift_en (shift_en),
                            .clr_acc  (clr_acc),
                            .a_in     (a_row2[0]),
                            .b_in     (b_col0[2]),
                            .shift_in (acc_wire[2][0]),
                            .a_out    (a_row2[1]),
                            .b_out    (b_col0[3]),
                            .acc      (acc_wire[3][0])
                        );
                    end else if (j == 1) begin : col1
                        pe_output_stationary pe_inst (
                            .clk      (clk),
                            .rst      (rst),
                            .en       (en),
                            .shift_en (shift_en),
                            .clr_acc  (clr_acc),
                            .a_in     (a_row2[1]),
                            .b_in     (b_col1[2]),
                            .shift_in (acc_wire[2][1]),
                            .a_out    (a_row2[2]),
                            .b_out    (b_col1[3]),
                            .acc      (acc_wire[3][1])
                        );
                    end else if (j == 2) begin : col2
                        pe_output_stationary pe_inst (
                            .clk      (clk),
                            .rst      (rst),
                            .en       (en),
                            .shift_en (shift_en),
                            .clr_acc  (clr_acc),
                            .a_in     (a_row2[2]),
                            .b_in     (b_col2[2]),
                            .shift_in (acc_wire[2][2]),
                            .a_out    (a_row2[3]),
                            .b_out    (b_col2[3]),
                            .acc      (acc_wire[3][2])
                        );
                    end else begin : col3
                        pe_output_stationary pe_inst (
                            .clk      (clk),
                            .rst      (rst),
                            .en       (en),
                            .shift_en (shift_en),
                            .clr_acc  (clr_acc),
                            .a_in     (a_row2[3]),
                            .b_in     (b_col3[2]),
                            .shift_in (acc_wire[2][3]),
                            .a_out    (a_row2[4]),
                            .b_out    (b_col3[3]),
                            .acc      (acc_wire[3][3])
                        );
                    end
                end else begin : row3
                    if (j == 0) begin : col0
                        pe_output_stationary pe_inst (
                            .clk      (clk),
                            .rst      (rst),
                            .en       (en),
                            .shift_en (shift_en),
                            .clr_acc  (clr_acc),
                            .a_in     (a_row3[0]),
                            .b_in     (b_col0[3]),
                            .shift_in (acc_wire[3][0]),
                            .a_out    (a_row3[1]),
                            .b_out    (b_col0[4]),
                            .acc      (acc_wire[4][0])
                        );
                    end else if (j == 1) begin : col1
                        pe_output_stationary pe_inst (
                            .clk      (clk),
                            .rst      (rst),
                            .en       (en),
                            .shift_en (shift_en),
                            .clr_acc  (clr_acc),
                            .a_in     (a_row3[1]),
                            .b_in     (b_col1[3]),
                            .shift_in (acc_wire[3][1]),
                            .a_out    (a_row3[2]),
                            .b_out    (b_col1[4]),
                            .acc      (acc_wire[4][1])
                        );
                    end else if (j == 2) begin : col2
                        pe_output_stationary pe_inst (
                            .clk      (clk),
                            .rst      (rst),
                            .en       (en),
                            .shift_en (shift_en),
                            .clr_acc  (clr_acc),
                            .a_in     (a_row3[2]),
                            .b_in     (b_col2[3]),
                            .shift_in (acc_wire[3][2]),
                            .a_out    (a_row3[3]),
                            .b_out    (b_col2[4]),
                            .acc      (acc_wire[4][2])
                        );
                    end else begin : col3
                        pe_output_stationary pe_inst (
                            .clk      (clk),
                            .rst      (rst),
                            .en       (en),
                            .shift_en (shift_en),
                            .clr_acc  (clr_acc),
                            .a_in     (a_row3[3]),
                            .b_in     (b_col3[3]),
                            .shift_in (acc_wire[3][3]),
                            .a_out    (a_row3[4]),
                            .b_out    (b_col3[4]),
                            .acc      (acc_wire[4][3])
                        );
                    end
                end
            end
        end
    endgenerate

endmodule
