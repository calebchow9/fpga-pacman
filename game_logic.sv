module game_logic (input logic Clk, Reset,
						 input [7:0] keycode,
						 // current location of PacMan and ghosts (top left corner)
						 input logic [9:0] pX, pY, rgX, rgY, bgX, bgY, ogX, ogY,
						 input logic [9:0] pSize, gSize,
						 input logic [9:0] score_from_reg,
						 input logic [3:0] fruits_from_reg,
						 input logic [1:0] lives_from_reg,
						 // register variables
						 output logic Load_S,
						 output logic Load_F,
						 output logic Load_L,
						 // control signal outputs
						 output logic win, lose, restart, lifeDown,
						 output logic [3:0] fruits_to_reg,
						 output logic [9:0] score_to_reg,
						 output logic [7:0] lives_to_reg
);

	enum logic [4:0] {  Pause, 
							  Restart,
							  Run,
							  Fruit,
							  LifeDown,
							  Game_over,
							  Game_won
						  }   State, Next_state;
						  
	logic [9:0] score_temp;
		
	always_ff @ (posedge Clk)
	begin
		if (Reset) 
			State <= Restart;
		else 
			State <= Next_state;
	end
   
	always_comb
	begin 
		// defaults for latches
		win = 1'b0;
		lose = 1'b0;
		restart = 1'b0;
		lifeDown = 1'b0;
		fruits_to_reg = 4'b0000;
		score_to_reg = 10'b0000000000;
		lives_to_reg = 8'b0;
		Load_S = 1'b0;
		Load_F = 1'b0;
		Load_L = 1'b0;
	
		// Default next state is staying at current state
		Next_state = State;
	
		// Assign next state
		unique case (State)
			// restart - set all variables to beginning
			Restart:
				Next_state = Pause;
		
			// halted state
			Pause:
				begin
					if (keycode == 8'h04 || keycode == 8'h07 || keycode == 8'h16 || keycode == 8'h1A)
						Next_state = Run;
				end
		
			Run: 
				begin
//					if (score_from_reg + 50 == 520)
//						Next_state = Game_won;
					if (keycode == 8'h29)
						Next_state = Restart;
					else
						begin
							// ghost collisions
							// top
//							if (pY == rgY + gSize || pY == bgY + gSize || pY == ogY + gSize)
//								Next_state = LifeDown;
//							// left
//							else if (pX == rgX + gSize || pX == bgX + gSize || pX == ogX + gSize)
//								Next_state = LifeDown;
//							// bottom
//							else if (pY + pSize == rgY || pY + pSize == bgY || pY + pSize == ogY)
//								Next_state = LifeDown;
//							// right
//							else if (pX + pSize == rgX || pX + pSize == bgX || pX + pSize == ogX)
//								Next_state = LifeDown;
								
							// fruit collisions
							// apple
							if(pX >= 12 && pX <= 37 && pY >= 10 && pY <= 35)
								Next_state = Fruit;
							// peas
							if(pX >= 370 && pX <= 395 && pY >= 10 && pY <= 35)
								Next_state = Fruit;
							// grapes
							if(pX >= 12 && pX <= 37 && pY >= 413 && pY <= 438)
								Next_state = Fruit;
							// drink
							if(pX >= 370 && pX <= 395 && pY >= 413 && pY <= 438)
								Next_state = Fruit;
						end
				end
				
			// collide with ghost -> remove life
			LifeDown: 
				begin
					lives_to_reg = lives_from_reg + 1;
					Load_L = 1'b1;
					
					// out of lives -> end game
					if(lives_to_reg == 3)
						Next_state = Game_over;
					else
						Next_state = Run;
				end
			
			// remove fruit -> continue game
			Fruit:
				Next_state = Run;
			
			// Game over -> resets
			Game_over:
				Next_state = Pause;
			
			// Game won -> resets
			Game_won:
				Next_state = Pause;
			
			// if game bugs out or crashes -> halt
			default:
				Next_state = Pause;

		endcase
		
		// Assign control signals based on current state
		case (State)
			Restart:
				begin
					restart = 1'b1;
				end
			Pause: ;
			
			LifeDown: 
				lifeDown = 1'b1;
				
			Game_over:
				lose = 1'b1;
			
			Game_won:
				win = 1'b1;
				
			Run:
				begin
				
				end
			
			Fruit:
				begin
					// if apple eaten, remove [0]
					if (fruits_from_reg[0] == 0 && (pX >= 12 && pX <= 37 && pY >= 10 && pY <= 35))
						begin
							// set apple bit from fruits (index 0)
							fruits_to_reg = fruits_from_reg + 4'b0001;
							Load_F = 1'b1;
							// update score register +50
							score_to_reg <= score_from_reg + 10'd50;
							Load_S <= 1'b1;
						end
					// if peas eaten, remove [1]
					else if (fruits_from_reg[1] == 0 && (pX >= 370 && pX <= 395 && pY >= 10 && pY <= 35))
						begin
							// set apple bit from fruits (index 0)
							fruits_to_reg = fruits_from_reg + 4'b0010;
							Load_F = 1'b1;
							// update score register +50
							score_to_reg <= score_from_reg + 10'd50;
							Load_S <= 1'b1;
						end
					// if grapes eaten, remove [2]
					else if (fruits_from_reg[2] == 0 && (pX >= 12 && pX <= 37 && pY >= 413 && pY <= 438))
						begin
							// set apple bit from fruits (index 0)
							fruits_to_reg = fruits_from_reg + 4'b0100;
							Load_F = 1'b1;
							// update score register +50
							score_to_reg <= score_from_reg + 10'd50;
							Load_S <= 1'b1;
						end
					// if grapes eaten, remove [2]
					else if (fruits_from_reg[3] == 0 && (pX >= 370 && pX <= 395 && pY >= 413 && pY <= 438))
						begin
							// set apple bit from fruits (index 0)
							fruits_to_reg = fruits_from_reg + 4'b1000;
							Load_F = 1'b1;
							// update score register +50
							score_to_reg <= score_from_reg + 10'd50;
							Load_S <= 1'b1;
						end
				end
			
			default: ;
		endcase
	end 
	
endmodule