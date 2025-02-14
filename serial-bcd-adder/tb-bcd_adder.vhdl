library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.env.finish;

-- Empty entity for testbench
entity TESTBENCH is
    end TESTBENCH;

architecture behav of TESTBENCH is

    -- Test data array
    type data_array_t is array (0 to 3) of integer;
    constant test_data_a : data_array_t := (1455,  33,   34, 753);
    constant test_data_b : data_array_t := (  55, 127,  987, 207);

    -- Constants definition
    constant clock_frequency  : integer := 100e6;
    constant clock_period     : time := 1000 ms / clock_frequency;

    -- Component definition
    component bcd_adder is
        port (
                 clk     : in    std_logic;
                 rstn    : in    std_logic;
                 a       : in    std_logic_vector(3 downto 0);
                 b       : in    std_logic_vector(3 downto 0);
                 start   : in    std_logic;
                 done    : in    std_logic;
                 sum     : out   std_logic_vector(3 downto 0)
             );
    end component bcd_adder;

    -- Signals definitions
    signal clk     : std_logic := '0';
    signal rstn    : std_logic;
    signal a       : std_logic_vector(3 downto 0);
    signal b       : std_logic_vector(3 downto 0);
    signal start   : std_logic;
    signal done    : std_logic;
    signal sum     : std_logic_vector(3 downto 0);


begin -- architecture behav

    dut: bcd_adder port map(clk, rstn, a, b, start, done, sum);

    -- Clock process
    clk <= not clk after clock_period / 2;

    -- Main simulation process
    stimuli: process is

        -- Variables definition
        variable n1, n2 : integer;

        -- Procedures definition
        procedure send_bcd(
                            signal a        : out   std_logic_vector(3 downto 0);
                            signal b        : out   std_logic_vector(3 downto 0);
                            signal sum      : in    std_logic_vector(3 downto 0);
                            signal clk      : in    std_logic;
                            signal start    : out   std_logic;
                            signal done     : out   std_logic
                          ) is

            variable expected_sum       : integer;

        begin -- procedure send_bcd

            -- Variable/Signal setup and report to the user what we are sending and
            -- and what we are expecting as result
            expected_sum := n1 + n2;
            start <= '1';
            report  "Sending " & integer'image(n1) &
                    " + " & integer'image(n2) &
                    " expect " & integer'image(expected_sum);

            -- Start sending the digits
            while (n1 > 0) or (n2 > 0) loop

                -- Setting the signals to the first digit of n1/n2
                a <= std_logic_vector(to_unsigned(n1 rem 10, a'length));
                b <= std_logic_vector(to_unsigned(n2 rem 10, b'length));

                -- Decimal right shift n1/n2 of one digit
                n1 := n1 / 10;
                n2 := n2 / 10;

                -- If both n1 and n2 are zero means that every digit has been sent
                if (n1 = 0) and (n2 = 0) then done <= '1'; end if;

                -- Wait for delta cycle to read output
                wait for clock_period / 10;

                -- Assert that the sum is correct
                assert integer(expected_sum rem 10) = to_integer(unsigned(sum))
                    report  "Expected " & integer'image(expected_sum rem 10) &
                            " got " & integer'image(to_integer(unsigned(sum)))
                    severity error;

                -- Decimal right shift the expected sum of one digit
                expected_sum := expected_sum / 10;

                -- Wait next rising to send the new digits
                wait until rising_edge(clk);
                start <= '0';
                done <= '0';

            end loop;

        end procedure send_bcd;

    begin -- stimuli process

        -- Initialize the signals
        rstn <= '1';
        start <= '0';
        done <= '0';
        a <= 4D"0";
        b <= 4D"0";
        wait until falling_edge(clk);

        -- Reset the system
        rstn <= '0';
        wait until falling_edge(clk);
        rstn <= '1';

        wait until falling_edge(clk);

        -- Test the DUT
        for i in test_data_a'range loop
            n1 := test_data_a(i);
            n2 := test_data_b(i);
            send_bcd(a, b, sum, clk, start, done);
        end loop;

        report "Test finished";
        finish;

    end process;

end behav;
