class AFN:
    cadeia = []
    reconhece = 0

    def __init__(self, estados, alfabeto, transicoes, inicio, aceitos, epsilon):
        self.estados = estados
        self.alfabeto = alfabeto
        self.transicoes = transicoes
        self.inicio = inicio
        self.aceitos = aceitos
        self.estado_atual = inicio
        self.estados_epsilon = epsilon
        return

    def visita_estados(self, estado_atual, index):
        if index == len(self.cadeia):
            bool_estado = estado_atual in self.aceitos

            if bool_estado:
                self.reconhece = 1

            # Checa se o último estado chego pela cadeia está conectado a outro por epsilon.
            if estado_atual in self.estados_epsilon:
                for estado_possivel in self.transicoes[estado_atual, 0]:
                    self.visita_estados(estado_possivel, index)

            return bool_estado

        elif index < len(self.cadeia):
            simbolo_atual = self.cadeia[index]
            funcao = (estado_atual, simbolo_atual)

            if funcao in self.transicoes.keys():
                for estado_possivel in self.transicoes[funcao]:
                    self.visita_estados(estado_possivel, index + 1)

            # Checa se há alguma conexão epsilon no meio da cadeia
            if estado_atual in self.estados_epsilon:
                for estado_possivel in self.transicoes[estado_atual, 0]:
                    self.visita_estados(estado_possivel, index)

    def reconhece_cadeias(self, cadeia):
        self.reconhece = 0
        self.cadeia = cadeia
        index = 0
        estado_atual = self.inicio

        if (cadeia[index] == 0) and (estado_atual not in self.estados_epsilon):  # Testa cadeia vazia
            # Checa se mesmo com cadeia vazia, há alguma conexão epsilon
            # não precisando ler quaisquer simbolos para percorrer, se houver.
            if self.inicio in self.aceitos:
                self.reconhece = 1
        else:
            self.visita_estados(estado_atual, index)

        # Só retorna True se a cadeia toda foi lida e está no estado final
        # Se a cadeia não foi lida por inteiro, a recursão retorna None
        # Se o estado após ler toda a cadeia não for final, retorna False
        return self.reconhece
