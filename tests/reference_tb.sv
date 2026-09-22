module checked_cpu #(parameter bit PIPELINED=0)(input logic clk, reset, output logic done);
timeunit 1ns; timeprecision 1ps;
import rv32_pkg::*;
logic [31:0] imem_addr;
logic [31:0] imem_rdata;
logic [3:0] imem_fault;
logic dmem_valid;
logic dmem_write;
logic [2:0] dmem_funct3;
logic [31:0] dmem_addr;
logic [31:0] dmem_wdata;
logic [31:0] dmem_rdata;
logic [3:0] dmem_fault;
logic halted;
logic retire_valid;
logic [31:0] retire_pc;
logic [31:0] retire_instr;
logic [31:0] retire_next_pc;
logic retire_rd_write;
logic [4:0] retire_rd;
logic [31:0] retire_rd_data;
logic retire_mem_valid;
logic retire_mem_write;
logic [2:0] retire_mem_funct3;
logic [31:0] retire_mem_addr;
logic [31:0] retire_mem_wdata;
logic [31:0] retire_mem_rdata;
logic [3:0] retire_fault;
logic stall;
logic redirect;
logic [31:0] debug_regs [0:31];
logic [15:0] leds;
generate
 if (PIPELINED) begin : gp
   cpu_pipeline dut (.clk(clk), .reset(reset), .imem_addr(imem_addr), .imem_rdata(imem_rdata), .imem_fault(imem_fault), .dmem_valid(dmem_valid), .dmem_write(dmem_write), .dmem_funct3(dmem_funct3), .dmem_addr(dmem_addr), .dmem_wdata(dmem_wdata), .dmem_rdata(dmem_rdata), .dmem_fault(dmem_fault), .halted(halted), .retire_valid(retire_valid), .retire_pc(retire_pc), .retire_instr(retire_instr), .retire_next_pc(retire_next_pc), .retire_rd_write(retire_rd_write), .retire_rd(retire_rd), .retire_rd_data(retire_rd_data), .retire_mem_valid(retire_mem_valid), .retire_mem_write(retire_mem_write), .retire_mem_funct3(retire_mem_funct3), .retire_mem_addr(retire_mem_addr), .retire_mem_wdata(retire_mem_wdata), .retire_mem_rdata(retire_mem_rdata), .retire_fault(retire_fault), .stall(stall), .redirect(redirect), .debug_regs(debug_regs),.debug_stage_valid(),.debug_stage_pc());
 end else begin : gs
   cpu_single dut (.clk(clk), .reset(reset), .imem_addr(imem_addr), .imem_rdata(imem_rdata), .imem_fault(imem_fault), .dmem_valid(dmem_valid), .dmem_write(dmem_write), .dmem_funct3(dmem_funct3), .dmem_addr(dmem_addr), .dmem_wdata(dmem_wdata), .dmem_rdata(dmem_rdata), .dmem_fault(dmem_fault), .halted(halted), .retire_valid(retire_valid), .retire_pc(retire_pc), .retire_instr(retire_instr), .retire_next_pc(retire_next_pc), .retire_rd_write(retire_rd_write), .retire_rd(retire_rd), .retire_rd_data(retire_rd_data), .retire_mem_valid(retire_mem_valid), .retire_mem_write(retire_mem_write), .retire_mem_funct3(retire_mem_funct3), .retire_mem_addr(retire_mem_addr), .retire_mem_wdata(retire_mem_wdata), .retire_mem_rdata(retire_mem_rdata), .retire_fault(retire_fault), .stall(stall), .redirect(redirect), .debug_regs(debug_regs));
 end
endgenerate
teaching_memory #(.IMEM_FILE("")) memory (
 .clk(clk),.reset(reset),.imem_addr(imem_addr),.imem_rdata(imem_rdata),.imem_fault(imem_fault),
 .dmem_valid(dmem_valid),.dmem_write(dmem_write),.dmem_funct3(dmem_funct3),
 .dmem_addr(dmem_addr),.dmem_wdata(dmem_wdata),.dmem_rdata(dmem_rdata),.dmem_fault(dmem_fault),
 .switches(16'ha55a),.leds(leds));
logic [31:0] expected_trace [0:25999];
logic [31:0] expected_stores [0:5999];
logic [31:0] expected_state [0:288];
string prefix;
integer expected_count, expected_store_count, expected_stalls;
integer index=0, store_index=0, stalls_seen=0, cycles=0;
bit ready=0;
initial begin
 done=0;
 if (!$value$plusargs("prefix=%s",prefix)) $fatal(1,"missing prefix");
 if (!$value$plusargs("count=%d",expected_count)) $fatal(1,"missing count");
 if (!$value$plusargs("stores=%d",expected_store_count)) $fatal(1,"missing stores");
 if (!$value$plusargs("stalls=%d",expected_stalls)) $fatal(1,"missing stalls");
 #1;
 $readmemh({prefix,".hex"},memory.imem);
 $readmemh({prefix,".data"},memory.dmem);
 $readmemh({prefix,".trace"},expected_trace,0,expected_count*13-1);
 $readmemh({prefix,".stores"},expected_stores,0,(expected_store_count>0?expected_store_count*3:3)-1);
 $readmemh({prefix,".state"},expected_state);
 ready=1;
end
task automatic equal(input string field, input logic [31:0] actual, expected);
 if(actual !== expected) $fatal(1,"core=%0d case=%s retire=%0d field=%s got=%08x expected=%08x",PIPELINED,prefix,index,field,actual,expected);
endtask
task automatic check_state;
 for(int n=0;n<32;n++) equal($sformatf("x%0d",n),debug_regs[n],expected_state[n]);
 for(int n=0;n<256;n++) equal($sformatf("RAM[%0d]",n),memory.dmem[n],expected_state[32+n]);
 equal("leds",{16'b0,leds},expected_state[288]);
endtask
task automatic check_reset;
 for(int n=0;n<32;n++) equal("reset register",debug_regs[n],0);
 for(int n=0;n<256;n++) equal("retained RAM",memory.dmem[n],expected_state[32+n]);
 equal("reset LEDs",{16'b0,leds},0);
 equal("reset halted",{31'b0,halted},0);
endtask
always @(posedge clk) begin
 if(ready && !reset && !done) begin
  cycles++;
  if(stall) stalls_seen++;
  if(dmem_valid && dmem_write && dmem_fault==FAULT_NONE) begin
   if(store_index>=expected_store_count) $fatal(1,"core=%0d extra physical store addr=%08x",PIPELINED,dmem_addr);
   equal("physical store address",dmem_addr,expected_stores[store_index*3]);
   equal("physical store data",dmem_wdata,expected_stores[store_index*3+1]);
   equal("physical store width",{29'b0,dmem_funct3},expected_stores[store_index*3+2]);
   store_index++;
  end
  #1;
  if(retire_valid) begin
   if(index>=expected_count) $fatal(1,"extra retirement");
   equal("pc",retire_pc,expected_trace[index*13]);
   equal("instruction",retire_instr,expected_trace[index*13+1]);
   equal("next_pc",retire_next_pc,expected_trace[index*13+2]);
   equal("rd_write",{31'b0,retire_rd_write},expected_trace[index*13+3]);
   equal("fault",{28'b0,retire_fault},expected_trace[index*13+12]);
   if(retire_rd_write) begin
    equal("rd",{27'b0,retire_rd},expected_trace[index*13+4]);
    equal("rd_data",retire_rd_data,expected_trace[index*13+5]);
   end
   begin
    equal("mem_valid",{31'b0,retire_mem_valid},expected_trace[index*13+6]);
    if(retire_mem_valid) begin
     equal("mem_write",{31'b0,retire_mem_write},expected_trace[index*13+7]);
     equal("mem_width",{29'b0,retire_mem_funct3},expected_trace[index*13+8]);
     equal("mem_address",retire_mem_addr,expected_trace[index*13+9]);
     if(retire_mem_write) equal("mem_data",retire_mem_wdata,expected_trace[index*13+10]);
     else if(retire_fault==FAULT_NONE) equal("load_data",retire_mem_rdata,expected_trace[index*13+11]);
    end
   end
   index++;
  end
  if(halted) begin
   if(index!=expected_count || store_index!=expected_store_count) $fatal(1,"incomplete trace/store stream");
   if(PIPELINED && expected_stalls>=0 && stalls_seen!=expected_stalls)
    $fatal(1,"case=%s stalls=%0d expected=%0d",prefix,stalls_seen,expected_stalls);
   check_state();
   done=1;
  end
 end
end
endmodule

module reference_tb;
timeunit 1ns; timeprecision 1ps;
logic clk=0,reset=1,done_single,done_pipeline;
string prefix,wave;
checked_cpu #(.PIPELINED(0)) single_core (clk,reset,done_single);
checked_cpu #(.PIPELINED(1)) pipeline_core (clk,reset,done_pipeline);
always #5 clk=~clk;
initial begin
 if($value$plusargs("wave=%s",wave)) begin
  $dumpfile(wave);$dumpvars(0,reference_tb);
 end
 if(!$value$plusargs("prefix=%s",prefix)) $fatal(1,"missing prefix");
 repeat(3) @(negedge clk);
 reset=0;
 wait(done_single && done_pipeline);
 repeat(2) begin
  @(posedge clk);#2;
  if(single_core.retire_valid || pipeline_core.retire_valid ||
     single_core.dmem_valid || pipeline_core.dmem_valid)
   $fatal(1,"activity after terminal halt");
 end
 @(negedge clk);reset=1;
 @(posedge clk);#2;
 single_core.check_reset();
 pipeline_core.check_reset();
 $display("PASS: %s single_cycles=%0d pipeline_cycles=%0d stalls=%0d",prefix,single_core.cycles,pipeline_core.cycles,pipeline_core.stalls_seen);
 $finish;
end
initial begin #100000; $fatal(1,"CPU timeout"); end
endmodule
