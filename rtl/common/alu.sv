module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [3:0]  op,
    output logic [31:0] result
);
    timeunit 1ns;
    timeprecision 1ps;
    // Teaching interface: this is a local control encoding, not an opcode.
    localparam logic [3:0] ADD = 4'd0, SUB = 4'd1, AND_OP = 4'd2,
        OR_OP = 4'd3, XOR_OP = 4'd4, SLT = 4'd5, SLTU = 4'd6,
        SLL = 4'd7, SRL = 4'd8, SRA = 4'd9;

    always_comb begin
        // Week 1: implement the operations using these local control encodings.
        // Start with ADD/SUB/AND/OR/XOR/SLT; extend when the basic gate passes.
        result = 32'b0;
    end
endmodule
