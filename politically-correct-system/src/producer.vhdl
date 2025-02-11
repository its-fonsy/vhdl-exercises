library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity producer is
  port (
        clk:            in  std_logic;
        rstn:           in  std_logic;
        value_to_send:  in  std_logic_vector(31 downto 0);
        free:           in  std_logic;
        put:            out std_logic;
        payload:        out std_logic_vector(7 downto 0)
       );
end entity;

architecture rtl of producer is

  -- FSM type definition
  type fsm_state is (FSM_WAIT_FREE, FSM_SEND);

  -- Signals definition
  signal cs: fsm_state;
  signal ns: fsm_state;
  signal counter_cnt: unsigned(1 downto 0);
  signal counter_reset: std_logic;
  signal sending: std_logic;
  signal shifted_value_to_send: std_logic_vector(31 downto 0);
  signal next_shifted_value_to_send: std_logic_vector(31 downto 0);

begin

  next_shifted_value_to_send <= std_logic_vector(shift_right(unsigned(shifted_value_to_send), 8));
  payload <= shifted_value_to_send(7 downto 0);

  counter: process(clk, rstn, sending, counter_reset) is
  begin
    if rising_edge(clk) then
      if (rstn = '0') or (counter_reset = '1')then
        counter_cnt <= (others => '0');
      elsif sending = '1' then
        counter_cnt <= counter_cnt + 1;
      end if;
    end if;
  end process;

  shift_reg: process(clk, rstn, value_to_send, sending) is
  begin
    if rising_edge(clk) then
      if (rstn = '0') or (counter_cnt = 0) then
        shifted_value_to_send <= value_to_send;
      elsif (sending = '1') then
        shifted_value_to_send <= next_shifted_value_to_send;
      end if;
    end if;
  end process;

  -- FSM state register
  fsm_reg: process(clk, ns, rstn) is
  begin
    if rising_edge(clk) then
      if rstn = '0' then
        cs <= FSM_WAIT_FREE;
      else
        cs <= ns;
      end if;
    end if;
  end process;

  --FSM datapath
  fsm_datapath: process(cs, free, counter_cnt) is
  begin
    
    put <= '0';
    sending <= '0';
    counter_reset <= '0';

    case cs is
      
      when FSM_WAIT_FREE =>
        case free is
          when '1' =>
            ns <= FSM_SEND;
            sending <= '1';
          when others => ns <= FSM_WAIT_FREE;
        end case;

      when FSM_SEND =>
        put <= '1';
        sending <= '1';
        if counter_cnt = 0 then
          ns <= FSM_WAIT_FREE;
          counter_reset <= '1';
        else
          ns <= FSM_SEND;
        end if;

      when others =>
          ns <= FSM_WAIT_FREE;

    end case;
  end process;

end rtl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity tb_producer is
end tb_producer;

architecture testbench of tb_producer is

  -- Constants definition
  constant clock_frequency : integer := 1e6;
  constant clock_period : time := 1000 ms / clock_frequency;

  -- Component definition
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
  signal value_to_send:  std_logic_vector(31 downto 0);
  signal free:           std_logic;
  signal put:            std_logic;
  signal payload:        std_logic_vector(7 downto 0);

begin

  dut: producer port map(clk, rstn, value_to_send, free, put, payload);

  clk <= not clk after clock_period / 2;

  simuli: process is
  begin

    -- Initialize the system
    rstn <= '1';
    value_to_send <= X"1234ABCD";
    free <= '0';
    wait until falling_edge(clk);

    -- Reset
    rstn <= '0';
    wait until falling_edge(clk);
    rstn <= '1';

    -- Test sending value
    free <= '1';
    wait until rising_edge(put);
    wait for clock_period;
    free <= '0';

    wait until falling_edge(put);
    wait until falling_edge(clk);
    
    -- Test sending value
    value_to_send <= X"BADC0FFE";
    free <= '1';
    wait until rising_edge(put);
    wait for clock_period;
    free <= '0';

    wait until falling_edge(put);
    wait for 2 * clock_period;

    finish;
  end process;

end architecture;
