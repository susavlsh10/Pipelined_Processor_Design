`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/01/2021 01:50:42 PM
// Design Name: 
// Module Name: DataMemory
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


module DataMemory(ReadData, Address, WriteData, MemoryRead, MemoryWrite, Clock);
output reg [31:0] ReadData;
input [5:0] Address;
input [31:0]WriteData;
input MemoryRead, MemoryWrite, Clock;

    reg [31:0] Memory[0:63]; //256 bytes of memory
    
    always @(posedge Clock)
        begin
        if (MemoryRead==1) //rising edge, read
            ReadData=Memory[Address];
    end
    
    always@(negedge Clock)
    begin
        if (MemoryWrite==1) //falling edge, write
            Memory[Address]= WriteData;
    end
    
endmodule
