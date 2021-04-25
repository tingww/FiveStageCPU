--ALU module
--add, subtract, and, or, xor 
--set-less-then, slt-unsigned 
--shift-left-logical, srl, shift-right-arithmetric
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.conf.all;

entity alu is
    generic (
        constant memwidth : integer := 32
    );
    port (
        data_i0,data_i1: in std_logic_vector(memwidth-1 downto 0);
        alu_ctrl : in alu_opcode;
        data_o : out std_logic_vector(memwidth-1 downto 0)
    );
end alu;

architecture behav of alu is

begin

end architecture;