import numpy as np
from collections import deque


class Vertice:
    def __init__(self, IDpessoa):
        self.id = IDpessoa
        self.vizinhos = list()

    def acrescentar_Vizinho(self, v):
        if v not in self.vizinhos:
            self.vizinhos.append(v)
            self.vizinhos.sort()


class Grafo:
    todosVertices = {}
    marked = []
    count = 0

    def adicionar_Vertice(self, v):
        if isinstance(v, Vertice) and v.id not in self.todosVertices:
            print("Adicionando vértice {0} à lista".format(v.id))
            self.todosVertices[v.id] = v
            return True
        else:
            return False

    def adicionar_NoAdj(self, u, v):
        if u in self.todosVertices and v in self.todosVertices:
            for key, value in self.todosVertices.items():
                if key == u:
                    value.acrescentar_Vizinho(v)
                if key == v:
                    value.acrescentar_Vizinho(u)
            return True
        else:
            return False

    def imprimir_Grafo(self):
        for key in sorted(list(self.todosVertices.keys())):
            print(str(key) + str(self.todosVertices[key].vizinhos))

    def mostrar_Vertice(self, key):
        print(str(key) + str(self.todosVertices[key].vizinhos))

    def contar_Grau(self, key):
        # Não contar o vértice inicial, dando assim o número de arestas
        return len(self.todosVertices[key].vizinhos)

    def contar_ArestasGrafo(self):
        total = 0
        for key in sorted(list(self.todosVertices.keys())):
            total = total + len(self.todosVertices[key].vizinhos)
        return total

    def setFalse(self, max):
        for x in range(max + 1):
            self.marked.append(False)

    def busca_ProfundidadeDFS(self, key, componente):
        self.count = 0

        if componente is not True:
            self.setFalse(len(self.todosVertices))

        self.visita_VerticeDFS(key)

        return self.count

    def visita_VerticeDFS(self, key):
        stack = deque()
        self.marked[key] = True
        stack.append(key)
        self.count += 1
        while len(stack) != 0:
            v = stack.pop()
            # print("Vértice", v)
            if self.marked[v] is not True:
                self.marked[v] = True
                self.count += 1
            for w in self.todosVertices[v].vizinhos:
                if self.marked[w] is not True:
                    # print("Vértice adjacente a {0}: {1}".format(v, w))
                    stack.append(w)

    def buscarComponentes_DFS(self):
        tamGrafo = len(self.todosVertices)

        qtdCompConex = np.zeros(tamGrafo + 1)  # inicializa vetor para contar componentes

        self.setFalse(tamGrafo)

        max = 0
        verticeMax = -1
        for r in range(1, tamGrafo + 1):
            # print(self.marked[r])
            # print(r)
            if self.marked[r] is not True:  # Para não recontar vértices
                print("Analisando vértice {0} do grafo".format(r))
                nComponente = self.busca_ProfundidadeDFS(r, True)
                qtdCompConex[nComponente] += 1
                if nComponente > max:
                    max = nComponente
                    verticeMax = r
            else:
                print("O vértice " + str(r) + " já foi visitado")

        a_file = open("Componentes.txt", "w")
        for j in range(1, tamGrafo + 1):
            if qtdCompConex[j] > 0:
                print(str(j) + ": " + str(qtdCompConex[j]))
                a_file.write(str(j) + ": " + str(qtdCompConex[j]) + "\n")
        a_file.close()

        print("A componente gigante contém por DFS:", max)
        print("Este é o vértice em que se inicia a componente gigante:", verticeMax)
