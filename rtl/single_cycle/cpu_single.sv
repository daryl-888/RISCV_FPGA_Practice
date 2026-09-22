// Learner skeleton. One successful instruction per rising edge.
module cpu_single (
    input  logic clk, reset,
    output logic [31:0] imem_addr,
    input  logic [31:0] imem_rdata,
    input  logic [3:0] imem_fault,
    output logic dmem_valid, dmem_write,
    output logic [2:0] dmem_funct3,
    output logic [31:0] dmem_addr, dmem_wdata,
    input  logic [31:0] dmem_rdata,
    input  logic [3:0] dmem_fault,
    output logic halted,
    output logic retire_valid,
    output logic [31:0] retire_pc, retire_instr, retire_next_pc,
    output logic retire_rd_write,
    output logic [4:0] retire_rd,
    output logic [31:0] retire_rd_data,
    output logic retire_mem_valid, retire_mem_write,
    output logic [2:0] retire_mem_funct3,
    output logic [31:0] retire_mem_addr, retire_mem_wdata, retire_mem_rdata,
    output logic [3:0] retire_fault,
    output logic stall, redirect,
    output logic [31:0] debug_regs [0:31]
);
    timeunit 1ns; timeprecision 1ps;
    import rv32_pkg::*;
    // Connect decode, execute_stage and regfile modules using the documented ports.
    // Single-cycle: week 3 arithmetic, week 4 memory/control flow.
    // Pipeline: week 5 four valid-tagged boundary registers; week 6 hazards/redirect.
    // Retirement outputs are registered POST-edge events, once per completed token.
    // Memory requests are PRE-edge levels. Never gate a request by its returned fault.
    assign imem_addr=0;
    assign dmem_valid=0; assign dmem_write=0; assign dmem_funct3=0;
    assign dmem_addr=0; assign dmem_wdata=0;
    assign halted=0; assign retire_valid=0;
    assign retire_pc=0; assign retire_instr=0; assign retire_next_pc=0;
    assign retire_rd_write=0; assign retire_rd=0; assign retire_rd_data=0;
    assign retire_mem_valid=0; assign retire_mem_write=0; assign retire_mem_funct3=0;
    assign retire_mem_addr=0; assign retire_mem_wdata=0; assign retire_mem_rdata=0;
    assign retire_fault=0; assign stall=0; assign redirect=0;
    for(genvar r=0;r<32;r++) begin : mirror
        assign debug_regs[r]=0;
    end
endmodule
