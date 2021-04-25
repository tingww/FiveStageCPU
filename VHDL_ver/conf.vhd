--package

package conf is
    
    type alu_opcode is 
        (add, slt, sltu, andd, orr, xorr,slll, srll, sub, sraa);
    --add, subtract, and, or, xor 
    --set-less-then, slt-unsigned 
    --shift-left-logical, srl, shift-right-arithmetric
    
    
end package conf;