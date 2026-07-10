`timescale 1ns / 1ps


module mnist_ann_top (
    input clk,
    input reset,
    input start,
    input [31:0] data_bus, 
    output [3:0] prediction,
    output ready
);

   
    wire [31:0] neuron_out;
    wire neuron_done;

    neuron_fpu u_neuron (
        .clk(clk),
        .reset(reset),
        .start(start),
        .pixel_in(data_bus),  
        .weight_in(data_bus), 
        .bias(32'h3F800000), 
        .result(neuron_out),
        .done(neuron_done)
    );

    assign prediction = (neuron_out[31] == 0) ? 4'd1 : 4'd0; 
    assign ready = neuron_done;

endmodule
