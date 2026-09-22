module controls_tb;
    timeunit 1ns; timeprecision 1ps;
    logic used=1, ex_valid=1, ex_write=1, ex_load=0, wb_valid=1, wb_write=1;
    logic [4:0] source=1, ex_rd=1, wb_rd=1;
    logic [31:0] captured=7, ex_value=11, wb_value=9, value;
    logic id_valid=1, load_valid=1, load_read=1, uses_rs1=1, uses_rs2=0;
    logic [4:0] load_rd=5, rs1=5, rs2=5;
    logic load_use;
    forwarding fwd(.*);
    hazard hz(.*);
    initial begin
        #1; if(value!==11) $fatal(1,"newest EX/MEM writer must win");
        ex_load=1; #1; if(value!==7) $fatal(1,"do not forward load address or stale older WB");
        ex_valid=0; #1; if(value!==9) $fatal(1,"MEM/WB forwarding");
        source=0; #1; if(value!==0) $fatal(1,"never forward into x0");
        source=1; used=0; #1; if(value!==0) $fatal(1,"unused source");
        if(!load_use) $fatal(1,"missing load-use interlock");
        uses_rs1=0; #1; if(load_use) $fatal(1,"false rs2 dependency");
        uses_rs2=1; #1; if(!load_use) $fatal(1,"store data dependency");
        load_rd=0; #1; if(load_use) $fatal(1,"x0 load dependency");
        load_rd=5; id_valid=0; #1; if(load_use) $fatal(1,"invalid ID dependency");
        $display("PASS: forwarding/hazard controls"); $finish;
    end
endmodule
