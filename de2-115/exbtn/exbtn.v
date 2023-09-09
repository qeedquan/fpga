// first scenario:
// push button controls 2 of the lights
// since the 2 gpio (gpio[0] and gpio[1])
// is wired right next to the push button
// the push button provides voltage through 
// both of them, so when the button is pressed
// two of the led lights should turn off

// second scenario:
// use push button to control the LED
// we also hook another wire to 5V so the LED
// will get brighter (by default 3.3 V is supplied by GPIO)
// when we press the push button, it cuts off the current
// so the LED won't be bright anymore
// LED is wired along the path of the push button PIN
module exbtn
(
	inout wire [35:0] gpio,
	output wire [8:0] ledg
);

	generate
		genvar i;
		for (i = 0; i <= 8; i=i+1) begin : loop
			assign gpio[i] = 1;
			assign ledg[i] = gpio[i];
		end
	endgenerate
endmodule
