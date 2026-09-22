module regfile_tb;
    timeunit 1ns; timeprecision 1ps;
    logic clk, reset, write_en;
    initial begin clk = 0; reset = 1; write_en = 0; end
    logic [4:0] ra, rb, rd;
    initial begin ra = 0; rb = 0; rd = 0; end
    logic [31:0] write_data, a, b;
    initial begin write_data = 0; end
    logic [31:0] debug_regs [0:31];
    regfile #(.BYPASS(1)) dut(.*);
    always #5 clk=~clk;
    initial begin
        @(posedge clk); @(negedge clk); reset=0; ra=1; rb=2;
        #1; if(a!==0 || b!==0) $fatal(1,"register reset");
        write_en=1; rd=1; write_data=32'h12345678;
        #1; if(a!==32'h12345678) $fatal(1,"WB-to-ID bypass");
        @(posedge clk); #1; write_en=0;
        #1; if(a!==32'h12345678 || debug_regs[1]!==a) $fatal(1,"edge write");
        @(negedge clk); ra=0; rd=0; write_en=1; write_data=99;
        @(posedge clk); #1;
        if(a!==0 || debug_regs[0]!==0) $fatal(1,"x0 write accepted");
        @(negedge clk); reset=1; rd=2;
        @(posedge clk); #1;
        if(debug_regs[1]!==0 || debug_regs[2]!==0) $fatal(1,"reset priority");
        $display("PASS: register file/reset/x0/WB bypass"); $finish;
    end
    initial begin #500; $fatal(1,"register-file timeout"); end
endmodule
