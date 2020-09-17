public interface Filtro {

    boolean aplicarFiltro(Produto produto);
}

class semFiltro implements Filtro {

    @Override
    public boolean aplicarFiltro(Produto produto) {
        return true;
    }
}

class porCategoria implements Filtro {

    private Object argFiltro;

    public porCategoria(Object argFiltro){
        this.argFiltro = argFiltro;
    }

    @Override
    public boolean aplicarFiltro(Produto produto) {
        if(produto.getCategoria().equalsIgnoreCase((String) argFiltro)) return true;
        return false;
    }
}

class porEstoque implements Filtro {

    private Object argFiltro;

    public porEstoque(Object argFiltro){
        this.argFiltro = argFiltro;
    }

    @Override
    public boolean aplicarFiltro(Produto produto) {

        if(produto.getQtdEstoque() <= (int) argFiltro) return true;
        return false;

    }
}