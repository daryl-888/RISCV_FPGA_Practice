// A final-state-only test could accidentally accept a one-cycle CPU. This cannot.
module pipeline_depth_tb;
    timeunit 1ns; timeprecision 1ps;
    logic clk=0, reset=1;
    logic [31:0] imem_addr, imem_rdata;
    logic retire_valid;
    logic [31:0] retire_pc;
    logic [3:0] debug_stage_valid;
    logic [31:0] debug_stage_pc [0:3], debug_regs [0:31];
    always #5 clk=~clk;
    always_comb begin
        case(imem_addr)
            0: imem_rdata=32'h00100093; // addi x1,x0,1
            4: imem_rdata=32'h00200113;
            8: imem_rdata=32'h00300193;
            12: imem_rdata=32'h00400213;
            default: imem_rdata=32'h00000013;
        endcase
    end
    cpu_pipeline dut(
        .clk(clk),.reset(reset),.imem_addr(imem_addr),.imem_rdata(imem_rdata),.imem_fault(4'b0),
        .dmem_valid(),.dmem_write(),.dmem_funct3(),.dmem_addr(),.dmem_wdata(),
        .dmem_rdata(32'b0),.dmem_fault(4'b0),.halted(),.retire_valid(retire_valid),
        .retire_pc(retire_pc),.retire_instr(),.retire_next_pc(),.retire_rd_write(),
        .retire_rd(),.retire_rd_data(),.retire_mem_valid(),.retire_mem_write(),
        .retire_mem_funct3(),.retire_mem_addr(),.retire_mem_wdata(),.retire_mem_rdata(),
        .retire_fault(),.stall(),.redirect(),.debug_regs(debug_regs),
        .debug_stage_valid(debug_stage_valid),.debug_stage_pc(debug_stage_pc));
    initial begin
        $dumpfile("build/waves/five_stages.vcd"); $dumpvars(0,pipeline_depth_tb);
        repeat(3) @(negedge clk); reset=0;
        for(int cycle=1;cycle<=8;cycle++) begin
            @(posedge clk); #1;
            for(int stage=0;stage<4;stage++) begin
                if(debug_stage_valid[stage] !== (cycle>stage))
                    $fatal(1,"boundary %0d wrong valid at edge %0d",stage,cycle);
                if(cycle>stage && debug_stage_pc[stage] !== 32'((cycle-stage-1)*4))
                    $fatal(1,"boundary %0d did not carry matching PC at edge %0d",stage,cycle);
            end
            if(retire_valid !== (cycle>=5)) $fatal(1,"first retirement must be at edge FIVE");
            if(cycle>=5 && retire_pc !== 32'((cycle-5)*4)) $fatal(1,"one retirement per edge after fill");
        end
        if(debug_regs[1]!==1 || debug_regs[2]!==2 || debug_regs[3]!==3 || debug_regs[4]!==4)
            $fatal(1,"independent pipeline results");
        $display("PASS: IF/ID/EX/MEM/WB overlap, four boundaries, first retirement edge 5"); $finish;
    end
    initial begin #1000; $fatal(1,"pipeline-depth timeout"); end
endmodule
