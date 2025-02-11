library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity pcs is
end entity;

architecture tb of pcs is

  -- Constants definition
  constant clock_frequency : integer := 1e6;
  constant clock_period : time := 1000 ms / clock_frequency;

  -- Component definition
  component consumer is
    port (
           clk:            in  std_logic;
           rstn:           in  std_logic;
           put:            in  std_logic;
           payload:        in  std_logic_vector(7 downto 0);
           value_received: out std_logic_vector(31 downto 0);
           free:           out std_logic
         );
  end component;

  component producer is
    port (
           clk:            in  std_logic;
           rstn:           in  std_logic;
           value_to_send:  in  std_logic_vector(31 downto 0);
           free:           in  std_logic;
           put:            out std_logic;
           payload:        out std_logic_vector(7 downto 0)
         );
  end component;

  signal clk:            std_logic := '0';
  signal rstn:           std_logic;
  signal put:            std_logic;
  signal payload:        std_logic_vector(7 downto 0);
  signal value_received: std_logic_vector(31 downto 0);
  signal value_to_send:  std_logic_vector(31 downto 0);
  signal free:           std_logic;

begin

  con0: consumer port map(clk, rstn, put, payload, value_received, free);
  pro0: producer port map(clk, rstn, value_to_send, free, put, payload);

  clk <= not clk after clock_period / 2;

  stimuli: process is
  begin

    -- Initialize the system
    value_to_send <= X"01234567";
    rstn <= '1';

    -- Reset
    wait until falling_edge(clk);
    rstn <= '0';
    wait until falling_edge(clk);
    rstn <= '1';

    wait until falling_edge(put);
    wait until falling_edge(clk);

    value_to_send <= X"DEADBEEF";
    wait until falling_edge(put);
    wait until falling_edge(clk);

    wait for clock_period;

    finish;
  end process;

end architecture;
