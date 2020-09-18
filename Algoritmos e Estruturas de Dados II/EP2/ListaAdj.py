class AdjNo:
    def __init__(self, IDpessoa):
        self.vertice = IDpessoa
        self.visitado = False
        self.proximo = None


class ListaDuplamenteLigada(object):
    cabeca = None
    rabo = None
    _tamanho = 0

    def acrescentar(self, IDpessoa):

        novo_no = AdjNo(IDpessoa)

        if self.cabeca is None:
            self.cabeca = novo_no
            self.rabo = novo_no
            self._tamanho += 1
        else:
            novo_no.anterior = self.rabo
            novo_no.proximo = None
            self.rabo.proximo = novo_no
            self.rabo = novo_no
            self._tamanho += 1

    def remover(self, dado):
        no_atual = self.cabeca

        while no_atual is not None:
            if no_atual.dado == dado:
                if no_atual.anterior is None:
                    self.cabeca = no_atual.proximo
                    no_atual.proximo.anterior = None
                else:
                    no_atual.anterior.proximo = no_atual.proximo
                    no_atual.proximo.anterior = no_atual.anterior

            no_atual = no_atual.proximo

    def __getitem__(self, index):
        no_atual = self.cabeca

        for i in range(index):
            if no_atual:
                no_atual = no_atual.proximo
            else:
                raise IndexError('List index out of range')
        if no_atual:
            return no_atual.vertice
        raise IndexError('List index out of range')

    def __len__(self):
        return self._tamanho

    def mostrar_Lista(self):
        no_atual = self.cabeca
        lista = ""
        print("Nós adjacentes ao vértice {0}:".format(no_atual.vertice))
        for i in range(self._tamanho):
            if no_atual:
                lista = lista + " --> " + str(no_atual.vertice)
                no_atual = no_atual.proximo
            else:
                raise IndexError('List index out of range')
        print(lista)

    def buscar_Item(self, IDx):
        no_atual = self.cabeca

        for i in range(self._tamanho):
            if no_atual.vertice == IDx:
                return True
            if no_atual:
                no_atual = no_atual.proximo
        if no_atual is None:
            return False



