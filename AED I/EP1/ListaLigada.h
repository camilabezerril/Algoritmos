#include <malloc.h>
#include <stdbool.h>
#include <string.h>

//-------------------------- STRUCTS DA LISTA -------------------------//

typedef struct {
    char nome_soldado[30];
    int vezes; // vezes q entrou na listalig
} REGISTRO_L;

typedef struct tempRegistro_L {
    REGISTRO_L reg;
    struct tempRegistro_L *prox;
} ELEMENTO_L;

typedef ELEMENTO_L *PONT_L;

typedef struct {
    PONT_L inicio;
} LISTA_LIGADA;

//---------------------- FUNCOES DA LISTA LIGADA ----------------------//
// lista de soldados que foram eliminados do círculo

void inicializarLista_L(LISTA_LIGADA *l) {
    l->inicio = NULL;
}

void reinicializarLista_L(LISTA_LIGADA *l) {
    PONT_L end = l->inicio;
    while (end != NULL) {
        PONT_L apagar = end;
        end = end->prox;
        free(apagar);
    }
    l->inicio = NULL;
}

PONT_L buscaSeq_L(LISTA_LIGADA *l, char nome[], PONT_L *ant) {
    *ant = NULL;
    PONT_L atual = l->inicio;

    while ((atual != NULL) && (strcmp(atual->reg.nome_soldado, nome)) < 0) {
        *ant = atual;
        atual = atual->prox;
    }

    if ((atual != NULL) && (strcmp(atual->reg.nome_soldado, nome)) == 0)
        return atual;
    return NULL;
}

bool insercaoLista_L(LISTA_LIGADA *l, REGISTRO_L reg) {
    PONT_L ant, i;

    i = buscaSeq_L(l, reg.nome_soldado, &ant);

    if (i != NULL)
        return false;

    i = (PONT_L)malloc(sizeof(ELEMENTO_L));
    i->reg = reg;

    if (ant == NULL) {
        i->prox = l->inicio;
        l->inicio = i;
    } else {
        i->prox = ant->prox;
        ant->prox = i;
    }
    return true;
}

bool exibirLista_L(LISTA_LIGADA *l) {
    PONT_L end = l->inicio;

    printf("\n\nList of unlucky soldiers:\n");

    if (qtdNomesLista_L(l) == 0)
        printf("The list is empty!");

    while (end != NULL) {
        printf("%s", end->reg.nome_soldado);
        end = end->prox;
        printf("\n");
    }
    printf("\n");
    return true;
}

bool excluirDaLista_L(LISTA_LIGADA *l, REGISTRO_L reg) {
    PONT_L ant, i;

    i = buscaSeq_L(l, reg.nome_soldado, &ant);
    if (i == NULL)
        return false;

    if (ant == NULL)
        l->inicio = i->prox;
    else
        ant->prox = i->prox;
    free(i);

    return true;
}

int qtdNomesLista_L(LISTA_LIGADA *l) {
    PONT_L end = l->inicio;
    int nroElem = 0;

    while (end != NULL) {
        nroElem++;
        end = end->prox;
    }

    return nroElem;
}