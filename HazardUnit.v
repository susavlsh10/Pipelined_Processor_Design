`timescale 1ns / 1ps


module Hazard(PCWrite, IFWrite, Bubble, addrSel, Branch, ALUZero4, Jump, memReadEX, UseShamt, UseImmed, rw, rs, rt, Reset_L, CLK);
	input			Branch;
	input			ALUZero4;
	input			Jump;
	input           memReadEX;
	input           UseShamt, UseImmed;
	input	[4:0]	rw;
	input	[4:0]	rs;
	input	[4:0]	rt;
	input			Reset_L;
	input			CLK;
	output reg		PCWrite;
	output reg		IFWrite;
	output reg		Bubble;
    output reg [1:0]addrSel;
    
	/*state definition for FSM*/
    parameter NoHazard_state= 3'b000,
              Bubble0_state = 3'b001,
              Bubble1_state = 3'b010,
              Jump_state    = 3'b011,
              Branch0_state = 3'b100,
              Branch1_state = 3'b101;
				/*Define a name for each of the states so it is easier to debug and follow*/ 
				 
	
	/*internal signals*/
	wire cmp1;
	
	/*internal state*/
	reg [2:0] FSM_state, FSM_nxt_state;
	reg [4:0] rw1; //rw history registers
	reg LdHazard;
	/*create compare logic*/
	assign  cmp1 = (((rs==rw1)||(rt==rw1))&&(rw1!= 0)) ? 1:0;
	/* cmp1 finds the dependancy btween current instruction and theonebefore make cmpx if needed
    
	/*keep track of rw*/
	//LdHazard logic
	always @(*) begin
	   if ((cmp1==1'b1) && (memReadEX==1'b1) && (UseShamt==1'b0) && (UseImmed==1'b0))
	       LdHazard<=1'b1;
       else if ((UseShamt==1'b1) && (rt==rw1) && (memReadEX==1'b1))
           LdHazard<=1'b1;
       else if ((UseImmed==1'b1) && (rt==rw1) && (memReadEX==1'b1))
           LdHazard<=1'b1;
       else
           LdHazard<=1'b0; 
	end
	
	always @(negedge CLK) begin
		if(Reset_L ==  0) begin
			rw1 <=  0;
			//LdHazard<=1'b0;
			//add here
		end
		else begin
			rw1 <= Bubble?0:rw;//insert bubble if needed
			//add here
		end
	end
	
		
	/*FSM state register*/
	always @(negedge CLK) begin
		if(Reset_L == 0) 
			FSM_state <= 0;
		else
			FSM_state <= FSM_nxt_state;
	end  
	
	/*FSM next state and output logic*/
	always @(*) begin //combinatory logic
		case(FSM_state)
			NoHazard_state: begin 
				
				if(Jump== 1'b1) begin //prioritize jump
                    FSM_nxt_state <= #2 Jump_state;
                    PCWrite <= #2 1'b1; //fetch a new inst
				    IFWrite <= #2 1'b0; //stall the decode stage
				    Bubble  <= #2 1'b0;
				    addrSel <= #2 2'b01; //jump
					/* Provde the value of FSM_nxt_state and outputs 				    			(PCWrite,IFWrite,Buble)*/ 
				end 
				else if(LdHazard== 1'b1) begin //3-delay data hazard
					//uncondition return to no hazard state
					/* Provde the value of FSM_nxt_state and outputs 				    			(PCWrite,IFWrite,Buble)*/ 
                    FSM_nxt_state <= #2 Bubble0_state;	
                    PCWrite <= #2 1'b0; //stall
                    IFWrite <= #2 1'b0; //stall
                    Bubble  <= #2 1'b1; //check this
                    addrSel <= #2 2'b00; //default
				end
				else if (Branch==1'b1) begin //branch operation
                    FSM_nxt_state <= #2 Branch0_state;
                    PCWrite <= #2 1'b0; //stall the fetch stage	
                    IFWrite <= #2 1'b1;
				    Bubble  <= #2 1'b0;
				    addrSel <= #2 2'b00;                  
				end
				else begin //normal operation
                    FSM_nxt_state <= #2 NoHazard_state;
                    PCWrite <= #2 1'b1;
                    IFWrite <= #2 1'b1;
                    Bubble  <= #2 1'b0;	
                    addrSel <= #2 2'b00;			
				end
				//add here
				/* Complite the "NoHazard_state" state as needed*/
			end
			Bubble0_state: begin
                FSM_nxt_state <= #2 NoHazard_state;
                PCWrite <= #2 1'b1; //normal
                IFWrite <= #2 1'b1; //normal 
                Bubble  <= #2 1'b0; //normal 
                addrSel <= #2 2'b00; //default			
			//uncondition return to no hazard state
			/* Provde the value of FSM_nxt_state and outputs 				    			(PCWrite,IFWrite,Buble)*/ 
			end
			
			Jump_state: begin
			    FSM_nxt_state <= #2 NoHazard_state;
                PCWrite <= #2 1'b1;
                IFWrite <= #2 1'b1; //
                Bubble  <= #2 1'b0;
                addrSel <= #2 2'b00; //jump
			end
			
			Branch0_state: begin
                FSM_nxt_state <= #2 NoHazard_state;
                PCWrite <= #2 1'b1; //stall the fetch stage
                IFWrite <= #2 1'b1; //allow the branch inst to continue
                Bubble  <= #2 1'b0;        
                if (ALUZero4==1'b1) begin
                    addrSel <= #2 2'b10; //branch	
                end
                else begin
                    addrSel <= #2 2'b00; //default PC+4
                end				 
			end
			
			default: begin
				FSM_nxt_state <= #2 NoHazard_state;
				PCWrite <= #2 1'b1;
				IFWrite <= #2 1'b1;
				Bubble  <= #2 1'b0;
				addrSel <= #2 2'b00;
			end
		endcase
	end
endmodule


