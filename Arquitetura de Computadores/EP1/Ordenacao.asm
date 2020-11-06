.data
# Arquivos
in: .space 80    				# Entrada
ord: .space 4					# Define ordenação

# Buffers
buffer: .space 512             			# Armazena ascii de números (Entrada)
temp: .space 512				# Armazena temporariamente número ascii
buffer_ordenados: .space 512			# Armazena números ascii para colocar em txt (Saída)

# Vetor
.align 4
numeros: .space 512				# Armazena números em vetor

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

	# Lê entradas do usuário
	jal entradaUsuario
	
	# Leitura de Arquivo de Entrada
	jal iniciarLeitura
	
	# Interpretar números armazenados no buffer (Str -> Int)
	jal iniciarBuffer_In
	
	la 	$a0, ($s1)
	la 	$a2, ($s2)				
	la	$a3, ($s6)                       # Define tipo ordenação (0 = selection, 1 = quick)
	
	# Ordenar números
	jal ordena
	
	add 	$s3, $zero, $v0		   	 # tamanho do vetor resultante retorna em $v0
	
	# Interpretar resultados para armazenar em buffer (Int -> Str)
	jal iniciarBuffer_Out
	
	# Escrita de Arquivo de Saída e finaliza programa
	j iniciarEscrita

# -------------------------------- ENTRADA DO USUÁRIO --------------------------------------- #
entradaUsuario:
	subi 	$sp, $sp, 12
	sw 	$t2, 8($sp)
	sw 	$t1, 4($sp)
	sw 	$t0, 0($sp) 

	# Qual é o nome do arquivo de entrada?
	li	$v0, 4
	la	$a0, entrada
	syscall
	li	$v0, 8
	la 	$a0, in
	li 	$a1, 80
	syscall
	
	la	$t2, in
	
	corrigirIn:  					# Corrige string lida do usuário para que o programa ache o arquivo
		lb 	$t0, 0($t2)  			# carrega um byte do buffer
		beq 	$t0, 10, foundChar		
	
		addi 	$t2, $t2, 1      		# incrementa endereço do buffer (vai pra prox letra)
		j 	corrigirIn

	foundChar:
		addi	$t1, $zero, 0
		sb	$t1, 0($t2)			# substitui char 10 por 0 (string possui \n, enquanto arquivos não possuem)
	
DefineOrdenacao:	
	li	$v0, 4
	la	$a0, ordenacao
	syscall
	li 	$v0, 5
	syscall
	move 	$s6, $v0
	
	lw 	$t0, 0($sp)
	lw 	$t1, 4($sp)
	lw 	$t2, 8($sp)
	addi 	$sp, $sp, 12
	
	jr 	$ra

# --------------------------------- LEITURA DO ARQUIVO -------------------------------------- #
iniciarLeitura:
	subi 	$sp, $sp, 16
	sw 	$a2, 12($sp)
	sw 	$a1, 8($sp)
	sw 	$a0, 4($sp)
	sw 	$t0, 0($sp)              

abrirIn:
	li	$v0, 13          		# 13 = abrir arquivo
	la	$a0, in        			# nome do arquivo de entrada
	li	$a1, 0           		# flag 0 = apenas leitura
	li	$a2, 0           		
	syscall			 		# abrir arquivo
	move	$t0, $v0         		# referencia do arquivo
	
lerIn:
	li	$v0, 14				# 14 = ler do arquivo
	move 	$a0, $t0      			# referencia 
	la	$a1, buffer			# buffer para guardar o que for lido
	li	$a2, 512			# le até 512 bytes (tamanho do buffer)
	syscall

fecharIn:
	li   	$v0, 16       			# 16 = fecha arquivo
	move 	$a0, $t0      			# referencia
	syscall            			
	
finalizarLeitura:
	lw 	$t0, 0($sp)
	lw 	$a0, 4($sp)
	lw 	$a1, 8($sp)
	lw 	$a2, 12($sp)
	addi 	$sp, $sp, 16
	
	jr 	$ra

# -------------- CONTA ELEMENTOS, OS CONVERTE PARA INTEIRO E ARMAZENA EM ARRAY ---------------- #
iniciarBuffer_In:
	subi 	$sp, $sp, 20
	sw 	$t4, 16($sp)
	sw 	$t3, 12($sp)
	sw 	$t2, 8($sp)
	sw 	$t1, 4($sp)
	sw 	$t0, 0($sp)

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
    	add    	$t3, $t3, $t1       		# numero += vetor[s1]-'0'
    	
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
	lw 	$t0, 0($sp)
	lw 	$t1, 4($sp)
	lw 	$t2, 8($sp)
	lw 	$t3, 12($sp)
	lw 	$t4, 16($sp)
	addi 	$sp, $sp, 20
	
	jr $ra

# --------------------------------- INICIA ORDENAÇÃO -------------------------------------- #	
ordena:
	beq 	$a3, $zero, iniciarSelection
	beq 	$a3, 1, iniciarQuick	

# ------------------------------------ SELECTION SORT ------------------------------------- #

# $t6 = i, $t7 = j, $t1 = index
# $a2 = numeros.length, $a0 = numeros
# resultado está em $a0 num vetor

iniciarSelection:
	subi 	$sp, $sp, 32
	sw 	$t7, 28($sp)
	sw 	$t6, 24($sp)
	sw 	$t5, 20($sp)
	sw 	$t4, 16($sp)
	sw 	$t3, 12($sp)
	sw 	$t2, 8($sp)
	sw 	$t1, 4($sp)
	sw 	$t0, 0($sp)

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
	move	$v0, $s2			# retorna qtd de elementos no vetor resultante               
	
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
	
# ------------------------------------- QUICK SORT -------------------------------------- #
iniciarQuick:
	subi 	$sp, $sp, 36
	sw 	$ra, 32($sp)
	sw 	$t7, 28($sp)
	sw 	$t6, 24($sp)
	sw 	$t5, 20($sp)
	sw 	$t4, 16($sp)
	sw 	$t3, 12($sp)
	sw 	$t2, 8($sp)
	sw 	$t1, 4($sp)
	sw 	$t0, 0($sp)

	subi	$a2, $a2, 1				# Subtrai 1 para contar vetor do 0
	li 	$a1, 0				 	# Define menor index do vetor
	
	jal 	quickSort
	j 	finalizarQuick

quickSort: 
	subi 	$sp, $sp, 16				 
	sw 	$ra, 12($sp)
	sw 	$a2, 8($sp)
	sw 	$a1, 4($sp)
	sw 	$a0, ($sp)
	
	bge 	$a1, $a2, retorna 			# inicio >= fim? -> se sim, retorna
	
	jal 	particionar 
	
	subi 	$a2, $v0, 1				# novo fim = pivot_index - 1
	jal 	quickSort 				
		
	lw 	$a2, 8($sp)				# Carrega novamente a2 para novo quick			
	addi 	$a1, $v0, 1				# novo inicio = pivot_index + 1
	jal 	quickSort 				
	
retorna: 
	lw 	$a0,($sp)
	lw 	$a1, 4($sp)
	lw 	$a2, 8($sp)
	lw 	$ra, 12($sp)
	addi 	$sp, $sp, 16	
	jr 	$ra 	 

particionar: 
	subi 	$sp, $sp, 16				
	sw 	$a0,($sp)
	sw 	$a1, 4($sp)
	sw 	$a2, 8($sp)
	sw 	$ra, 12($sp)
	
	sll 	$t0, $a1, 2				
	add 	$t0, $t0, $a0				# numeros[inicio]
	lw 	$t0,($t0)				# pivot = numeros[inicio]
	
	move 	$t1, $a1				# i = inicio
	addi 	$t2, $a1, 1				# j = inicio + 1
	
for: 
	lw 	$a2, 8($sp)				# carrega a2 de novo, caso ele tenha sido modificado (entrou no if)	
	bgt 	$t2, $a2, continue 			# j > fim? se sim -> continue
				
	sll 	$t3, $t2, 2			
	add 	$t3, $t3, $a0				# numeros[j]
	lw 	$t3,($t3)				# carrega valor de numeros[j]
	
	bge 	$t3, $t0, maior				# numeros[j] < pivot? se não -> maior
	
	addi 	$t1, $t1, 1				# i++
					
	move 	$a1, $t1				# arg1 = i
	move 	$a2, $t2				# arg2 = j
	jal 	trocaQuick 
	
	maior: 
	addi 	$t2, $t2, 1				# j++
	
	j 	for 

continue: 
	lw 	$a1, 4($sp)				# agr1 = inicio
	move 	$a2, $t1				# arg2 = i
	jal 	trocaQuick 			
	
	move 	$v0, $t1				# retorna i
	
	lw 	$a0,($sp)				 
	lw 	$a1, 4($sp)
	lw 	$a2, 8($sp)
	lw 	$ra, 12($sp)
	addi 	$sp, $sp, 16	
	jr 	$ra 
	
trocaQuick: 
	sll 	$t4, $a1, 2 	
	add 	$t4, $a0, $t4				# numeros[arg1]
	
	sll 	$t5, $a2, 2		
	add 	$t5, $a0, $t5				# numeros[arg3]
	
	lw 	$t6, 0($t4)				# valor de numeros[arg1]
	lw 	$t7, 0($t5)				# valor de numeros[arg2]
	sw 	$t6, 0($t5)		
	sw 	$t7, 0($t4)		

	jr 	$ra
	
finalizarQuick:
	la 	$s0, numeros
	la	$s0, ($a0)				# salva array ordenado em $s0
	
	move	$v0, $s2				# retorna qtd de elementos no vetor resultante  

	lw 	$t0, 0($sp)
	lw 	$t1, 4($sp)
	lw 	$t2, 8($sp)
	lw 	$t3, 12($sp)
	lw 	$t4, 16($sp)
	lw 	$t5, 20($sp)
	lw 	$t6, 24($sp)
	lw 	$t7, 28($sp)
	lw	$ra, 32($sp)
	addi 	$sp, $sp, 36
	
	jr	$ra

# ---------------------------- CONVERTE VETOR ORDENADO INT -> STR -------------------------- #

# $s0 = array dos numeros ordenados a serem escritos
# $s2 = tamanho do vetor
# $s4 = tamanho de caracteres que entrou

iniciarBuffer_Out:
	subi 	$sp, $sp, 28
	sw 	$t6, 24($sp)
	sw 	$t5, 20($sp)
	sw 	$t4, 16($sp)
	sw 	$t3, 12($sp)
	sw 	$t2, 8($sp)
	sw 	$t1, 4($sp)
	sw 	$t0, 0($sp)

usarBuffers:
	la 	$s5, buffer_ordenados
	addi	$s4, $s4, 1					# adicionando espaço para caractere de espaço extra devido ao loop
	
escreverBuffers:
	beq	$t0, $s2, finalizarBuffer_Out			# i = número de elementos do vetor? se sim, escrever buffer no arquivo
	
	sll 	$t1, $t0, 2					# acerta i
   	add 	$t1, $t1, $s0					# $s0[i]   	
   	lw 	$t1, 0($t1)
   	
	# Converte int -> str
   	la   	$t6, temp + 30
      	sb   	$0, 1($t6)     				# sb para null terminator
      	li   	$t2, '0'       				# 0 => 48 em ascii  
      	sb   	$t2, ($t6)    				# coloca ascii 0   
      	li   	$t3, 10        				
      	beq  	$t1, $0, findNullTerminator  		# = 0 -> termina direto
      
	loop:
      		div  	$t1, $t3       				# a /= 10
      		mflo 	$t1
      		mfhi 	$t4           				# resto da divisão
      		add  	$t4, $t4, $t2  				# equivalente a 0x30 (-48 na primeira conversão)	
      		sb   	$t4, ($t6)     				
      		sub  	$t6, $t6, 1    				# decrementa buffer (a conversão é feita ao contrário)
      		bne  	$t1, $0, loop  				
      		addi 	$t6, $t6, 1    				# ajusta ponteiro do buffer
   	
   	findNullTerminator:    					# semelhante ao pular espaço, pulando null terminator para adicionar espaço
   		lbu 	$t5, 0($t6)
   		beq	$t5, $0, found
   		
   		sb 	$t5, 0($s5) 				# adiciona novo numero sem null terminator
   		
   		addi	$s5, $s5, 1
   		addi 	$t6, $t6, 1 
   		j 	findNullTerminator
   	
   	found: 
		li 	$t5, 32					# 32 = espaço dec -> ascii
   		sb 	$t5, 0($s5) 				# adiciona espaço
   		
   		addi	$s5, $s5, 1
	
   	addi	$t0, $t0, 1
   	j 	escreverBuffers
   	
finalizarBuffer_Out:
	lw 	$t0, 0($sp)
	lw 	$t1, 4($sp)
	lw 	$t2, 8($sp)
	lw 	$t3, 12($sp)
	lw 	$t4, 16($sp)
	lw 	$t5, 20($sp)
	lw 	$t6, 24($sp)
	addi 	$sp, $sp, 28
	
	jr 	$ra

# ---------------------- ESCREVE EM ARQUIVO DE SAIDA E FINALIZA PROGRAMA ------------------------ #
iniciarEscrita:
	sub	$s5, $s5, $s4				# decrementa endereço para voltar ao ínicio da string

   	li 	$v0, 4
   	la 	$a0, ($s5)
   	syscall
   		
abrirOut:
	li	$v0, 13          			# 13 = abrir arquivo
	la	$a0, in	        			# nome do arquivo
	li	$a1, 9           			# 0 = flag para escrever sem sobreescrever arquivo
	li	$a2, 0           		
	syscall			 			# abrir arquivo
	move	$t0, $v0         			# salva referencia do arquivo
	
escreverOut:
	li	$v0, 15					# 15 = escreve no arquivo
	move 	$a0, $t0      				# usa referencia
	la	$a1, newline				# Adiciona quebra de linha
	la	$a2, 1
	syscall
	
	li   	$v0, 15       				# 15 = escrece no arquivo
	move 	$a0, $t0      				# usa referencia 
	la	$a1, ($s5)				# buffer a ser escrito
	la	$a2, ($s4)				# Escreve a qtd de caracteres que entrou (evita espaços nulos)
	syscall
	
fecharOut:
	li   	$v0, 16       				# 16 = fecha arquivo
	move 	$a0, $t0      				# usa referencia
	syscall            				
	
fim:	
	li 	$v0, 10         			# termina programa
	syscall
