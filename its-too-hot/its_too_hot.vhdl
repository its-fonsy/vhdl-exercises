library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity its_too_hot is
  port (
        clk         : in  std_logic;
        rstn        : in  std_logic;
        data_in     : in  std_logic;
        data_valid  : out std_logic
       );
end its_too_hot;

architecture rtl of its_too_hot is

  -- FSM states type definition
  type fsm_state is (INIT, RX, SET_VALID);

  -- Signals
  signal bit_count      : unsigned(2 downto 0);
  signal n_ones         : unsigned(2 downto 0);
  signal reset_counters : std_logic;
  signal cs, ns         : fsm_state;

begin

  bit_counter: process (clk) is
  begin
    if rising_edge(clk) then
      if reset_counters = '1' then
        bit_count <= (others => '0');
      else
        bit_count <= bit_count + 1;
      end if;
    end if;
  end process;

  ones_counter: process (clk) is
  begin
    if rising_edge(clk) then
      if reset_counters = '1' then
        case data_in is
          when '1' => n_ones <= B"001";
          when others => n_ones <= (others => '0');
        end case;
      else
        if data_in = '1' then
          n_ones <= n_ones + 1;
        end if;
      end if;
    end if;
  end process;

  -- FSM flip-flop
  state_ff: process (clk) is
  begin
    if rising_edge(clk) then
      if rstn = '0' then
        cs <= INIT;
      else
        cs <= ns;
      end if;
    end if;
  end process;

  -- FSM datapath
  FSM: process (cs, bit_count) is
  begin
    data_valid <= '0';
    reset_counters <= '0';

    case cs is
      when INIT =>
        ns <= RX;
        reset_counters <= '1';

      when RX =>
        case to_integer(bit_count) is
          when 3 =>
            ns <= SET_VALID;
          when others =>
            ns <= RX;
        end case;

      when SET_VALID =>
        if n_ones = 2 then
          data_valid <= '1';
        end if;
        reset_counters <= '1';
        ns <= RX;

      when others =>
        ns <= INIT;

    end case;
  end process;

end rtl;

