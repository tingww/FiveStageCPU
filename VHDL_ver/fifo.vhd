--fifo with n-1 slots

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.conf.all;

entity fifo is
    generic(
        constant n : natural := 8
    );
    port (
        d_in : in std_logic_vector(memwidth-1 downto 0);
        w_en : in std_logic;
        d_out : out std_logic_vector(memwidth-1 downto 0);
        r_en : in std_logic;
        full : out std_logic := '0';
        empty : out std_logic := '0';
        rst : in std_logic;
        clk : in std_logic            
    );
end fifo;

architecture rtl of fifo is
    signal head,tail : unsigned(integer(ceil(log2(real(n))))-1 downto 0);
    type ring_buffer_type is array (0 to n-1) of std_logic_vector(memwidth-1 downto 0);
    signal ring_buffer : ring_buffer_type;
begin
    HEAD_PROC : process(clk,rst)
        variable one : unsigned(integer(ceil(log2(real(n))))-1 downto 0) := (0 =>'1', others => '0');
    begin
        if rst then
            head <= (others => '0');
        elsif rising_edge(clk) then
            if w_en and (not full) then
                ring_buffer(to_integer(head)) <= d_in;
                head <= head + one;
            end if;
        end if;
    end process;

    TAIL_PROC : process(clk,rst)
        variable one : unsigned(integer(ceil(log2(real(n))))-1 downto 0) := (0 =>'1', others => '0');
    begin
        if rst then
            tail <= (others => '0');
        elsif rising_edge(clk) then
            if r_en and (not empty) then
                d_out <= ring_buffer(to_integer(tail));
                tail <= tail + one;
            end if;
        end if;
    end process;

    COMB_PROC : process(head,tail)
        variable one : unsigned(integer(ceil(log2(real(n))))-1 downto 0) := (0 =>'1', others => '0');
    begin
        if head = tail then
            empty <= '1';
        else 
            empty <= '0';
        end if;

        if (tail-one) = head then
            full <= '1';
        else
            full <= '0';
        end if;
    end process;

end architecture;