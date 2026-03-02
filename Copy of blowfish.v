module blowfish (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [63:0] plaintext,
    input wire [63:0] key,
    output reg [63:0] ciphertext,
    output reg valid,
    output reg done
);

    // Internal registers
    reg [31:0] left, right, temp;
    reg [31:0] p_array [0:17];
    reg [31:0] s_box0  [0:255];
    reg [31:0] s_box1  [0:255];
    reg [31:0] s_box2  [0:255];
    reg [31:0] s_box3  [0:255];
    reg [4:0] round;
    reg [3:0] state;
    reg init_done;
    
    // State encoding
    localparam  IDLE       = 4'd0,
						INIT 	      = 4'd1,
               	ENCRYPT_1 = 4'd2,
               	ENCRYPT_2 = 4'd3,
               	FINISH          = 4'd4,
						WAIT_DONE_CLEAR = 4'd5;
	  
    initial begin         

        end
        
    // Blowfish F-function
    function [31:0] F;
        input [31:0] x;
        	begin
            		F = ((s_box0[x[31:24]] + s_box1[x[23:16]]) ^ s_box2[x[15:8]]) + s_box3[x[7:0]];
        	end 
    endfunction

    // FSM 
    always @(posedge clk) begin
        if (rst) begin
        
			//insert p-array here
		
				$readmemh("p_array.hex",	p_array);
				$readmemh("sbox0.hex",		s_box0);
				$readmemh("sbox1.hex", 	   s_box1);
				$readmemh("sbox2.hex",		s_box2);
				$readmemh("sbox3.hex",		s_box3);

			temp  <= 0;
			right <= 0;
			left  <= 0;
        			round <= 0;
         			state <= IDLE;
         			valid <= 0;
         			done  <= 0;
         			ciphertext <= 64'h0;
         			init_done <=0;
         
			end else begin
            			case (state)
                				IDLE: begin
					 
                    					valid <= 0;
                    					done  <= 0;
						  
                    				if (!init_done) begin
						  
                    					state <= INIT;
							
                    				end
						  
                    				else if (start && init_done) begin
                        				left  <= plaintext[63:32];
                       					right <= plaintext[31:0];
                       					round <= 0;
                        				state <= ENCRYPT_1;
                    				end
                			end

		INIT: begin
			init_done <=1;
			state <= IDLE;	
		end
		
                	ENCRYPT_1: begin
                        	temp  <= right;
                        	right <= left ^ p_array [round];
                       		state <= ENCRYPT_2;     
      	         end
                
                	ENCRYPT_2: begin
                        
                        left <= temp ^ F(right);
                        round <= round + 1;
                        if (round == 16) state <= FINISH;
                        else state <= ENCRYPT_1;
                        
                	end

                	FINISH: begin
                    
                    	ciphertext <= {left ^ p_array[16], right ^ p_array[17]};
                    	valid <= 1;
                    	done  <= 1;
                    	state <= WAIT_DONE_CLEAR;
                	end
					 
	        	WAIT_DONE_CLEAR: begin
		    
			state <= IDLE;
			end
                
                	default: state <= IDLE;
            	endcase
        	end
    end

endmodule
