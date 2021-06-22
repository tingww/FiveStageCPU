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
    signal u_counter, c_counter, wb_counter : unsigned(blockfield-1 downto 0);
    signal u_ctr_en, u_ctr_start, u_ctr_incr, c_ctr_en, c_ctr_start, c_ctr_incr, wb_ctr_en, wb_ctr_start, wb_ctr_incr : std_logic;
    signal u_burst_last, c_burst_last, wb_burst_last : std_logic;
    signal ready_nxt, u_rewr_nxt, u_valid_nxt : std_logic;                      --output registers, registers of r_data and u_w_data are assumed in the module
    signal u_address_nxt : std_logic_vector(memwidth-1 downto 0);
    --connection to cache
    signal cache_hit, cache_ready, cache_dirty ,cache_rewr, cache_burst, cache_invalidate: std_logic;
    signal cache_address, cache_w_data, cache_r_data: std_logic_vector(memwidth-1 downto 0);
    --connection to write buffer
    signal wbuffer_ready, wbuffer_valid, wbuffer_rewr, wbuffer_full, wbuffer_empty, wbuffer_idle : std_logic;
    signal wbuffer_address, wbuffer_data, wbuffer_r_data : std_logic_vector(memwidth-1 downto 0);

    
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
        if rst = rst_val then
            state <= idle;
        elsif rising_edge(clk) then
            state <= nstate;            
        end if;
    end process state_proc;
    
    seq: process(clk, rst)
    begin
        if rst = rst_val then
            ready <= '1';
            u_rewr <= '0';
            u_valid <= '0';
            u_address <= (memwidth-1 downto 0 => '0');
        elsif rising_edge(clk) then
            ready <= ready_nxt;
            u_rewr <= u_rewr_nxt;
            u_valid <= u_valid_nxt;
            u_address <= u_address_nxt;
        end if;
    end process seq;

    state_transition: process(all)
    begin
        case state is
            when idle =>
                if valid = '1' then
                    nstate <= acces;
                else
                    nstate <= state;
                end if;

            when acces =>
                if cache_hit='1' and cache_ready='1' then                         --valid,hit,(-)
                    nstate <= idle;
                elsif cache_hit='0' and cache_ready='1' and cache_dirty='0' and u_idle='1' then  --(-),miss,clean
                    nstate <= allocate;
                elsif cache_hit='0' and cache_ready='1' and cache_dirty='1' and wbuffer_idle='1' then  --valid,miss,dirty
                    nstate <= writeback;
                else
                    nstate <= state;
                end if;

            when allocate =>
                if c_burst_last = '1' and u_burst_done='1' and cache_ready='1' then    --when finish allocating
                    nstate <= acces;
                else
                    nstate <= state;
                end if;

            when writeback =>
                if c_burst_last = '1' and wb_burst_done='1' and wb_ready='1' then
                    nstate <= allocate;
                else
                    nstate <= state;
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
                cache_valid <= u_ready when (u_counter or c_counter) /= (u_counter'length downto 0 => '0') else '0';

                wbuffer_valid <= '0';

            when writeback =>
                ready <= '0';
                u_valid <= '0';

                cache_address <= (address(memwidth-1 downto 4),c_counter,others => '0');   --read cache to write buffer, burst length = block size
                cache_rewr <= '0';
                cache_burst <= '1';
                cache_valid <= wbuffer_ready when wb_burst_done='0' else '0';

                wbuffer_valid <= wbuffer_ready when (wb_counter or c_counter) /= (wb_counter'length downto 0 => '0') else '0';;
                wbuffer_address <= (address(memwidth-1 downto 4),wb_counter,others => '0');
                wbuffer_w_data <= cache_r_data;
                wbuffer_rewr <= '1';
        
            when others =>
                assert false
                    report "state value incorrect"
                    severity failure;
        end case;
    end process control_signal;

    upstream_mem_counter : conditional_counter(clk, rst, u_ctr_en, u_ctr_start, u_counter); --counts numbers of (u_valid and u_ready) when enabled
    cache_counter : conditional_counter(clk, rst, c_ctr_en, c_ctr_start, c_counter);
    writebuffer_counter : conditional_counter(clk, rst, wb_ctr_en, wb_ctr_start, wb_counter);

    if state/=allocate and nstate=allocate then
        u_ctr_start <= '1';
    else
        u_ctr_start <= '0';
    end if;

    if u_ctr_en='1' and u_ready='1' and u_valid='1' then
        u_ctr_incr <= '1';
    else
        u_ctr_incr <= '0';
    end if;

    if state=acces and (nstate=writeback or nstate=allocate) then
        c_ctr_start <= '1';
    else
        c_ctr_start <= '0';
    end if;

    if cache_burst='1' and cache_ready='1' and cache_valid='1' then
        c_ctr_incr <= '1';
    else
        c_ctr_incr <= '0';
    end if;

    if state=acces and nstate=writeback then
        wb_ctr_start <= '1';
    else
        wb_ctr_start <= '0';
    end if;

    if wb_ctr_en='1' and wbuffer_ready='1' and wbuffer_valid='1' then
        wb_ctr_incr <= '1';
    else
        wb_ctr_incr <= '0';
    end if;

    u_burst_last_proc : process(clk, rst)
    begin
        if rst = rst_val then
            u_burst_last <= '0';
        elsif u_ctr_en = '1' then
            if rising_edge(clk) then
                if (u_valid='1' and u_ready='1' and u_counter=(u_counter'length downto 0 => '1')) then
                    u_burst_last <= '1';
                end if;
            end if;
        else
            u_burst_last <= '0';
        end if;
    end process u_burst_last_proc;

    wb_burst_last_proc : process(clk, rst)
    begin
        if rst = rst_val then
            wb_burst_last <= '0';
        elsif wb_ctr_en = '1' then
            if rising_edge(clk) then
                if (wb_valid='1' and wb_ready='1' and wb_counter=(wb_counter'length downto 0 => '1')) then
                    wb_burst_last <= '1';
                end if;
            end if;
        else
            wb_burst_last <= '0';
        end if;
    end process wb_burst_last_proc;


    c_burst_last_proc : process(clk,rst)
        variable allone : unsigned(blockfield-1 downto 0) := (others => '1');
    begin
        if rst = rst_val then
            c_burst_last <= '0';
        elsif cache_burst = '1' then
            if rising_edge(clk) then
                if (cache_valid='1' and cache_ready='1' and c_counter=allone) then
                    c_burst_last <= '1';
                end if;
            end if;
        else
            c_burst_last <= '0';
        end if;
    end process c_burst_last_proc;


end architecture;