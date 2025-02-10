library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity max is
    port(
        clk:        in  std_logic;
        rstn:       in  std_logic;
        start:      in  std_logic;
        inputA:     in  std_logic_vector(7 downto 0);
        done:       out std_logic;
        maxValue:   out std_logic_vector(7 downto 0)
        );
end max;

architecture rtl of max is 

  -- FSM states type definition
  type fsm_state is (FSM_WAIT_FOR_START, FSM_UPDATE_MAX, FSM_DONE);

  -- Signals definition
  signal cs:          fsm_state;
  signal ns:          fsm_state;
  signal update_max:  std_logic;
  signal reset_max:   std_logic;
  signal max:         unsigned(7 downto 0);

begin
  
  update_max_reg: process(clk, rstn, update_max, reset_max, inputA) is
  begin
    if rising_edge(clk) then
      if (rstn = '0') or (reset_max = '1') then
        max <= (others => '0');
      else
        if (update_max = '1') and (unsigned(inputA) > max) then
          max <= unsigned(inputA);
        end if;
      end if;
    end if;
  end process;

  maxValue <= std_logic_vector(max);

  -- FSM state register
  fsm_reg: process(clk) is
  begin
    if rising_edge(clk) then
      case rstn is
        when '0' => cs <= FSM_WAIT_FOR_START;
        when '1' => cs <= ns;
        when others => cs <= FSM_WAIT_FOR_START;
      end case;
    end if;
  end process;

  -- FSM datapath
  fsm_datapath: process(cs, start, inputA) is
  begin

    -- Default value state signals
    done <= '0';
    update_max <= '0';
    reset_max <= '0';

    case cs is

      when FSM_WAIT_FOR_START =>
        if start = '0' then
          ns <= FSM_WAIT_FOR_START;
        else
          ns <= FSM_UPDATE_MAX;
          update_max <= '1';
        end if;

      when FSM_UPDATE_MAX =>
        update_max <= '1';
        if start = '1' then
          ns <= FSM_UPDATE_MAX;
        else
          ns <= FSM_DONE;
        end if;

      when FSM_DONE =>
        done <= '1';
        reset_max <= '1';
        ns <= FSM_WAIT_FOR_START;

      when others =>
        ns <= FSM_WAIT_FOR_START;

    end case;

  end process;

end rtl;

