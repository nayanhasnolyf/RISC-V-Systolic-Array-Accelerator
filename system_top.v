module system_top (
    input wire clk,
    input wire rst
);

    localparam SRAM_BASE       = 32'h00000000;
    localparam SRAM_SIZE_BYTES = 32'h00004000;
    localparam ACCEL_BASE      = 32'h40000000;
    localparam ACCEL_LAST      = 32'h4000001C;

    wire        mem_valid;
    wire        mem_instr;
    reg         mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    reg  [31:0] mem_rdata;

    wire        sram_sel;
    wire        accel_sel;
    wire        mem_write;
    wire [31:0] sram_rdata;
    wire [31:0] sram_b_rdata;
    wire [31:0] accel_rdata;
    wire        accel_wen;
    wire        trap;
    wire        mem_la_read;
    wire        mem_la_write;
    wire [31:0] mem_la_addr;
    wire [31:0] mem_la_wdata;
    wire [3:0]  mem_la_wstrb;
    wire        pcpi_valid;
    wire [31:0] pcpi_insn;
    wire [31:0] pcpi_rs1;
    wire [31:0] pcpi_rs2;
    wire [31:0] eoi;
    wire        trace_valid;
    wire [35:0] trace_data;

    /* verilator lint_off UNUSEDSIGNAL */
    wire mem_instr_unused = mem_instr;
    wire [31:0] sram_b_rdata_unused = sram_b_rdata;
    wire trap_unused = trap;
    wire mem_la_read_unused = mem_la_read;
    wire mem_la_write_unused = mem_la_write;
    wire [31:0] mem_la_addr_unused = mem_la_addr;
    wire [31:0] mem_la_wdata_unused = mem_la_wdata;
    wire [3:0] mem_la_wstrb_unused = mem_la_wstrb;
    wire pcpi_valid_unused = pcpi_valid;
    wire [31:0] pcpi_insn_unused = pcpi_insn;
    wire [31:0] pcpi_rs1_unused = pcpi_rs1;
    wire [31:0] pcpi_rs2_unused = pcpi_rs2;
    wire [31:0] eoi_unused = eoi;
    wire trace_valid_unused = trace_valid;
    wire [35:0] trace_data_unused = trace_data;
    /* verilator lint_on UNUSEDSIGNAL */

    /* verilator lint_off UNSIGNED */
    assign sram_sel  = (mem_addr >= SRAM_BASE) &&
                       (mem_addr < (SRAM_BASE + SRAM_SIZE_BYTES));
    /* verilator lint_on UNSIGNED */
    assign accel_sel = (mem_addr >= ACCEL_BASE) && (mem_addr <= ACCEL_LAST);
    assign mem_write = |mem_wstrb;
    assign accel_wen = mem_valid && !mem_ready && accel_sel && mem_write;

    picorv32 cpu_inst (
        .clk          (clk),
        .resetn       (~rst),
        .trap         (trap),
        .mem_valid    (mem_valid),
        .mem_instr    (mem_instr),
        .mem_ready    (mem_ready),
        .mem_addr     (mem_addr),
        .mem_wdata    (mem_wdata),
        .mem_wstrb    (mem_wstrb),
        .mem_rdata    (mem_rdata),
        .mem_la_read  (mem_la_read),
        .mem_la_write (mem_la_write),
        .mem_la_addr  (mem_la_addr),
        .mem_la_wdata (mem_la_wdata),
        .mem_la_wstrb (mem_la_wstrb),
        .pcpi_valid   (pcpi_valid),
        .pcpi_insn    (pcpi_insn),
        .pcpi_rs1     (pcpi_rs1),
        .pcpi_rs2     (pcpi_rs2),
        .pcpi_wr      (1'b0),
        .pcpi_rd      (32'd0),
        .pcpi_wait    (1'b0),
        .pcpi_ready   (1'b0),
        .irq          (32'd0),
        .eoi          (eoi),
        .trace_valid  (trace_valid),
        .trace_data   (trace_data)
    );

    simple_16kb_dual_port_sram sram_inst (
        .clk      (clk),
        .a_addr   (mem_addr[13:0]),
        .a_wdata  (mem_wdata),
        .a_wstrb  ((mem_valid && !mem_ready && sram_sel) ? mem_wstrb : 4'b0000),
        .a_rdata  (sram_rdata),
        .b_addr   (14'd0),
        .b_wdata  (32'd0),
        .b_wstrb  (4'b0000),
        .b_rdata  (sram_b_rdata)
    );

    accelerator_bus_interface accel_inst (
        .clk   (clk),
        .rst   (rst),
        .addr  ({27'd0, mem_addr[4:0]}),
        .wdata (mem_wdata),
        .wen   (accel_wen),
        .rdata (accel_rdata)
    );

    always @(posedge clk) begin
        if (rst) begin
            mem_ready <= 1'b0;
            mem_rdata <= 32'd0;
        end else begin
            mem_ready <= 1'b0;

            if (mem_valid && !mem_ready) begin
                mem_ready <= 1'b1;

                if (sram_sel) begin
                    mem_rdata <= sram_rdata;
                end else if (accel_sel) begin
                    mem_rdata <= accel_rdata;
                end else begin
                    mem_rdata <= 32'd0;
                end
            end
        end
    end

endmodule

/* verilator lint_off DECLFILENAME */
module simple_16kb_dual_port_sram (
    input  wire        clk,
    input  wire [13:0] a_addr,
    input  wire [31:0] a_wdata,
    input  wire [3:0]  a_wstrb,
    output wire [31:0] a_rdata,
    input  wire [13:0] b_addr,
    input  wire [31:0] b_wdata,
    input  wire [3:0]  b_wstrb,
    output wire [31:0] b_rdata
);

    reg [7:0] mem [0:16383];

    assign a_rdata = {
        mem[{a_addr[13:2], 2'b11}],
        mem[{a_addr[13:2], 2'b10}],
        mem[{a_addr[13:2], 2'b01}],
        mem[{a_addr[13:2], 2'b00}]
    };

    assign b_rdata = {
        mem[{b_addr[13:2], 2'b11}],
        mem[{b_addr[13:2], 2'b10}],
        mem[{b_addr[13:2], 2'b01}],
        mem[{b_addr[13:2], 2'b00}]
    };

    always @(posedge clk) begin
        if (a_wstrb[0]) begin
            mem[{a_addr[13:2], 2'b00}] <= a_wdata[7:0];
        end
        if (a_wstrb[1]) begin
            mem[{a_addr[13:2], 2'b01}] <= a_wdata[15:8];
        end
        if (a_wstrb[2]) begin
            mem[{a_addr[13:2], 2'b10}] <= a_wdata[23:16];
        end
        if (a_wstrb[3]) begin
            mem[{a_addr[13:2], 2'b11}] <= a_wdata[31:24];
        end

        if (b_wstrb[0]) begin
            mem[{b_addr[13:2], 2'b00}] <= b_wdata[7:0];
        end
        if (b_wstrb[1]) begin
            mem[{b_addr[13:2], 2'b01}] <= b_wdata[15:8];
        end
        if (b_wstrb[2]) begin
            mem[{b_addr[13:2], 2'b10}] <= b_wdata[23:16];
        end
        if (b_wstrb[3]) begin
            mem[{b_addr[13:2], 2'b11}] <= b_wdata[31:24];
        end
    end

endmodule
/* verilator lint_on DECLFILENAME */
