`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2021 05:36:05 PM
// Design Name: 
// Module Name: Mux3to1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Mux3to1(out, in1, in2, in3, sel);
    output reg [31:0] out;
    input [31:0] in1, in2, in3;
    input [1:0] sel;
    
    always@(in1 or in2 or in3 or sel) begin
        case(sel) 
            2'b00: out<= in1;
            2'b01: out<= in2;
            2'b10: out<= in3;           
        endcase
    end
    
endmodule
