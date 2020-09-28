from afn import AFN

with open('ArqTeste.txt') as file:
    n_automatos = int(file.readline())

    for i in range(n_automatos):

        print("\n------------- AUTÔMATO {0} ------------- \n".format(i + 1))

        # CRIACAO DO AUTOMATO

        estados = []
        alfabeto = []
        aceitos = []
        n_trans = 0
        n_cadeias = 0
        transicoes = dict()
        cadeias = dict()
        epsilon = []
        resultado = []

        cabecalho = file.readline().split(" ")

        for j in range(int(cabecalho[0])):
            estados.append(j)
        print("Estados do AFN: {0}".format(estados))

        for j in range(int(cabecalho[1])):
            alfabeto.append(j)
        print("Alfabeto do AFN: {0}".format(alfabeto))

        inicio = int(cabecalho[3])
        print("Estado inicial do AFN: {0}".format(inicio))

        n_trans = int(cabecalho[2])

        estados_aceitos = file.readline().split(" ")

        for j in range(len(estados_aceitos)):
            aceitos.append(int(estados_aceitos[j]))
        print("Estados finais do AFN: {0}".format(aceitos))

        for j in range(n_trans):
            transicao = file.readline().split(" ")

            estado_atual = int(transicao[0])
            simbolo = int(transicao[1])
            estado_posterior = int(transicao[2])

            funcao = (estado_atual, simbolo)

            if funcao not in transicoes.keys():
                # cria lista com novo estado para a funcao de transicao em questão
                transicoes[funcao] = [estado_posterior]
            else:
                # lista já está criada, basta adicionar novo item
                transicoes[funcao].append(estado_posterior)

            if simbolo == 0 and estado_atual not in epsilon:
                epsilon.append(estado_atual)

        n_cadeias = int(file.readline())

        # LEITURA DAS CADEIAS

        for j in range(n_cadeias):
            cadeia = file.readline().split(" ")
            cadeias_inteiro = []
            for estado in cadeia:
                cadeias_inteiro.append(int(estado))
            cadeias[j] = cadeias_inteiro

        print("As funções de transição do AFN são: {0}".format(transicoes))

        afn = AFN(estados, alfabeto, transicoes, inicio, aceitos, epsilon)

        # RECONHECIMENTO DE CADEIAS

        for cadeia in cadeias.values():
            resultado.append(afn.reconhece_cadeias(cadeia))

        print("As cadeias aceitas/rejeitadas foram: " + str(resultado))

        # RESULTADOS EM TXT

        fileSaida = open('ArqSaida.txt', 'a')
        for item in resultado:
            fileSaida.write(str(item) + " ")
        fileSaida.write("\n")

fileSaida.close()
file.close()
