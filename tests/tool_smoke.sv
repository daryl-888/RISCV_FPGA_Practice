// Infrastructure check: deliberately independent of the learner's RTL.
module tool_smoke;
    timeunit 1ns; timeprecision 1ps;
    logic clk = 0, reset = 1;
    logic [3:0] count;
    always #5 clk = ~clk;
    always_ff @(posedge clk) begin
        if (reset) count <= 0;
        else count <= count + 1'b1;
    end
    initial begin
        $dumpfile("build/waves/tool_smoke.vcd");
        $dumpvars(0, tool_smoke);
        @(negedge clk); reset = 0;
        repeat (3) @(posedge clk);
        #1;
        assert(count == 3) else $fatal(1, "timing/nonblocking smoke test failed");
        if ($test$plusargs("fail")) $fatal(1, "deliberate smoke failure");
        $display("PASS: tool smoke (timing, assertions, C++ build and VCD)");
        $finish;
    end
    initial begin #200; $fatal(1, "smoke timeout"); end
endmodule
