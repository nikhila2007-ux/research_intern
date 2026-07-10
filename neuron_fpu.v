`timescale 1ns / 1ps


module neuron_fpu (
    input clk,
    input reset,
    input start,
    input [31:0] pixel_in,   
    input [31:0] weight_in,  
    input [31:0] bias,       
    output reg [31:0] result,
    output reg done
);

    localparam IDLE = 3'd0;
    localparam MULTIPLY = 3'd1;
    localparam ADD = 3'd2;
    localparam BIAS_ADD = 3'd3;
    localparam FINISH = 3'd4;

    reg [2:0] state;
    reg [9:0] counter; 

    // FPU Signals
    reg [31:0] fadd_a, fadd_b;
    wire [31:0] fadd_res;
    reg [31:0] fmult_a, fmult_b;
    wire [31:0] fmult_res;

    // Accumulator for the weighted sum
    reg [31:0] accumulator;

    // Instantiate FPU Multiplier
    FloatingMultiplication fmult (
        .A(fmult_a),
        .B(fmult_b),
        .result(fmult_res)
    );

    // Instantiate FPU Adder
    FloatingAddition fadd (
        .A(fadd_a),
        .B(fadd_b),
        .result(fadd_res)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            accumulator <= 32'h0;
            done <= 1'b0;
            counter <= 10'd0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= MULTIPLY;
                        accumulator <= 32'h0;
                        counter <= 10'd0;
                        done <= 1'b0;
                    end
                end

                MULTIPLY: begin
                    fmult_a <= pixel_in;
                    fmult_b <= weight_in;
                    state <= ADD;
                end

                ADD: begin
                    fadd_a <= accumulator;
                    fadd_b <= fmult_res;
                    accumulator <= fadd_res;
                    
                    if (counter == 10'd783) begin
                        state <= BIAS_ADD;
                    end else begin
                        counter <= counter + 1;
                        state <= MULTIPLY;
                    end
                end

                BIAS_ADD: begin
                    fadd_a <= accumulator;
                    fadd_b <= bias;
                    accumulator <= fadd_res;
                    state <= FINISH;
                end

                FINISH: begin
                    result <= accumulator;
                    done <= 1'b1;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
