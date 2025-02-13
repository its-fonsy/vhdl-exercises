library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.env.finish;

-- Empty entity for testbench
entity TESTBENCH is
end TESTBENCH;

architecture behav of TESTBENCH is

  -- Constants definition
  constant clock_frequency  : integer := 100e6;
  constant clock_period     : time := 1000 ms / clock_frequency;

  -- Component definition
  component ENTITY_TO_TEST is
    port(
        clk : in std_logic
        );
  end component;

  -- Signals definitions
  signal clk         : std_logic := '0';
  signal rstn        : std_logic;

begin

  dut: ENTITY_TO_TEST port map(clk);

  -- Clock process
  clk <= not clk after clock_period / 2;

  -- Main simulation process
  stimuli: process is
  begin

    -- Initialize the signals
    rstn <= '1';
    wait until falling_edge(clk);
    
    -- Reset the system
    rstn <= '0';
    wait until falling_edge(clk);
    rstn <= '1';

    report "Test finished";
    finish;

  end process;

end behav;
