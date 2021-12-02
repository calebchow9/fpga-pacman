module game_logic (input logic Clk, Reset,
						 input [7:0] keycode,
						 // current location of PacMan and ghosts (top left corner)
						 input logic [9:0] pX, pY, rgX, rgY, bgX, bgY, ogX, ogY,
						 input logic [9:0] pSize, gSize,
						 
						 // control signal outputs
						 output logic win, lose, 
						 output logic [3:0] fruits,
						 output logic [9:0] score
);

	enum logic [4:0] {  Pause, 
							  Run,
							  Fruit,
							  Game_over,
							  Game_won
						  }   State, Next_state;
						  
	logic [5:0] dots;
		
	always_ff @ (posedge Clk)
	begin
		if (Reset) 
			State <= Pause;
		else 
			State <= Next_state;
	end
   
	always_comb
	begin 
		// defaults for latches
		win = 1'b0;
		lose = 1'b0;
		fruits = 4'b0;
		score = 10'b0;
	
		// Default next state is staying at current state
		Next_state = State;
	
		// Assign next state
		unique case (State)
			// halted state - when player loses, wins, or game hasn't started yet
			Pause:
				begin
					if (keycode == 8'h04 || keycode == 8'h07 || keycode == 8'h16 || keycode == 8'h1A)
						Next_state = Run;
				end
		
			Run: 
				begin
					// ghost collisions
					// top
					if (pY == rgY + gSize || pY == bgY + gSize || pY == ogY + gSize)
						Next_state = Game_over;
					// left
					else if (pX == rgX + gSize || pX == bgX + gSize || pX == ogX + gSize)
						Next_state = Game_over;
					// bottom
					else if (pY + pSize == rgY || pY + pSize == bgY || pY + pSize == ogY)
						Next_state = Game_over;
					// right
					else if (pX + pSize == rgX || pX + pSize == bgX || pX + pSize == ogX)
						Next_state = Game_over;
					
					// fruit collisions
					// apple
					if(pX >= 12 && pX <= 37 && pY >= 10 && pY <= 35)
						Next_state = Fruit;
				
				end
			
			// remove fruit -> continue game
			Fruit:
				if (score + 50 == 520)
					Next_state = Game_won;
				else
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
			Pause:
				begin
					win = 1'b0;
					lose = 1'b0;
					fruits = 4'b0000;
				end
				
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
					if (fruits[0] == 0 && (pX >= 12 && pX <= 37 && pY >= 10 && pY <= 35))
					
						// change to registers
						fruits[0] = 1'b1;
						score += 50;
				
				end
			
			default: ;
		endcase
	end 
	
endmodule
