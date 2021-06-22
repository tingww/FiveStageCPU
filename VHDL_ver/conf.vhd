--package
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package conf is
    constant memwidth : integer := 32;
    constant clock_period : time := 10 ns;
    constant rst_val : std_logic := '0';
    type slv_arr is array (integer range <>) of std_logic_vector(memwidth-1 downto 0);
    type alu_opcode is 
        (add, slt, sltu, andd, orr, xorr,slll, srll, sub, sraa);
    --add, subtract, and, or, xor 
    --set-less-then, slt-unsigned 
    --shift-left-logical, srl, shift-right-arithmetric

    procedure conditional_counter(              --count up when en, incr = 1; reset on rst or rising edge enable
        signal clk,rst,en,incr : in std_logic;
        signal ctr_val : out unsigned
        );
end package conf;

package body conf is
    procedure conditional_counter(              --count up when en, incr = 1; reset on rst or start
        signal clk,rst,en,incr,start : in std_logic;
        signal ctr_val : out unsigned
        ) is
    begin
        if rst = rst_val then
            ctr_val <= (ctr_val'length downto 0 => '0');
        elsif rising_edge(clk) then     
            if start = '1' then
                ctr_val <= (ctr_val'length downto 0 => '0');
            elsif en='1' and incr='1' then
                ctr_val <= ctr_val + (ctr_val'length downto 1 => '0' , 0 => '1');
            end if;
        end if;
    end procedure;
    
    
end package body conf;