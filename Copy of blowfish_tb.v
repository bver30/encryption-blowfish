`timescale 1ns / 1ps

module blowfish_tb;
	reg clk;
	reg rst;
	reg start;
	reg [63:0] plaintext; // Ensure 64-bit plaintext
	reg [63:0] key;
	wire [63:0] ciphertext; // Ensure 64-bit ciphertext
	wire valid;
	wire done;

	// Instantiate the Blowfish module
	blowfish uut (
	`ifdef USE_POWER_PINS
	.vdda1(vdda1),	// User area 1 3.3V power
	.vdda2(vdda2),	// User area 2 3.3V power
	.vssa1(vssa1),	// User area 1 analog ground
	.vssa2(vssa2),	// User area 2 analog ground
	.vccd1(vccd1),	// User area 1 1.8V power
	.vccd2(vccd2),	// User area 2 1.8V power
	.vssd1(vssd1),	// User area 1 digital ground
	.vssd2(vssd2),	// User area 2 digital ground
	`endif
    	.clk(clk),
    	.rst(rst),
    	.start(start),
    	.plaintext(plaintext),
    	.key(key),
    	.ciphertext(ciphertext),
    	.done(done),
	.valid(valid)
	);

	// Clock generation
	always #10 clk = ~clk; // 50 MHz clock

	initial begin
    
	$dumpfile("blowfish_tb.vcd");
	$dumpvars(0, blowfish_tb);
    
	end
    
    
	initial begin	
    	 
	// Initialize signals
    	clk = 0;
    	rst = 1;
    	start = 0;
    	plaintext = 64'h0;
    	key = 64'h0;

    	#200 rst = 0; 

    	// Test cases
   	 
    	//start = 1;
    	plaintext = 64'h0123456789abcdef;
	key = 64'h0f1571c9ac4198de;
	start = 1; #1000;
	start = 0;#1000;
    
     	 
	plaintext = 64'hfedcba0987654321;
	key = 64'hcade514815fde3a8;
	start = 1; #1000;
	start = 0;
         	 
	wait(done);
   	 
    	// Finish simulation
    	#2000 $finish;
	end
		
	// Monitor signal changes continuously
	initial begin
    	$monitor("Time=%0t clk=%b rst=%b start=%b done=%b ciphertext=%h",
             	$time, clk, rst, start, valid, done, plaintext, key, ciphertext);
	end
endmodule
