from noOD import No


class ListaLigada:
    def __init__(self):
        self.cabeca = None
        self._tamanho = 0

    def append(self, cdX, cdY, IDpessoa):
        if self.cabeca:
            atual = self.cabeca
            while atual.prox is not None and (atual.coordenada_dX != cdX or atual.coordenada_dY != cdY):
                atual = atual.prox
            if atual.coordenada_dX == cdX and atual.coordenada_dY == cdY:
                if IDpessoa not in atual.frequentadores:  # Tira IDPessoas repetidas no local
                    atual.frequentadores.append(IDpessoa)
            elif atual.prox is None:
                print("Criando local", cdX, cdY)
                atual.prox = No(cdX, cdY, IDpessoa)
                self._tamanho += 1
        else:
            print("Criando local na cabeça", cdX, cdY)
            self.cabeca = No(cdX, cdY, IDpessoa)
            self._tamanho += 1

    def __len__(self):
        return self._tamanho

    # get por index
    def __getitem__(self, index):
        atual = self.cabeca
        for i in range(index):
            if atual:
                atual = atual.prox
            else:
                return IndexError('List index out of range')
        if atual:
            return "{0},{1},{2}".format(atual.coordenada_dX, atual.coordenada_dY, len(atual.frequentadores))
        return IndexError('List index out of range')

    # get por coordenada
    def getItem(self, cdX, cdY):
        atual = self.cabeca
        i = 0
        while atual:
            if atual.coordenada_dX == cdX and atual.coordenada_dY == cdY:
                return "{0},{1},{2},{3}".format(atual.coordenada_dX, atual.coordenada_dY, len(atual.frequentadores), i)
            if atual.prox is not None and (atual.coordenada_dX != cdX or atual.coordenada_dY != cdY):
                    atual = atual.prox
                    i += 1
            else:
                return ValueError('X:{0}, Y:{1} is not in list'.format(cdX, cdY))

    # Retorna quantidade de frequentadores em uma coordenada
    def contarFreq(self, cdX, cdY):
        atual = self.cabeca
        while atual:
            if atual.coordenada_dX == cdX and atual.coordenada_dY == cdY:
                return len(atual.frequentadores)
            if atual.prox is not None and (atual.coordenada_dX != cdX or atual.coordenada_dY != cdY):
                atual = atual.prox
            else:
                return ValueError('X:{0}, Y:{1} is not in list'.format(cdX, cdY))

    # Retorna quantidade de frequentadores em um index
    def contFreqIndex(self, index):
        atual = self.cabeca
        for i in range(index):
            if atual:
                atual = atual.prox
            else:
                return IndexError('List index out of range')
        if atual:
            return len(atual.frequentadores)
        return IndexError('List index out of range')
