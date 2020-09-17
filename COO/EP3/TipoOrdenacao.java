public interface TipoOrdenacao {

    void aplicarOrdenacao(Produto[] produtos, CritOrdenacao crit);
}

class insertionSort implements TipoOrdenacao {

    @Override
    public void aplicarOrdenacao(Produto[] produtos, CritOrdenacao crit) {

        for (int i = 0; i <= produtos.length - 1; i++) {

            Produto x = produtos[i];
            int j = (i - 1);

            while (j >= 0) {

                if(crit.criterioMaiorQue(produtos[j], x)){
                    produtos[j + 1] = produtos[j];
                    j--;
                }
                else break;
            }
            produtos[j + 1] = x;
        }
    }
}

class quickSort implements TipoOrdenacao {

    private Produto[] produtos;
    private CritOrdenacao crit;

    @Override
    public void aplicarOrdenacao(Produto[] produtos, CritOrdenacao crit) {
        this.produtos = produtos;
        this.crit = crit;

        ordena(0, produtos.length - 1);
    }

    public void ordena(int ini, int fim){
        if(ini < fim) {

            int q = particiona(ini, fim);

            ordena(ini, q);
            ordena(q + 1, fim);
        }
    }

    public int particiona(int ini, int fim){

        Produto x = produtos[ini];
        int i = (ini - 1);
        int j = (fim + 1);

        while(true){
            do{
                j--;

            } while(crit.criterioMaiorQue(produtos[j], x));

            do{
                i++;

            } while(crit.criterioMenorQue(produtos[i], x));

            if(i < j){
                Produto temp = produtos[i];
                produtos[i] = produtos[j];
                produtos[j] = temp;
            }
            else return j;
        }
    }
}

