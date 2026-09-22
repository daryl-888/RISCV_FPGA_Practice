module forwarding(
    input logic used, ex_valid, ex_write, ex_load, wb_valid, wb_write,
    input logic [4:0] source, ex_rd, wb_rd,
    input logic [31:0] captured, ex_value, wb_value,
    output logic [31:0] value
);
    timeunit 1ns; timeprecision 1ps;
    // Week 6: x0/unused -> 0; newest eligible producer wins. Never forward a load address.
    assign value=captured;
endmodule
