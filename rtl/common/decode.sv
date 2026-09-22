module decode(input logic [31:0] instr, output rv32_pkg::decoded_t decoded);
    timeunit 1ns; timeprecision 1ps;
    import rv32_pkg::*;
    // Week 3: decode exact funct7/funct3; set used sources and sign-extend I immediate.
    // Week 4: add S/B/U/J formats and memory/control flow. Default has no side effects.
    assign decoded='0;
endmodule
