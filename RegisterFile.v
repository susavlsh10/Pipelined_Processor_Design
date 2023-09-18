`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2021 11:22:25 PM
// Design Name: 
// Module Name: RegisterFile
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

module RegisterFile(BusA, BusB, BusW, RA, RB, RW, RegWr, Clk);
output reg [31:0] BusA, BusB;
input [31:0] BusW;
input [4:0]RA, RB, RW;
input RegWr, Clk;
    
    reg [31:0] Register[0:31]; //create 32 registers of 32 bits long 
    initial 
    begin
        Register[0]=32'b0; //store 0 on address 0
    end
    
    always @(*) //whenever RA or RB changes
    begin
        BusA<= Register[RA]; //update BusA
        BusB<= Register[RB]; //update BusB
    end
    
    always @(posedge Clk) //on the posetive edge of the clock
    begin
        //Register[0]<=32'b0;
        if (RegWr==1) //if write is enabled
            begin
                if(RW!=0) //only if write address is not 0
                    Register[RW]=BusW; //write to register
                     //update BusB
            end
            
    end
endmodule
