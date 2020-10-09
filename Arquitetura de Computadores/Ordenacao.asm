.data

file: .asciiz "teste.txt"      # filename for input
buffer: .space 512            # 512 / 4 = 128 space for words
elem: .space 50
array: .space 512

# Mensagens
vetorMsg: .asciiz "O vetor a ser ordenado é: "
numElemMsg: .asciiz "O numero de elementos é: "
newline: .asciiz "\n"

.text

###################### LEITURA DO ARQUIVO ######################
AbrirArquivo:
	li	$v0, 13          # system call for open file
	la	$a0, file        # input file name
	li	$a1, 0           # flag for read-only
	li	$a2, 0           # mode is ignored
	syscall			 # open a file 
	move	$s0, $v0         # save the file descriptor 
	
LerArquivo:
	li	$v0, 14			# 14 = read from file
	move 	$a0, $s0      		# file descriptor 
	la	$a1, buffer		# buffer to hold int charged in a1
	li	$a2, 512		# Read 512 bytes - size of buffer
	syscall

	li	$v0, 4			# 1 = print int // but txt is a string = 4	
	la	$a0, vetorMsg
	syscall
	la	$a0, buffer
	syscall				# print int
	la	$a0, newline
	syscall
	
############## CONTA ELEMENTOS E USA PROCEDIMENTO PARA CONVERTER STRING PARA INTEIRO - armazenando em array ##############
j LerBuffer

PrintaElementos:
	# soma 1 ao n° de elementos e printa
	la $a0, numElemMsg
	syscall
	li $v0, 1
	addi $s1, $s1, 1		# O número de elementos é o número de espaços + 1
	la $a0, ($s1)
	syscall
	
	j Fim
	
LerBuffer:
	la 	$s0, buffer
	li 	$s1, 0      		# contador para elementos
	
	la 	$s3, elem               # guarda números a serem concatenados (grandes)
	
pulaEspaco:  
	lb $t1, 0($s0)  		# Load the first byte from address in $t1 
	beqz $t1, PrintaElementos  	# if $t1 == 0 then go to label end
	
	beq $t1, 32, contaElem		# branch if symbol equals 32 (" ")
	
	# concatena número
	# ---
	
	li $v0, 4
	la $a0, 0($s0)
	syscall
	la $a0, newline
	syscall
	
	addi $s0, $s0, 1      		# increment the address -- vai pra prox numero
	j pulaEspaco

contaElem:
	#jal converteStrToInt           # valor estará salvo em $s3, é feito quando um espaço é achado - o número acabou
	#la 	$s3, elem               # apaga o que tinha em elem para guardar novo número

	addi $s0, $s0, 1      		# increment the address -- pula espaço
	addi $s1, $s1, 1		# O número de elementos é o número de espaços + 1
	
    	j pulaEspaco 
    	
############### CONVERTE STRING PARA INTEIRO E SALVA EM ARRAY ################   
converteStrToInt:
	 			
    	
############### FECHA ARQUIVO E TERMINA PROGRAMA ###############
Fim:
	# FECHAR ARQUIVO
	li   $v0, 16       # system call for close file
	move $a0, $s6      # file descriptor to close
	syscall            # close file
	
	# TERMINA EXECUÇÃO
	li $v0, 10         # termina programa
	syscall
	
	
	
