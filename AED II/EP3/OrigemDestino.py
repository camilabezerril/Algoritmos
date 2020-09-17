from Grafo import Grafo
from Grafo import Vertice

grafoODpessoas = Grafo()

# Tamanho do arranjo original: 86318
for i in range(1, 86319):  # obs: ele só adiciona um nó adjacente se exister no grafo ambos os vértices
    grafoODpessoas.adicionar_Vertice(Vertice(i))

# Descarta as primeiras duas linhas do arquivo
with open('cenario3.txt') as f:
    lin1 = int(f.readline())
    lin2 = int(f.readline())
    restante = f.readlines()

i = 0
for line in restante:  # comeca na linha 3
    dadoSplit = line.split(" ")
    grafoODpessoas.adicionar_NoAdj(int(dadoSplit[0]), int(dadoSplit[1]))
    print("Dado {0} de IDPessoas {1} e {2} adicionado!".format(i, int(dadoSplit[0]), int(dadoSplit[1])))
    i += 1
#     Para testes
#    if i == 1000:
#        break

grafoODpessoas.buscarComponentes_DFS()
