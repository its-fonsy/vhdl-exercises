library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ENTITY_NAME is
  port (
        clk   : in  std_logic;
        rstn  : in  std_logic
       );
end ENTITY_NAME;

architecture RTL of ENTITY_NAME is

  -- FSM states type definition
  type fsm_state is (FSM_INIT);

  -- Constants definition

  -- Signals
  signal cs, ns : fsm_state;

begin

  -- FSM state register
  fsm_reg: process(clk) is
  begin
    if rising_edge(clk) then
      if rstn = '0' then
        cs <= FSM_INIT;
      else
        cs <= ns;
      end if;
    end if;
  end process;

  -- FSM datapath
  fsm_datapath: process(cs) is
  begin

    -- Default signals values

    -- State switch case
    case cs is

      when FSM_INIT =>
        ns <= FSM_INIT;

      when others =>
        ns <= FSM_INIT;

    end case;
  end process;

end RTL;
