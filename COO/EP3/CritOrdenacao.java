public interface CritOrdenacao {

    boolean criterioMaiorQue(Produto j, Produto x);
    boolean criterioMenorQue(Produto j, Produto x);
}

class pelaDescricao implements CritOrdenacao {

    private String ordem;

    public pelaDescricao(String ordem){
        this.ordem = ordem;
    }

    @Override
    public boolean criterioMaiorQue(Produto j, Produto x) {
        if(ordem.equals("Crescente") && j.getDescricao().compareToIgnoreCase(x.getDescricao()) > 0) return true;
        else if(ordem.equals("Decrescente") && j.getDescricao().compareToIgnoreCase(x.getDescricao()) < 0) return true;
        return false;
    }

    @Override
    public boolean criterioMenorQue(Produto j, Produto x) {
        if(ordem.equals("Crescente") && j.getDescricao().compareToIgnoreCase(x.getDescricao()) < 0) return true;
        else if(ordem.equals("Decrescente") && j.getDescricao().compareToIgnoreCase(x.getDescricao()) > 0) return true;
        return false;
    }
}

class peloPreco implements CritOrdenacao {

    private String ordem;

    public peloPreco(String ordem){
        this.ordem = ordem;
    }

    @Override
    public boolean criterioMaiorQue(Produto j, Produto x) {
        if(ordem.equals("Crescente") && j.getPreco() > x.getPreco()) return true;
        else if(ordem.equals("Decrescente") && j.getPreco() < x.getPreco()) return true;
        return false;
    }

    @Override
    public boolean criterioMenorQue(Produto j, Produto x) {
        if(ordem.equals("Crescente") && j.getPreco() < x.getPreco()) return true;
        else if(ordem.equals("Decrescente") && j.getPreco() > x.getPreco()) return true;
        return false;
    }
}

class peloEstoque implements CritOrdenacao {

    private String ordem;

    public peloEstoque(String ordem){
        this.ordem = ordem;
    }

    @Override
    public boolean criterioMaiorQue(Produto j, Produto x) {
        if(ordem.equals("Crescente") && j.getQtdEstoque() > x.getQtdEstoque()) return true;
        else if(ordem.equals("Decrescente") && j.getQtdEstoque() < x.getQtdEstoque()) return true;
        return false;
    }

    @Override
    public boolean criterioMenorQue(Produto j, Produto x) {
        if(ordem.equals("Crescente") && j.getQtdEstoque() < x.getQtdEstoque()) return true;
        else if(ordem.equals("Decrescente") && j.getQtdEstoque() > x.getQtdEstoque()) return true;
        return false;
    }
}
