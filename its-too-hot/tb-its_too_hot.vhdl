library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.env.finish;

-- Empty entity for testbench
entity tb is
end tb;

architecture behav of tb is

  -- Test data array
  type data_array_t is array (0 to 7) of std_logic_vector(4 downto 0);
  constant test_data : data_array_t := (  "00110", "00000", "01010", "11111",
                                          "00000", "11100", "10001", "01100" );

  -- Constants definition
  constant clock_freq   : integer := 100e6;
  constant clock_period : time := 1000 ms / clock_freq;

  -- Component definition
  component its_too_hot is
    port (
          clk         : in  std_logic;
          rstn        : in  std_logic;
          data_in     : in  std_logic;
          data_valid  : out std_logic
         );
  end component;

  -- Signals definitions
  signal clk         : std_logic := '0';
  signal rstn        : std_logic;
  signal data_in     : std_logic;
  signal data_valid  : std_logic;

begin

  dut: its_too_hot port map(clk, rstn, data_in, data_valid);

  -- Clock process
  clk <= not clk after clock_period / 2;

  -- Main simulation process
  stimuli: process is
    variable i, j : integer;
    variable data : std_logic_vector(4 downto 0);
  begin

    -- Initialize the signals
    rstn <= '1';
    data_in <= '0';
    wait until falling_edge(clk);
    
    -- Reset the system
    rstn <= '0';
    wait until falling_edge(clk);
    rstn <= '1';

    -- Send the test values
    for i in test_data'range loop
      data := test_data(i);
      for j in 0 to 4 loop
        data_in <= data(j);
        wait until falling_edge(clk);
      end loop;
    end loop;

    wait for clock_period;

    report "Test finished";
    finish;

  end process;

end behav;
