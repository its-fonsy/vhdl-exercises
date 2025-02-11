library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity consumer is
  port (
        clk:            in  std_logic;
        rstn:           in  std_logic;
        put:            in  std_logic;
        payload:        in  std_logic_vector(7 downto 0);
        value_received: out std_logic_vector(31 downto 0);
        free:           out std_logic
       );
end entity;

architecture rtl of consumer is

  -- FSM type definition
  type fsm_state is (FSM_WAIT_PUT, FSM_RECEIVE);

  -- Signals definition
  signal cs: fsm_state;
  signal ns: fsm_state;
  signal counter_cnt: unsigned(1 downto 0);
  signal counter_reset: std_logic;
  signal receiving: std_logic;
  signal shifted_value_received: std_logic_vector(31 downto 0);
  signal next_shifted_value_received: std_logic_vector(31 downto 0);

begin

  next_shifted_value_received(23 downto 0) <= shifted_value_received(31 downto 8);
  next_shifted_value_received(31 downto 24) <= payload;
  value_received <= shifted_value_received;

  counter: process(clk, rstn, receiving, counter_reset) is
  begin
    if rising_edge(clk) then
      if (rstn = '0') or (counter_reset = '1')then
        counter_cnt <= (others => '0');
      elsif receiving = '1' then
        counter_cnt <= counter_cnt + 1;
      end if;
    end if;
  end process;

  shift_reg: process(clk, rstn, receiving, payload, next_shifted_value_received) is
  begin
    if rising_edge(clk) then
      if rstn = '0' then
        shifted_value_received <= (others => '0');
      elsif (receiving = '1') then
        shifted_value_received <= next_shifted_value_received;
      end if;
    end if;
  end process;

  -- FSM state register
  fsm_reg: process(clk, ns, rstn) is
  begin
    if rising_edge(clk) then
      if rstn = '0' then
        cs <= FSM_WAIT_PUT;
      else
        cs <= ns;
      end if;
    end if;
  end process;

  --FSM datapath
  fsm_datapath: process(cs, put, counter_cnt) is
  begin
    
    free <= '1';
    receiving <= '0';
    counter_reset <= '0';

    case cs is
      
      when FSM_WAIT_PUT =>
        case put is
          when '1' =>
            ns <= FSM_RECEIVE;
            receiving <= '1';
          when others => ns <= FSM_WAIT_PUT;
        end case;

      when FSM_RECEIVE =>
        free <= '0';
        receiving <= '1';
        if counter_cnt = 3 then
          ns <= FSM_WAIT_PUT;
          counter_reset <= '1';
        else
          ns <= FSM_RECEIVE;
        end if;

      when others =>
          ns <= FSM_WAIT_PUT;

    end case;
  end process;

end rtl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity tb_consumer is
end tb_consumer;

architecture testbench of tb_consumer is

  -- Constants definition
  constant clock_frequency : integer := 1e6;
  constant clock_period : time := 1000 ms / clock_frequency;

  -- Test data
  type data_array_t is array (0 to 3) of std_logic_vector(7 downto 0);
  constant data1 : data_array_t := ( X"AB", X"CD", X"EF", X"01" );
  constant data2 : data_array_t := ( X"DE", X"AD", X"BE", X"EF" );

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

  signal clk:            std_logic := '0';
  signal rstn:           std_logic;
  signal put:            std_logic;
  signal payload:        std_logic_vector(7 downto 0);
  signal value_received: std_logic_vector(31 downto 0);
  signal free:           std_logic;

begin

  dut: consumer port map(clk, rstn, put, payload, value_received, free);

  clk <= not clk after clock_period / 2;

  simuli: process is
  begin

    -- Initialize the system
    rstn <= '1';
    put <= '0';
    payload <= (others => '0');
    wait until falling_edge(clk);

    -- Reset
    rstn <= '0';
    wait until falling_edge(clk);
    rstn <= '1';

    wait until falling_edge(clk);

    -- Test receiving value
    put <= '1';
    for i in data1'range loop
      payload <= data1(i);
      wait until falling_edge(clk);
    end loop;
    put <= '0';

    wait until falling_edge(clk);
    
    -- Test receiving value
    put <= '1';
    for i in data2'range loop
      payload <= data2(i);
      wait until falling_edge(clk);
    end loop;
    put <= '0';

    wait until falling_edge(put);
    wait for 2 * clock_period;

    finish;
  end process;

end architecture;
