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

    printf("\nOBS: This first k value is the one that defines where the count should start\n");
    pos = soldados->cabeca->prox;
    pos = sortearSoldado(soldados, &pos); //sorteia um soldado para começar a contagem

    while (qtdNomesLista_C(soldados) > 1) {

        printf("\n----------------------------- START OF ROUND -----------------------------\n");

        printf("\nLIST OF SOLDIERS AT THE BEGINNING\n");
        exibirLista_C(soldados);

        printf("The count will now start on %s\n", pos->reg.nome_soldado);

        PONT_C novoAzarado = sortearSoldado(soldados, &pos);
        printf("\nThe new unlucky one is %s\n", novoAzarado->reg.nome_soldado);

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
            printf("\nActually... it seems that the soldier %s is the only one remain...", soldados->cabeca->prox);
            break;
        }
        if (chance % valorT == 0)
            resgatarAzarado(azarados, soldados);

        printf("\nLISTS AFTER THIS ROUND");
        exibirLista_L(azarados);
        exibirLista_C(soldados); 

        printf("------------------------------ END OF ROUND ------------------------------\n");
    }

    if (qtdNomesLista_C(soldados) == 1)
        printf("\nThe soldier %s should be the one to take the horse!\n\n", soldados->cabeca->prox);
}

PONT_C sortearSoldado(LISTA_CIRCULAR *soldados, PONT_C *pos) {

    int k, i;
    PONT_C atual;

    k = rand() % 15;
    printf("The k value to a new unlucky soldier is: %i\n", k);

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
    printf("\n\nThe k value to a rescue soldier is: %i\n", k);

    atual = azarados->inicio;

    for (i = 0; i < k - 1; i++)
        atual = atual->prox;

    if (atual->reg.vezes < 1) {
        atual->reg.vezes++;

        REGISTRO_C regC;
        strcpy(regC.nome_soldado, atual->reg.nome_soldado);
        regC.vezes = atual->reg.vezes;

        printf("The unlucky soldier %s is luckier than we thought, he's back to the game!\n\n", atual->reg.nome_soldado);
        insercaoLista_C(soldados, regC);
        excluirDaLista_L(azarados, atual->reg);

    } else {
        printf("\nThe unlucky one %s tried his way back, but it wasn't enough...\n", atual->reg.nome_soldado);
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
        printf("\n//-------------Menu-------------//\n");
        printf("1 - Insert a name into the list\n");
        printf("2 - Delete a name of the list\n");
        printf("3 - Reset list\n");
        printf("4 - Insert a t value and start the game\n");
        printf("5 - Exit\n\n");

        printf("\nThe current list of soldiers: \n");
        exibirLista_C(&Soldados);

        printf("\nThe current list of unlucky soldiers:");
        exibirLista_L(&Azarados);

        printf("\nChoose an option on the menu: ");
        scanf("%i", &resposta);

        int qtdnomes;
        int i;
        char retornarmenu = "n";

        switch (resposta) {
        case (1):
            while (strcmp(&retornarmenu, "y") != 0) {
                REGISTRO_C reg;

                system("cls");
                printf("\nHow many names are gonna be on the list? ");
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

                printf("Do you wish to go back to the menu? [y/n]\n");
                scanf("%s", &retornarmenu);
            }
            break;

        case (2):
            while (strcmp(&retornarmenu, "y") != 0) {
                REGISTRO_C reg;
                system("cls");

                printf("\nType a name to be deleted: ");
                scanf("%s", reg.nome_soldado);

                exibirLista_C(&Soldados);
                excluirDaLista_C(&Soldados, reg);
                exibirLista_C(&Soldados);

                printf("Do you wish to go back to the menu? [y/n]\n");
                scanf("%s", &retornarmenu);
            }
            break;

        case (3):

            while (strcmp(&retornarmenu, "y") != 0) {
                system("cls");

                reinicializarLista_C(&Soldados);
                reinicializarLista_L(&Azarados);

                printf("The list has been reset\n\n");
                printf("Do you wish to go back to the menu? [y/n]\n");
                scanf("%s", &retornarmenu);
            }
            break;

        case (4):

            while (strcmp(&retornarmenu, "y") != 0) {
                int valorT;

                system("cls");
                printf("Type a t value which the unlucky ones will be given a new chance: \n");
                scanf("%i", &valorT);
                system("cls");

                printf("The soldiers list at the beginning is: \n");
                exibirLista_C(&Soldados);
                printf("The t value chosen was: %i\n", valorT);

                iniciarJogo(&Soldados, &Azarados, valorT);

                printf("Do you wish to go back to the menu? [y/n]\n");
                scanf("%s", &retornarmenu);
            }
            break;

        case (5):
            return;
        }
    }
}
