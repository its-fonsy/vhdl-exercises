library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

use std.env.finish;

-- Empty entity for testbench
entity TESTBENCH is
    end TESTBENCH;

architecture behav of TESTBENCH is

    -- Constants definition
    constant clock_frequency  : integer := 100e6;
    constant clock_period     : time := 1000 ms / clock_frequency;

    -- Component definition
    component crc_sender is
        port (
                clk         :   in  std_logic;
                rstn        :   in  std_logic;
                start       :   in  std_logic;
                data_in     :   in  std_logic;
                data_out    :   out std_logic;
                done        :   out std_logic
             );
    end component crc_sender;

    -- Signals definitions
    signal clk          : std_logic := '0';
    signal rstn         : std_logic;
    signal start        : std_logic;
    signal done         : std_logic;
    signal data_in      : std_logic;
    signal data_out     : std_logic;
    file file_test_msg  : text;

begin   -- architecture

    dut: crc_sender port map(clk, rstn, start, data_in, data_out, done);

    -- Clock process
    clk <= not clk after clock_period / 2;

    -- Main simulation process
    stimuli: process is

        variable v_ILINE        : line;
        variable v_SPACE        : character;
        variable file_msg       : std_logic_vector(10 downto 0);
        variable file_crc       : std_logic_vector(4 downto 0);
        variable msg            : std_logic_vector(0 to 10);
        variable computed_crc   : std_logic_vector(4 downto 0);

        -- Procedure to send the 11-bit message stored in variable "msg"
        procedure send_message(
                                signal data_in  : out std_logic;
                                signal clk      : in std_logic;
                                signal start    : out std_logic
        ) is
        begin   -- procedure send_message
            start <= '1';
            for i in msg'range loop
                data_in <= msg(i);
                wait until falling_edge(clk);
                start <= '0';
            end loop;
        end procedure send_message;

        -- Procedure that reads the crc_sender and saves it to "computed_crc" variable
        procedure read_crc(
                                signal clk      : in std_logic;
                                signal data_out : in std_logic
        ) is
        begin   -- procedure read_crc
            computed_crc := (others => '0');
            for i in 0 to 4 loop
                wait until rising_edge(clk);
                wait for 5 ps;
                computed_crc := computed_crc sll 1;
                computed_crc(0) := data_out;
            end loop;
        end procedure read_crc;


    begin -- process stimuli

        -- Initialize the signals
        rstn <= '1';
        data_in <= '0';
        start <= '0';
        wait until falling_edge(clk);

        -- Reset the system
        rstn <= '0';
        wait until falling_edge(clk);
        rstn <= '1';

        -- Read the file with test messages and precomputed crc_sender and test the entity
        file_open(file_test_msg, "messages_and_crc.txt", read_mode);
        while not endfile(file_test_msg) loop

            -- Read data from file
            readline(file_test_msg, v_ILINE);
            read(v_ILINE, file_msg);
            read(v_ILINE, v_SPACE);
            read(v_ILINE, file_crc);

            -- Sending the message and read CRC
            msg := file_msg;
            report "Sending=" & to_string(msg) severity note;
            send_message(data_in, clk, start);
            read_crc(clk, data_out);

            -- Report the user if resulted CRC is correct
            if file_crc /= computed_crc then
                report "Wrong CRC, expected " & to_string(file_crc) & " got " & to_string(computed_crc) severity error;
            else
                report "CRC=" & to_string(computed_crc) & " is correct"severity note;
            end if;

            wait until falling_edge(clk);
            wait until falling_edge(clk);

        end loop;

        file_close(file_test_msg);
        wait for clock_period;

        report "Test finished";
        finish;

    end process;

end behav;
