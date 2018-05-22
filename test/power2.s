main:   ori  $3,$0,60   # $3=60     # check f
        ori $4,$0,1     # $4=1
        addi $7,$0,256  # $7=256
        addi $6,$0,7    # $6=7
loop:   sw   $4,($3)    # [$3]=2^i  # check 0f, 10, 11 ...
        add  $4,$4,$4   # $4=$4*2
        addi $3,$3,4    # $3=$3+4
        beq  $4,$7,end  #
        j  loop
end:    sw   $6,($7)    #[256]=7   # check 20