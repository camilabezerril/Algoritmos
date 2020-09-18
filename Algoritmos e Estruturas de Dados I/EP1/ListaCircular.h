#include <malloc.h>
#include <stdbool.h>
#include <string.h>

//-------------------------- STRUCTS DA LISTA -------------------------//

typedef struct {
    char nome_soldado[30];
    int vezes; // vezes q entrou na listalig
} REGISTRO_C;

typedef struct tempRegistro_C {
    REGISTRO_C reg;
    struct tempRegistro_C *prox;
} ELEMENTO_C;

typedef ELEMENTO_C *PONT_C;

typedef struct {
    PONT_C cabeca;
} LISTA_CIRCULAR;

//--------------------- FUNCOES DA LISTA CIRCULAR --------------------//

void inicializarLista_C(LISTA_CIRCULAR *c) {
    c->cabeca = (PONT_C)malloc(sizeof(ELEMENTO_C));
    c->cabeca->prox = c->cabeca; // lista circular
}

void reinicializarLista_C(LISTA_CIRCULAR *c) {
    PONT_C end = c->cabeca->prox;
    while (end != c->cabeca) {
        PONT_C apagar = end;
        end = end->prox;
        free(apagar);
    }
    c->cabeca->prox = c->cabeca;
}

PONT_C buscaSeq_C(LISTA_CIRCULAR *c, char nome[], PONT_C *ant) {
    *ant = c->cabeca;
    PONT_C atual = c->cabeca->prox;

    while (strcmp(atual->reg.nome_soldado, nome) < 0) {
        *ant = atual;
        atual = atual->prox;
    }

    if (atual != c->cabeca && strcmp(atual->reg.nome_soldado, nome) == 0)
        return atual;
    return NULL;
}

bool insercaoLista_C(LISTA_CIRCULAR *c, REGISTRO_C reg) {
    PONT_C ant, i;

    i = buscaSeq_C(c, reg.nome_soldado, &ant);

    if (i != NULL)
        return false;
    i = (PONT_C)malloc(sizeof(ELEMENTO_C)); // aloca memória para novo elemento
    i->reg = reg;
    i->prox = ant->prox;
    ant->prox = i;

    return true;
}

bool excluirDaLista_C(LISTA_CIRCULAR *c, REGISTRO_C reg) {
    PONT_C ant, i;

    i = buscaSeq_C(c, reg.nome_soldado, &ant);
    if (i == NULL)
        return false;

    ant->prox = i->prox;
    free(i);

    return true;
}

bool exibirLista_C(LISTA_CIRCULAR *c) {
    PONT_C end = c->cabeca->prox;

    printf("\nList of soldiers: \n");

    if (qtdNomesLista_C(c) == 0)
        printf("The list is empty!");

    while (end != c->cabeca) {
        printf("%s", end->reg.nome_soldado);
        end = end->prox;
        printf("\n");
    }
    printf("\n");
}

int qtdNomesLista_C(LISTA_CIRCULAR *c) {
    PONT_C end = c->cabeca->prox;
    int nroElem = 0;

    while (end != c->cabeca) {
        nroElem++;
        end = end->prox;
    }

    return nroElem;
}
