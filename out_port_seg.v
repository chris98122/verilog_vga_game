module out_port_seg(in,out1,out0);
	input [31:0] in;
	output [6:0] out1,out0;
	
	reg [3:0] num5,num4,num3,num2,num1,num0;

	sevenseg display_1( num1, out1 );
	sevenseg display_0( num0, out0 );
	
	always @ (in)
	begin
		num1 = ( in / 10 ) % 10;
		num0 = in % 10;
	end
	
endmodule