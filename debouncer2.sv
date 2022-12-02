/*===============================================================================================================================
   Module       : Debouncer

   Description  : Debouncer is used to filter bouncing found in typical switches and provide a clean, glitch-free state change.
                  -- Configurable threshold in powers of 2. 
                  -- Changes state at the output based on averaging the samples and filtering.
                     Switch state transition appears at output only if the averaged value crosses the threshold. 
                  -- Debounces both assertion and release of switches.                            
                  -- Supports both pull-up and pull-down switch inputs.
                  -- Debouncer is designed to debounce switches with pull-down (OFF state = '0', ON state = '1').                                        
                     For pull-up switches (OFF state = '1', ON state = '0'), debounced signal should be treated as valid 
                     only after one bouncing interval latency after reset. Because on reset, debounced signal 
                     drives '0' by default, which is ON state for pull-up switch. This may be undesirable. 
                     If the initial latency is undesired, IS_PULLUP parameter can be set.                      

   Developer    : Mitu Raj, chip@chipmunklogic.com at Chipmunk Logic ™, https://chipmunklogic.com
   Notes        : Fully synthesisable, portable and tested code.
                  < 10 MHz clock is recommended for minimal resource usage assuming < 10 ms as switch bouncing time.
   License      : Open-source.
   Date         : Dec-01-2022
===============================================================================================================================*/

/*-------------------------------------------------------------------------------------------------------------------------------
                                                      D E B O U N C E R
-------------------------------------------------------------------------------------------------------------------------------*/

module debouncer2 #(
   
   // Global Parameters   
   parameter N_THRESH    =  3   ,           // Threshold in clock cycles = 2^N_THRESH
   parameter IS_PULLUP   =  0               // Optional: '1' for pull-up switch, '0' for pull-down switch
                                                  
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
logic                isig_rg, isig_sync_rg              ;        // Registers in 2FF Synchronizer 
logic                sig_rg, sig_debounced_rg           ;        // Registers for switch's state
logic [N_THRESH : 0] counter_rg                         ;        // Counter


/*-------------------------------------------------------------------------------------------------------------------------------
   Synchronous logic for debouncing
-------------------------------------------------------------------------------------------------------------------------------*/
always @(posedge clk) begin
   
   // Reset  
   if (!rstn) begin
      
      // Internal Registers
      sig_rg           <= IS_PULLUP ; 
      sig_debounced_rg <= IS_PULLUP ;
      counter_rg       <=  0        ;

   end
   
   // Out of reset
   else begin
      
      // Register state of switch      
      sig_rg <= isig_sync_rg ;

      // Increment counter if sampled state = different from present state, otherwise decrement
      counter_rg <= (sig_rg != sig_debounced_rg) ? counter_rg + 1 : 
                    (counter_rg > 0) ? counter_rg - 1 : counter_rg ;
      
      // Counter overflow, valid state transition registered
      if (counter_rg [N_THRESH]) begin
         sig_debounced_rg <= sig_rg ;
      end

   end

end


/*-------------------------------------------------------------------------------------------------------------------------------
   2FF Synchronizer
-------------------------------------------------------------------------------------------------------------------------------*/
always @(posedge clk) begin
   
   // Reset  
   if (!rstn) begin
      
      // Internal Registers
      isig_rg      <= IS_PULLUP ;
      isig_sync_rg <= IS_PULLUP ;
      
   end
   
   // Out of reset
   else begin
      
      isig_rg      <= i_sig   ;        // Metastable flop
      isig_sync_rg <= isig_rg ;        // Synchronizing flop

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