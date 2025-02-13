library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serial_adder is
    port(
             a               : in    std_logic;
             b               : in    std_logic;
             start           : in    std_logic;
             rstn            : in    std_logic;
             clk             : in    std_logic;
             sum             : out   std_logic_vector(5 downto 0);
             done            : out   std_logic;
             cout            : out   std_logic;
             zero            : out   std_logic;
             neg             : out   std_logic
        );
end serial_adder;

architecture RTL of serial_adder is

    -- FSM states type definition
    type fsm_state is (FSM_WAIT_START, FSM_RX, FSM_DONE);

    -- Signals definition
    signal cs, ns : fsm_state;
    signal curr_sum, next_sum : std_logic_vector(5 downto 0);
    signal curr_cout, next_cout : std_logic;
    signal bit_count: unsigned(3 downto 0);
    signal receiving_bits, reset_bit_count: std_logic;
    signal sum_finished : std_logic;

begin

    -- Full adder
    full_adder : process(curr_sum, a, b, bit_count) is
    begin
        next_sum <= curr_sum;
        next_sum(to_integer(bit_count)) <= a xor b xor curr_cout;
    end process full_adder;

    next_cout <= ((a xor b) and curr_cout) xor (a and b);

    -- Output signals
    sum <= curr_sum;

    -- Sum register
    sum_reg: process(clk, rstn, next_cout) is
    begin
        if rising_edge(clk) then
            if (rstn = '0') or (sum_finished = '1') then
                curr_sum <= (others => '0');
                curr_cout <= '0';
            else
                curr_sum <= next_sum;
                curr_cout <= next_cout;
            end if;
        end if;
    end process sum_reg;

    -- Counter of the received bits
    bit_counter: process(clk, rstn, reset_bit_count, receiving_bits) is
    begin
        if rising_edge(clk) then
            if (rstn = '0') or (reset_bit_count = '1') then
                bit_count <= (others => '0');
            elsif receiving_bits = '1' then
                bit_count <= bit_count + 1;
            end if;
        end if;
    end process bit_counter;

    -- FSM state register
    fsm_reg: process(clk, rstn, ns) is
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
    fsm_datapath: process(cs, start, bit_count) is
    begin

        -- Default signals values
        receiving_bits <= '0';
        reset_bit_count <= '0';
        sum_finished <= '0';

        -- Outputs
        done <= '0';
        zero <= '0';
        neg <= '0';
        cout <= '0';

        -- State switch case
        case cs is

            when FSM_WAIT_START =>
                case start is
                    when '0' => ns <= FSM_WAIT_START;
                    when '1' =>
                        ns <= FSM_RX;
                        receiving_bits <= '1';
                    when others => ns <= FSM_WAIT_START;
                end case;

            when FSM_RX =>
                receiving_bits <= '1';
                ns <= FSM_RX;
                if bit_count = 5 then
                    reset_bit_count <= '1';
                    ns <= FSM_DONE;
                end if;

            when FSM_DONE =>
                sum_finished <= '1';

                -- outputs
                done <= '1';
                zero <= not (or curr_sum);
                neg <= sum(5);
                cout <= curr_cout;

                case start is
                    when '0' => ns <= FSM_WAIT_START;
                    when '1' => ns <= FSM_RX;
                    when others => ns <= FSM_WAIT_START;
                end case;

            when others => ns <= FSM_WAIT_START;

        end case;
    end process fsm_datapath;

end RTL;
