package rv32_pkg;
    timeunit 1ns;
    timeprecision 1ps;

    localparam logic [3:0] FAULT_NONE=0, ILLEGAL_INSTRUCTION=1,
        UNSUPPORTED_INSTRUCTION=2, INSTRUCTION_MISALIGNED=3,
        INSTRUCTION_ACCESS=4, LOAD_MISALIGNED=5, LOAD_ACCESS=6,
        STORE_MISALIGNED=7, STORE_ACCESS=8;
    localparam logic [3:0] ALU_ADD=0, ALU_SUB=1, ALU_AND=2,
        ALU_OR=3, ALU_XOR=4, ALU_SLT=5, ALU_SLTU=6,
        ALU_SLL=7, ALU_SRL=8, ALU_SRA=9;

    typedef struct packed {
        logic legal, unsupported, uses_rs1, uses_rs2;
        logic reg_write, mem_read, mem_write, branch;
        logic jal, jalr, lui, auipc, alu_imm;
        logic [4:0] rs1, rs2, rd;
        logic [2:0] funct3;
        logic [31:0] imm;
        logic [3:0] alu_op;
    } decoded_t;

    typedef struct packed {
        logic [31:0] value, addr, store_data, next_pc;
        logic redirect;
        logic [3:0] fault;
    } exec_result_t;

endpackage
