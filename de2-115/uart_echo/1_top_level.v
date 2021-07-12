// ported from http://www.dejazzer.com/eece4740/lectures/uart_test_impl1.zip
// modified to echo back what user type in and instead of an increment of that character
module uart_echo
(
	input wire        clk_i,
	input wire        btn_reset,
	input wire        btn_send_back,
	input wire        rx,
	output wire       tx,
	output wire [7:0] LEDG,
	output wire [6:0] seven_seg
);
	wire       clk50;
	wire       tx_full, rx_empty;
	wire [7:0] rec_data;
	wire [7:0] send_back_data;
	wire       top_level_reset;
	wire       top_level_sendback, send_back_db;
	
	assign top_level_reset = ~btn_reset;
	assign top_level_sendback = ~btn_send_back;
	
	// pll is not really needed, since input clock is already 50 mhz
	pll p0(clk_i, clk50);
	
	uart u0(
		.clk(clk50),
		.reset(top_level_reset),
		.rd_uart(send_back_db),
		.wr_uart(send_back_db),
		.rx(rx),
		.w_data(send_back_data),
		.tx_full(tx_full),
		.rx_empty(rx_empty),
		.r_data(rec_data),
		.tx(tx)
	);
	
	// push button is already debounced, don't really need to do this
	debounce d0(
		.clk(clk50),
		.sw(top_level_sendback),
		.db_level(),
		.db_tick(send_back_db)
	);
	
	assign send_back_data = rec_data;
	
	assign LEDG = rec_data;
	assign seven_seg = {1'b1, ~tx_full, 2'b11, ~rx_empty, 2'b11};

endmodule
