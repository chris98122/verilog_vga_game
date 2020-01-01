module color_assigner(
	input clk,
	input[9:0] Hcnt,
	input[9:0] Vcnt,
	input[9:0] birdhead_left, birdhead_right, birdhead_top, birdhead_bottom,
	input[9:0] birdbody_left, birdbody_right, birdbody_top, birdbody_bottom,
	input[9:0] birdleg_left, birdleg_right, birdleg_top, birdleg_bottom,
	output reg[7:0] Red,
	output reg[7:0] Green,
	output reg[7:0] Blue
);

	always@(posedge clk)
	begin
		//birdhead
		if (Hcnt >= birdhead_left && Hcnt < birdhead_right 
			&& Vcnt >= birdhead_top && Vcnt < birdhead_bottom)
		begin
			Red = 8'd0;
			Green = 8'd0;
			Blue = 8'd0;
		end
		//birdbody
		else if (Hcnt >= birdbody_left && Hcnt < birdbody_right 
			&& Vcnt >= birdbody_top && Vcnt < birdbody_bottom)
		begin
			Red = 8'd0;
			Green = 8'd0;
			Blue = 8'd0;
		end
		//birdleg
		else if (Hcnt >= birdleg_left && Hcnt < birdleg_right 
			&& Vcnt >= birdleg_top && Vcnt < birdleg_bottom)
		begin
			Red = 8'd0;
			Green = 8'd0;
			Blue = 8'd0;
		end
		//background
		else
		begin
			Red = 8'd255;
			Green = 8'd255;
			Blue = 8'd255;
		end
	end

endmodule
