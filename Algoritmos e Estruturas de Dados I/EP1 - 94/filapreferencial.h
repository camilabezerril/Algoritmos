#include <stdlib.h>
#include <stdio.h>
#define true 1
#define false 0
#define IDADEPREFERENCIAL 60

typedef int bool;

typedef struct aux {
  int id;
  int idade;
  struct aux* prox;
} ELEMENTO, * PONT;

typedef struct {
  PONT inicio;
  PONT fimPref;
  PONT inicioNaoPref;
  PONT fim;
} FILAPREFERENCIAL, * PFILA;

