module board_tb;
timeunit 1ns; timeprecision 1ps;
logic clk=0,btnC=1;
logic [15:0] sw=0,led_single,led_pipeline;
basys3_top #(.PIPELINED(0),.IMEM_FILE("programs/boot.hex")) single_top
 (.clk(clk),.btnC(btnC),.sw(sw),.led(led_single));
basys3_top #(.PIPELINED(1),.IMEM_FILE("programs/boot.hex")) pipeline_top
 (.clk(clk),.btnC(btnC),.sw(sw),.led(led_pipeline));
always #5 clk=~clk;
task automatic pattern(input logic [15:0] value);
 @(negedge clk);sw=value;
 for(int n=0;n<200;n++) begin
  @(posedge clk);#1;
  if(n>=8 && led_single===value && led_pipeline===value) return;
 end
 $fatal(1,"switch pattern %04x did not reach LEDs: single=%04x pipeline=%04x",value,led_single,led_pipeline);
endtask
initial begin
 repeat(10) @(negedge clk);
 if(led_single!==0 || led_pipeline!==0) $fatal(1,"reset did not clear LEDs");
 btnC=0;
 pattern(16'h0001);pattern(16'h8000);pattern(16'ha55a);
 pattern(16'h5555);pattern(16'haaaa);pattern(16'hffff);pattern(16'h0000);
 @(negedge clk);btnC=1;sw=16'h1234;
 repeat(10) @(negedge clk);
 repeat(5) begin
  @(posedge clk);#1;
  if(led_single!==0 || led_pipeline!==0) $fatal(1,"write escaped active reset");
 end
 @(negedge clk);btnC=0;
 pattern(16'h1234);
 $display("PASS: board wrappers for both CPUs, seven switch patterns plus reset/restart");
 $finish;
end
initial begin #100000; $fatal(1,"board timeout"); end
endmodule
