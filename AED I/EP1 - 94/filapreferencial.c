#include "filapreferencial.h"

PFILA criarFila() {
    PFILA res = (PFILA)malloc(sizeof(FILAPREFERENCIAL));
    res->inicio = NULL;
    res->fimPref = NULL;
    res->inicioNaoPref = NULL;
    res->fim = NULL;
    return res;
}

int tamanho(PFILA f) {
    PONT atual = f->inicio;
    int tam = 0;
    while (atual) {
        atual = atual->prox;
        tam++;
    }
    return tam;
}

PONT buscarID(PFILA f, int id) {
    PONT atual = f->inicio;
    while (atual) {
        if (atual->id == id)
            return atual;
        atual = atual->prox;
    }
    return NULL;
}

void exibirLog(PFILA f) {
    int numElementos = tamanho(f);
    printf("\nLog fila [elementos: %i] - Inicio:", numElementos);
    PONT atual = f->inicio;
    while (atual) {
        printf(" [%i;%i]", atual->id, atual->idade);
        atual = atual->prox;
    }
    printf("\n\n");
}

int consultarIdade(PFILA f, int id) {
    PONT atual = f->inicio;
    while (atual) {
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

    	/* Casos a serem tratados:
	1. Antes da inserção a fila pode estar vazia
	2. Pode ter apenas pessoas sem direito ao atendimento preferencial
	3. Pode ter apenas pessoas com direito ao atendimento preferencial
	4. Ou pode ter pessoas da duas categorias
	...
	*/

    if (tamanho(f) == 0) {
        f->inicio = novo_no;
        f->fim = novo_no;
    }

    if (idade >= IDADEPREFERENCIAL) {
        if (f->fimPref != NULL) {
            f->fimPref->prox = novo_no;

        } else if (f->inicioNaoPref == f->inicio) {
            f->inicio = novo_no;
        }

        f->fimPref = novo_no;

        if (f->inicioNaoPref == NULL) {
            f->fim = novo_no;
        }
    } else if (idade < IDADEPREFERENCIAL) {
        if (f->inicioNaoPref == NULL) {
            f->inicioNaoPref = novo_no;
        } else {
            f->fim->prox = novo_no;
        }
        f->fim = novo_no;
    }

    if (f->inicioNaoPref != NULL && f->fimPref != NULL)
        f->fimPref->prox = f->inicioNaoPref;

    return true;
}

bool atenderPrimeiraDaFila(PFILA f, int *id) {
    if (f->inicio == NULL)
        return false;
    *id = f->inicio->id;
    PONT apagar = f->inicio;
    f->inicio = f->inicio->prox;
    free(apagar);
    if (f->inicio == NULL) {
        f->fim = NULL;
        f->inicioNaoPref = NULL;
        f->fimPref = NULL;
    }
    return true;
}

bool desistirDaFila(PFILA f, int id) {
    PONT pessoa = buscarID(f, id);
    if (pessoa == NULL)
        return false;

    	/* Casos a serem tratados:
	1. A pessoa pode ser a única na fila
	2. Pode ser a primeira com atendimento não preferencial
	3. Pode ser a primeira com atendimento preferencial
	4. Pode ser a ultima com atendimento não preferencial
    	5. Poder ser a última da fila
	...
	*/

    if (tamanho(f) == 1) {
        f->inicio = NULL;
        f->fim = NULL;
        f->fimPref = NULL;
        f->inicioNaoPref = NULL;

    } else if (f->inicioNaoPref == pessoa) {
        if (f->inicioNaoPref->prox == NULL) {
            f->inicioNaoPref == NULL;
            f->fim = f->fimPref;

        } else {
            f->inicioNaoPref = f->inicioNaoPref->prox;
            f->fimPref->prox = f->inicioNaoPref;
        }

    } else if (f->inicio == pessoa) {
        if (f->inicio->prox == NULL) {
            f->inicio = f->inicioNaoPref;

        } else {
            f->inicio = f->inicio->prox;
        }
    }

    free(pessoa);

    return true;
}
