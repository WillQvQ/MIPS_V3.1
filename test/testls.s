main:   addi $2,$0,6
        ld   $3,66($2) # ld
        lbu  $4,55($2) 
        add  $5,$4,$3
        sb   $5,57($2)
        dadd  $6,$3,$4  # dadd
        add  $7,$3,$4    
        daddi $6,$6,13  # daddi
        dsub  $8,$2,$3  # dsub 
        sd   $6,66($2) # sd
        sd   $7,74($2) # sd
        sd   $8,82($2) # sd