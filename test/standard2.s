main:   addi $2,$0,5	#2=5    
        ori $3,$0,12	#3=12
        addi $7,$0,7	#7=7
	andi $7,$7,3	#7=3            3NOP
        or   $4,$7,$2   #4=7            3NOP
        and  $5,$3,$4   #5=4            3NOP
        add  $5,$5,$4   #5=11           3NOP
        beq  $5,$7,end  # 11 = 3        3NOP+2NOP
        slt  $4,$3,$4   #4=0            
        bne  $3,$0,around # 0 = 0       3NOP+2NOP
        addi $5,$0,0    
around: slti  $4,$7,5   #4=1    
        add  $7,$4,$5   #7=12           3NOP
        sub  $7,$7,$2   #7=7            3NOP
        sw   $7,84($3)  #[0x60]=7       3NOP 0x60/4=0x18
        lw   $2,96($0)  #2=[0x60]=7     
        j    end        # go to end
        sw   $7,80($3)  #[0x5b]=7       
end:    sw   $2,100($0)  #[0x64]=7      1NOP 0x64/4=0x19
        j    main       # do it again
        addi $7,$0,7    #7=7
	andi $7,$7,3	#7=3 