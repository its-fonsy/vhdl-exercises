library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity crc_sender is
    port (
            clk :       in  std_logic;
            rstn :      in  std_logic;
            start :     in  std_logic;
            data_in :   in  std_logic;
            data_out :  out std_logic;
            done :      out std_logic
         );
end entity crc_sender;

architecture RTL of crc_sender is

    -- FSM states type definition
    type fsm_state is (FSM_WAIT_START, FSM_RX, FSM_TX);

    -- Signals
    signal cs, ns               : fsm_state;
    signal curr_crc, next_crc   : std_logic_vector(4 downto 0);
    signal cnt                  : unsigned(4 downto 0);
    signal enable_counter       : std_logic;
    signal reset_counter        : std_logic;
    signal reset_crc            : std_logic;
    signal curr_rem, next_rem   : std_logic_vector(4 downto 0);

begin

    with cs select
        data_out <=     data_in when FSM_RX,
                    curr_rem(4) when FSM_TX,
                            '0' when others;

    -- curr_remainder reg
    remainder_reg : process (clk, rstn, cnt, curr_crc, next_rem) is
    begin
        if rising_edge(clk) then
            if rstn = '0' then
                curr_rem <= (others => '0');
            elsif cnt = 10 then
                curr_rem <= not curr_crc;
            else
                curr_rem <= next_rem;
            end if;
        end if;
    end process remainder_reg;

    next_rem <= curr_rem sll 1;

    counter : process(clk, rstn, enable_counter) is
    begin
        if rising_edge(clk) then
            if (rstn = '0') or (reset_counter = '1') then
                cnt <= (others => '0');
            elsif enable_counter = '1' then
                cnt <= cnt + 1;
            end if;
        end if;
    end process counter;

    -- Next curr_crc value datapath
    next_crc_datapath : process(curr_crc, data_in) is
    begin
        next_crc <= curr_crc sll 1;
        next_crc(0) <= data_in xor curr_crc(4);
        next_crc(2) <= curr_crc(1) xor (data_in xor curr_crc(4));
    end process next_crc_datapath;

    -- curr_crc reg
    curr_crc_reg : process (clk, rstn, next_crc) is
    begin
        if rising_edge(clk) then
            if (rstn = '0') or (reset_crc = '1') then
                curr_crc <= (others => '1');
            else
                curr_crc <= next_crc;
            end if;
        end if;
    end process curr_crc_reg;

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
    fsm_datapath: process(cs, start, cnt) is
    begin

        -- Default signals values
        enable_counter <= '0';
        reset_counter <= '0';
        reset_crc <= '0';
        done <= '0';

        -- State switch case
        case cs is

            when FSM_WAIT_START =>
                if start = '1' then
                    ns <= FSM_RX;
                else
                    ns <= FSM_WAIT_START;
                end if;

            when FSM_RX =>
                enable_counter <= '1';
                if cnt = 10 then
                    ns <= FSM_TX;
                    reset_counter <= '1';
                else 
                    ns <= FSM_RX;
                end if;

            when FSM_TX =>
                enable_counter <= '1';
                if cnt = 4 then
                    ns <= FSM_WAIT_START;
                    reset_counter <= '1';
                    reset_crc <= '1';
                    done <= '1';
                else
                    ns <= FSM_TX;
                end if;

            when others =>
                ns <= FSM_WAIT_START;

        end case;
    end process fsm_datapath;

end architecture RTL;
