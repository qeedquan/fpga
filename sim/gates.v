module gates
(
	output wire o_and,
	output wire o_nand,
	output wire o_or,
	output wire o_nor,
	output wire o_xor,
	output wire o_xnor,
	output wire o_not1,
	output wire o_not2,
	output wire o_dff,
	output wire o_one,
	output wire o_zero,
	output wire o_cp_and,
	output wire o_cp_or,
	output wire o_cp_xor
);
	function f_nand
	(
		input x,
		input y
	);	
		f_nand = ~(x & y);
	endfunction
	
	function f_not
	(
		input x
	);
		f_not = f_nand(x, x);
	endfunction
	
	function f_and
	(
		input x,
		input y
	);
		f_and = f_not(f_nand(x, y));
	endfunction
	
	function f_or
	(
		input x,
		input y
	);
		reg r1, r2;
		
		begin
			r1   = f_nand(x, x);
			r2   = f_nand(y, y);
			f_or = f_not(f_and(r1, r2));
		end
	endfunction
	
	function f_nor
	(
		input x,
		input y
	);
		f_nor = f_not(f_or(x, y));
	endfunction
	
	function f_xor
	(
		input x,
		input y
	);
		reg r1, r2;
		
		begin
			r1    = f_and(x, f_not(y));
			r2    = f_and(f_not(x), y);
			f_xor = f_or(r1, r2);
		end
	endfunction
	
	function f_xnor
	(
		input x,
		input y
	);
		f_xnor = f_not(f_xor(x, y));
	endfunction
	
	function f_dff
	(
		input d,
		input clk
	);
		reg Q, Q_BAR;
		reg X, Y;
		begin
			X = ~(d & clk);
			Y = ~(X & clk);
			Q = ~(Q_BAR & X);
			Q_BAR = ~(Q & Y);
			f_dff = Q;
		end
	endfunction
	
	reg x, y;
	
	initial begin
		x = 0;
		y = 0;
		
		#5 x = 0;
			y = 1;
			
		#5 x = 1;
			y = 0;
			 
		#5 x = 1;
			y = 1;
		
		#5 $finish;
	end
	
	assign o_cp_and = o_and;
	assign o_cp_or  = o_or;
	assign o_cp_xor = o_xor;

	assign o_nand = f_nand(x, y);
	assign o_and  = f_and(x, y);
	assign o_nor  = f_nor(x, y);
	assign o_or   = f_or(x, y);
	assign o_xnor = f_xnor(x, y);
	assign o_xor  = f_xor(x, y);
	assign o_not1 = f_not(x);
	assign o_not2 = f_not(y);
	assign o_dff  = f_dff(x, y);
	assign o_one  = 1;
	assign o_zero = 0;
endmodule