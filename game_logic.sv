module game_logic (input logic Clk, Reset,
						 input [7:0] keycode,
						 input [31:0] counter,
						 input [31:0] dots_left,
						 // current location of PacMan and ghosts (top left corner)
						 input logic [9:0] pX, pY, rgX, rgY, bgX, bgY, ogX, ogY,
						 input logic [9:0] pSize, gSize,
						 input logic [9:0] score_from_reg,
						 input logic [3:0] fruits_from_reg,
						 input logic [7:0] lives_from_reg,
						 // register variables
						 output logic Load_S,
						 output logic Load_F,
						 output logic Load_L,
						 // control signal outputs
						 output logic win, lose, pause, lifeDown,
						 output logic [3:0] fruits_to_reg,
						 output logic [9:0] score_to_reg,
						 output logic [7:0] lives_to_reg
);

	enum logic [4:0] {  Pause, 
							  Restart,
							  Run,
							  Fruit,
							  LifeDown,
							  LifeDownHold,
							  Game_over,
							  Game_won
						  }   State, Next_state;
		
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
		pause = 1'b0;
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
					if(keycode == 8'h28)
						Next_state = Run;
					else
						Next_state = Pause;
				end
		
			Run: 
				begin
					// all dots eaten
					if(dots_left == 32'b11111111111111111111111111111111)
						Next_state = Game_won;
				
					// red ghost collisions
					// top
					else if(((pY+pSize) == (rgY-gSize) || (pY+pSize + 10'd1) == (rgY-gSize) || (pY+pSize - 10'd1) == (rgY-gSize) || (pY+pSize+10'd2) == (rgY-gSize) || (pY+pSize-10'd2) == (rgY-gSize)) &&
						(pX == rgX || (pX + 10'd1) == rgX || (pX - 10'd1) == rgX || (pX+10'd2) == rgX || (pX-10'd2) == rgX))
							Next_state = LifeDown;
					// bottom
					else if(((pY-pSize) == (rgY+gSize) || (pY-pSize + 10'd1) == (rgY+gSize) || (pY-pSize - 10'd1) == (rgY+gSize) || (pY-pSize+10'd2) == (rgY+gSize) || (pY-pSize-10'd2) == (rgY+gSize)) &&
							  (pX == rgX || (pX + 10'd1) == rgX || (pX - 10'd1) == rgX || (pX+10'd2) == rgX || (pX-10'd2) == rgX))
							Next_state = LifeDown;
					// left
					else if(((pX-pSize) == (rgX+gSize) || (pX-pSize + 10'd1) == (rgX+gSize) || (pX-pSize - 10'd1) == (rgX+gSize) || (pX-pSize+10'd2) == (rgX+gSize) || (pX-pSize-10'd2) == (rgX+gSize)) &&
							  (pY == rgY || (pY + 10'd1) == rgY || (pY - 10'd1) == rgY || (pY+10'd2) == rgY || (pY-10'd2) == rgY))
							Next_state = LifeDown;
					// right
					else if(((pX+pSize) == (rgX-gSize) || (pX+pSize + 10'd1) == (rgX-gSize) || (pX+pSize - 10'd1) == (rgX-gSize) || (pX+pSize+10'd2) == (rgX-gSize) || (pX+pSize-10'd2) == (rgX-gSize)) &&
							  (pY == rgY || (pY + 10'd1) == rgY || (pY - 10'd1) == rgY || (pY+10'd2) == rgY || (pY-10'd2) == rgY))
							Next_state = LifeDown;
		
					// orange ghost collisions
					// top
					else if(((pY+pSize) == (ogY-gSize) || (pY+pSize + 10'd1) == (ogY-gSize) || (pY+pSize - 10'd1) == (ogY-gSize) || (pY+pSize+10'd2) == (ogY-gSize) || (pY+pSize-10'd2) == (ogY-gSize)) &&
						(pX == ogX || (pX + 10'd1) == ogX || (pX - 10'd1) == ogX || (pX+10'd2) == ogX || (pX-10'd2) == ogX))
							Next_state = LifeDown;
					// bottom
					else if(((pY-pSize) == (ogY+gSize) || (pY-pSize + 10'd1) == (ogY+gSize) || (pY-pSize - 10'd1) == (ogY+gSize) || (pY-pSize+10'd2) == (ogY+gSize) || (pY-pSize-10'd2) == (ogY+gSize)) &&
							  (pX == ogX || (pX + 10'd1) == ogX || (pX - 10'd1) == ogX || (pX+10'd2) == ogX || (pX-10'd2) == ogX))
							Next_state = LifeDown;
					// left
					else if(((pX-pSize) == (ogX+gSize) || (pX-pSize + 10'd1) == (ogX+gSize) || (pX-pSize - 10'd1) == (ogX+gSize) || (pX-pSize+10'd2) == (ogX+gSize) || (pX-pSize-10'd2) == (ogX+gSize)) &&
							  (pY == ogY || (pY + 10'd1) == ogY || (pY - 10'd1) == ogY || (pY+10'd2) == ogY || (pY-10'd2) == ogY))
							Next_state = LifeDown;
					// right
					else if(((pX+pSize) == (ogX-gSize) || (pX+pSize + 10'd1) == (ogX-gSize) || (pX+pSize - 10'd1) == (ogX-gSize) || (pX+pSize+10'd2) == (ogX-gSize) || (pX+pSize-10'd2) == (ogX-gSize)) &&
							  (pY == ogY || (pY + 10'd1) == ogY || (pY - 10'd1) == ogY || (pY+10'd2) == ogY || (pY-10'd2) == ogY))
							Next_state = LifeDown;
							
					// blue ghost collisions
					// top
					else if(((pY+pSize) == (bgY-gSize) || (pY+pSize + 10'd1) == (bgY-gSize) || (pY+pSize - 10'd1) == (bgY-gSize) || (pY+pSize+10'd2) == (bgY-gSize) || (pY+pSize-10'd2) == (bgY-gSize)) &&
						(pX == bgX || (pX + 10'd1) == bgX || (pX - 10'd1) == bgX || (pX+10'd2) == bgX || (pX-10'd2) == bgX))
							Next_state = LifeDown;
					// bottom
					else if(((pY-pSize) == (bgY+gSize) || (pY-pSize + 10'd1) == (bgY+gSize) || (pY-pSize - 10'd1) == (bgY+gSize) || (pY-pSize+10'd2) == (bgY+gSize) || (pY-pSize-10'd2) == (bgY+gSize)) &&
							  (pX == bgX || (pX + 10'd1) == bgX || (pX - 10'd1) == bgX || (pX+10'd2) == bgX || (pX-10'd2) == bgX))
							Next_state = LifeDown;
					// left
					else if(((pX-pSize) == (bgX+gSize) || (pX-pSize + 10'd1) == (bgX+gSize) || (pX-pSize - 10'd1) == (bgX+gSize) || (pX-pSize+10'd2) == (bgX+gSize) || (pX-pSize-10'd2) == (bgX+gSize)) &&
							  (pY == bgY || (pY + 10'd1) == bgY || (pY - 10'd1) == bgY || (pY+10'd2) == bgY || (pY-10'd2) == bgY))
							Next_state = LifeDown;
					// right
					else if(((pX+pSize) == (bgX-gSize) || (pX+pSize + 10'd1) == (bgX-gSize) || (pX+pSize - 10'd1) == (bgX-gSize) || (pX+pSize+10'd2) == (bgX-gSize) || (pX+pSize-10'd2) == (bgX-gSize)) &&
							  (pY == bgY || (pY + 10'd1) == bgY || (pY - 10'd1) == bgY || (pY+10'd2) == bgY || (pY-10'd2) == bgY))
							Next_state = LifeDown;
					
					else
						begin
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
					
					// ran out of time
					if(counter == 32'd0)
						Next_state = Game_over;
				end
				
			// collide with ghost -> remove life
			LifeDown: 
				begin
					// out of lives -> end game
					if(lives_from_reg == 8'd2)
						Next_state = Game_over;
					else
						Next_state = LifeDownHold;
				end
																																																																																																																																																																																																																																																																																			
			LifeDownHold:
				begin
					if(((pY+pSize) == (rgY-gSize) || (pY+pSize + 10'd1) == (rgY-gSize) || (pY+pSize - 10'd1) == (rgY-gSize) || (pY+pSize+10'd2) == (rgY-gSize) || (pY+pSize-10'd2) == (rgY-gSize)) &&
						(pX == rgX || (pX + 10'd1) == rgX || (pX - 10'd1) == rgX || (pX+10'd2) == rgX || (pX-10'd2) == rgX))
							Next_state = LifeDownHold;
					// bottom
					else if(((pY-pSize) == (rgY+gSize) || (pY-pSize + 10'd1) == (rgY+gSize) || (pY-pSize - 10'd1) == (rgY+gSize) || (pY-pSize+10'd2) == (rgY+gSize) || (pY-pSize-10'd2) == (rgY+gSize)) &&
							  (pX == rgX || (pX + 10'd1) == rgX || (pX - 10'd1) == rgX || (pX+10'd2) == rgX || (pX-10'd2) == rgX))
							Next_state = LifeDownHold;
					// left
					else if(((pX-pSize) == (rgX+gSize) || (pX-pSize + 10'd1) == (rgX+gSize) || (pX-pSize - 10'd1) == (rgX+gSize) || (pX-pSize+10'd2) == (rgX+gSize) || (pX-pSize-10'd2) == (rgX+gSize)) &&
							  (pY == rgY || (pY + 10'd1) == rgY || (pY - 10'd1) == rgY || (pY+10'd2) == rgY || (pY-10'd2) == rgY))
							Next_state = LifeDownHold;
					// right
					else if(((pX+pSize) == (rgX-gSize) || (pX+pSize + 10'd1) == (rgX-gSize) || (pX+pSize - 10'd1) == (rgX-gSize) || (pX+pSize+10'd2) == (rgX-gSize) || (pX+pSize-10'd2) == (rgX-gSize)) &&
							  (pY == rgY || (pY + 10'd1) == rgY || (pY - 10'd1) == rgY || (pY+10'd2) == rgY || (pY-10'd2) == rgY))
							Next_state = LifeDownHold;
							
					// top
					else if(((pY+pSize) == (ogY-gSize) || (pY+pSize + 10'd1) == (ogY-gSize) || (pY+pSize - 10'd1) == (ogY-gSize) || (pY+pSize+10'd2) == (ogY-gSize) || (pY+pSize-10'd2) == (ogY-gSize)) &&
						(pX == ogX || (pX + 10'd1) == ogX || (pX - 10'd1) == ogX || (pX+10'd2) == ogX || (pX-10'd2) == ogX))
							Next_state = LifeDownHold;
					// bottom
					else if(((pY-pSize) == (ogY+gSize) || (pY-pSize + 10'd1) == (ogY+gSize) || (pY-pSize - 10'd1) == (ogY+gSize) || (pY-pSize+10'd2) == (ogY+gSize) || (pY-pSize-10'd2) == (ogY+gSize)) &&
							  (pX == ogX || (pX + 10'd1) == ogX || (pX - 10'd1) == ogX || (pX+10'd2) == ogX || (pX-10'd2) == ogX))
							Next_state = LifeDownHold;
					// left
					else if(((pX-pSize) == (ogX+gSize) || (pX-pSize + 10'd1) == (ogX+gSize) || (pX-pSize - 10'd1) == (ogX+gSize) || (pX-pSize+10'd2) == (ogX+gSize) || (pX-pSize-10'd2) == (ogX+gSize)) &&
							  (pY == ogY || (pY + 10'd1) == ogY || (pY - 10'd1) == ogY || (pY+10'd2) == ogY || (pY-10'd2) == ogY))
							Next_state = LifeDownHold;
					// right
					else if(((pX+pSize) == (ogX-gSize) || (pX+pSize + 10'd1) == (ogX-gSize) || (pX+pSize - 10'd1) == (ogX-gSize) || (pX+pSize+10'd2) == (ogX-gSize) || (pX+pSize-10'd2) == (ogX-gSize)) &&
							  (pY == ogY || (pY + 10'd1) == ogY || (pY - 10'd1) == ogY || (pY+10'd2) == ogY || (pY-10'd2) == ogY))
							Next_state = LifeDownHold;
							
					// top
					else if(((pY+pSize) == (bgY-gSize) || (pY+pSize + 10'd1) == (bgY-gSize) || (pY+pSize - 10'd1) == (bgY-gSize) || (pY+pSize+10'd2) == (bgY-gSize) || (pY+pSize-10'd2) == (bgY-gSize)) &&
						(pX == bgX || (pX + 10'd1) == bgX || (pX - 10'd1) == bgX || (pX+10'd2) == bgX || (pX-10'd2) == bgX))
							Next_state = LifeDownHold;
					// bottom
					else if(((pY-pSize) == (bgY+gSize) || (pY-pSize + 10'd1) == (bgY+gSize) || (pY-pSize - 10'd1) == (bgY+gSize) || (pY-pSize+10'd2) == (bgY+gSize) || (pY-pSize-10'd2) == (bgY+gSize)) &&
							  (pX == bgX || (pX + 10'd1) == bgX || (pX - 10'd1) == bgX || (pX+10'd2) == bgX || (pX-10'd2) == bgX))
							Next_state = LifeDownHold;
					// left
					else if(((pX-pSize) == (bgX+gSize) || (pX-pSize + 10'd1) == (bgX+gSize) || (pX-pSize - 10'd1) == (bgX+gSize) || (pX-pSize+10'd2) == (bgX+gSize) || (pX-pSize-10'd2) == (bgX+gSize)) &&
							  (pY == bgY || (pY + 10'd1) == bgY || (pY - 10'd1) == bgY || (pY+10'd2) == bgY || (pY-10'd2) == bgY))
							Next_state = LifeDownHold;
					// right
					else if(((pX+pSize) == (bgX-gSize) || (pX+pSize + 10'd1) == (bgX-gSize) || (pX+pSize - 10'd1) == (bgX-gSize) || (pX+pSize+10'd2) == (bgX-gSize) || (pX+pSize-10'd2) == (bgX-gSize)) &&
							  (pY == bgY || (pY + 10'd1) == bgY || (pY - 10'd1) == bgY || (pY+10'd2) == bgY || (pY-10'd2) == bgY))
							Next_state = LifeDownHold;
				
					else
						Next_state = Run;
				
				end
			
			// remove fruit -> continue game
			Fruit:
				Next_state = Run;
			
			// Game over -> resets
			Game_over: ;
			
			// Game won -> resets
			Game_won: ;
				
			default: ;

		endcase
		
		// Assign control signals based on current state
		case (State)
			Restart: ;
			Pause: 
				pause = 1'b1;
			
			LifeDown: 
				begin
					lives_to_reg = lives_from_reg + 8'd1;
					Load_L = 1'b1;
					lifeDown = 1'b1;
				end
			
			LifeDownHold: 
				lifeDown = 1'b1;
				
			Game_over:
				lose = 1'b1;
				pause = 1'b1;
			
			Game_won:
				win = 1'b1;
				pause = 1'b1;
				
			Run: ;
			
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
