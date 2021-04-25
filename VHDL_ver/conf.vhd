--package
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package conf is
    constant memwidth : integer := 32;
    type alu_opcode is 
        (add, slt, sltu, andd, orr, xorr,slll, srll, sub, sraa);
    --add, subtract, and, or, xor 
    --set-less-then, slt-unsigned 
    --shift-left-logical, srl, shift-right-arithmetric
   
end package conf;