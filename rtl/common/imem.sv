module imem #(parameter string IMAGE="programs/fetch.hex")(
    input logic [31:0] address,
    output logic [31:0] instruction,
    output logic access_fault, misaligned
);
    timeunit 1ns; timeprecision 1ps;
    logic [31:0] words [0:255];
    // Week 2: initialize NOPs, read IMAGE, check full byte address before [9:2].
    assign instruction=0;
    assign access_fault=0;
    assign misaligned=0;
endmodule
