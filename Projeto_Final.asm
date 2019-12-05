#cores
li $s0, 0x00008b8b	#dark cyan - cenario
li $s1, 0x00ffd700	#gold - mobilias
li $s2, 0x00cd2626	#firebrick - aspirador
li $s3, 0x0087ceff 	#skyblue - area limpa

li $s4, 0		#contador de areas vazias
li $s6, 0		#contador para as linhas 
li $s7, 0		#contador para as colunas

move $s5, $gp		#move para o inicio do cenario

#contrucao do cenario
cenario:
	up: 
		sw $s0, 0($gp)	 #memoria[0+$gp] = $s0 - o local da memoria recebe a cor dark cyan
		addi $gp,$gp,4   #locomove um bit a direita
		addi $s7,$s7,1   #adiciona uma coluna no contador
		bne $s7,16,up	 #repete o procedimento enquanto a coluna for diferente de 16 
	li $s7,0		 #zera o contador de colunas para o procedimento abaixo
	left:
		addi $s6,$s6,1 	 #adiciona uma linha no contador 
		sw $s0,0($gp)	 #memoria[0+$gp] = $s0 - o local da memria recebe a cor do cenario 
		addi $gp,$gp,64  #locomove pela coluna esquerda como se percorresse 
		bne $s6,15,left  #repete o procedimento ate atingir a ultima linha 
	 
	addi $gp,$gp,-60         #traz o ponto para a posicao 
	down:
		addi $s7,$s7,1	 #adiciona uma coluna no contador
		sw $s0,0($gp) 	 #memoria[0+$gp] = $s0 - local da memoria recebe a cor do cenerio
		addi $gp,$gp,4	 #locomove um bit a direita
		bne $s7,15,down  #repete o procedimento enquanto a coluna for diferente de 15
	
	addi $gp,$gp,-4		 #traz o ponto para a posicao
	right:
		addi $s6,$s6,-1	 #remove uma linha no contador
		addi $gp,$gp,-64 #locomove pela coluna direita 
		sw $s0,0($gp)	 #memoria[0+$gp] = $s0 - local da memoria recebe a cor do cenario
		bne $s6,0,right  #repete o procedimento enquanto a coluna for diferente de 0
	 
	addi $gp,$gp,-28 	 #move o gp para o meio 
	li $v0,42		 #gera um numero aleatorio
	li $a1,12		 #ate 12
	syscall			 #faz a chamado do syscall para 42 para gerar um numero aleatorio
	add $a0,$a0,1 		 #adiciona +1 no numero aleatorio
	move $t0,$a0		 #move o valor aleatorio para $t0
	
	divisoria:
		addi $gp,$gp,64		#move para a linha de baixo
		addi $s6,$s6,1		#adiciona mais uma linha no contador
		beq $s6,$t0,divisoria	#caso a linha seja igual a $t0 retorna a divisoria
		sw $s0,0($gp)		#pinta o bit com cyan
		bne $s6,15,divisoria	#repete o procedimento ate 15 vezes

move $gp,$s5				#move o $gp para o inicio



#Moveis/Mobilia
furniture:
	lw $t1,0($gp)			#$t1 = memoria[0+$gp]
	addi $gp,$gp,4			#move um bit a direita
	beq $t1,$s0,furniture		#caso o t1 = $s0 (cenario) volta nos moveis
	
	li $v0,42			#gera o numero aleatorio
	li $a1,10			#ate 10
	syscall				
	add $a0,$a0,1			#chao 1
	move $t0,$a0			#move o valor aleatorio para t0
	bne $t0,10,furniture		#caso o valor seja diferente de 15 retorna para moveis
	
	sw $s1,-4($gp)			#pinta o bit
	ble $gp,0x10008400,furniture	#caso o valor seja menor volta para mobilia
	
move $gp,$s5				#move para o inicio
#Verificar posicao
contar:
	lw $t1,0($gp)			#$t1 = memoria[0+$gp]
	addi $gp,$gp,4			#move um bit a direita
	beq $t1,$s0,contar		#caso o valor seja igual a parade retorna contar
	beq $t1,$s1,contar		#caso o valor seja igual a movel retorna contar
	addi $s4,$s4,1			#adiciona mais um no contador
	ble $gp,0x10008400,contar	#caso o valor seja menor retorna para contar
	
addi $s4,$s4,-2	      			#retira dois do contador

robot:
	move $gp,$s5			#move o robo para o inicio
	li $v0, 42			#gera um numero aleatorio
	li $a1, 255			#ate 255
	syscall

	move $t0, $a0			#move o valor para $t0
	mul $t0, $t0, 4			#multiplica esse valor por 4
	add $gp, $gp, $t0		#move o bit para t0
	
	lw $t1,0($gp)			#$t1 = memoria[0+$gp]
	
	bge $gp,0x10008400,robot 	#caso o valor seja maior que o cenario retorna para o robo
	beq $t1,$s0,robot		#caso o valor seja igual ao cenario retorna
	beq $t1,$s1,robot		#caso o valor seja igual aos movel retorna
	sw $s2,0($gp)			#colore o robo na posicao resultante
	
direction:
	ble $s4,0,fim			#caso valor do contador seja 0 ele encerra o programa
	li $v0,42			#gera um num aleatorio
	li $a1,8			#ate 8
	syscall
	add $a0,$a0,1			#adiciona mais um no numero aleatorio
	move $t2,$a0			#move o valor para $t2
	
	li $v0, 32			#define a velocidade na qual o aspirar ira se mover
	la $a0, 50
	syscall
	
	beq $t2,1,north			#caso o valor seja 1 vai para o Norte
	beq $t2,2,northeast		#caso o valor seja 2 vai para o Nordeste
	beq $t2,3,east	 		#caso o valor seja 3 vai para o oeste
	beq $t2,4,southeast		#e assim por diante
	beq $t2,5,south		
	beq $t2,6,southwest	
	beq $t2,7,west		
	beq $t2,8,northwest	
	
	north:
		move $t3,$gp		#move o valor de gp para t3 (aux)
		addi $t3,$t3,-64	#move o aux para cima
		lw $t1,0($t3)		#t1 = memoria[0+$t3]
		beq $t1,$s0,direction	#caso o valor bata num cenario retorna uma nova direcao
		beq $t1,$s1,direction	#caso o valor bata num imovel retorna uma nova direcao
		move $gp,$t3		#senao $gp recebe o valor de $t3
		beq $t1,$s3,N		#caso valor bata com uma area limpa entao vai para N
		addi $s4,$s4,-1		#tira um da area vazia
		N:
		sw $s2,0($gp)		#colore o aspirador na area do bit
		sw $s3,64($gp)		#colore a area que passou como limpa
		j north
		
	northeast:
		move $t3,$gp
		addi $t3,$t3,-60
		lw $t1,0($t3)
		beq $t1,$s0,direction
		beq $t1,$s1,direction
		move $gp,$t3
		beq $t1,$s3,printaNE
		addi $s4,$s4,-1
		printaNE:
		sw $s2,0($gp)
		sw $s3,60($gp)
		j northeast
		
	east:
		move $t3,$gp
		addi $t3,$t3,4
		lw $t1,0($t3)
		beq $t1,$s0,direction
		beq $t1,$s1,direction
		move $gp,$t3
		beq $t1,$s3,printaE
		addi $s4,$s4,-1
		printaE:
		sw $s2,0($gp)
		sw $s3,-4($gp)
		j east
		
	southeast:
		move $t3,$gp
		addi $t3,$t3,68
		lw $t1,0($t3)
		beq $t1,$s0,direction
		beq $t1,$s1,direction
		move $gp,$t3
		beq $t1,$s3,printaSE
		addi $s4,$s4,-1
		printaSE:
		sw $s2,0($gp)
		sw $s3,-68($gp)
		j southeast
		
	south:
		move $t3,$gp
		addi $t3,$t3,64
		lw $t1,0($t3)
		beq $t1,$s0,direction
		beq $t1,$s1,direction
		move $gp,$t3
		beq $t1,$s3,printaS
		addi $s4,$s4,-1
		printaS:
		sw $s2,0($gp)
		sw $s3,-64($gp)
		j south
		
	southwest:
		move $t3,$gp
		addi $t3,$t3,60
		lw $t1,0($t3)
		beq $t1,$s0,direction
		beq $t1,$s1,direction
		move $gp,$t3
		beq $t1,$s3,printaSW
		addi $s4,$s4,-1
		printaSW:
		sw $s2,0($gp)
		sw $s3,-60($gp)
		j southwest
		
	west:
		move $t3,$gp
		addi $t3,$t3,-4
		lw $t1,0($t3)
		beq $t1,$s0,direction
		beq $t1,$s1,direction
		move $gp,$t3
		beq $t1,$s3,printaW
		addi $s4,$s4,-1
		printaW:
		sw $s2,0($gp)
		sw $s3,4($gp)
		j west
		
	northwest:
		move $t3,$gp
		addi $t3,$t3,-68
		lw $t1,0($t3)
		beq $t1,$s0,direction
		beq $t1,$s1,direction
		move $gp,$t3
		beq $t1,$s3,printaNW
		addi $s4,$s4,-1
		printaNW:
		sw $s2,0($gp)
		sw $s3,68($gp)
		j northwest

fim:
	li $v0,10			#comando que encerra o programa
	syscall
