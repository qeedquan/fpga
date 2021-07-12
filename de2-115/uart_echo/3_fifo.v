// a FIFO buffer, provides a way of storing
// data from UART and can empty it later
module fifo
(
	input wire          clk,
	input wire          reset,
	input wire          rd,
	input wire          wr,
	input wire [B-1:0]  w_data,
	output wire         empty,
	output wire         full,
	output wire [B-1:0] r_data
);
	parameter B = 8; // number of bits
	parameter W = 4; // number of address bits

	reg [B-1:0]  array_reg[2**W-1:0];
	reg [W-1:0]  w_ptr_reg, w_ptr_next;
	reg [W-1:0]  r_ptr_reg, r_ptr_next;
	reg          full_reg, empty_reg, full_next, empty_next;
	wire [W-1:0] w_ptr_succ, r_ptr_succ;
	wire [1:0]   wr_op;
	wire         wr_en;
	integer      i;
	
	always @ (posedge clk, posedge reset) begin
		if (reset) begin
			for (i = 0; i <= 2**W-1; i = i+1)
				array_reg[i] <= 0;
		end
		else begin
			if (wr_en)
				array_reg[w_ptr_reg] <= w_data;
		end
	end
	
	assign r_data = array_reg[r_ptr_reg];
	assign wr_en = wr && !full_reg;
	
	always @ (posedge clk, posedge reset) begin
		if (reset) begin
			w_ptr_reg <= 0;
			r_ptr_reg <= 0;
			full_reg <= 0;
			empty_reg <= 1;
		end
		else begin
			w_ptr_reg <= w_ptr_next;
			r_ptr_reg <= r_ptr_next;
			full_reg <= full_next;
			empty_reg <= empty_next;
		end
	end
	
	assign w_ptr_succ = w_ptr_reg + 1;
	assign r_ptr_succ = r_ptr_reg + 1;
	
	// state machine works as follows
	// READ:, it checks
	// if the queue is empty, if it is not
	// it will increment the queue, otherwise it does nothing
	// WRITE: it checks if the queue is full before writing,	
	// if it is, then it will just be a nop waiting
	// READ/WRITE: if read and write happens at the same time,
	// we increment the counter for both of them, since it is assume
	// they will get the same data	
	assign wr_op = {wr, rd};
	always @ (w_ptr_reg, w_ptr_succ, r_ptr_reg, r_ptr_succ, wr_op, empty_reg, full_reg) begin
		w_ptr_next <= w_ptr_reg;
		r_ptr_next <= r_ptr_reg;
		full_next <= full_reg;
		empty_next <= empty_reg;
			
		case (wr_op)
			// nop
			2'b00: begin
			end

			// read
			2'b01: begin
				if (!empty_reg) begin
					r_ptr_next <= r_ptr_succ;
					full_next <= 0;
					if (r_ptr_succ == w_ptr_reg)
						empty_next <= 1;
				end
			end
			
			// write
			2'b10: begin
				if (!full_reg) begin
					w_ptr_next <= w_ptr_succ;
					empty_next <= 0;
					if (w_ptr_succ == r_ptr_reg)
						full_next <= 1;
				end
			end
			
			// read/write
			default: begin
				w_ptr_next <= w_ptr_succ;
				w_ptr_next <= r_ptr_succ;
			end
		endcase
	end
	
	assign full = full_reg;
	assign empty = empty_reg;
	
endmodule
