module execute_stage(
    input rv32_pkg::decoded_t decoded,
    input logic [31:0] pc, a, b,
    output rv32_pkg::exec_result_t result
);
    timeunit 1ns;
    timeprecision 1ps;
    
    import rv32_pkg::*;
    // Week 3: instantiate the week-1 ALU and choose b versus immediate.
    
    logic [31:0] alu_b;
    logic [31:0] alu_result;

    assign alu_b = decoded.alu_imm ? decoded.imm : b;

    alu u_alu(
        .a(a),
        .b(alu_b),
        .op(decoded.alu_op),
        result(alu_result)
    );

    always_comb begin
        result = '0;

        result.value = alu_result;
        result.next_pc = pc + 32'd4;
    end

    // Week 4: effective address, store_data=b, branch/jump target, PC+4 link, U ops.
    // Reject illegal instructions/misaligned taken targets without writes.
endmodule
