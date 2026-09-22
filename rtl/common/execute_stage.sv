module execute_stage(
    input rv32_pkg::decoded_t decoded,
    input logic [31:0] pc, a, b,
    output rv32_pkg::exec_result_t result
);
    timeunit 1ns; timeprecision 1ps;
    import rv32_pkg::*;
    // Week 3: instantiate the week-1 ALU and choose b versus immediate.
    // Week 4: effective address, store_data=b, branch/jump target, PC+4 link, U ops.
    // Reject illegal instructions/misaligned taken targets without writes.
    assign result='0;
endmodule
