--direct mapped cache
--mode : read, write, allocate, reset, invalidate
--cache line = | valid | dirty | tags     | data                |
--             | 1 bit | 1 bit | tagfield | memwidth*blocksize  |
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.conf.all;

entity cache is
    generic(
        constant blockfield : natural := 2; --block size = 4 words
        constant indexfield : natural := 10; --cache size = 1024 blocks
        constant cachemem_delay : time := clock_period*0.5  --same delay for read and write, hit and miss
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        cache_valid : in std_logic;
        cache_ready : out std_logic;
        rewr : in std_logic;
        inval : in std_logic;
        burst : in std_logic;                                    --allocate mode
        address : in std_logic_vector(memwidth-1 downto 0);
        w_data : in std_logic_vector(memwidth-1 downto 0);
        r_data : out std_logic_vector(memwidth-1 downto 0);
        hit : out std_logic;
        dirty : out std_logic
    );
end cache;

architecture rtl of cache is
    constant tagfield : integer := (memwidth-indexfield-blockfield-2);
    constant linesize : integer := memwidth*(blockfield**2)+tagfield+1+1;  --valid bit, dirty bit, tags, words
    type cache_type is array (natural range <>) of std_logic_vector(linesize-1 downto 0);
    signal cachemem : cache_type(0 to indexfield-1);
    signal tag : std_logic_vector(tagfield-1 downto 0);
    signal index : integer;
    signal wordoffset : std_logic_vector(blockfield-1 downto 0);
begin
    tag <= address(memwidth-1 downto memwidth-tagfield);
    index <= to_integer(unsigned( address(memwidth-tagfield-1 downto memwidth-tagfield-indexfield) ));
    wordoffset <= address(blockfield+2-1 downto 2);

    ready_proc: process(clk, rst)
    begin
        if rst = '1' then
            cache_ready <='0';
        elsif rising_edge(clk) then
            if cache_valid= '1' and cache_ready='1' then    --at least one clock_period delay, cache_ready hold high for one clock
                cache_ready <= '0';
                cache_ready <= '1' after cachemem_delay;
            end if;
        end if;
    end process ready_proc;

    PROC : process(all)
    begin
        if cache_ready='0' then
            --cache is busy
            if burst='0' then       --read/write/invalidate mode
                if cachemem(index)(linesize-1-1-1 downto linesize-1-1-tagfield) = tag and cachemem(index)(linesize-1) = '1' then    --valid hit
                    hit <= '1';
                    dirty <= '0';
                    if rewr = '0' then --read
                        case wordoffset is
                            when "11" => r_data <= cachemem(index)(memwidth*4-1 downto memwidth*3);          ---NOT Parameterized---
                            when "10" => r_data <= cachemem(index)(memwidth*3-1 downto memwidth*2); 
                            when "01" => r_data <= cachemem(index)(memwidth*2-1 downto memwidth*1); 
                            when "00" => r_data <= cachemem(index)(memwidth*1-1 downto memwidth*0);
                            when others => assert false
                                report "wordoffset incorrect value"
                                severity failure;
                        end case;
                    elsif rewr = '1' then  --write/invalidate
                        if inval= '1'then   --invalidate
                            cachemem(index)(linesize-1) <= '0';
                        else                --write
                            case wordoffset is
                                when "11" => cachemem(index)(memwidth*4-1 downto memwidth*3) <= w_data;          ---NOT Parameterized---
                                when "10" => cachemem(index)(memwidth*3-1 downto memwidth*2) <= w_data; 
                                when "01" => cachemem(index)(memwidth*2-1 downto memwidth*1) <= w_data; 
                                when "00" => cachemem(index)(memwidth*1-1 downto memwidth*0) <= w_data; 
                                when others => assert false
                                    report "wordoffset incorrect value"
                                    severity failure;
                            end case;
                            cachemem(index)(linesize-1-1) <= '1';   --set dirty bit
                        end if;                        
                    end if;
                elsif cachemem(index)(linesize-1) = '1' and cachemem(index)(linesize-2) = '1' then  --valid miss dirty
                    hit <= '0';
                    dirty <= '1';
                else
                    hit <= '0';
                    dirty <= '0';
                end if;
            elsif burst='1' then    --read/allocate mode
                if rewr= '0'then    --burst mode(same as read mode), in state writeback
                    case wordoffset is
                        when "11" => r_data <= cachemem(index)(memwidth*4-1 downto memwidth*3);          ---NOT Parameterized---
                        when "10" => r_data <= cachemem(index)(memwidth*3-1 downto memwidth*2); 
                        when "01" => r_data <= cachemem(index)(memwidth*2-1 downto memwidth*1); 
                        when "00" => r_data <= cachemem(index)(memwidth*1-1 downto memwidth*0);
                        when others => assert false
                            report "wordoffset incorrect value"
                            severity failure;
                    end case;
                elsif rewr='1' then    --allocate mode, in state allocate
                    case wordoffset is
                        when "11" => cachemem(index)(memwidth*4-1 downto memwidth*3) <= w_data;          ---NOT Parameterized---
                                     cachemem(index)(linesize-1-1-1 downto linesize-1-1-tagfield) <= tag; --write tagfield
                                     cachemem(index)(linesize-1) <= '1'; --valid
                                     cachemem(index)(linesize-1-1) <= '0'; --clean
                        when "10" => cachemem(index)(memwidth*3-1 downto memwidth*2) <= w_data; 
                        when "01" => cachemem(index)(memwidth*2-1 downto memwidth*1) <= w_data; 
                        when "00" => cachemem(index)(memwidth*1-1 downto memwidth*0) <= w_data; 
                        when others => assert false
                            report "wordoffset incorrect value"
                            severity failure;
                    end case;
                end if;
            end if;
        end if;
    end process;
    
    
end architecture;