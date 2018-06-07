main:   addi $2,$0,99   # $2=99
        and  $6,$0,$0   # $6=0
loop:   ori  $3,$0,164  # $3=164
        ori  $4,$0,328  # $4=328        
        add  $5,$3,$4   # $5=492        3NOP
        sw   $2,($4)    # [328]=$2      
        lw   $4,($4)    # 4=[328]=$2    
        add  $6,$6,$4   # $6=sigma{$2}  3NOP            1NOP
        addi $2,$2,-1   # $2--
        sw   $6,324($2) #               3NOP
        beq  $2,$0,end  # $2==0 break   +2NOP           +1NOP
        add  $3,$2,$0   # $3=$2                       
        beq  $2,$3,loop #               3NOP+2NOP       +1NOP
end:    sw   $6,320($2) #
                        #               16NOP           3NOP