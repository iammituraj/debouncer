/*===============================================================================================================================
   Module       : Test Bench - Debouncer

   Description  : Emulates a simple switch to test Debouncer.                               
                  
   Developer    : Mitu Raj, iammituraj@gmail.com
   Notes        : -
   License      : Open-source.
   Date         : Oct-28-2021
===============================================================================================================================*/

/*-------------------------------------------------------------------------------------------------------------------------------
                                             T E S T B E N C H   -   D E B O U N C E R
-------------------------------------------------------------------------------------------------------------------------------*/

// Timescale for simulation
`timescale 1ns / 100ps

module tb_debouncer () ;


/*-------------------------------------------------------------------------------------------------------------------------------
   Local Parameters to configure test
-------------------------------------------------------------------------------------------------------------------------------*/
localparam real CLK_PERIOD = 1000000                                  ;        // Clock period in ns
localparam real BOUNCING   = 10                                       ;        // Bouncing time of switch in ms


/*-------------------------------------------------------------------------------------------------------------------------------
   Derived Parameters
-------------------------------------------------------------------------------------------------------------------------------*/
localparam BOUNCING_CYCLES = int'((BOUNCING / CLK_PERIOD) * 1000000)  ;        // Bouncing time in clock cycles
localparam N_BOUNCE        = $clog2 (BOUNCING_CYCLES)                 ;        // N_BOUNCE configuration at DUT


/*-------------------------------------------------------------------------------------------------------------------------------
   Internal Registers/Signals
-------------------------------------------------------------------------------------------------------------------------------*/
logic clk, rstn, sig_in, sig_debounced ;        // DUT signals


/*-------------------------------------------------------------------------------------------------------------------------------
   DUT: Debouncer instance
-------------------------------------------------------------------------------------------------------------------------------*/
debouncer #( 

   .N_BOUNCE ( N_BOUNCE ) 

)

debouncer_inst (
   
   .clk             ( clk           ) ,
   .rstn            ( rstn          ) ,
   .i_sig           ( sig_in        ) ,
   .o_sig_debounced ( sig_debounced )

) ;

/*-------------------------------------------------------------------------------------------------------------------------------
   Clocking block
-------------------------------------------------------------------------------------------------------------------------------*/
always #(CLK_PERIOD / 2) clk = ~ clk ;


/*-------------------------------------------------------------------------------------------------------------------------------
   Initial block to setup clock and reset, and trigger stimulus
-------------------------------------------------------------------------------------------------------------------------------*/
initial begin

   clk    = 1'b0 ;   
   rstn   <= 1'b0 ;
   sig_in <= 1'b0 ;
   
   // Reset de-assertion
   repeat (10) @(posedge clk) ;
   rstn <= 1'b1 ;
   
   // Bouncing and clean switching to high state   
   repeat (BOUNCING_CYCLES)     @(posedge clk) sig_in <= ~ sig_in ;
   sig_in <= 1'b1 ;
   repeat (BOUNCING_CYCLES * 3) @(posedge clk)                    ;

   // Bouncing and clean switching to low state
   repeat (BOUNCING_CYCLES)     @(posedge clk) sig_in <= ~ sig_in ;
   sig_in <= 1'b0 ;
   repeat (BOUNCING_CYCLES * 3) @(posedge clk)                    ;
   
   // Bouncing and not switching
   repeat (BOUNCING_CYCLES)     @(posedge clk) sig_in <= ~ sig_in ;
   sig_in <= 1'b1 ;
   repeat (BOUNCING_CYCLES / 2) @(posedge clk)                    ;

   // Bouncing and clean switching to high state
   repeat (BOUNCING_CYCLES)     @(posedge clk) sig_in <= ~ sig_in ;
   sig_in <= 1'b1 ;
   repeat (BOUNCING_CYCLES * 3) @(posedge clk)                    ;

   // Bouncing and not switching
   repeat (BOUNCING_CYCLES)     @(posedge clk) sig_in <= ~ sig_in ;
   sig_in <= 1'b0 ;
   repeat (BOUNCING_CYCLES / 2) @(posedge clk)                    ;

   // Bouncing and clean switching to low state
   repeat (BOUNCING_CYCLES)     @(posedge clk) sig_in <= ~ sig_in ;
   sig_in <= 1'b0 ;
   repeat (BOUNCING_CYCLES * 3) @(posedge clk)                    ;

   $finish ;

end


endmodule

/*-------------------------------------------------------------------------------------------------------------------------------
                                             T E S T B E N C H   -   D E B O U N C E R
-------------------------------------------------------------------------------------------------------------------------------*/