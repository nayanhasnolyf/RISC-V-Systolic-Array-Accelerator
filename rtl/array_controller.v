module array_controller (
    input  wire clk,
    input  wire rst,
    input  wire start,
    output reg  en,
    output reg  shift_en,
    output reg  clr_acc,
    output reg  done_flag
);

    localparam IDLE    = 2'd0;
    localparam COMPUTE = 2'd1;
    localparam DRAIN   = 2'd2;
    localparam DONE    = 2'd3;

    reg [1:0] state;
    reg [1:0] next_state;
    reg [3:0] count;
    reg [3:0] compute_tick;

    // State transition and timing counter.
    always @(posedge clk) begin
        if (rst) begin
            state        <= IDLE;
            count        <= 4'd0;
            compute_tick <= 4'd0;
        end else begin
            state <= next_state;

            if (state != next_state) begin
                count <= 4'd0;
            end else if ((state == COMPUTE) || (state == DRAIN)) begin
                count <= count + 4'd1;
            end else begin
                count <= 4'd0;
            end

            if (state != COMPUTE) begin
                compute_tick <= 4'd0;
            end else begin
                compute_tick <= compute_tick + 4'd1;
            end
        end
    end

    // Next state logic.
    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                // Leave IDLE when a new array operation is requested.
                if (start) begin
                    next_state = COMPUTE;
                end
            end

            COMPUTE: begin
                // Run compute for 10 cycles, then begin draining results.
                if (count == 4'd9) begin
                    next_state = DRAIN;
                end
            end

            DRAIN: begin
                // Shift accumulated results down for 4 cycles.
                if (count == 4'd3) begin
                    next_state = DONE;
                end
            end

            DONE: begin
                // Pulse done for one cycle, then wait for the next start.
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Moore output logic: outputs depend only on the current state.
    always @(*) begin
        en        = 1'b0;
        shift_en  = 1'b0;
        clr_acc   = 1'b0;
        done_flag = 1'b0;

        case (state)
            IDLE: begin
                clr_acc = 1'b1;
            end

            COMPUTE: begin
                if (compute_tick < 4'd4) begin
                    en = 1'b1;
                end
            end

            DRAIN: begin
                shift_en = 1'b1;
            end

            DONE: begin
                done_flag = 1'b1;
            end

            default: begin
                clr_acc = 1'b1;
            end
        endcase
    end

endmodule
