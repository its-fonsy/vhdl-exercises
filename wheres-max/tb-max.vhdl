library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.env.finish;

entity tb is
end tb;

architecture stimuli of tb is

  -- Constants definition
  constant clock_frequency: integer := 1e6;
  constant clock_period: time := 1000 ms / clock_frequency;

  -- Test data
  type data_array_t is array (integer range <>) of std_logic_vector(7 downto 0);
  constant test_data1: data_array_t := (X"32", X"11", X"F0", X"05");
  constant test_data2: data_array_t := (X"22", X"AA", X"F0", X"00", X"25", X"FA", X"B0", X"CC");

  -- Component definition
  component max is
      port(
          clk:        in  std_logic;
          rstn:       in  std_logic;
          start:      in  std_logic;
          inputA:     in  std_logic_vector(7 downto 0);
          done:       out std_logic;
          maxValue:   out std_logic_vector(7 downto 0)
          );
  end component;

  -- Signals definition
  signal clk:       std_logic := '0';
  signal rstn:      std_logic;
  signal start:     std_logic;
  signal inputA:    std_logic_vector(7 downto 0);
  signal done:      std_logic;
  signal maxValue:  std_logic_vector(7 downto 0);

begin

  dut: max port map(clk, rstn, start, inputA, done, maxValue);

  clk <= not clk after clock_period / 2;

  stimuli: process is
    variable i: integer;
  begin
    rstn <= '1';
    start <= '0';
    inputA <= X"00";
    wait until falling_edge(clk);

    -- Reset the system
    rstn <= '0';
    wait until falling_edge(clk);
    rstn <= '1';

    -- Test first set of data
    start <= '1';
    for i in test_data1'range loop
      inputA <= test_data1(i);
      wait until falling_edge(clk);
    end loop;
    start <= '0';

    wait for 2*clock_period;

    -- Test second set of data
    start <= '1';
    for i in test_data2'range loop
      inputA <= test_data2(i);
      wait until falling_edge(clk);
    end loop;
    start <= '0';

    wait for 2*clock_period;

    finish;
  end process;

end stimuli;
