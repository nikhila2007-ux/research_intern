`timescale 1ns / 1ps

// Top-level module for a basic MNIST ANN (Single Layer / Single Neuron for simplicity)
// This module demonstrates how to interface with the FPU-based neuron.

module mnist_ann_top (
    input clk,
    input reset,
    input start,
    input [31:0] data_bus, // Input pixels/weights from memory
    output [3:0] prediction,
    output ready
);

    // In a full implementation, you would have:
    // 1. Memory for 784 pixels
    // 2. Memory for weights (e.g., 784 * 10 for a single hidden layer)
    // 3. Control logic to feed data to multiple neurons
    
    // For this example, we show a single neuron processing
    wire [31:0] neuron_out;
    wire neuron_done;

    neuron_fpu u_neuron (
        .clk(clk),
        .reset(reset),
        .start(start),
        .pixel_in(data_bus),  // Simplified: data comes from a bus
        .weight_in(data_bus), // Simplified: weights come from a bus
        .bias(32'h3F800000),  // Example bias (1.0 in IEEE-754)
        .result(neuron_out),
        .done(neuron_done)
    );

    // Simple prediction logic (Argmax)
    // If we had 10 neurons, we would compare their results here.
    assign prediction = (neuron_out[31] == 0) ? 4'd1 : 4'd0; // Dummy logic
    assign ready = neuron_done;

endmodule
