.data
# Arquivos
in: .space 80    			# Entrada
ord: .space 4				# Define ordenação

# Buffers
buffer: .space 512             		# Armazena ascii de números (Entrada)
temp: .space 512			# Armazena temporariamente número ascii
buffer_ordenados: .space 512		# Armazena números ascii para colocar em txt (Saída)

# Vetor
.align 4
numeros: .space 512			# Armazena números em vetor

# Mensagens
entrada: .asciiz "Qual é o nome do arquivo de entrada? "
ordenacao: .asciiz "Qual é a ordenação a ser utilizada (0 = selection, 1 = quick)? "
newline: .asciiz "\n"

.text

main:	
	# Registradores não reutilizados:
	# vetor ordenado pela função ordena: $s0
	# int *vetor (Vetor a ser ordenado): $s1 - endereço base
	# int tam (Tamanho do vetor a ser ordenado): $s2
	# tamanho do vetor resultante da ordenação: $s3
	# quantidade de caracteres lidos na entrada: $s4
	# buffer ascii com números ordenados: $s5
	# ordenação a ser utilizada: $s6

	# Lê entradas do usuário
	jal entradaUsuario
	
	# Leitura de Arquivo de Entrada
	jal iniciarLeitura
	
	# Interpretar números armazenados no buffer (Str -> Int)
	jal iniciarBuffer_In
	
	la 	$a0, ($s1)
	li 	$a1, 0				 # Define menor index do vetor (Usado no quickSort)
	la 	$a2, ($s2)				
	la	$a3, ($s6)                       # Define tipo ordenação (0 = selection, 1 = quick)
	
	# Ordenar números
	jal ordena
	
	add 	$s3, $zero, $v0		   	# tamanho do vetor resultante retorna em $v0
	
	# Interpretar resultados para armazenar em buffer (Int -> Str)
	jal iniciarBuffer_Out
	
	# Escrita de Arquivo de Saída e finaliza programa
	j iniciarEscrita

# -------------------------------- ENTRADA DO USUÁRIO --------------------------------------- #
entradaUsuario:
	subi $sp, $sp, 12
	sw $t2, 8($sp)
	sw $t1, 4($sp)
	sw $t0, 0($sp) 

	# Qual é o nome do arquivo de entrada?
	li	$v0, 4
	la	$a0, entrada
	syscall
	li	$v0, 8
	la 	$a0, in
	li 	$a1, 80
	syscall
	
	la	$t2, in
	
	corrigirIn:  
		lb 	$t0, 0($t2)  			# carrega um byte do buffer
		beq 	$t0, 10, foundChar		
	
		addi 	$t2, $t2, 1      		# incrementa endereço do buffer (vai pra prox numero)
		j 	corrigirIn

	foundChar:
		addi	$t1, $zero, 0
		sb	$t1, 0($t2)			# substitui char 10 por 0
	
DefineOrdenacao:	
	li	$v0, 4
	la	$a0, ordenacao
	syscall
	li 	$v0, 5
	syscall
	move 	$s6, $v0
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	addi $sp, $sp, 12
	
	jr $ra

# --------------------------------- LEITURA DO ARQUIVO -------------------------------------- #
iniciarLeitura:
	subi $sp, $sp, 16
	sw $a2, 12($sp)
	sw $a1, 8($sp)
	sw $a0, 4($sp)
	sw $t0, 0($sp)              

abrirIn:
	li	$v0, 13          		# system call for open file
	la	$a0, in        			# input file name
	li	$a1, 0           		# flag for read-only
	li	$a2, 0           		# mode is ignored
	syscall			 		# open a file 
	move	$t0, $v0         		# save the file descriptor 
	
lerIn:
	li	$v0, 14				# 14 = read from file
	move 	$a0, $t0      			# file descriptor 
	la	$a1, buffer			# buffer to hold int charged in a1
	li	$a2, 512			# Read 512 bytes - size of buffer
	syscall

fecharIn:
	li   	$v0, 16       			# system call for close file
	move 	$a0, $t0      			# file descriptor to close
	syscall            			# close file
	
finalizarLeitura:
	lw $t0, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $a2, 12($sp)
	addi $sp, $sp, 16
	
	jr $ra

# -------------- CONTA ELEMENTOS, OS CONVERTE PARA INTEIRO E ARMAZENA EM ARRAY ---------------- #
iniciarBuffer_In:
	subi $sp, $sp, 20
	sw $t4, 16($sp)
	sw $t3, 12($sp)
	sw $t2, 8($sp)
	sw $t1, 4($sp)
	sw $t0, 0($sp)

usarBuffer:
	la 	$t4, buffer
	la 	$s1, numeros             	# Guarda números em array
	
lerBuffer:  
	lbu 	$t1, 0($t4)  			# carrega um byte do buffer
	beqz 	$t1, numElem  			# if $t1 == 0, ou seja, null terminator, então finaliza indo para numElem
	
	beq 	$t1, 32, spaceFound		# desvia se encontrar espaço (ascii = 32)
	
	# Converte ascii para int
	addi    $t1, $t1, -48    
    	mul    	$t3, $t3, 10            	# multiplica palavra por 10
    	add    	$t3, $t3, $t1       		# numero += array[s1]-'0'
    	
    	# Salva int em vetor
    	sll 	$t0, $s2, 2           		# acerta i - só incrementa em spacefound
	add 	$t0, $t0, $s1         		# acerta numeros[i]
	sw 	$t3, 0($t0)
    	
    	addi	$s4, $s4, 1			# conta numero de caracteres entrando (usado na saida depois)
	addi 	$t4, $t4, 1      		# incrementa endereço do buffer (vai pra prox numero)
	j 	lerBuffer

spaceFound:
	li 	$t3, 0				# zera variavel da conversao str -> int
	addi 	$t4, $t4, 1      		# incrementa endereço do buffer (pula espaço)
	addi	$s4, $s4, 1			# conta numero de caracteres entrando (usado na saida depois)
	addi 	$s2, $s2, 1			# O número de elementos é o número de espaços + 1 (somado posteriormente)
						# $s2 também é usado como i para incrementar array para novo número
	
    	j 	lerBuffer

numElem:	
	addi 	$s2, $s2, 1			# O número de elementos é o número de espaços + 1

finalizarBuffer_In:
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	addi $sp, $sp, 20
	
	jr $ra

# --------------------------------- INICIA ORDENAÇÃO -------------------------------------- #	
ordena:
	beq 	$a3, $zero, iniciarSelection
	beq 	$a3, 1, quickSort	

# ------------------------------------ SELECTION SORT ------------------------------------- #

# $t6 = i, $t7 = j, $t1 = index
# $a2 = numeros.length, $a0 = numeros
# resultado está em $a0 num vetor

iniciarSelection:
	subi $sp, $sp, 32
	sw $t7, 28($sp)
	sw $t6, 24($sp)
	sw $t5, 20($sp)
	sw $t4, 16($sp)
	sw $t3, 12($sp)
	sw $t2, 8($sp)
	sw $t1, 4($sp)
	sw $t0, 0($sp)

selectionSort:
	addi 	$t0, $a2, -1			# $t1 = numeros.length - 1
	
forFora:
	beq 	$t6, $t0, fimSelection      	# Se i = numeros.length - 1 -> desvio
	add 	$t1, $t6, $zero             	# index = $s0 (i)
	
	addi 	$t7, $t6, 1                	# j = i + 1 -> inicio do for de dentro
	
forDentro:
	beq 	$t7, $a2, troca			# Se j = numeros.length -> desvio
	sll 	$t2, $t1, 2                     # acerta index
	add 	$t2, $t2, $a0                   # acerta numeros[index]
	lw 	$t2, 0($t2)               	# $t2 = numeros[index]
   	sll 	$t3, $t7, 2                     # acerta j
   	add 	$t3, $t3, $a0			# acerta numeros[j]
   	lw 	$t3, 0($t3)                  	# $t3 = numeros[j]
   	slt	$t2, $t3, $t2			# numeros[j] < numeros[index]?
   	bne 	$t2, $zero, atualizaIndex     	# Se sim ($t2 = 1), troca numeros[index] por numeros[j]
   	
   	add 	$t7, $t7, 1 			# incrementa j
   	j 	forDentro
   	
atualizaIndex:
	move 	$t1, $t7                        # index = j
	add 	$t7, $t7, 1 			# incrementa j
	j 	forDentro
   	
troca:	
   	sll 	$t2, $t6, 2                     # acerta i
   	add 	$t2, $t2,$a0			# numeros[i]
   	sll 	$t3, $t1, 2			# acerta index   
   	add 	$t3, $t3,$a0			# numeros[index]
   	lw 	$t4, 0($t2)        
   	lw 	$t5, 0($t3)        
   	sw 	$t4, 0($t3)
   	sw 	$t5, 0($t2)
   	
incrementaForFora:
	addi	$t6, $t6, 1                     # incrementa i
	j 	forFora

fimSelection:
	addi	$v0, $t6, 1			# retorna i + 1, isto é, qtd de elementos no vetor resultante               
	
	la 	$s0, numeros
	la	$s0, ($a0)			# salva array ordenado em $s0
	
	lw 	$t0, 0($sp)
	lw 	$t1, 4($sp)
	lw 	$t2, 8($sp)
	lw 	$t3, 12($sp)
	lw 	$t4, 16($sp)
	lw 	$t5, 20($sp)
	lw 	$t6, 24($sp)
	lw 	$t7, 28($sp)
	addi 	$sp, $sp, 32

	jr 	$ra
	
# ----------------------------------- QUICK SORT - INCOMPLETO AINDA ---------------------------------- #

quickSort:	
	subi 	$sp, $sp, 20
	sw 	$ra, 16($sp)
	sw 	$fp, 12($sp)	
	sw 	$a0, 8($sp)			# Numeros (vetor)		
	sw 	$a1, 4($sp)			# Inicio			
	sw 	$a2, 0($sp)			# Fim			
	move 	$fp, $sp
	
	slt 	$t1, $a1, $a2			# se inicio < fim = 1
	beq 	$t1, $zero, fimQuick		# se inicio >= fim, fimQuick
	
	jal 	particionar
	add 	$t0, $v0, $zero			# pivot_index = particionar
	
	add	$t2, $a2, $zero			# Salva fim antes da recursão
	subi	$a2, $t2, 1			# novo fim = pivot - 1
	jal 	quickSort
	
	add	$a2, $t2, $zero			# Restaura fim
	subi	$a1, $t0, 1			# novo inicio = pivot + 1
	jal	quickSort

particionar:
	subi 	$sp, $sp, 36
	sw 	$ra, 32($sp)			# particionar chama troca, portanto salvar ra
	sw 	$fp, 28($sp)
	sw	$a3, 24($sp)		
	sw	$a1, 20($sp)			# arg são reutilizados em troca
	sw	$t0, 16($sp)
	sw	$t1, 12($sp)
	sw	$t2, 8($sp)
	sw	$t3, 4($sp)
	sw	$t4, 0($sp)			
	move 	$fp, $sp
	
	sll	$t0, $a2, 2			
	add	$t0, $a0, $t0			# numeros[fim]
	lw	$t0, 0($t0)			# pivot = numeros[fim]
	
	subi	$t1, $a1, 1			# i = inicio - 1
	add	$t2, $a1, $zero			# j = inicio
	
	for:
		beq 	$t2, $a2, fimFor		# j = fim?
		
		sll	$t4, $t2, 2			
		add	$t4, $a0, $t4			# numeros[j]
		lw	$t4, 0($t4)			# valor de numeros[j]
		
		slt	$t4, $t4, $t0			# numeros[j] < pivot?
		beq	$t4, $zero, maior		# Se numeros[j] > pivot -> maior
		
		addi 	$t1, $t1, 1			# i++
		
		add	$a1, $t1, $zero			# arg1 = i --> para função troca
		add	$a3, $t2, $zero			# arg3 = j --> para função troca
		jal 	trocaQuick
		
		maior:
		add	$t2, $t2, 1			# j++
		
		j	for
	
fimFor:
	add 	$a1, $t1, 1				# arg2 = i + 1
	add	$a3, $a2, $zero				# arg3 = fim
	jal 	trocaQuick
	
	addi 	$v0, $t1, 1				# retorna i + 1
	
	lw 	$t4, 0($sp)
	lw 	$t3, 4($sp)
	lw 	$t2, 8($sp)
	lw 	$t1, 12($sp)
	lw 	$t0, 16($sp)
	lw 	$a1, 20($sp)
	lw 	$a3, 24($sp)
	lw 	$fp, 28($sp)
	lw 	$ra, 32($sp)
	addi 	$sp, $sp, 36
	
	jr $ra
	
trocaQuick:
	subi 	$sp, $sp, 16
	sw	$t0, 12($sp)			
	sw	$t1, 8($sp)
	sw	$t2, 4($sp)
	sw	$t3, 0($sp)		

	sll	$t1, $a1, 2			# arg1 * 4
	add	$t1, $a0, $t1			# numeros[arg1]
	
	sll	$t0, $a3, 2			# arg3 * 4
	add	$t0, $a0, $t0			# numeros[arg3]
	
	lw	$t2, 0($t1)			# valor de numeros[arg1]
	lw	$t3, 0($t0)			# valor de numeros[arg3]
	sw	$t2, 0($t0)			
	sw	$t3, 0($t1)
				
	lw $t3, 0($sp)
	lw $t2, 4($sp)
	lw $t1, 8($sp)
	lw $t0, 12($sp)
	addi $sp, $sp, 16
	
	jr $ra
	
fimQuick:
	la 	$s0, numeros
	la	$s0, ($a0)			# salva array ordenado em $s0

	lw 	$a2, 0($sp)
	lw 	$a1, 4($sp)
	lw 	$a0, 8($sp)
	lw 	$fp, 12($sp)
	lw 	$ra, 16($sp)
	addi 	$sp, $sp, 20
	
	jr $ra

# ---------------------------- CONVERTE VETOR ORDENADO INT -> STR -------------------------- #

# $s0 = array dos numeros ordenados a serem escritos
# $s2 = tamanho do vetor
# $s4 = tamanho de caracteres que entrou

iniciarBuffer_Out:
	subi $sp, $sp, 28
	sw $t6, 24($sp)
	sw $t5, 20($sp)
	sw $t4, 16($sp)
	sw $t3, 12($sp)
	sw $t2, 8($sp)
	sw $t1, 4($sp)
	sw $t0, 0($sp)

usarBuffers:
	la 	$s5, buffer_ordenados
	addi	$s4, $s4, 1			# adicionando espaço para caractere de espaço extra devido ao loop
	
escreverBuffers:
	beq	$t0, $s2, finalizarBuffer_Out	# i = número de elementos do vetor? se sim, escrever buffer no arquivo
	
	sll 	$t1, $t0, 2			# acerta i
   	add 	$t1, $t1, $s0			# $s0[i]   	
   	lw 	$t1, 0($t1)
   	
   	itoa:
   		la   	$t6, temp + 30
      		sb   	$0, 1($t6)     				# null-terminated str
      		li   	$t2, '0'       				# 0 => 48 em ascii  
      		sb   	$t2, ($t6)    				# init. with ascii 0   
      		li   	$t3, 10        				# preload 10
      		beq  	$t1, $0, findNullTerminator  		# end if 0
      
	loop:
      		div  	$t1, $t3       				# a /= 10
      		mflo 	$t1
      		mfhi 	$t4           				# resto da divisão
      		add  	$t4, $t4, $t2  				# convert to ASCII digit -- equivalente a 0x30 (-48 na primeira conversão)	
      		sb   	$t4, ($t6)     				# store it
      		sub  	$t6, $t6, 1    				# decrease buffer pointer
      		bne  	$t1, $0, loop  				# if not zero, loop
      		addi 	$t6, $t6, 1    				# adjust buffer pointer
   	
   	findNullTerminator:    					# semelhante ao pular espaço, pulando null terminator
   		lbu 	$t5, 0($t6)
   		beq	$t5, $0, found
   		
   		sb 	$t5, 0($s5) # adiciona novo numero sem null terminator
   		
   		addi	$s5, $s5, 1
   		addi 	$t6, $t6, 1 
   		j 	findNullTerminator
   	
   	found: 
		li 	$t5, 32
   		sb 	$t5, 0($s5) # adiciona espaço
   		
   		addi	$s5, $s5, 1
	
   	addi	$t0, $t0, 1
   	j 	escreverBuffers
   	
finalizarBuffer_Out:
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $t6, 24($sp)
	addi $sp, $sp, 28
	
	jr $ra

# ---------------------- ESCREVE EM ARQUIVO DE SAIDA E FINALIZA PROGRAMA ------------------------ #
iniciarEscrita:
	sub	$s5, $s5, $s4			# decrementa endereço para voltar ao ínicio da string

   	li 	$v0, 4
   	la 	$a0, ($s5)
   	syscall
   		
abrirOut:
	li	$v0, 13          		# system call for open file
	la	$a0, in	        		# input file name
	li	$a1, 9           		# flag for write (append)
	li	$a2, 0           		# mode is ignored
	syscall			 		# open a file 
	move	$t0, $v0         		# save the file descriptor 
	
escreverOut:
	li	$v0, 15				# 15 = write from file
	move 	$a0, $t0      			# file descriptor
	
	la	$a1, newline			# Adiciona quebra de linha
	la	$a2, 1
	syscall
	
	li   	$v0, 15       			# system call for reading from file
	move 	$a0, $t0      			# file descriptor 
	la	$a1, ($s5)			# buffer to hold int charged in a1
	la	$a2, ($s4)			# Escreve a qtd de caracteres que entrou
	syscall
	
fecharOut:
	li   	$v0, 16       			# system call for close file
	move 	$a0, $t0      			# file descriptor to close
	syscall            			# close file
	
fim:	
	li 	$v0, 10         		# termina programa
	syscall
