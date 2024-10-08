
module i2c_slave_top (
  input logic clk_27mhz, // board clock, this should be faster than SCL
  input logic button_s1, // board button, reset
  input logic scl,
  inout wire  sda
);

  logic clk;
  assign clk = clk_27mhz;

  logic rst_n;
  logic sda_out;
  logic sda_in;
  
  logic [7:0] addr;
  logic [7:0] wdata;
  logic [7:0] rdata;
  logic       wr_en_wdata;
  logic       wr_en_wdata_sync;
  logic [1:0] sda_shift;
  
  assign sda_in = sda; // this is for read-ablity
  
  // button_s1 is low when pressed
  synchronizer u_synchronous_rst_n
  ( .clk,                   // input
    .rst_n    (button_s1),  // input
    .data_in  (1'b1),       // input
    .data_out (rst_n)       // output
  );
    
  bidir u_sda
  ( .pad    ( sda ),     // inout
    .to_pad ( sda_out ), // input
    .oe     ( ~sda_out)  // input, open drain
  );

  i2c_slave 
  # ( .SLAVE_ID(7'h24) )
  u_i2c_slave
  ( .rst_n,                // input 
    .scl,                  // input 
    .sda_in,               // input 
    .sda_out,              // output  
    .i2c_active      ( ),  // output 
    .rd_en           ( ),  // output
    .wr_en           ( ),  // output
    .rdata,                // input [7:0]
    .addr,                 // output [7:0]
    .wdata,                // output [7:0]
    .wr_en_wdata           // output
  );
  
  synchronizer u_wr_en_sync
  ( .clk,                        // input
    .rst_n    (rst_n),           // input
    .data_in  (wr_en_wdata),     // input
    .data_out (wr_en_wdata_sync) // output
  );

  reg_map u_reg_map
  ( .clk,                     // input
    .rst_n,                   // input
    .addr,                    // input [7:0], data is stable when used
    .wdata,                   // input [7:0], data is stable when used
    .wr_en_wdata (wr_en_wdata_sync), // input
    .rdata,                   // output [7:0]
    .register_0 ( ),          // output [7:0]
    .register_1 ( ),          // output [7:0]
    .register_2 ( ),          // output [7:0]
    .register_3 ( )           // output [7:0]
  );

endmodule