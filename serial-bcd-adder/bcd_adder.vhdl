library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcd_adder is
    port (
            clk     : in    std_logic;
            rstn    : in    std_logic;
            a       : in    std_logic_vector(3 downto 0);
            b       : in    std_logic_vector(3 downto 0);
            start   : in    std_logic;
            done    : in    std_logic;
            sum     : out   std_logic_vector(3 downto 0)
         );
end entity bcd_adder;

architecture RTL of bcd_adder is

    -- FSM states type definition
    type fsm_state is (FSM_WAIT_START, FSM_COMPUTE);

    -- Constants definition

    -- Signals
    signal cs, ns : fsm_state;
    signal enable_compute : std_logic;
    signal curr_carry, next_carry : std_logic;

begin

    -- Carry register
    carry_reg: process(clk, rstn, next_carry, enable_compute, done) is
    begin
        if rising_edge(clk) then
            if (rstn = '0') or (done = '1') then
                curr_carry <= '0';
            elsif enable_compute = '1' then
                curr_carry <= next_carry;
            end if;
        end if;
    end process carry_reg;

    -- BCD adder datapath
    bcd_adder: process(a, b, enable_compute, curr_carry) is
       variable bcd_sum : unsigned(3 downto 0);
    begin
        bcd_sum := unsigned(a) + unsigned(b) + curr_carry;
        next_carry <= '0';

        if bcd_sum >= 10 then
            bcd_sum := bcd_sum - 10;
            next_carry <= '1';
        end if;

        sum <= std_logic_vector(bcd_sum);
    end process bcd_adder;


    -- FSM state register
    fsm_reg: process(clk) is
    begin
        if rising_edge(clk) then
            if rstn = '0' then
                cs <= FSM_WAIT_START;
            else
                cs <= ns;
            end if;
        end if;
    end process fsm_reg;

    -- FSM datapath
    fsm_datapath: process(cs, start, done) is
    begin

        -- Signals default value
        enable_compute <= '0';

        -- State switch case
        case cs is

            when FSM_WAIT_START =>
                case start is
                    when '1' =>
                        ns <= FSM_COMPUTE;
                        enable_compute <= '1';
                    when '0' => ns <= FSM_WAIT_START;
                    when others => ns <= FSM_WAIT_START;
                end case;

            when FSM_COMPUTE =>
                enable_compute <= '1';
                ns <= FSM_COMPUTE;
                if done = '1' then
                    ns <= FSM_WAIT_START;
                end if;

            when others =>
                ns <= FSM_WAIT_START;

        end case;
    end process fsm_datapath;

end architecture RTL;
