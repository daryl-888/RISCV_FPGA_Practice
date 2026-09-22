module basys3_top #(parameter bit PIPELINED=1'b1, parameter IMEM_FILE="boot.hex")(
    input logic clk, btnC,
    input logic [15:0] sw,
    output logic [15:0] led
);
    timeunit 1ns; timeprecision 1ps;
    // Week 8: synchronize inputs; hold reset at startup; connect CPU and memories.
    // PIPELINED=1 is the required final deployment. No fabric-generated/gated clock.
    assign led=0;
endmodule
