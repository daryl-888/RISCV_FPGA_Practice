module regfile #(parameter bit BYPASS=0)(
    input logic clk, reset, write_en,
    input logic [4:0] ra, rb, rd,
    input logic [31:0] write_data,
    output logic [31:0] a, b,
    output logic [31:0] debug_regs [0:31]
);
    timeunit 1ns; timeprecision 1ps;
    // Week 2: two asynchronous reads, one rising-edge write, synchronous reset.
    // x0 is always zero. Week 6: when BYPASS=1, forward this edge's write to reads.
    // Implement storage here; these safe ties are deliberately incomplete.
    assign a=0;
    assign b=0;
    for(genvar n=0;n<32;n++) begin : mirror
        assign debug_regs[n]=0;
    end
endmodule
