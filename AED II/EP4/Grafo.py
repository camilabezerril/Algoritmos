import queue
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
    verticesValidos = []
    marked = []
    edgeTo = []
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
                    if u not in self.verticesValidos:
                        self.verticesValidos.append(u)
                if key == v:
                    value.acrescentar_Vizinho(u)
                    if v not in self.verticesValidos:
                        self.verticesValidos.append(v)
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

    def createFalse(self, max):
        for x in range(max + 1):
            self.marked.append(False)

    def createEdgeZerado(self, max):
        for j in range(max + 1):
            self.edgeTo.append(0)

    def setFalse(self, max):
        for x in range(max + 1):
            self.marked[x] = False

    def setEdgeZerado(self, max):
        for j in range(max + 1):
            self.edgeTo[j] = 0

    def busca_LarguraBFS(self, key):
        self.count = 0

        self.setFalse(len(self.todosVertices))
        self.setEdgeZerado(len(self.todosVertices))

        self.visita_VerticeBFS(key)

        # print(self.edgeTo)
        return self.count

    def visita_VerticeBFS(self, key):
        q = queue.Queue(maxsize=0)
        self.marked[key] = True
        q.put(key)
        self.count += 1
        while q.empty() is not True:
            v = q.get()
            for w in self.todosVertices[v].vizinhos:
                # print("w: " + str(w))
                # print("marked: " + str(self.marked[w]))
                if self.marked[w] is not True:
                    #print(v, w)
                    self.edgeTo[w] = v
                    self.marked[w] = True
                    q.put(w)
                    self.count += 1

    def caminhoVertice(self, source, v):
        if self.marked[v] is not True:          # self.marked[v] = hasPathTo
            return None
        path = deque()
        x = v
        while x != source:
            x = self.edgeTo[x]
            # print("EdgeTo:", x)
            path.append(x)
        print("A distância de {0} até {1} é de {2} arestas".format(source, v, len(path)))
        print("O caminho de {0} até {1} é: {2}".format(v, source, path))
        return len(path)

    def diametroGrafo_BFS(self):
        maxDistancia = 0
        tamVerticesValidos = len(self.verticesValidos)
        self.verticesValidos.sort()

        qtdDistancias = np.zeros(100)

        for w in range(len(self.verticesValidos)):
            vBuscado = self.verticesValidos[w]
            self.busca_LarguraBFS(vBuscado)
            for v in range(len(self.verticesValidos)):
                posAtual = self.verticesValidos[v]
                print("O vértice buscado atual {0} é o {1} da lista de vertices válidos de tamanho {2}".format(vBuscado, w, tamVerticesValidos))
                if v != w:
                    distancia = self.caminhoVertice(vBuscado, posAtual)
                    if distancia is not None:
                        qtdDistancias[distancia] += 1
                        if distancia > maxDistancia:
                            maxDistancia = distancia

        if maxDistancia != 0:
            a_file = open("Distancias.txt", "w")
            for j in range(100):
                if qtdDistancias[j] > 0:
                    print(str(j) + ": " + str(int(qtdDistancias[j])))
                    a_file.write(str(j) + ": " + str(int(qtdDistancias[j])) + "\n")
            a_file.close()
            print("O diâmetro calculado do grafo é:", maxDistancia)
