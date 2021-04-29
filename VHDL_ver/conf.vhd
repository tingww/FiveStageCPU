--package
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package conf is
    constant memwidth : integer := 32;
    type slv_arr is array (integer range <>) of std_logic_vector(memwidth-1 downto 0);
    type alu_opcode is 
        (add, slt, sltu, andd, orr, xorr,slll, srll, sub, sraa);
    --add, subtract, and, or, xor 
    --set-less-then, slt-unsigned 
    --shift-left-logical, srl, shift-right-arithmetric
   
end package conf;