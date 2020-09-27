#include "ListaCircular.h"
#include "ListaLigada.h"

#include <locale.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

//prototype to solve conflicting types
PONT_C sortearSoldado(LISTA_CIRCULAR* a, PONT_C* b);

void iniciarJogo(LISTA_CIRCULAR *soldados, LISTA_LIGADA *azarados, int valorT) {
    int chance = 0;
    PONT_C pos;

    printf("\nOBS: Este primeiro valor k define onde a contagem deve comecar\n");
    pos = soldados->cabeca->prox;
    pos = sortearSoldado(soldados, &pos); //sorteia um soldado para começar a contagem

    while (qtdNomesLista_C(soldados) > 1) {

        printf("\n----------------------------- INICIO DA RODADA -----------------------------\n");

        printf("\nLISTA DE SOLDADOS INICIAL:\n");
        exibirLista_C(soldados);

        printf("A contagem deveria comecar no %s\n", pos->reg.nome_soldado);

        PONT_C novoAzarado = sortearSoldado(soldados, &pos);
        printf("\nO novo azarado e %s\n", novoAzarado->reg.nome_soldado);

        //a contagem irá iniciar no próximo do novoAzarado na próxima rodada
        if (novoAzarado->prox != soldados->cabeca)
            pos = novoAzarado->prox;
        else
            pos = soldados->cabeca->prox; //Pular nó cabeça ao recomeçar lista

        REGISTRO_L regA;
        strcpy(regA.nome_soldado, novoAzarado->reg.nome_soldado);
        regA.vezes = novoAzarado->reg.vezes;

        insercaoLista_L(azarados, regA); //O novo azarado é inserido na lista de azarado.

        excluirDaLista_C(soldados, novoAzarado->reg); //O novo azarado é excluido da lista de soldados
        chance++;                //A chance de alguém retornar da lista de azarados é aumentada

        if (qtdNomesLista_C(soldados) == 1) {
            printf("\nNa verdade... parece que o soldado %s e o unico que esta na roda...", soldados->cabeca->prox);
            break;
        }
        if (chance % valorT == 0)
            resgatarAzarado(azarados, soldados);

        printf("\nLISTS AFTER THIS ROUND");
        exibirLista_L(azarados);
        exibirLista_C(soldados); 

        printf("------------------------------ FIM DA RODADA ------------------------------\n");
    }

    if (qtdNomesLista_C(soldados) == 1)
        printf("\nO soldado %s deve pegar o cavalo!\n\n", soldados->cabeca->prox);
}

PONT_C sortearSoldado(LISTA_CIRCULAR *soldados, PONT_C *pos) {

    int k, i;
    PONT_C atual;

    k = rand() % 15;
    printf("O valor k para um novo soldado azarado e: %i\n", k);

    atual = soldados->cabeca->prox;

    while (atual != *pos)
        atual = atual->prox;

    for (i = 0; i < k; i++) {
        if (atual == soldados->cabeca)
            atual = atual->prox; //Pular nó cabeça ao recomeçar lista

        if (i + 1 == k) //se estiver no fim do laço, n pular pro prox q pode ser o nó cabeça
            break;
        atual = atual->prox; //se esse atual for o cabeca no prox i do laço vai sair no if
    }

    return atual;
}

void resgatarAzarado(LISTA_LIGADA *azarados, LISTA_CIRCULAR *soldados) {
    PONT_L atual;
    int k, i;

    k = rand() % qtdNomesLista_L(azarados);
    printf("\n\nO valor k para resgatar um soldado e: %i\n", k);

    atual = azarados->inicio;

    for (i = 0; i < k - 1; i++)
        atual = atual->prox;

    if (atual->reg.vezes < 1) {
        atual->reg.vezes++;

        REGISTRO_C regC;
        strcpy(regC.nome_soldado, atual->reg.nome_soldado);
        regC.vezes = atual->reg.vezes;

        printf("O azarado %s tem mais sorte do que pensavamos, ele esta de volta a roda!\n\n", atual->reg.nome_soldado);
        insercaoLista_C(soldados, regC);
        excluirDaLista_L(azarados, atual->reg);

    } else {
        printf("\nO azarado %s tentou voltar a roda, mas infelizmente não conseguiu...\n", atual->reg.nome_soldado);
    }
}

int main() {

    setlocale(LC_ALL, "portuguese");

    LISTA_CIRCULAR Soldados;
    LISTA_LIGADA Azarados;
    srand(time(NULL));

    inicializarLista_C(&Soldados);
    inicializarLista_L(&Azarados);

    int resposta;

    while (true) {

        system("cls");
        printf("\n//------------- Menu -------------//\n");
        printf("1 - Inserir um nome na lista\n");
        printf("2 - Deletar um nome da lista\n");
        printf("3 - Reiniciar lista\n");
        printf("4 - Inserir um valor t e iniciar o jogo\n");
        printf("5 - Sair\n\n");

        printf("\nA lista atual de soldados e: \n");
        exibirLista_C(&Soldados);

        printf("\nA lista atual de azarados e:");
        exibirLista_L(&Azarados);

        printf("\nEscolha uma opcao no menu ");
        scanf("%i", &resposta);

        int qtdnomes;
        int i;
        char retornarmenu = "n";

        switch (resposta) {
        case (1):
            while (strcmp(&retornarmenu, "y") != 0) {
                REGISTRO_C reg;

                system("cls");
                printf("\nQuantos nomes terao na lista? ");
                scanf("%d", &qtdnomes);
                system("cls");

                for (i = 0; i < qtdnomes; i++) {
                    printf("\n[name %i]", i + 1);
                    printf("\nType the name: ");
                    scanf("%s", reg.nome_soldado);

                    reg.vezes = 0;
                    insercaoLista_C(&Soldados, reg);
                }

                system("cls");
                exibirLista_C(&Soldados);

                printf("Deseja voltar ao menu? [y/n]\n");
                scanf("%s", &retornarmenu);
            }
            break;

        case (2):
            while (strcmp(&retornarmenu, "y") != 0) {
                REGISTRO_C reg;
                system("cls");

                printf("\nDigite um nome para ser deletado ");
                scanf("%s", reg.nome_soldado);

                exibirLista_C(&Soldados);
                excluirDaLista_C(&Soldados, reg);
                exibirLista_C(&Soldados);

                printf("Deseja voltar ao menu? [y/n]\n");
                scanf("%s", &retornarmenu);
            }
            break;

        case (3):

            while (strcmp(&retornarmenu, "y") != 0) {
                system("cls");

                reinicializarLista_C(&Soldados);
                reinicializarLista_L(&Azarados);

                printf("A lista foi reiniciada\n\n");
                printf("Deseja voltar ao menu? [y/n]\n");
                scanf("%s", &retornarmenu);
            }
            break;

        case (4):

            while (strcmp(&retornarmenu, "y") != 0) {
                int valorT;

                system("cls");
                printf("Digite um valor t no qual os azarados terao uma nova chance: \n");
                scanf("%i", &valorT);
                system("cls");

                printf("A lista de soldados no comeco do jogo e: \n");
                exibirLista_C(&Soldados);
                printf("O valor t escolhido foi: %i\n", valorT);

                iniciarJogo(&Soldados, &Azarados, valorT);

                printf("Deseja voltar ao menu? [y/n]\n");
                scanf("%s", &retornarmenu);
            }
            break;

        case (5):
            return;
        }
    }
}
