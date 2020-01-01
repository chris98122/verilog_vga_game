module simple_vga_game (
	input reset,
	input left, 
	input clk, 
	output HS,
	output VS,
	output reg[7:0] VGA_R,
	output reg[7:0] VGA_G,
	output reg[7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_CLK,
	output [6:0] hex0,
	output [6:0] hex1,
	output [6:0] hex4,
	output [6:0] hex5
);
	//Hcnt, Vcnt for vga
	wire[9:0] Hcnt;
	wire[9:0] Vcnt;
	
	//head(left, top, right, bottom) 
	reg[9:0] head_left_init, head_right_init, head_top_init, head_bottom_init; 	  
	reg[9:0] head_left, head_right, head_top, head_bottom; 
	   
	reg[9:0] body_left[12], body_right[12], body_top[12], body_bottom[12]; 
	
	reg[9:0] food_left,food_right,food_top,food_bottom;
	reg[9:0] food_left_init, food_right_init, food_top_init, food_bottom_init; 
	
	initial
	begin 
		//head
		head_left_init <= 10'd260;
		head_right_init <= 10'd280;
		head_top_init <= 10'd230;
		head_bottom_init <= 10'd250; 
		 
		
		//food
		food_left_init <= 10'd220;
		food_right_init <= 10'd230;
		food_top_init <= 10'd90;
		food_bottom_init <= 10'd100; 
	end

	reg clk_25M;
	//generate a half frequency clock of 25MHz
	always@(posedge(clk))
	begin
		clk_25M <= ~clk_25M;
	end
	
	//generate 200ms clock
	reg[31:0] counter_200ms;
	reg clk_200ms;
	parameter COUNT_200ms = 4999999;
	always@(posedge(clk))
	begin
		if (counter_200ms == COUNT_200ms)
		begin
			counter_200ms = 0;
			clk_200ms = ~clk_200ms;
		end
		else
		begin
			counter_200ms = counter_200ms + 1;
		end
	end
	
	//generate 500ms clock
	reg[31:0] counter_500ms;
	reg clk_500ms;
	parameter COUNT_500ms = 12999999;
	always@(posedge(clk))
	begin
		if (counter_500ms == COUNT_500ms)
		begin
			counter_500ms = 0;
			clk_500ms = ~clk_500ms;
		end
		else
		begin
			counter_500ms = counter_500ms + 1;
		end
	end
	 
	reg[2:0] move_direction;
	
	//move left
	parameter left_distance = 10;
	reg[9:0] left_total;
	parameter right_distance = 10;
	reg[9:0] right_total;
	parameter down_distance = 10;
	reg[9:0] down_total;
	parameter up_distance = 10;
	reg[9:0] up_total;
	
	
	always@(posedge(left) )
	begin 
			move_direction  = move_direction +1;
			if(move_direction == 4)
				move_direction  = 0;
	end 
	
	
	always@(posedge(clk_200ms))
	  begin 
			if(move_direction == 0) 
				left_total = left_total + left_distance ;
			if(move_direction == 1) 
				right_total = right_total + right_distance ;
			if(move_direction == 2)
				up_total = up_total + up_distance  ;
			if(move_direction == 3)
				down_total = down_total + down_distance  ; 
		end
		
	//refresh head pos
	
			reg [8:0] temp1;  //for循环变量 
	always@(posedge clk_25M) 
			begin
			 //body  
			for( temp1= 0 ; temp1 + 1< body_num ; temp1=temp1+1'b1 ) 
				   //循环次数固定
				begin 
					body_left[temp1+1'b1] <= body_left[temp1];
					body_right[temp1+1'b1] <= body_right[temp1] ;
					body_bottom[temp1+1'b1] <= body_bottom[temp1];
					body_top[temp1+1'b1] <= body_top[temp1] ;
				end
				
			if(body_num >=1)
				begin
					body_left[0]  <=  head_left;
					body_right[0] <=  head_right;
					body_top[0]  <=  head_top;
					body_bottom[0]  <=  head_bottom; 
				end
				
			//head
			head_left <= head_left_init - left_total+ right_total;
			head_right <= head_right_init - left_total + right_total;
			head_top <= head_top_init + up_total - down_total  ;
			head_bottom <= head_bottom_init  + up_total - down_total ;
			 
			
			//food
			food_left <= food_left_init ;
			food_right <= food_right_init ;
			food_top <= food_top_init;
			food_bottom <= food_bottom_init;
			
			
			end
			
	reg[31:0] score;
	reg [2:0] body_num;
	
	//detect collision
	always@(posedge(clk_200ms))
			begin
			if(head_left <= food_left && head_top <= food_top  && head_right>=food_right && head_bottom >= food_bottom)
				begin
					score = score + 1;
				
				//food relocation
					food_left_init <= (food_left_init + 10'd180) % 10'd640;
					food_right_init <= (food_right_init + 10'd180) % 10'd640;
					food_top_init <= (food_top_init + 10'd80) % 10'd480;
					food_bottom_init <= (food_bottom_init + 10'd80) % 10'd480;
					
					//add body  
					body_num = body_num+1;
				end
			end
	
	vga_display screen(
	.clk(clk_25M),//50MHZ
	.reset(reset),
	.Hcnt(Hcnt),
	.Vcnt(Vcnt),
	.hs(HS),
	.vs(VS),
	.blank(VGA_BLANK_N),
	.vga_clk(VGA_CLK)
	);
	
	out_port_seg historyScoreboard(
	.in(history_score),
	.out1(hex5),
	.out0(hex4)
	);
	
	out_port_seg scoreboard(
	.in(score),
	.out1(hex1),
	.out0(hex0)
	);
	 
	//game over
	integer k;
	reg finish;
	 
	
   reg [8:0] temp2;  //for循环变量 
	always@(posedge clk_25M)
	begin
		if (finish == 0)
		begin 
			//head 
		   if (Hcnt >= head_left && Hcnt < head_right 
				&& Vcnt >= head_top && Vcnt < head_bottom)
			begin
				VGA_R = 8'd210;
				VGA_G = 8'd80;
				VGA_B = 8'd80;
			end 
			//food
			else if (Hcnt >= food_left && Hcnt < food_right 
				&& Vcnt >= food_top && Vcnt < food_bottom)
				begin
					VGA_R = 8'd221;
					VGA_G = 8'd169;
					VGA_B = 8'd105;
				end  
			else  
				begin
				
					//sky  
						VGA_R = 8'd135;
						VGA_G = 8'd206;
						VGA_B = 8'd250; 
					
					//body
						if(body_num >=1)
							begin
								for( temp2 = 0 ; temp2< body_num ; temp2=temp2+1'b1 ) 
									begin
										if( Hcnt >= body_left[temp2] && Hcnt <  body_right[temp2] 
											&& Vcnt >= body_top[temp2] && Vcnt <  body_bottom[temp2])
												begin 
											 	VGA_R = 8'd210;
											 	VGA_G = 8'd80;
												VGA_B = 8'd80;
												end
									end 	
							end 
				end
		end
		//game over
		else
		begin
			VGA_R = 8'd255;
			VGA_G = 8'd128;
			VGA_B = 8'd128;
		end
	end

endmodule
