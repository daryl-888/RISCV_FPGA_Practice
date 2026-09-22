module fetch_tb;
    timeunit 1ns; timeprecision 1ps;
    logic clk;
    initial begin clk = 0; end
    logic reset, enable, probe;
    initial begin reset = 1; enable = 1; probe = 0; end
    logic [31:0] value, next_pc, address, instruction;
    logic [31:0] probe_address;
    initial begin probe_address = 0; end
    logic access_fault, misaligned;
    assign next_pc = value + 32'd4;
    assign address = probe ? probe_address : value;
    pc pc_u (.clk, .reset, .enable, .next_pc, .value);
    imem imem_u (.address, .instruction, .access_fault, .misaligned);
    always #5 clk <= ~clk;

    task automatic check_fetch(input logic [31:0] p, word_value);
        if (value !== p || instruction !== word_value ||
            access_fault !== 1'b0 || misaligned !== 1'b0)
            $fatal(1, "fetch: PC=%h instruction=%h expected=%h/%h",
                   value, instruction, p, word_value);
    endtask

    initial begin
        $dumpfile("build/waves/fetch.vcd");
        $dumpvars(0, fetch_tb);
        repeat (2) begin
            @(posedge clk); #1;
            check_fetch(32'h0, 32'h00500093);
        end
        @(negedge clk); reset = 0;
        #1; check_fetch(32'h0, 32'h00500093);
        @(posedge clk); #1; check_fetch(32'h4, 32'h00700113);
        @(posedge clk); #1; check_fetch(32'h8, 32'h002081b3);
        @(negedge clk); enable = 0;
        repeat (2) begin
            @(posedge clk); #1; check_fetch(32'h8, 32'h002081b3);
        end
        // Reset must work even while enable is zero.
        @(negedge clk); reset = 1;
        repeat (2) begin
            @(posedge clk); #1; check_fetch(32'h0, 32'h00500093);
        end
        @(negedge clk); reset = 0; probe = 1;
        probe_address = 32'h3fc; #1;
        if (instruction !== 32'h00000013 || access_fault || misaligned)
            $fatal(1, "last ROM word");
        probe_address = 32'h400; #1;
        if (!access_fault || misaligned || instruction !== 32'b0)
            $fatal(1, "out-of-range ROM must not wrap");
        probe_address = 32'h2; #1;
        if (!misaligned || access_fault || instruction !== 32'b0)
            $fatal(1, "misaligned fetch");
        $display("PASS fetch/reset/hold/bounds");
        $finish;
    end
    initial begin
        #500;
        $fatal(1, "fetch watchdog");
    end
endmodule
