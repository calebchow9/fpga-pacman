//Legal Notice: (C)2021 Altera Corporation. All rights reserved.  Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module lab62soc_timer_0 (
                          // inputs:
                           address,
                           chipselect,
                           clk,
                           reset_n,
                           write_n,
                           writedata,

                          // outputs:
                           irq,
                           readdata,
                           resetrequest
                        )
;

  output           irq;
  output  [ 15: 0] readdata;
  output           resetrequest;
  input   [  3: 0] address;
  input            chipselect;
  input            clk;
  input            reset_n;
  input            write_n;
  input   [ 15: 0] writedata;


wire             clk_en;
wire             control_interrupt_enable;
reg              control_register;
wire             control_wr_strobe;
reg              counter_is_running;
wire             counter_is_zero;
wire    [ 15: 0] counter_load_value;
reg              delayed_unxcounter_is_zeroxx0;
reg              delayed_unxtimeout_occurredxx1;
wire             do_start_counter;
wire             do_stop_counter;
reg              force_reload;
reg     [ 15: 0] internal_counter;
wire             irq;
wire             period_halfword_0_wr_strobe;
wire             period_halfword_1_wr_strobe;
wire             period_halfword_2_wr_strobe;
wire             period_halfword_3_wr_strobe;
wire    [ 15: 0] read_mux_out;
reg     [ 15: 0] readdata;
wire             resetrequest;
wire             start_strobe;
wire             status_wr_strobe;
reg     [  1: 0] timeout_counter;
wire    [  1: 0] timeout_counter_load_value;
wire             timeout_detected;
wire             timeout_event;
reg              timeout_occurred;
  assign clk_en = 1;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          internal_counter <= 16'hC34F;
      else if (counter_is_running || force_reload)
          if (counter_is_zero    || force_reload)
              internal_counter <= counter_load_value;
          else 
            internal_counter <= internal_counter - 1;
    end


  assign counter_is_zero = internal_counter == 0;
  assign counter_load_value = 16'hC34F;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          force_reload <= 0;
      else if (clk_en)
          force_reload <= period_halfword_3_wr_strobe || period_halfword_2_wr_strobe || period_halfword_1_wr_strobe || period_halfword_0_wr_strobe;
    end


  assign do_start_counter = start_strobe;
  assign do_stop_counter = 0;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          counter_is_running <= 1'b0;
      else if (clk_en)
          if (do_start_counter)
              counter_is_running <= -1;
          else if (do_stop_counter)
              counter_is_running <= 0;
    end


  //delayed_unxcounter_is_zeroxx0, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          delayed_unxcounter_is_zeroxx0 <= 0;
      else if (clk_en)
          delayed_unxcounter_is_zeroxx0 <= counter_is_zero;
    end


  assign timeout_event = (counter_is_zero) & ~(delayed_unxcounter_is_zeroxx0);
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          timeout_occurred <= 0;
      else if (clk_en)
          if (status_wr_strobe)
              timeout_occurred <= 0;
          else if (timeout_event)
              timeout_occurred <= -1;
    end


  assign irq = timeout_occurred && control_interrupt_enable;
  //s1, which is an e_avalon_slave
  //delayed_unxtimeout_occurredxx1, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          delayed_unxtimeout_occurredxx1 <= 0;
      else if (clk_en)
          delayed_unxtimeout_occurredxx1 <= timeout_occurred;
    end


  assign timeout_detected = (timeout_occurred) & ~(delayed_unxtimeout_occurredxx1);
  assign timeout_counter_load_value = 2;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          timeout_counter <= 0;
      else if (timeout_detected || timeout_counter > 0)
          if (timeout_detected)
              timeout_counter <= timeout_counter_load_value;
          else 
            timeout_counter <= timeout_counter - 1;
    end


  assign resetrequest = timeout_counter > 0;
  assign read_mux_out = ({16 {(address == 1)}} & control_register) |
    ({16 {(address == 0)}} & {counter_is_running,
    timeout_occurred});

  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          readdata <= 0;
      else if (clk_en)
          readdata <= read_mux_out;
    end


  assign period_halfword_0_wr_strobe = chipselect && ~write_n && (address == 2);
  assign period_halfword_1_wr_strobe = chipselect && ~write_n && (address == 3);
  assign period_halfword_2_wr_strobe = chipselect && ~write_n && (address == 4);
  assign period_halfword_3_wr_strobe = chipselect && ~write_n && (address == 5);
  assign control_wr_strobe = chipselect && ~write_n && (address == 1);
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          control_register <= 0;
      else if (control_wr_strobe)
          control_register <= writedata[0];
    end


  assign start_strobe = writedata[2] && control_wr_strobe;
  assign control_interrupt_enable = control_register;
  assign status_wr_strobe = chipselect && ~write_n && (address == 0);

endmodule

