.data
in: .asciiz "in.txt"      # filename for input
out: .asciiz "out.txt"
buffer: .space 512             # 512 / 4 = 128 space for words

.align 4
numbers: .space 512

temp: .space 512
buffer_ordenados: .space 512          # Armazena ascii para colocar em txt

# Mensagens
newline: .asciiz "\n"
space: .asciiz " "

.text
# --------------------------------- LEITURA DO ARQUIVO -------------------------------------- #
abrirIn:
	li	$v0, 13          		# system call for open file
	la	$a0, in        			# input file name
	li	$a1, 0           		# flag for read-only
	li	$a2, 0           		# mode is ignored
	syscall			 		# open a file 
	move	$s0, $v0         		# save the file descriptor 
	
lerIn:
	li	$v0, 14				# 14 = read from file
	move 	$a0, $s0      			# file descriptor 
	la	$a1, buffer			# buffer to hold int charged in a1
	li	$a2, 512			# Read 512 bytes - size of buffer
	syscall

fecharIn:
	li   	$v0, 16       			# system call for close file
	move 	$a0, $s6      			# file descriptor to close
	syscall            			# close file
	
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
	li	$a3, 0                          # Usado no quickSort para o index_menor
	
	beq 	$a2, $zero, selectionSort
	beq 	$a2, 1, quickSort
	
	add 	$s1, $zero, $v0		   	# tamanho do vetor resultante retorna em $v0
	
	j usarBuffers 	#INDA N FUNCIONA

# -------------------------------- SELECTION SORT --------------------------------- #

# public static void selectionSort(int[] arr){  
#        for (int i = 0; i < arr.length - 1; i++){  
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
   	
incrementaForFora:
	addi	$s0, $s0, 1                     # incrementa i
	j 	forFora

fimSelection:
	add 	$v0, $v0, $s1                   # retorna j, isto é, qtd de elementos no vetor resultante
	
	la 	$s0, numbers
	la	$s0, ($a0)			# salva array ordenado em $s0

	j usarBuffers 	# TEMPORARIO

# ----------------------------------- QUICK SORT - INCOMPLETO AINDA ---------------------------------- #

#quickSort(arr[], low, high)
#{
#    if (low < high){
#        // pivot_index is partitioning index, arr[pivot_index] is now at correct place in sorted array
#        pivot_index = partition(arr, low, high);
#
#        quickSort(arr, low, pivot_index - 1);  // Before pivot_index
#        quickSort(arr, pivot_index + 1, high); // After pivot_index
#    }
#}

#partition (arr[], low, high){
#    // pivot - Element at right most position
#    pivot = arr[high];  
#    i = (low - 1);  // Index of smaller element
#    for (j = low; j <= high-1; j++){
#        // If current element is smaller than the pivot, swap the element with pivot
#        if (arr[j] < pivot){
#            i++;    // increment index of smaller element
#            swap(arr[i], arr[j]);
#        }
#    }
#    swap(arr[i + 1], arr[high]);
#    return (i + 1);
#}

# pivot = $s0

quickSort:	
	subi $sp, $sp, -12		
	sw $a0, 12($sp)			# salva array atual
	sw $a1, 8($sp)			# salva index_maior atual
	sw $a3, 4($sp)			# salva index_menor atual
	sw $ra, 0($sp)		
	move $fp, $sp
	
	slt $t1, $a1, $a1		# t1=1 if low < high, else 0
	beq $t1, $zero, fimQuick	# if low >= high, quick
	
	jal particionar
	add $s0, $v0, $v0
	

particionar:

fimQuick:
	

# ------------------ CONVERTE ARRAY INT -> STR, ESCREVE EM TXT E FINALIZA PROGRAMA ------------------- #

# $s0 = array dos numeros ordenados a serem escritos
# $s2 = tamanho do vetor

usarBuffers:
	#la 	$s1, buffer_ordenados
	li 	$t0, 0
	li	$t1, 0
	li	$t2, 0
	li	$t3, 0
	li 	$t4, 0
	
escreverBuffers:
	beq	$t0, $s2, abrirOut		# i = número de elementos do vetor? se sim, escrever buffer no arquivo
	
	sll 	$t1, $t0, 2			# acerta i
   	add 	$t1, $t1, $s0			# $s0[i]   	
   	lw 	$t1, 0($t1)
   	
   	itoa:
   		la   $s3, temp + 30
      		#add  $s3, $s3, 30   # seek the end
      		sb   $0, 1($s3)     # null-terminated str
      		li   $t2, '0'  
      		sb   $t2, ($s3)     # init. with ascii 0      
      		li   $t3, 10        # preload 10
      		beq  $t1, $0, fimItoa  # end if 0
      
	loop:
      		div  $t1, $t3       # a /= 10
      		mflo $t1
      		mfhi $t4            # get remainder
      		add  $t4, $t4, $t2  # convert to ASCII digit
      		sb   $t4, ($s3)     # store it
      		sub  $s3, $s3, 1    # decrease buffer pointer
      		bne  $t1, $0, loop  # if not zero, loop
      		addi $s3, $s3, 1    # adjust buffer pointer
      
	fimItoa:
		li $v0, 4
   		la $a0, ($s3)
   		syscall
   		la $a0, newline
   		syscall
   	
   	
   	addi	$t0, $t0, 1
   	j escreverBuffers 			

abrirOut:
	li	$v0, 13          		# system call for open file
	la	$a0, out        		# input file name
	li	$a1, 1           		# flag for write-only
	li	$a2, 0           		# mode is ignored
	syscall			 		# open a file 
	move	$s0, $v0         		# save the file descriptor 
	
escreverOut:
	li	$v0, 15				# 15 = write from file
	move 	$a0, $s0      			# file descriptor 
	la	$a1, ($s3)			# buffer to hold int charged in a1
	li	$a2, 512			# Write 512 bytes - size of buffer
	syscall
	
fecharOut:
	li   	$v0, 16       			# system call for close file
	move 	$a0, $s6      			# file descriptor to close
	syscall            			# close file
	
fim:	
	li 	$v0, 10         		# termina programa
	syscall
	
