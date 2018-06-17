main:   ori  $3,$0,60   # $3=60         
        ori  $8,$0,0
        ori  $4,$0,1     # $4=1         
        addi $7,$0,508  # $7=508
        addi $6,$0,7    # $6=7          
loop:   sd   $4,($3)    # [$3]=2^i      
        dadd $4,$4,$4   # $4=$4*2       
        dadd $8,$8,$4   #               3NOP
        addi $3,$3,8    # $3=$3+8       
        beq  $3,$7,end  #               3NOP+2NOP
        j  loop                         
end:    sw   $6,($7)    #[508]=7        8NOP