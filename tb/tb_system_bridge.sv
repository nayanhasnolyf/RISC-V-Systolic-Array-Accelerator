`timescale 1ns/1ps

module tb_system_bridge;

    localparam ACCEL_BASE = 32'h40000000;
    localparam ADDR_START = 32'h40000000;
    localparam ADDR_A     = 32'h40000004;
    localparam ADDR_B     = 32'h40000008;
    localparam ADDR_DONE  = 32'h4000000C;
    localparam ADDR_RES0  = 32'h40000010;

    reg         clk;
    reg         rst;
    reg  [31:0] bus_addr;
    reg  [31:0] wdata;
    reg         wen;
    reg         started;
    wire [31:0] rdata;

    wire [31:0] accel_local_addr;

    integer poll_count;
    reg [31:0] read_value;

    assign accel_local_addr = bus_addr - ACCEL_BASE;

    accelerator_bus_interface dut (
        .clk   (clk),
        .rst   (rst),
        .addr  (accel_local_addr),
        .wdata (wdata),
        .wen   (wen),
        .rdata (rdata)
    );

    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (started) begin
            $display("Time=%t | Start_Pulse=%b | State=%d",
                     $time,
                     dut.start_pulse,
                     dut.accelerator_inst.controller_inst.state);
        end
    end

    task bus_write;
        input [31:0] write_addr;
        input [31:0] write_data;
        begin
            @(posedge clk);
            bus_addr = write_addr;
            wdata    = write_data;
            wen      = 1'b1;
            @(posedge clk);
            wen      = 1'b0;
            wdata    = 32'd0;
        end
    endtask

    task bus_read;
        input  [31:0] read_addr;
        output [31:0] read_data;
        begin
            @(posedge clk);
            bus_addr = read_addr;
            wen      = 1'b0;
            #1;
            read_data = rdata;
        end
    endtask

    initial begin
        $dumpfile("system.vcd");
        $dumpvars;

        clk = 1'b0;
        rst = 1'b1;
        bus_addr = 32'd0;
        wdata = 32'd0;
        wen = 1'b0;
        started = 1'b0;
        poll_count = 0;
        read_value = 32'd0;

        repeat (2) @(posedge clk);
        rst = 1'b0;

        bus_write(ADDR_A, 32'h02020202);
        bus_write(ADDR_B, 32'h03030303);
        bus_write(ADDR_START, 32'h00000001);
        started = 1'b1;

        bus_read(ADDR_DONE, read_value);
        while (read_value[0] == 1'b0 && poll_count < 256) begin
            poll_count = poll_count + 1;
            bus_read(ADDR_DONE, read_value);
        end

        if (read_value[0]) begin
            bus_read(ADDR_RES0, read_value);
            $display("Result 0: %0d (0x%08h)", read_value, read_value);
        end else begin
            $display("Timeout waiting for accelerator done");
        end

        $finish;
    end

endmodule
