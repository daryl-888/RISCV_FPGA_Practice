module single_tb;
    timeunit 1ns; timeprecision 1ps;
    logic clk, reset, done;
    initial begin clk = 0; reset = 1; end
    checked_cpu #(.PIPELINED(0)) core(clk,reset,done);
    always #5 clk=~clk;
    initial begin
        repeat(3) @(negedge clk); reset=0;
        wait(done);
        repeat(2) begin
            @(posedge clk); #2;
            if(core.retire_valid || core.dmem_valid) $fatal(1,"activity after halt");
        end
        @(negedge clk); reset=1;
        @(posedge clk); #2; core.check_reset();
        $display("PASS: single-cycle trace, final state and reset"); $finish;
    end
    initial begin #100000; $fatal(1,"single-cycle timeout"); end
endmodule
