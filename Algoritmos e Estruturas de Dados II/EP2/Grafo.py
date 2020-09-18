from ListaAdj import ListaDuplamenteLigada


class Grafo:
    def __init__(self, v): # v + 1
        self.vertices = []
        self._tamanho = 0
        for i in range(1, v):
            self.vertices.append(i)

    def novo_Vertice(self, IDPessoa):
        listaAdjacente = ListaDuplamenteLigada()

        # Insere no index IDPessoa a lista
        self.vertices.insert(IDPessoa, listaAdjacente)
        # Insere o próprio IDpessoa na lista
        self.vertices[IDPessoa].acrescentar(IDPessoa)

    def novo_NoAdj(self, IDy, IDx):
        if self.vertices[IDy].buscar_Item(IDx) is not True:
            self.vertices[IDy].acrescentar(IDx)
            self._tamanho += 1
        if self.vertices[IDx].buscar_Item(IDy) is not True:
            self.vertices[IDx].acrescentar(IDy)
            self._tamanho += 1

    def contar_NoVertice(self, IDPessoa):
        return len(self.vertices[IDPessoa])

    def mostrar_ItemVertice(self, IDy, IDx):
        return self.vertices[IDy][IDx]

    def contar_GrauVertice(self, IDy):
        return len(self.vertices[IDy]) - 1

    def contar_arestasGrafo(self):
        return self._tamanho

    def mostrar_NosAdj(self, IDy):
        return self.vertices[IDy].mostrar_Lista()

    def buscar_Item(self, IDy, IDx):
        return self.vertices[IDy].buscar_Item(IDx)