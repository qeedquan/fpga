// display hex digit based on the switch
module swhex
(
	input wire [17:0]    sw,
	output wire [8*7-1:0] hex
);
	hexdigit h0(sw[3:0], hex[6:0]);
	hexdigit h1(sw[7:4], hex[13:7]);
	hexdigit h2(sw[11:8], hex[20:14]);
	hexdigit h3(sw[15:12], hex[27:21]);
endmodule