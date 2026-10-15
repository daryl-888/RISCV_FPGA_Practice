module decode(
    input logic [31:0] instr,
    output rv32_pkg::decoded_t decoded
);
    
    timeunit 1ns;
    timeprecision 1ps;
    import rv32_pkg::*;

    logic [6:0] opcode;
    logic [4:0] rd;
    logic [2:0] funct3;
    logic [4:0] rs1;
    logic [6:0] funct7;
    logic [4:0] rs2;
    
    assign opcode = instr[6:0];
    assign rd = instr[11:7];
    assign funct3 = instr[14:12];
    assign rs1 = instr[19:15];
    assign funct7 = instr[31:25];
    assign rs2 = instr[24:20];

    // Week 3: decode exact funct7/funct3; set used sources and sign-extend I immediate.
    // Week 4: add S/B/U/J formats and memory/control flow. Default has no side effects.
    
    always_comb begin
        decoded = '0;

        if (opcode == 7'b0010011) begin
            if (funct3 == 3'b000) begin
                decoded.legal = 1'b1;
                decoded.uses_rs1 = 1'b1;
                decoded.reg_write = 1'b1;
                decoded.alu_imm = 1'b1;

                decoded.rs1 = rs1;
                decoded.rd = rd;
                decoded.funct3 = funct3;
                decoded.alu_op = ALU_ADD;

                decoded.imm = {{20{instr[31]}}, instr[31:20]};
            end
        end

        if (opcode == 7'b0110011) begin
            if (funct3 == 3'b000 && 
                funct7 == 7'b0000000) begin

                decoded.legal = 1'b1;
                decoded.uses_rs1 = 1'b1;
                decoded.uses_rs2 = 1'b1;
                decoded.reg_write = 1'b1;

                decoded.rs1 = rs1;
                decoded.rs2 = rs2;
                decoded.rd = rd;
                decoded.funct3 = funct3;
                decoded.alu_op = ALU_ADD;
            end

            else if (funct3 == 3'b000 && 
                    funct7 == 7'b0100000) begin
                
                decoded.legal = 1'b1;
                decoded.uses_rs1 = 1'b1;
                decoded.uses_rs2 = 1'b1;
                decoded.reg_write = 1'b1;

                decoded.rs1 = rs1;
                decoded.rs2 = rs2;
                decoded.rd = rd;
                decoded.funct3 = funct3;
                decoded.alu_op = ALU_SUB;
            end
            else if (funct3 == 3'b111 && 
                    funct7 == 7'b0000000) begin
                
                decoded.legal = 1'b1;
                decoded.uses_rs1 = 1'b1;
                decoded.uses_rs2 = 1'b1;
                decoded.reg_write = 1'b1;

                decoded.rs1 = rs1;
                decoded.rs2 = rs2;
                decoded.rd = rd;
                decoded.funct3 = funct3;
                decoded.alu_op = ALU_AND;
            end
            else if (funct3 == 3'b110 && 
                    funct7 == 7'b0000000) begin 
                
                decoded.legal = 1'b1;
                decoded.uses_rs1 = 1'b1;
                decoded.uses_rs2 = 1'b1;
                decoded.reg_write = 1'b1;

                decoded.rs1 = rs1;
                decoded.rs2 = rs2;
                decoded.rd = rd;
                decoded.funct3 = funct3;
                decoded.alu_op = ALU_OR;
            end
            else if (funct3 == 3'b100 &&
                    funct7 == 7'b0000000) begin 
                
                decoded.legal = 1'b1;
                decoded.uses_rs1 = 1'b1;
                decoded.uses_rs2 = 1'b1;
                decoded.reg_write = 1'b1;

                decoded.rs1 = rs1;
                decoded.rs2 = rs2;
                decoded.rd = rd;
                decoded.funct3 = funct3;
                decoded.alu_op = ALU_XOR;
            end
            else if (funct3 == 3'b010 &&
                    funct7 == 7'b0000000) begin
                
                decoded.legal = 1'b1;
                decoded.uses_rs1 = 1'b1;
                decoded.uses_rs2 = 1'b1;
                decoded.reg_write = 1'b1;
                
                decoded.rs1 = rs1;
                decoded.rs2 = rs2;
                decoded.rd = rd;
                decoded.funct3 = funct3;
                decoded.alu_op = ALU_SLT;
            end
        end
    end

endmodule
