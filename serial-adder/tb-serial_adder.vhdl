library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.env.finish;

-- Empty entity for testbench
entity TESTBENCH is
    end TESTBENCH;

architecture behav of TESTBENCH is

    -- Test data array
    type data_array_t is array (0 to 3) of std_logic_vector(5 downto 0);
    constant test_a : data_array_t := (6D"15", 6D"0", 6D"19", 6D"60");
    constant test_b : data_array_t := (6D"18", 6D"0", 6D"31", 6D"3");

    -- Constants definition
    constant clock_frequency  : integer := 100e6;
    constant clock_period     : time := 1000 ms / clock_frequency;

    -- Component definition
    component serial_adder is
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
    end component serial_adder;

    -- Signals definitions
    signal a                : std_logic;
    signal b                : std_logic;
    signal start            : std_logic;
    signal rstn             : std_logic;
    signal clk              : std_logic := '0';
    signal sum              : std_logic_vector(5 downto 0);
    signal done             : std_logic;
    signal cout             : std_logic;
    signal zero             : std_logic;
    signal neg              : std_logic;

begin

    dut: serial_adder port map(a, b, start, rstn, clk, sum, done, cout, zero, neg);

    -- Clock process
    clk <= not clk after clock_period / 2;

    -- Main simulation process
    stimuli: process is
        variable i,j : integer;
        variable expected_sum : unsigned(5 downto 0);
    begin

        -- Initialize the signals
        a <= '0';
        b <= '0';
        start <= '0';
        rstn <= '1';
        wait until falling_edge(clk);

        -- Reset the system
        rstn <= '0';
        wait until falling_edge(clk);
        rstn <= '1';

        -- Test 4 sums
        for i in test_a'range loop

            -- Send start
            wait until falling_edge(clk);
            start <= '1';

            -- Send the 6-bit sequence of "a" and "b"
            for j in 0 to 5 loop
                a <= test_a(i)(j);
                b <= test_b(i)(j);
                wait until falling_edge(clk);
                start <= '0';
            end loop;

            -- Assert the correctness of the computed sum
            expected_sum := unsigned(test_a(i)) + unsigned(test_b(i));
            assert unsigned(sum) = expected_sum
                report "Summing " & integer'image(to_integer(unsigned(test_a(i)))) &
                    " + " & integer'image(to_integer(unsigned(test_b(i)))) &
                    ". Expected " & integer'image(to_integer(expected_sum)) &
                    ", got " & integer'image(to_integer(unsigned(sum)))
                severity error;

        end loop;

        a <= '0';
        b <= '0';

        wait for 2 * clock_period;
        finish;

    end process stimuli;

end behav;
