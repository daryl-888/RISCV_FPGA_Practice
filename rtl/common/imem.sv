module imem #(parameter string IMAGE="programs/fetch.hex")(
    input logic [31:0] address,
    output logic [31:0] instruction,
    output logic access_fault, misaligned
);
    timeunit 1ns; 
    timeprecision 1ps;
    
    logic [31:0] words [0:255];
    
    initial begin
        for (int i=0; i<256; i++) begin
            words[i] = 32'h00000013;
        end
        
        $readmemh(IMAGE,words);

    end

    // Week 2: initialize NOPs, read IMAGE, check full byte address before [9:2].
    
    assign instruction =
        (misaligned || access_fault)
        ? 32'b0
        : words[address[9:2]];
    assign access_fault = (address >= 32'd1024);
    assign misaligned = (address[1:0] != 2'b00);
endmodule
