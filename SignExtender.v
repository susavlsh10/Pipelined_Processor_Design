`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2021 03:14:06 PM
// Design Name: 
// Module Name: SignExtender
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


module SignExtender(signExtImm, Immediate, signExtend);
    input [15:0] Immediate;
    input signExtend;
    output [31:0] signExtImm;
    
    wire [31:0] SignExtendI, Zero_ext_I;
    
    assign SignExtendI= {{16{Immediate[15]}}, Immediate}; //sign extended immediate 
    assign Zero_ext_I= {{16{1'b0}}, Immediate}; //zero exteded immediate 
    
    assign signExtImm= (signExtend==1'b1) ? SignExtendI : Zero_ext_I;
    

endmodule
