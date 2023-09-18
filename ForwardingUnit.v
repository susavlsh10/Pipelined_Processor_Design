`timescale 1ns / 1ps

module ForwardingUnit(UseShamt, UseImmed, ID_RD, ID_Rs, ID_Rt, EX_Rw, MEM_Rw, EX_RegWrite,  MEM_RegWrite, AluOPCtrlA, AluOPCtrlB, DataMemForwardCtrl_EX, DataMemForwardCtrl_MEM); 
input UseShamt, UseImmed;
input [4:0] ID_RD, ID_Rs, ID_Rt, EX_Rw, MEM_Rw; //ID_RD=current register destination
input EX_RegWrite, MEM_RegWrite;
output reg [1:0] AluOPCtrlA, AluOPCtrlB;
output reg DataMemForwardCtrl_EX, DataMemForwardCtrl_MEM;
    
//Select line for Mux of Input Bus A of ALU
always @(*) begin
    if ((UseShamt==1'b0) && (ID_RD != 5'b00000)) begin
        if((ID_Rs == MEM_Rw) && (MEM_Rw!= EX_Rw) && (MEM_RegWrite==1'b1)) begin
            //ALUOPCtrl_A=Select Data of Memory Stage to input of ALU BusA
            AluOPCtrlA<= 2'b11;
        end
        else if ((ID_Rs==EX_Rw) && (EX_RegWrite==1'b1)) begin
            //ALUOPCtrl_A=Select Data of Execute Stage to input of ALU BusA
            AluOPCtrlA<= 2'b10;
        end
        else begin 
            AluOPCtrlA<= 2'b00;
        end
    end
    else if (UseShamt==1'b1) begin
        //ALUOPCtrl_A=Select Shamt
        AluOPCtrlA<= 2'b01;
    end
    else begin
    //ALUOPCtrl_A=Select Normal Operation
        AluOPCtrlA<= 2'b00;
    end
  
end

//Select line for Mux of Input Bus B of ALU    
always @(*) begin
    if ((UseImmed==1'b0) && (ID_RD != 5'b00000)) begin
        if((ID_Rt == MEM_Rw) && (MEM_Rw!= EX_Rw) && (MEM_RegWrite==1'b1)) begin
            //ALUOPCtrl_B=Select Data of Memory Stage to input of ALU BusB
            AluOPCtrlB<= 2'b11;
        end
        else if ((ID_Rt==EX_Rw) && (EX_RegWrite==1'b1)) begin
            //ALUOPCtrl_B=Select Data of Execute Stage to input of ALU BusA
            AluOPCtrlB<= 2'b10;
        end
        else begin 
            AluOPCtrlB<= 2'b00;
        end
    end
    else if (UseImmed==1'b1) begin
        //ALUOPCtrl_B=Select Immed
        AluOPCtrlB<= 2'b01;
    end
    else begin
        //ALUOPCtrl_B=Select Normal Operation
        AluOPCtrlB<= 2'b00;
    end
  
end

//DataMemForwardCtrl

always @(*) begin
    
    if((MEM_RegWrite == 1'b1) && (ID_Rt == MEM_Rw)) begin
        DataMemForwardCtrl_EX=1'b1;
        DataMemForwardCtrl_MEM=1'b0;
    end
    else if ((EX_RegWrite==1'b1) && (ID_Rt == EX_Rw)) begin
        DataMemForwardCtrl_EX=1'b0;
        DataMemForwardCtrl_MEM=1'b1;    
    end
    else begin
        DataMemForwardCtrl_EX=1'b0;
        DataMemForwardCtrl_MEM=1'b0;    
    end

end
endmodule

