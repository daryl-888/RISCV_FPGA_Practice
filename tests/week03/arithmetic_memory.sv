// Test fixture for week 3 only: isolates CPU arithmetic from the week-4 RAM lab.
module teaching_memory #(parameter IMEM_FILE="")(
    input logic clk, reset,
    input logic [31:0] imem_addr,
    output logic [31:0] imem_rdata,
    output logic [3:0] imem_fault,
    input logic dmem_valid, dmem_write,
    input logic [2:0] dmem_funct3,
    input logic [31:0] dmem_addr,dmem_wdata,
    output logic [31:0] dmem_rdata,
    output logic [3:0] dmem_fault,
    input logic [15:0] switches,
    output logic [15:0] leds
);
    timeunit 1ns; timeprecision 1ps;
    logic [31:0] imem [0:255], dmem [0:255];
    assign imem_fault=imem_addr[1:0]!=0 ? 4'd3 : (imem_addr>1020 ? 4'd4 : 4'd0);
    assign imem_rdata=imem_fault==0 ? imem[imem_addr[9:2]] : 32'b0;
    assign dmem_rdata=0;
    assign dmem_fault=0;
    assign leds=0;
    always @(posedge clk) if(!reset && dmem_valid)
        $fatal(1,"week-3 arithmetic must not request data memory");
endmodule
