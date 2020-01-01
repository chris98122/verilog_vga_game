module vga_display(
	input clk,
	input reset,
	output reg[9:0] Hcnt,
	output reg[9:0] Vcnt,
	output hs,
	output vs,
	output blank,
	output vga_clk
);
	assign vga_clk = clk;
	assign vs = ~(Vcnt >= visible_area_v + front_porch_v && Vcnt < visible_area_v + front_porch_v + sync_pulse_v);
	assign hs = ~(Hcnt >= visible_area_h + front_porch_h && Hcnt < visible_area_h + front_porch_h + sync_pulse_h);
	assign blank = Vcnt < visible_area_v && Hcnt < visible_area_h;
	
	 //parameter definition
	parameter integer visible_area_h = 640;
	parameter integer front_porch_h = 16;
	parameter integer sync_pulse_h = 96;
	parameter integer back_porch_h = 48;
	parameter integer whole_line_h = 800;

	parameter integer visible_area_v = 480;
	parameter integer front_porch_v = 10;
	parameter integer sync_pulse_v = 2;
	parameter integer back_porch_v = 33;
	parameter integer whole_line_v = 525;
	
	/*generate the hs && vs timing*/
	always@(posedge(clk)) 
	begin
		if (!reset)
		begin
			Hcnt = 0;
			Vcnt = 0;
		end
		/*conditions of reseting Hcnter && Vcnter*/
		else
		begin
			Hcnt = Hcnt + 1;
			if( Hcnt == whole_line_h)
			begin
				Hcnt = 0;
				Vcnt = Vcnt + 1;
				if( Vcnt == whole_line_v)
					Vcnt = 0;
			end
		end
	end
endmodule
