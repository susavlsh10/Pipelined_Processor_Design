`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:42:15 04/01/2008 
// Design Name: 
// Module Name:    Pipelined 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module PipelinedProc(CLK, Reset_L, startPC, dMemOut);
	input CLK;
	input Reset_L;
	input [31:0] startPC;
	output [31:0] dMemOut;


	//Hazard
	wire Bubble;
	wire PCWrite;
	wire IFWrite;
	
	//Stage 1
	wire	[31:0]	currentPCPlus4;
	wire	[31:0]	jumpDescisionTarget;
	wire	[31:0]	nextPC;
	reg	[31:0]	currentPC;
	wire	[31:0]	currentInstruction;
	
	//Stage 2
	reg	[31:0]	currentInstruction2;
	wire	[5:0]	opcode;
	wire	[4:0]	rs, rt, rd;
	wire	[15:0]	imm16;
	wire	[4:0]	shamt;
	wire	[5:0]	func;
	wire	[31:0]	busA, busB, ALUImmRegChoice, signExtImm;
	wire	[31:0]	jumpTarget;
	
	//Stage 2 Control Wires
	wire	regDst, aluSrc, memToReg, regWrite, memRead, memWrite, branch, jump, signExtend;
	wire	UseShiftField;
	wire	rsUsed, rtUsed;
	wire	[4:0]	rw;
	wire	[3:0]	aluOp;
	wire	[31:0]	ALUBIn;
	wire	[31:0]	ALUAIn;
	//---Data Forwarding unit signals---
	wire UseShamt;
	wire DataMemForwardCtrl_EX, DataMemForwardCtrl_MEM;
	wire [1:0] AluOPCtrlA, AluOPCtrlB;
	//--Hazard signals---
	wire [1:0]addrSel;
	
	
	//Stage 3
	reg	[31:0]	ALUAIn3, ALUBIn3, busA3, busB3, signExtImm3;
	reg	[4:0]	rw3;
	wire [31:0] ALU3inA, ALU3inB;
	wire	[5:0]	func3;
	wire	[31:0]	shiftedSignExtImm;
	wire	[31:0]	branchDst;
	wire	[3:0]	aluCtrl;
	wire	aluZero;
	wire	[31:0]	aluOut;
	wire [31:0] Datain3; //Muxout busB vs MemForward
	
	//Stage 3 Control
	reg	regDst3, memToReg3, regWrite3, memRead3, memWrite3, branch3;
	reg	[3:0]	aluOp3;
	reg	[4:0]	shamt3;
	//stage 3 forwarding control
	reg [1:0] AluOPCtrlA3, AluOPCtrlB3;
	reg DataMemForwardCtrl_EX3, DataMemForwardCtrl_MEM3;
	
	//Stage 4
	reg	aluZero4;
	reg	[31:0]	branchDst4, aluOut4, busB4;
	reg	[4:0]	rw4;
	wire	[31:0]	memOut;
	
	assign dMemOut = memOut;
	
	//Stage 4 Control
	reg memToReg4, regWrite4, memRead4, memWrite4, branch4;
	//forwarding control
	reg DataMemForwardCtrl_MEM4;
	//Stage 5
	reg	[31:0]	memOut5, aluOut5;
	reg	[4:0]	rw5;
	wire	[31:0]	regWriteData;
	wire [31:0] Datain4;
	//Stage 5 Control
	reg memToReg5, regWrite5;
	
	//Test this, if not use addrSel and 3 to 1 Mux 
	
	Mux3to1 nextAddr(nextPC, currentPCPlus4, jumpTarget, branchDst, addrSel);
	
	//assign #1 jumpDescisionTarget = (jump & ~IFWrite) ? jumpTarget : currentPCPlus4;
	//assign #1 nextPC = (branch4 & aluZero4 & ~IFWrite) ? branchDst4 : jumpDescisionTarget;
	
	always @ (negedge CLK) begin
		if(~Reset_L)
			currentPC = startPC;
		else if(PCWrite)
			currentPC = nextPC;
	end
	assign #2 currentPCPlus4 = currentPC + 4;
	InstructionMemory instrMemory(currentInstruction, currentPC);
	
	//Stage 2 Logic
	always @ (negedge CLK or negedge Reset_L) begin
		if(~Reset_L)
			currentInstruction2 = 32'b0;
		else if(IFWrite) begin
			currentInstruction2 = currentInstruction;
		end
	end
	assign {opcode, rs, rt, rd, shamt, func} = currentInstruction2;
	assign imm16 = currentInstruction2[15:0];
	
	PipelinedControl controller(regDst, aluSrc, memToReg, regWrite, memRead, memWrite, branch, jump, signExtend, aluOp, UseShamt, opcode,func, Bubble);
	
	assign #1 rw = regDst ? rd : rt;
	assign #2 UseShiftField = ((aluOp == 4'b1111) && ((func == 6'b000000) || (func == 6'b000010) || (func == 6'b000011)));
	assign #2 rsUsed = (opcode != 6'b001111/*LUI*/) & ~UseShiftField;
	assign #1 rtUsed = (opcode == 6'b0) || branch || (opcode == 6'b101011/*SW*/);
	Hazard hazard(PCWrite, IFWrite, Bubble,addrSel, branch, aluZero, jump, memRead3, UseShamt, aluSrc,
				regWrite ? rw : 5'b0,
				rsUsed ? rs : 5'b0,
				rtUsed ? rt : 5'b0,
				Reset_L, CLK);
	
	RegisterFile Registers(busA, busB, regWriteData, rs, rt, rw5, regWrite5, CLK);
	SignExtender immExt(signExtImm, imm16, signExtend);
	assign jumpTarget = {currentPC[31:28], currentInstruction2[25:0], 2'b00};

	assign #2 ALUBIn = aluSrc ? signExtImm : busB;
	assign #2 ALUAIn = UseShiftField ? {27'b0, shamt} : busA;
	
	//assign #2 ALUBIn = UseShiftField ?  busB : ALUImmRegChoice;
	
	//original
	/*
	assign #2 ALUImmRegChoice = aluSrc ? signExtImm : busB;
	assign #2 ALUAIn = UseShiftField ? busB : busA;
	assign #2 ALUBIn = UseShiftField ? {27'b0, shamt} : ALUImmRegChoice;
	*/
	
	//assign #2 ALUAIn = 
	
	ForwardingUnit forward(.UseShamt(UseShamt), .UseImmed(aluSrc), .ID_RD(rd), .ID_Rs(rs), .ID_Rt(rt), .EX_Rw(rw3), .MEM_Rw(rw4),
	                .EX_RegWrite(regWrite3),  .MEM_RegWrite(regWrite4), .AluOPCtrlA(AluOPCtrlA), .AluOPCtrlB(AluOPCtrlB),
	                 .DataMemForwardCtrl_EX(DataMemForwardCtrl_EX), .DataMemForwardCtrl_MEM(DataMemForwardCtrl_MEM));
	
	//Stage 3 Logic
	always @ (negedge CLK or negedge Reset_L) begin
		if(~Reset_L) begin
			ALUAIn3 <= 0;
			ALUBIn3 <= 0;
			busA3 <= 0;
			busB3 <= 0;
			shamt3<=0;
			signExtImm3 <= 0;
			rw3 <= 0;
			regDst3 <= 0;
			memToReg3 <= 0;
			regWrite3 <= 0;
			memRead3 <= 0;
			memWrite3 <= 0;
			branch3 <= 0;
			aluOp3 <= 0;
			AluOPCtrlA3<=0;
			AluOPCtrlB3<=0;
	        DataMemForwardCtrl_EX3<=0;
	        DataMemForwardCtrl_MEM3<=0;
		end
		else if(Bubble) begin
			ALUAIn3 <= 0;
			ALUBIn3 <= 0;
			busA3 <= 0;
			busB3 <= 0;
			shamt3<=0;
			signExtImm3 <= 0;
			rw3 <= 0;
			regDst3 <= 0;
			memToReg3 <= 0;
			regWrite3 <= 0;
			memRead3 <= 0;
			memWrite3 <= 0;
			branch3 <= 0;
			aluOp3 <= 0;
			AluOPCtrlA3<=0;
			AluOPCtrlB3<=0;
	        DataMemForwardCtrl_EX3<=0;
	        DataMemForwardCtrl_MEM3<=0;
		end
		else begin
			ALUAIn3 <= ALUAIn;
			ALUBIn3 <= ALUBIn;
			busA3 <= busA;
			busB3 <= busB;
			shamt3<=shamt;
			signExtImm3 <= signExtImm;
			rw3 <= rw;
			regDst3 <= regDst;
			memToReg3 <= memToReg;
			regWrite3 <= regWrite;
			memRead3 <= memRead;
			memWrite3 <= memWrite;
			branch3 <= branch;
			aluOp3 <= aluOp;
			AluOPCtrlA3<=AluOPCtrlA;
			AluOPCtrlB3<=AluOPCtrlB;
	        DataMemForwardCtrl_EX3<=DataMemForwardCtrl_EX;
	        DataMemForwardCtrl_MEM3<=DataMemForwardCtrl_MEM;
		end
	end
	
	assign func3 = signExtImm3[5:0];
	ALUControl mainALUControl(aluCtrl, aluOp3, func3);
	
	//Using mux to select correct forwarded A
	Mux4to1 muxA(.out(ALU3inA), .in1(busA3), .in2({27'b0,shamt3}), .in3(aluOut4), .in4(regWriteData), .sel(AluOPCtrlA3)); 
	
	//Using mux to select correct forwarded B
	Mux4to1 muxB(.out(ALU3inB), .in1(busB3), .in2(signExtImm3), .in3(aluOut4), .in4(regWriteData), .sel(AluOPCtrlB3));
	
	
	ALU mainALU(aluOut, aluZero, ALU3inA, ALU3inB, aluCtrl);

	assign shiftedSignExtImm = {signExtImm3[29:0], 2'b0};
	assign #2 branchDst = currentPC + shiftedSignExtImm;
    
    assign #2 Datain3= (DataMemForwardCtrl_EX3)? regWriteData: busB3;
    
	//Stage 4 Logic
	always @ (negedge CLK or negedge Reset_L) begin
		if(~Reset_L) begin
			aluZero4 <= 0;
			branchDst4 <= 0;
			aluOut4 <= 0;
			busB4 <= 0;
			rw4 <= 0;
			memToReg4 <= 0;
			regWrite4 <= 0;
			memRead4 <= 0;
			memWrite4 <= 0;
			branch4 <= 0;
			DataMemForwardCtrl_MEM4 <=0;
		end
		else begin
			aluZero4 <= aluZero;
			branchDst4 <= branchDst;
			aluOut4 <= aluOut;
			busB4 <= Datain3;
			rw4 <= rw3;
			memToReg4 <= memToReg3;
			regWrite4 <= regWrite3;
			memRead4 <= memRead3;
			memWrite4 <= memWrite3;
			branch4 <= branch3;
			DataMemForwardCtrl_MEM4 <=DataMemForwardCtrl_MEM3;
		end
	end
	assign Datain4= (DataMemForwardCtrl_MEM4)? regWriteData: busB4;
	DataMemory dmem(memOut, aluOut4[5:0], Datain4, memRead4, memWrite4, CLK);
	
	//Stage 5 Logic
	always @ (negedge CLK or negedge Reset_L) begin
		if(~Reset_L) begin
			memOut5 <= 0;
			aluOut5 <= 0;
			rw5 <= 0;
			memToReg5 <= 0;
			regWrite5 <= 0;
		end
		else begin
			memOut5 <= memOut;
			aluOut5 <= aluOut4;
			rw5 <= rw4;
			memToReg5 <= memToReg4;
			regWrite5 <= regWrite4;
		end
	end
	assign #1 regWriteData = memToReg5 ? memOut5 : aluOut5;

endmodule
