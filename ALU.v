

`timescale 1ns / 1ps



`define AND 4'b0000
`define OR 4'b0001
`define ADD 4'b0010
`define SLL 4'b0011
`define SRL 4'b0100
`define SUB 4'b0110
`define SLT 4'b0111
`define ADDU 4'b1000
`define SUBU 4'b1001
`define XOR 4'b1010
`define SLTU 4'b1011
`define NOR 4'b1100
`define SRA 4'b1101
`define LUI 4'b1110

module ALU(BusW, Zero, BusA, BusB, ALUCtrl
    );
input wire [31:0] BusA, BusB;
output reg [31:0] BusW;
input wire [3:0] ALUCtrl ;
output wire Zero ;

wire less;
wire [63:0] Bus64;
assign Zero = ({BusW == 32'b0} ? 1'b1 : 1'b0);
assign less = ({1'b0,BusA} < {1'b0,BusB}  ? 1'b1 : 1'b0);

assign Bus64 = 0; //come back to this 

always@(*)begin	
	
	case (ALUCtrl)
	`AND:   BusW <= BusA & BusB;
	`OR:    BusW <= BusA | BusB;
	`ADD:   BusW <= BusA + BusB;
	`ADDU:  BusW <= BusA + BusB;
	`SLL:   BusW <= BusB << BusA;
	`SRL:   BusW <= BusB >> BusA;
	`SUB:   BusW <= BusA - BusB;
	`SUBU:  BusW <= BusA - BusB;
	`XOR:   BusW <= BusA ^ BusB;
	`NOR:   BusW <= ~(BusA | BusB);
	`SLT:   BusW <= ({$signed(BusA) < $signed(BusB)} ? 1'b1:1'b0);
	`SLTU:  BusW <= ({BusA < BusB} ? 1'b1:1'b0);
	`SRA:   BusW <= $signed(BusB) >>> BusA;
	`LUI:   BusW <= {BusB[15:0], 16'b0};
	default:BusW <= 0;
	endcase
end
endmodule