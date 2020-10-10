.data
file: .asciiz "teste.txt"      # filename for input
buffer: .space 512            # 512 / 4 = 128 space for words

.align 4
numbers: .space 512

# Mensagens
newline: .asciiz "\n"

.text
####################### LEITURA DO ARQUIVO ########################
AbrirArquivo:
	li	$v0, 13          		# system call for open file
	la	$a0, file        		# input file name
	li	$a1, 0           		# flag for read-only
	li	$a2, 0           		# mode is ignored
	syscall			 		# open a file 
	move	$s0, $v0         		# save the file descriptor 
	
LerArquivo:
	li	$v0, 14				# 14 = read from file
	move 	$a0, $s0      			# file descriptor 
	la	$a1, buffer			# buffer to hold int charged in a1
	li	$a2, 512			# Read 512 bytes - size of buffer
	syscall
	
############## CONTA ELEMENTOS, OS CONVERTE PARA INTEIRO E GUARDA EM ARRAY ##############
UsarBuffer:
	la 	$s0, buffer	
	la 	$s1, numbers             	# Guarda números em array
	
LerBuffer:  
	lbu 	$t1, 0($s0)  			# carrega um byte do buffer
	beqz 	$t1, numElem  			# if $t1 == 0, ou seja, null terminator, então finaliza indo para numElem
	
	beq 	$t1, 32, SpaceFound		# desvia se encontrar espaço (ascii = 32)
	
	# Converte ascii para int
	addi    $t1, $t1, -48    
    	mul    $t4, $t4, 10            		# Multiply word by 10
    	add    $t4, $t4, $t1       		# numero += array[s1]-'0'
    	
    	# Salva int em array
    	sll $t0, $t9, 2           		# acerta i - só incrementa em spacefound
	add $t0, $t0, $s1         		# acerta numbers[i]
	sw $t4, 0($t0)
    	
	addi 	$s0, $s0, 1      		# incrementa endereço do buffer (vai pra prox numero)
	j LerBuffer

SpaceFound:
	add 	$t4, $zero, $zero		# zera variavel da conversao str -> int
	addi 	$t9, $t9, 1			# incrementa i para novo número em array
	addi 	$s0, $s0, 1      		# incrementa endereço do buffer (pula espaço)
	addi 	$s2, $s2, 1			# O número de elementos é o número de espaços + 1 (somado posteriormente)
	
    	j LerBuffer

numElem:
	addi 	$s2, $s2, 1			# O número de elementos é o número de espaços + 1
	
##################### PROGRAMA PRINCIPAL #######################

# int tam (Tamanho do vetor a ser ordenado): $s2
# int *vetor (Vetor a ser ordenado): $s1 - endereço base
main:

ordena:
	
############### FECHA ARQUIVO E TERMINA PROGRAMA ###############
Fim:
	# FECHAR ARQUIVO
	li   	$v0, 16       			# system call for close file
	move 	$a0, $s6      			# file descriptor to close
	syscall            			# close file
	
	# TERMINA EXECUÇÃO
	li 	$v0, 10         		# termina programa
	syscall
	
