/*===============================================================================================================================
   Module       : Debouncer

   Description  : Debouncer is used to filter bouncing found in typical switches and provide a clean, glitch-free state change.
                  -- Configurable bouncing interval in powers of 2. 
                  -- Changes state at the output based on counting number of consecutive same states latched at the input.                               
                  
   Developer    : Mitu Raj, iammituraj@gmail.com
   Notes        : Fully synthesisable, portable and tested code.
                  < 1 MHz clock is recommended for minimal resource usage; and < 10 ms as bouncing interval.
   License      : Open-source.
   Date         : Oct-28-2021
===============================================================================================================================*/

/*-------------------------------------------------------------------------------------------------------------------------------
                                                      D E B O U N C E R
-------------------------------------------------------------------------------------------------------------------------------*/

module debouncer #(
   
   // Global Parameters   
   parameter N_BOUNCE     =  3              // Bouncing interval in clock cycles = 2^N_BOUNCE
   
) 

(
   input  logic clk             ,           // Clock
   input  logic rstn            ,           // Active-low synchronous reset
   input  logic i_sig           ,           // Bouncing signal from switch
   output logic o_sig_debounced             // Debounced signal
) ;


/*-------------------------------------------------------------------------------------------------------------------------------
   Internal Registers/Signals
-------------------------------------------------------------------------------------------------------------------------------*/
logic                sig_rg, sig_d_rg, sig_debounced_rg ;        // Registers for switch state
logic [N_BOUNCE : 0] counter_rg                         ;        // Counter


/*-------------------------------------------------------------------------------------------------------------------------------
   Synchronous logic for debouncing
-------------------------------------------------------------------------------------------------------------------------------*/
always @(posedge clk) begin
   
   // Reset  
   if (!rstn) begin
      
      // Internal Registers
      sig_rg           <= 1'b0 ;
      sig_d_rg         <= 1'b0 ;
      sig_debounced_rg <= 1'b0 ;
      counter_rg       <=  1   ;

   end
   
   // Out of reset
   else begin
      
      // Register state of switch      
      sig_rg     <= i_sig                                     ;
      sig_d_rg   <= sig_rg                                    ;

      // Increment counter if two consecutive states are same, otherwise reset
      counter_rg <= (sig_d_rg == sig_rg) ? counter_rg + 1 : 1 ;
      
      // Counter overflow, valid state registered
      if (counter_rg [N_BOUNCE]) begin
         sig_debounced_rg <= sig_d_rg ;
      end

   end

end


/*-------------------------------------------------------------------------------------------------------------------------------
   Continuous Assignments
-------------------------------------------------------------------------------------------------------------------------------*/
assign o_sig_debounced = sig_debounced_rg ;


endmodule

/*-------------------------------------------------------------------------------------------------------------------------------
                                                      D E B O U N C E R
-------------------------------------------------------------------------------------------------------------------------------*/