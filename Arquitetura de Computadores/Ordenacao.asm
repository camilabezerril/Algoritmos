.data
file: .asciiz "teste.txt"      # filename for input
buffer: .space 512             # 512 / 4 = 128 space for words

.align 4
numbers: .space 512

ordenados: .space 512          # Armazena ascii para colocar em txt

# Mensagens
newline: .asciiz "\n"

.text
# --------------------------------- LEITURA DO ARQUIVO -------------------------------------- #
abrirArquivo:
	li	$v0, 13          		# system call for open file
	la	$a0, file        		# input file name
	li	$a1, 0           		# flag for read-only
	li	$a2, 0           		# mode is ignored
	syscall			 		# open a file 
	move	$s0, $v0         		# save the file descriptor 
	
lerArquivo:
	li	$v0, 14				# 14 = read from file
	move 	$a0, $s0      			# file descriptor 
	la	$a1, buffer			# buffer to hold int charged in a1
	li	$a2, 512			# Read 512 bytes - size of buffer
	syscall
	
# -------------- CONTA ELEMENTOS, OS CONVERTE PARA INTEIRO E ARMAZENA EM ARRAY ---------------- #
usarBuffer:
	la 	$s0, buffer	
	la 	$s1, numbers             	# Guarda números em array
	
lerBuffer:  
	lbu 	$t1, 0($s0)  			# carrega um byte do buffer
	beqz 	$t1, numElem  			# if $t1 == 0, ou seja, null terminator, então finaliza indo para numElem
	
	beq 	$t1, 32, spaceFound		# desvia se encontrar espaço (ascii = 32)
	
	# Converte ascii para int
	addi    $t1, $t1, -48    
    	mul    	$t4, $t4, 10            	# multiplica palavra por 10
    	add    	$t4, $t4, $t1       		# numero += array[s1]-'0'
    	
    	# Salva int em array
    	sll 	$t0, $s2, 2           		# acerta i - só incrementa em spacefound
	add 	$t0, $t0, $s1         		# acerta numbers[i]
	sw 	$t4, 0($t0)
    	
	addi 	$s0, $s0, 1      		# incrementa endereço do buffer (vai pra prox numero)
	j 	lerBuffer

spaceFound:
	li 	$t4, 0				# zera variavel da conversao str -> int
	addi 	$s0, $s0, 1      		# incrementa endereço do buffer (pula espaço)
	addi 	$s2, $s2, 1			# O número de elementos é o número de espaços + 1 (somado posteriormente)
						# $s2 também é usado como i para incrementar array para novo número
	
    	j 	lerBuffer

numElem:
	addi 	$s2, $s2, 1			# O número de elementos é o número de espaços + 1
	
# ------------------------------- PROGRAMA PRINCIPAL -------------------------------- #

# int *vetor (Vetor a ser ordenado): $s1 - endereço base
# int tam (Tamanho do vetor a ser ordenado): $s2
# int tipo (Tipo de ordenação a ser usada): $s3

main:
	li 	$s3, 0                     	# Define tipo ordenação (0 = selection, 1 = quick)
	
	la 	$a0, ($s1)
	la 	$a1, ($s2)
	la 	$a2, ($s3)
	
	beq 	$a2, $zero, selectionSort
	beq 	$a2, 1, quickSort
	
	add 	$s4, $s4, $v0		   	# tamanho do vetor resultante retorna em $v0
	
	li $v0, 1
	lw $t0, 0($a0)
	la $a0, ($t0)
	syscall
	
	j Fim

# -------------------------------- SELECTION SORT --------------------------------- #

# public static void selectionSort(int[] arr){  
#        for (int i = 0; i < arr.length - 1; i++)  
#        {  
#            int index = i;  
#            for (int j = i + 1; j < arr.length; j++){  
#                if (arr[j] < arr[index]){  
#                    index = j;//searching for lowest index  
#                }  
#            }  
#            int smallerNumber = arr[index];   
#            arr[index] = arr[i];  
#            arr[i] = smallerNumber;  
#        }  
#    }  

# $s0 = i, $s1 = j, $t1 = index
# $a1 = array.length, $a0 = arr
# resultado está em $a0 num array

selectionSort:
	la 	$s0, 0                          # Inicio do array -> $t0 = min
	addi 	$t0, $a1, -1			# $t1 = array.length - 1
	
forFora:
	beq 	$s0, $t0, fimSelection      	# Se i = array.length - 1 -> desvio
	add 	$t1, $s0, $zero             	# index = $s0 (i)
	
	addi 	$s1, $s0, 1                	# j = i + 1 -> inicio do for de dentro
	
forDentro:
	beq 	$s1, $a1, troca			# Se j = array.length -> desvio
	sll 	$t2, $t1, 2                     # acerta index
	add 	$t2, $t2, $a0                   # acerta numbers[index]
	lw 	$t2, 0($t2)               	# $t2 = numbers[index]
   	sll 	$t3, $s1, 2                     # acerta j
   	add 	$t3, $t3, $a0			# acerta numbers[j]
   	lw 	$t3, 0($t3)                  	# $t3 = numbers[j]
   	slt	$t2, $t3, $t2			# numbers[j] < numbers[index]?
   	bne 	$t2, $zero, atualizaIndex     	# Se sim ($t2 = 1), troca numbers[index] por numbers[j]
   	
   	add 	$s1, $s1, 1 			# incrementa j
   	j 	forDentro
   	
atualizaIndex:
	move 	$t1, $s1                        # index = j
	j 	forDentro
   	
troca:	
   	sll 	$t2, $s0, 2                     # acerta i
   	add 	$t2, $t2,$a0			# numbers[i]
   	sll 	$t3, $t1, 2			# acerta index   
   	add 	$t3, $t3,$a0			# numbers[index]
   	lw 	$t4, 0($t2)        
   	lw 	$t5, 0($t3)        
   	sw 	$t4, 0($t3)
   	sw 	$t5, 0($t2)
   	
atualizaForFora:
	addi	$s0, $s0, 1                     # incrementa i
	j 	forFora

fimSelection:
	add 	$v0, $v0, $s1                   # retorna j, isto é, qtd de elementos no vetor resultante

# ----------------------------------- QUICK SORT ---------------------------------- #
quickSort:

	
# ------------------------ FECHA ARQUIVO E TERMINA PROGRAMA ----------------------- #
Fim:	
	# FECHAR ARQUIVO
	li   	$v0, 16       			# system call for close file
	move 	$a0, $s6      			# file descriptor to close
	syscall            			# close file
	
	# TERMINA EXECUÇÃO
	li 	$v0, 10         		# termina programa
	syscall
	
