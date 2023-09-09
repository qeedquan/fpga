module uart
(
	input wire        clk,
	input wire        reset,
	input wire        rd_uart,
	input wire        wr_uart,
	input wire        rx,
	input wire [7:0]  w_data,
	output wire       tx_full,
	output wire       rx_empty,
	output wire [7:0] r_data,
	output wire       tx
);
	parameter DBIT     = 8;   // # data bits
	parameter SB_TICK  = 16;  // # of ticks for stop bits 16/24/32 for 1/1.5/2 stop bits
	parameter DVSR     = 163; // baud rate divisor, DVSR = clock_rate/(16*baud_rate)
	parameter DVSR_BIT = 9;   // # of bits of DVSR
	parameter FIFO_W   = 5;   // # addr bits of FIFO
	                          // # words in FIFO=2^FIFO_W
	
	wire       tick;
	wire       rx_done_tick;
	wire [7:0] tx_fifo_out;
	wire [7:0] rx_data_out;
	wire       tx_empty, tx_fifo_not_empty;
	wire       tx_done_tick;
	
	// acts as a clock divisor to get needed baud rate for tx/rx
	mod_m_counter#(
		.M(DVSR),
		.N(DVSR_BIT)
	) m(
		.clk(clk),
		.reset(reset),
		.q(),
		.max_tick(tick)
	);
	
	fifo#(
		.B(DBIT),
		.W(FIFO_W)
	) f_rx(
		.clk(clk),
		.reset(reset),
		.rd(rd_uart),
		.wr(rx_done_tick),
		.w_data(rx_data_out),
		.empty(rx_empty),
		.full(),
		.r_data(r_data)
	);
	
	uart_rx#(
		.DBIT(DBIT),
		.SB_TICK(SB_TICK)
	) u_rx(
		.clk(clk),
		.reset(reset),
		.rx(rx),
		.s_tick(tick),
		.rx_done_tick(rx_done_tick),
		.dout(rx_data_out)
	);
	
	fifo#(
		.B(DBIT),
		.W(FIFO_W)
	) f_tx(
		.clk(clk),
		.reset(reset),
		.rd(tx_done_tick),
		.wr(wr_uart),
		.w_data(w_data),
		.empty(tx_empty),
		.full(tx_full),
		.r_data(tx_fifo_out)
	);
	
	uart_tx#(
		.DBIT(DBIT),
		.SB_TICK(SB_TICK)
	) u_tx(
		.clk(clk),
		.reset(reset),
		.tx_start(tx_fifo_not_empty),
		.s_tick(tick),
		.din(tx_fifo_out),
		.tx_done_tick(tx_done_tick),
		.tx(tx)
	);
	
	assign tx_fifo_not_empty = !tx_empty;
	
endmodule