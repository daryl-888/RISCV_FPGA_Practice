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
    
    // Week 1: implement the operations using these local control encodings. 
    // Start with ADD/SUB/AND/OR/XOR/SLT; extend when the basic gate passes.
    //test
    
    always_comb begin
        case(op)
        ADD: result = a + b;
        SUB: result = a - b;
        AND_OP: result = a & b;
        OR_OP: result = a | b;
        XOR_OP: result = a ^ b;
        SLT: result = ($signed(a) < $signed(b)) ? 32'd1:32'd0;
        SLTU: result = (a < b) ? 32'd1:32'd0;
        SLL: result = a << b[4:0];
        SRL: result = a >> b[4:0];
        SRA: result = $signed(a) >>> b[4:0];
        default: result = 32'b0;
        endcase
    end
endmodule
