module pc(
    input logic clk, reset, enable, 
    input logic [31:0] next_pc,
    output logic [31:0] value
);
    timeunit 1ns;
    timeprecision 1ps;
    
    // Week 2: synchronous reset has priority over enable; capture next_pc on posedge.
    
    always_ff @(posedge clk) begin
        if (reset) begin    
            value <= 32'd0;
        end
        else if (enable) begin
            value <= next_pc;
        end
    end       
        
endmodule
