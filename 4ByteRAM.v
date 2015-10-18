module Decoder74LS139(S0, S1, En, A0, A1, A2, A3);

	input S0, S1, En;	//S1 is MSB and S0 is LSB , Enable En is active LOW
	output A0, A1, A2, A3;
	
	wire v0, v1, v2, v3;
	
	assign v0 = (~S1) & (~S0);	
	assign v1 = (~S1) & S0;
	assign v2 = S1 & (~S0);
	assign v3 = S1 & S0;

	assign A0 = ~v0 | En;	//taking or with En so that when En is high (disabled) all outputs are high
	assign A1 = ~v1 | En;
	assign A2 = ~v2 | En;
	assign A3 = ~v3 | En;
	
endmodule

module dff(q,d,clk,reset);

	input d,clk,reset;    //reset is active LOW
	output q;
	reg q;
  	
	always@(posedge clk)	//Positive edge triggered DFF
		q <= d;

	always@(~reset)    //active LOW reset
		q <= 1'b0;
		
endmodule

module QuadDFF74LS175(D0, D1, D2, D3, Q0, Q1, Q2, Q3, Reset, Clk);

	input D0, D1, D2, D3, Clk, Reset;	//Reset is active LOW
	output Q0, Q1, Q2, Q3;
	
	dff DFF0(Q0, D0, Clk, Reset);
	dff DFF1(Q1, D1, Clk, Reset);
	dff DFF2(Q2, D2, Clk, Reset);
	dff DFF3(Q3, D3, Clk, Reset);
	
endmodule
	
module mux(a0, a1, a2, a3, O, s0, s1, E);
	
	input a0, a1, a2, a3, s0, s1, E;	//s1 is MSB and s0 is LSB , Enable E is active LOW
	output O;
	
	wire t0, t1, t2, t3;
	
	assign t0 = a0 & (~s1) & (~s0) & (~E);
	assign t1 = a1 & (~s1) & (s0) & (~E);
	assign t2 = a2 & (s1) & (~s0) & (~E);
	assign t3 = a3 & (s1) & (s0) & (~E);
	
	assign O = t0 | t1 | t2 | t3;
	
endmodule

module MUX74HC153(A0, A1, A2, A3, o1, A4, A5, A6, A7, o2, S0, S1, E1, E2);

	input A0, A1, A2, A3, A4, A5, A6, A7, S0, S1, E1, E2;	//s1 is MsB and s0 is LSB , enable E1 and E2 are active LOW
	output o1, o2;
	
	mux MUX1(A0, A1, A2, A3, o1, S0, S1, E1);
	mux MUX2(A4, A5, A6, A7, o2, S0, S1, E2);
	
endmodule

module Circuit(I0, I1, I2, I3, I4, I5, I6, I7, O0, O1, O2, O3, O4, O5, O6, O7, Select0, Select1, Read, Clear);

	input I0, I1, I2, I3, I4, I5, I6, I7, Select0, Select1, Read, Clear;
	output O0, O1, O2, O3, O4, O5, O6, O7;
	
	wire w0, w1, w2, w3; 
	wire q0, q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, q12, q13, q14, q15;
	wire q16, q17, q18, q19, q20, q21, q22, q23, q24, q25, q26, q27, q28, q29, q30, q31;
		
	Decoder74LS139 Decoder0(Select0, Select1, Read, w0, w1, w2, w3);
	
	QuadDFF74LS175 DFFIC0(I0, I1, I2, I3, q0, q1, q2, q3, Clear, ~w0);
	QuadDFF74LS175 DFFIC1(I0, I1, I2, I3, q4, q5, q6, q7, Clear, ~w1);
	QuadDFF74LS175 DFFIC2(I0, I1, I2, I3, q8, q9, q10, q11, Clear, ~w2);
	QuadDFF74LS175 DFFIC3(I0, I1, I2, I3, q12, q13, q14, q15, Clear, ~w3);
	
	QuadDFF74LS175 DFFIC4(I4, I5, I6, I7, q16, q17, q18, q19, Clear, ~w0);
	QuadDFF74LS175 DFFIC5(I4, I5, I6, I7, q20, q21, q22, q23, Clear, ~w1);
	QuadDFF74LS175 DFFIC6(I4, I5, I6, I7, q24, q25, q26, q27, Clear, ~w2);
	QuadDFF74LS175 DFFIC7(I4, I5, I6, I7, q28, q29, q30, q31, Clear, ~w3);
	
	MUX74HC153 MUXIC0(q0, q4, q8, q12, O0, q16, q20, q24, q28, O4, Select0, Select1, ~Read, ~Read);
	MUX74HC153 MUXIC1(q1, q5, q9, q13, O1, q17, q21, q25, q29, O5, Select0, Select1, ~Read, ~Read);
	MUX74HC153 MUXIC2(q2, q6, q10, q14, O2, q18, q22, q26, q30, O6, Select0, Select1, ~Read, ~Read);
	MUX74HC153 MUXIC3(q3, q7, q11, q15, O3, q19, q23, q27, q31, O7, Select0, Select1, ~Read, ~Read);
	
endmodule

module test_bench;

	reg [7:0] i;	//Input variable
	wire [7:0] o;	//Output variable
	reg [1:0] select;
	reg read, clear;	
	
	Circuit C1(i[0], i[1], i[2], i[3], i[4], i[5], i[6], i[7], o[0], o[1], o[2], o[3], o[4], o[5], o[6], o[7], select[0], select[1], read, clear);
	
	initial 
		begin
			
			/*
				Sequence of operations:
				1 - erase memory by setting clear as LOW (active LOW reset for DFFs)
				2 - once memory is erased, clear can be set back to HIGH for data storage
				3 - perform READ operation and read all 32 bits. Result should be 0 for all since memory was cleared.
				4 - Set circuit to WRITE mode and write in some data
				5 - perform READ operation to verify that data was written
				6 - erase memory
				7 - perform READ operation to verify that memory was wiped
			*/
			
				i = 8'b11001010;	//some random input state which won't be stored
			
				clear = 1'b0;	//active LOW reset for all DFFs to clear memory
			#10 clear = 1'b1;   
			
			/*	MEMORY HAS BEEN CLEARED  */
					
			#10 read = 1'b1;   //Setting circuit to READ mode by giving active LOW enable to multiplexers
			
			/*  CIRCUIT IS NOW IN READ MODE  */
			
				select = 2'b00;    //Telling multiplexers to read from DFF IC's 0 and 4
			
			#10 select = 2'b01;   //Telling multiplexers to read from DFF IC's 1 and 5
			
			#10 select = 2'b10;   //Telling multiplexers to read from DFF IC's 2 and 6
			
			#10 select = 2'b11;   //Telling multiplexers to read from DFF IC's 3 and 7
			
			/*  DATA HAS NOW BEEN READ FROM THE MEMORY. ALL BITS ARE 0  */
			
			#10 read = 1'b0;	//Setting circuit to WRITE mode by giving active low to decoder
			
			/*  CIRCUIT IS NOW IN WRITE MODE  */
			
				select = 2'b00;  //Telling decoder to provide HIGH signals to DFF ICs 0 and 4 for storage
				i = 8'b00010001;   //Writing this value into DFF IC's
			
			#10 select = 2'b01;    //Telling decoder to provide HIGH signals to DFF ICs 1 and 5 for storage
				i = 8'b00100010;	//Writing this value into DFF IC's
			
			#10 select = 2'b10;    //Telling decoder to provide HIGH signals to DFF ICs 2 and 6 for storage
				i = 8'b01000100;	//Writing this value into DFF IC's
			
			#10 select = 2'b11;    //Telling decoder to provide HIGH signals to DFF ICs 3 and 7 for storage
				i = 8'b10001000;	//Writing this value into DFF IC's
			
			/*  DATA HAS BEEN WRITTEN TO THE MEMORY  */
			
			#10 read = 1'b1;	//Setting circuit to READ mode by giving active LOW enable to multiplexers
			
			/*  CIRCUIT IS NOW IN READ MODE  */
			
				select = 2'b00;    //Telling multiplexers to read from DFF IC's 0 and 4
			
			#10 select = 2'b01;   //Telling multiplexers to read from DFF IC's 1 and 5
			
			#10 select = 2'b10;   //Telling multiplexers to read from DFF IC's 2 and 6
			
			#10 select = 2'b11;   //Telling multiplexers to read from DFF IC's 3 and 7

			/*  DATA HAS NOW BEEN READ FROM THE MEMORY. ALL BITS SHOULD MATCH THE ENTERED DATA  */
			
			#10	clear = 1'b0;	//active LOW reset for all DFFs to clear memory
			#10 clear = 1'b1;   //disabling reset so that DFFs can store data
			
			/*	MEMORY HAS BEEN CLEARED  */
					
			#10 read = 1'b1;   //Setting circuit to READ mode by giving active LOW enable to multiplexers
			
			/*  CIRCUIT IS NOW IN READ MODE  */
			
				select = 2'b00;    //Telling multiplexers to read from DFF IC's 0 and 4
			
			#10 select = 2'b01;   //Telling multiplexers to read from DFF IC's 1 and 5
			
			#10 select = 2'b10;   //Telling multiplexers to read from DFF IC's 2 and 6
			
			#10 select = 2'b11;   //Telling multiplexers to read from DFF IC's 3 and 7
			
			/*  DATA HAS NOW BEEN READ FROM THE MEMORY. ALL BITS ARE 0  */
					
		end
endmodule

module test_bench2;

	reg [7:0] i;	//Input variable
	wire [7:0] o;	//Output variable
	reg [1:0] select;
	reg read, clear;	
	
	Circuit C1(i[0], i[1], i[2], i[3], i[4], i[5], i[6], i[7], o[0], o[1], o[2], o[3], o[4], o[5], o[6], o[7], select[0], select[1], read, clear);
	
	initial 
		begin
		
			clear = 1'b0;	//active LOW reset for all DFFs to clear memory
			#10 clear = 1'b1;   //disabling reset so that DFFs can store data
			
			
			#10 read = 1'b0;   //Setting circuit to WRITE mode by giving active LOW enable to decoder
				select = 2'b00;  //Telling decoder to provide HIGH signals to DFF ICs 0 and 4 for storage
				i = 8'b00010001;   //Writing this value into DFF IC's

			#200 read = 1'b1;
        select = 2'b00;    //Telling multiplexers to read from DFF IC's 0 and 4
    
    
      #200 read = 1'b0;
			#10 select = 2'b01;    //Telling decoder to provide HIGH signals to DFF ICs 1 and 5 for storage
				i = 8'b00100010;	//Writing this value into DFF IC's
			
			
			#200 read = 1'b1;
       select = 2'b01;   //Telling multiplexers to read from DFF IC's 1 and 5
      
      
			
			#200 read = 1'b0;
			#10 select = 2'b10;    //Telling decoder to provide HIGH signals to DFF ICs 2 and 6 for storage
				i = 8'b01000100;	//Writing this value into DFF IC's
			#200 read = 1'b1;	//Setting circuit to READ mode by giving active LOW enable to multiplexers
			  select = 2'b10;   //Telling multiplexers to read from DFF IC's 2 and 6
			
			
			#200 read = 1'b0;
			#10 select = 2'b11;    //Telling decoder to provide HIGH signals to DFF ICs 3 and 7 for storage
				i = 8'b10001000;	//Writing this value into DFF IC's
			
			#200 read = 1'b1;	//Setting circuit to READ mode by giving active LOW enable to multiplexers
			 select = 2'b11;   //Telling multiplexers to read from DFF IC's 3 and 7
		
			
			
			
			end
endmodule		

