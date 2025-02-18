## Exercise

The cyclic redundancy check (CRC) is a widely used bit-serial technique for
detecting errors in data transmission. When a serial stream of data is sent, a
generator polynomial is used to generate a remainder. A complemented copy of
this remainder is sent to the receiver. The receiver uses this to determine if
there was an error in transmission.

What to do: From a stream of eleven message bits being transmitted serially,
calculate the remainder and transmit its complement too. The example generator
and CRC technique presented here are one of the ones used in USB-2.0. Write the
hardware thread that implements this functionality, using always_comb,
always_ff, and assign statements (no gates).

Develop a testbench to demonstrate it working. 

```
                                                      bit_in
                                                         |  
                                                         v  
                                                       +---+
+----------------------------------------------------->|xor|
|                                                      +-+-+
|                                                        |  
|                               +------------------------+  
|                               |                        |  
|  +----+   +----+   +----+     v     +----+   +----+    |  
|  | FF |   | FF |   | FF |   +---+   | FF |   | FF |    |  
+--+  4 |<--+  3 |<--+  2 |<--|xor|<--+  1 |<--+  0 |<---+  
   |    |   |    |   |    |   +---+   |    |   |    |       
   +----+   +----+   +----+           +----+   +----+       
```

Here's how it works. At the start of a message (as part of reset), the sender's
CRC calculator flip-flops are set to ones. At each succeeding clock rick, the
message bits (nub first) are sent into the CRC calculator serially (one bit per
clock tick. i.e., they're connected to bit-in). The message bits are also
transmitted (via a wire) to the receiver but we're not doing that here. After
the eleven message bits are sent in to the calculator, the remainder (the value
in the sender's CRC calculator flip-flops) is copied into a separate shift
register (not shown) in complemented form. The msb of it is shifted into
bit-in. (It is sent to the receiver too.) After the five complemented bits have
been shifted in (fed to input bit_in), the value in the CRC calculator should
be what is called the residue value: 5'b01100. 

Note that when we say "complement the remainder," it's not complemented in the
CRC calculator's flip-flops. i.e., the CRC calculator's shift register value
doesn't change. This is a complemented copy of the remainder. Also note that
after the last message bit is shifted into the sender's CRC calculator, the
complemented remainder msb is shifted in at the next dock edge. To complete the
story: The receiver is similar except that it doesn't complement its remainder.
It just receives the values transmitted by the sender (msg and the complemented
remainder). Its residue should also be 5'b01100 which indicates that the
message was received correctly. Write a testbench that will send the following
11-bit messages to the CRC calculator (msb — left-most — first):
11'b0101_1100_101.

From this message, the remainder will be x(4:0) = 5'b01011, which then gets
complemented and sent as per above. To start you off correctly, the first
several values of x for the first message are 5'b11111 (the reset value),
5'b11011, 5'b01001, 5'b10010, .... . Another message is 11'b0101_1100_101 which
will produce remainder 5'b11100. Have monitor audio( display statements that
print the values so you can see them generating correctly. 

**Note**. The text of the exercise has been copied 1:1. But it has an error.
The first input vector suggested by the exercise ("11'b0101_1100_101") says it
will produce the complemented remainder "5'b01011". In the last paragraph it
suggests the same input vector saying that produces a different complemented
remainder 5'b11100". The latter is the correct one.

## Solution

The solution has been tested with a batch and waveform simulation. The former
uses the file `messages_and_crc.txt` with a list of vectors and their
pre-computed CRC with this [website](https://leventozturk.com/engineering/crc/).
The batch simulation output is the following
```
$ make batch
vsim -c -do "run -all" -suppress GroupWarning -quiet work.TESTBENCH
Reading pref.tcl

# 2020.1

# vsim -c -do "run -all" -suppress GroupWarning -quiet work.TESTBENCH
# Start time: 09:14:52 on Feb 18,2025
# run -all
# ** Note: Sending=01011100101
#    Time: 20 ns  Iteration: 0  Instance: /testbench
# ** Note: CRC=11100 is correct
#    Time: 175005 ps  Iteration: 0  Instance: /testbench
# ** Note: Sending=01111001111
#    Time: 190 ns  Iteration: 0  Instance: /testbench
# ** Note: CRC=10110 is correct
#    Time: 345005 ps  Iteration: 0  Instance: /testbench
# ** Note: Sending=00110000101
#    Time: 360 ns  Iteration: 0  Instance: /testbench
# ** Note: CRC=01011 is correct
#    Time: 515005 ps  Iteration: 0  Instance: /testbench
# ** Note: Sending=10110001111
#    Time: 530 ns  Iteration: 0  Instance: /testbench
# ** Note: CRC=10011 is correct
#    Time: 685005 ps  Iteration: 0  Instance: /testbench
# ** Note: Sending=01011100111
#    Time: 700 ns  Iteration: 0  Instance: /testbench
# ** Note: CRC=10110 is correct
#    Time: 855005 ps  Iteration: 0  Instance: /testbench
# ** Note: Sending=00110111010
#    Time: 870 ns  Iteration: 0  Instance: /testbench
# ** Note: CRC=10110 is correct
#    Time: 1025005 ps  Iteration: 0  Instance: /testbench
# ** Note: Sending=00001010101
#    Time: 1040 ns  Iteration: 0  Instance: /testbench
# ** Note: CRC=00100 is correct
#    Time: 1195005 ps  Iteration: 0  Instance: /testbench
# ** Note: Test finished
#    Time: 1220 ns  Iteration: 0  Instance: /testbench
# End time: 09:14:52 on Feb 18,2025, Elapsed time: 0:00:00
# Errors: 0, Warnings: 0
```

Instead, the waveform simulation shows the following

![Waveform](wave.bmp)
