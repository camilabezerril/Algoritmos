#include "filapreferencial.h"

PFILA criarFila() {
    PFILA res = (PFILA)malloc(sizeof(FILAPREFERENCIAL));
    res->cabeca = (PONT)malloc(sizeof(ELEMENTO));
    res->inicioNaoPref = res->cabeca;
    res->cabeca->id = -1;
    res->cabeca->idade = -1;
    res->cabeca->ant = res->cabeca;
    res->cabeca->prox = res->cabeca;
    return res;
}

int tamanho(PFILA f) {
    PONT atual = f->cabeca->prox;
    int tam = 0;
    while (atual != f->cabeca) {
        atual = atual->prox;
        tam++;
    }
    return tam;
}

PONT buscarID(PFILA f, int id) {
    PONT atual = f->cabeca->prox;
    while (atual != f->cabeca) {
        if (atual->id == id)
            return atual;
        atual = atual->prox;
    }
    return NULL;
}

void exibirLog(PFILA f) {
    int numElementos = tamanho(f);
    printf("\nLog fila [elementos: %i]\t- Inicio:", numElementos);
    PONT atual = f->cabeca->prox;
    while (atual != f->cabeca) {
        printf(" [%i;%i]", atual->id, atual->idade);
        atual = atual->prox;
    }
    printf("\n                       \t-    Fim:");
    atual = f->cabeca->ant;
    while (atual != f->cabeca) {
        printf(" [%i;%i]", atual->id, atual->idade);
        atual = atual->ant;
    }
    printf("\n\n");
}

int consultarIdade(PFILA f, int id) {
    PONT atual = f->cabeca->prox;
    while (atual != f->cabeca) {
        if (atual->id == id)
            return atual->idade;
        atual = atual->prox;
    }
    return -1;
}

bool inserirPessoaNaFila(PFILA f, int id, int idade) {
    if (id < 0 || idade < 0 || buscarID(f, id) != NULL)
        return false;

    PONT novo_no = (PONT)malloc(sizeof(ELEMENTO));
    novo_no->id = id;
    novo_no->idade = idade;
    novo_no->prox = NULL;
    novo_no->ant = NULL;

    if (tamanho(f) == 0) {
        f->inicioNaoPref = novo_no;
        f->inicioNaoPref->prox = f->cabeca;
        f->inicioNaoPref->ant = f->cabeca;
        f->cabeca->prox = f->inicioNaoPref;
        f->cabeca->ant = f->inicioNaoPref;

    } else if (idade < IDADEPREFERENCIAL) {
        if (f->inicioNaoPref->idade >= IDADEPREFERENCIAL)
            f->inicioNaoPref = novo_no;

        PONT finalAnt = f->cabeca->ant;
        novo_no->ant = finalAnt;
        finalAnt->prox = novo_no;

        novo_no->prox = f->cabeca;
        f->cabeca->ant = novo_no;

    } else if (idade >= IDADEPREFERENCIAL) {

        PONT finalAnt = f->inicioNaoPref->ant;
        novo_no->ant = finalAnt;
        finalAnt->prox = novo_no;

        novo_no->prox = f->inicioNaoPref;
        f->inicioNaoPref->ant = novo_no;
    }

    return true;
}

bool atenderPrimeiraDaFila(PFILA f, int *id) {
    if (tamanho(f) == 0)
        return false;

    *id = f->cabeca->prox->id;
    PONT apagar = f->cabeca->prox;

    f->cabeca->prox = apagar->prox;
    apagar->prox->ant = f->cabeca;

    free(apagar);

    if (tamanho(f) == 0) {
        f->inicioNaoPref = f->cabeca;
        f->cabeca->ant = f->cabeca;
        f->cabeca->prox = f->cabeca;
    }

    return true;
}

bool desistirDaFila(PFILA f, int id) {
    PONT pessoa = buscarID(f, id);
    if (pessoa == NULL)
        return false;

    if (tamanho(f) == 1) {
        f->inicioNaoPref = f->cabeca;
        f->cabeca->ant = f->cabeca;
        f->cabeca->prox = f->cabeca;

    } else if (f->inicioNaoPref == pessoa) {

        if (f->inicioNaoPref->prox != f->cabeca) {
            PONT ant = pessoa->ant;
            f->inicioNaoPref = pessoa->prox;
            f->inicioNaoPref->ant = ant;
            f->inicioNaoPref->ant->prox = f->inicioNaoPref;

        } else {
            if (f->cabeca->prox != f->cabeca)
                f->inicioNaoPref = f->cabeca->prox;

        }
    } else if (f->cabeca->prox == pessoa) {
        
            PONT ant = pessoa->ant;
            f->cabeca->prox = pessoa->prox;
            pessoa->prox->ant = ant;
    }

    free(pessoa);

    return true;
}
