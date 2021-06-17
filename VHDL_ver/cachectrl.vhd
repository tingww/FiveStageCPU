--cache controller
--use write buffer

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.conf.all;

entity cachectrl is
    generic(
        constant blockfield : natural := 2 --block size = 4 words
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        --processer
        address : in std_logic_vector(memwidth-1 downto 0);
        w_data : in std_logic_vector(memwidth-1 downto 0);
        r_data : out std_logic_vector(memwidth-1 downto 0);
        rewr : in std_logic;
        valid : in std_logic;
        ready : out std_logic;

        --upper level memory
        u_address : out std_logic_vector(memwidth-1 downto 0);
        u_w_data : out std_logic_vector(memwidth-1 downto 0);
        u_r_data : in std_logic_vector(memwidth-1 downto 0);
        u_rewr : out std_logic;
        u_valid : out std_logic;
        u_ready : in std_logic;
        u_idle : in std_logic
    );
end cachectrl;

architecture rtl of cachectrl is

    type state_type is (idle, acces, allocate, writeback);
    signal state,nstate : state_type;
    signal cache_hit, cache_ready, cache_dirty ,cache_rewr, cache_burst, cache_invalidate: std_logic;
    signal cache_address, cache_w_data, cache_r_data: std_logic_vector(memwidth-1 downto 0);
    signal wbuffer_ready, wbuffer_valid, wbuffer_rewr, wbuffer_full, wbuffer_empty, wbuffer_idle : std_logic;
    signal wbuffer_address, wbuffer_data, wbuffer_r_data : std_logic_vector(memwidth-1 downto 0);

    signal u_counter, c_counter : unsigned(blockfield-1 downto 0);
begin
    cache0: entity work.cache port map(
        cache_valid => cache_valid,
        cache_ready => cache_ready,
        rewr => cache_rewr,
        invalidate => cache_invalidate,
        burst => cache_burst,
        address => cache_address,
        w_data => cache_w_data,
        r_data => cache_r_data,
        hit => cache_hit,
        dirty => cache_dirty
    );
    r_data <= cache_r_data;

    wbuffer0: entity work.wbuffer port map(
        valid => wbuffer_valid,
        ready => wbuffer_ready,
        rewr => wbuffer_rewr,
        idle => wbuffer_idle,
        address => wbuffer_address,
        w_data => wbuffer_w_data,
        r_data => wbuffer_r_data,
        full => wbuffer_full,
        empty => wbuffer_empty
    );
    u_w_data <= wbuffer_r_data;     --only write buffer writes to upstream memory

    state_proc: process(clk, rst)
    begin
        if rst = '1' then
            state <= idle;
        elsif rising_edge(clk) then
            state <= nstate;            
        end if;
    end process state_proc;

    state_transition: process(all)
    begin
        case state is
            when idle =>
                if valid = '1' then
                    nstate <= acces;
                else
                    nstate <= idle;
                end if;

            when acces =>
                if cache_hit='1' and cache_ready='1' then                         --valid,hit,(-)
                    nstate <= idle;
                elsif cache_hit='0' and cache_ready='1' and cache_dirty='0' and u_idle='1' then  --(-),miss,clean
                    nstate <= allocate;
                elsif cache_hit='0' and cache_ready='1' and cache_dirty='1' and wbuffer_idle='1' then  --valid,miss,dirty
                    nstate <= writeback;
                else
                    nstate <= acces;
                end if;

            when allocate =>
                if cache_burst_done = '1'then    --when finish allocating
                    nstate <= acces;
                else
                    nstate <= allocate;
                end if;

            when writeback =>
                if cache_burst_done = '1' then
                    nstate <= allocate;
                else
                    nstate <= writeback;
                end if;
        
            when others =>
                assert false
                    report "state value incorrect"
                    severity failure;
        end case;
    end process state_transition;

    control_signal: process(state)
    begin
        case state is
            when idle =>
                ready <= '1';

                cache_address <= address;
                cache_w_data <= w_data;
                cache_rewr <= rewr;
                cache_burst <= '0';
                cache_valid <= valid;

            when acces =>
                ready <= '0';
            
                cache_address <= address;
                cache_w_data <= w_data;
                cache_rewr <= rewr;
                cache_burst <= '0';
                cache_valid <= '0';

            when allocate =>                    --write cache with upstream memory data, burst length = block size
                ready <= '0';

                u_valid <= cache_ready when u_burst_done='0' else '0';
                u_rewr <= '0';
                u_address <= (address(memwidth-1 downto 4),u_counter,others => '0');

                cache_address <= (address(memwidth-1 downto 4),c_counter,others => '0');   
                cache_w_data <= u_r_data;
                cache_rewr <= '1';
                cache_burst <= '1';
                cache_valid <= u_ready when (u_counter /= 0) else '0';

                wbuffer_valid <= '0';

            when writeback =>
                ready <= '0';
                u_valid <= '0';

                cache_address <= address;   --read cache to write buffer, burst length = block size
                cache_rewr <= '0';
                cache_burst <= '1';
                cache_valid <= '1';

                wbuffer_valid <= cache_ready;
                wbuffer_address <= address;
                wbuffer_w_data <= cache_r_data;
                wbuffer_rewr <= '1';
        
            when others =>
                assert false
                    report "state value incorrect"
                    severity failure;
        end case;
    end process control_signal;

    upstream_counter: process(clk, rst, cache_burst)     --counts numbers of (u_valid and u_ready) when bursting
        variable one : unsigned(blockfield-1 downto 0) := ( 0=>'1' ,others => '0');
    begin
        if rst = '1' then
            u_counter <= (others => '0');
        elsif rising_edge(cache_burst) then
            u_counter <= (others => '0');
        elsif rising_edge(clk) then     
            if cache_burst='1' and u_ready='1' and u_valid='1'then
                u_counter <= u_counter+ one;
            end if;
        end if;
    end process upstream_counter;

    u_burst_done_proc : process(clk, rst)
        variable allone : unsigned(blockfield-1 downto 0) := (others => '1');
    begin
        if cache_burst = '1' then
            if rising_edge(clk) then
                if (u_valid='1' and u_ready='1' and u_counter=allone) then
                    u_burst_done <= '1';
                end if;
            end if;
        else
            u_burst_done <= '0';
        end if;
    end process u_burst_done_proc;

    cache_counter: process(clk, rst, cache_burst)
        variable one : unsigned(blockfield-1 downto 0) := ( 0=>'1' ,others => '0');
    begin
        if rst = '1' then
            c_counter <= (others => '0');
        elsif rising_edge(cache_burst) then
            c_counter <= (others => '0');
        elsif rising_edge(clk) then     
            if cache_burst='1' and cache_ready='1' and cache_valid='1'then
                c_counter <= c_counter+ one;
            end if;
        end if;
    end process cache_counter;

    c_burst_done_proc : process(all)
        variable allone : unsigned(blockfield-1 downto 0) := (others => '1');
    begin
        if cache_burst = '1' then
            if rising_edge(clk) then
                if (cache_valid='1' and cache_ready='1' and c_counter=allone) then
                    burst_done <= '1';
                end if;
            end if;
        else
            burst_done <= '0';
        end if;
    end process c_burst_done_proc;

end architecture;