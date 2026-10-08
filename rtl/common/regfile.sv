module regfile #(parameter bit BYPASS=0)(
    input logic clk, reset, write_en,
    input logic [4:0] ra, rb, rd,
    input logic [31:0] write_data,
    output logic [31:0] a, b,
    output logic [31:0] debug_regs [0:31]
);
    timeunit 1ns; 
    timeprecision 1ps;
    // Week 2: two asynchronous reads, one rising-edge write, synchronous reset.
    // x0 is always zero. Week 6: when BYPASS=1, forward this edge's write to reads.
    // Implement storage here; these safe ties are deliberately incomplete.
    logic [31:0] regs [0:31];
    
    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < 32; i++) begin
                regs[i] <= 32'b0;
            end
        end
        else if (write_en && rd != 5'd0) begin
            regs[rd] <= write_data;
        end
    end
    
    assign a= (BYPASS && write_en && rd != 5'd0 && rd == ra)
        ? write_data
        : regs[ra];

    assign b= (BYPASS && write_en && rd != 5'd0 && rd == rb)
        ? write_data
        : regs[rb];
    
    for(genvar n=0;n<32;n++) begin : mirror
        assign debug_regs[n]= regs[n];
    end
endmodule
