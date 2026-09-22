module pc(input logic clk, reset, enable, input logic [31:0] next_pc,
          output logic [31:0] value);
    timeunit 1ns; timeprecision 1ps;
    // Week 2: synchronous reset has priority over enable; capture next_pc on posedge.
    assign value=0;
endmodule
