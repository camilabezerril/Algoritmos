import java.io.*;
import java.util.*;

public class glc {
    private static int nVariaveis = 0;
    private static int nTerminais = 0;
    private static int nRegras = 0;
    private static String inicial;
    private static List<String> variaveis = new ArrayList<>();
    private static List<String> terminais = new ArrayList<>();
    private static Map<String, List<String>> regras = new HashMap<>();

    public static void main(String[] args){
        lerGlc();
    }

    public static void lerGlc(){
        try {
            Scanner ler = new Scanner(new FileReader(new File("inputTesteGLC.txt")));

            while(ler.hasNextLine()){
                //ler.nextLine(); --> // linha q dirá quantas gramáticas serão lidas = desnecessária devido ao while
                String[] cabecalho = ler.nextLine().split(" ");

                nVariaveis = Integer.parseInt(cabecalho[0]);
                nTerminais = Integer.parseInt(cabecalho[1]);
                nRegras = Integer.parseInt(cabecalho[2]);
                variaveis = Arrays.asList(ler.nextLine().split(" "));
                terminais = Arrays.asList(ler.nextLine().split(" "));
                inicial = variaveis.get(0);

                for (String variavel : variaveis)
                    regras.computeIfAbsent(variavel, simbolosDireita -> new ArrayList<>());

                for (int i = 0; i < nRegras; i++) {
                    List<String> regraAtual = Arrays.asList(ler.nextLine().split(" "));

                    String simbolos = regraAtual.get(2);
                    if (regraAtual.size() > 3) simbolos += regraAtual.get(3);

                    regras.get(regraAtual.get(0)).add(simbolos);
                }

                System.out.println(regras);

                testarCadeias();
            }

        } catch(IOException e){
            e.printStackTrace();
        }
    }

    public static void testarCadeias(){
        try {
            Scanner ler = new Scanner(new FileReader(new File("inputTesteCadeias.txt")));

            int nCadeias = Integer.parseInt(ler.nextLine());

            for(int i = 0; i < nCadeias; i++){
                List<String> cadeia = Arrays.asList(ler.nextLine().split(" "));
                escreverResultados(iniciarCYK(cadeia), (nCadeias - 1) - i);
            }
        } catch(IOException e){
            e.printStackTrace();
        }
    }

    public static int iniciarCYK(List<String> cadeia){
        if(cadeia.get(0).equals("&") && regras.get(inicial).contains("&")) return 1;

        int tamCadeia = cadeia.size();
        String[][] cyk = criarMatrizCYK(tamCadeia);

        //StringBuilder addVariavel = new StringBuilder();

        // Trata substrings de tamanho 1
        for(int j = 0; j < tamCadeia; j++){
            for (String variavel : variaveis){
                if(regras.get(variavel).contains(cadeia.get(j))){
                    cyk[0][j] = cyk[0][j] + variavel;
                }
            }
        }

        // Passo 1: Definir o tamanho de substring atual
        for(int tamSubstr = 2; tamSubstr < tamCadeia; tamSubstr++){       // Tamanho das substrings

            // Passo: 2: Definir o inicio da substring atual
            for(int i = 0; i < tamCadeia - 1; i++){                       // Avança 1 para ler nova substring (cadeia.get(i) -> inicio)
                int j = i + tamSubstr - 1;                                // Posição do final desta nova substring (para saber até onde ler)

                // Passo: 3: Splitar substring atual
                for(int k = i; k < j; k++){
                    List<String> BxC = new ArrayList<>();

                    // Passo 4: Procurar resultados anteriores dado uma parte do split (esquerda ou direita)
                    List<String> B  = Arrays.asList(cyk[k - i][i].split(""));                       // Procura resultados anteriores com a primeira parte do split
                    List<String> C  = Arrays.asList(cyk[j - (k + 1)][k + 1].split(""));             // Procura resultados anteriores com a segunda parte do split

                    // Passo 5: Produto Cartesiano B x C
                    BxC = produtoCartesiano(B, C);
                    System.out.print(BxC + " ");

                    // Passo 6: Checar se B x C produziu variaveis que existem nas regras
                    for(String variavel : variaveis)
                        for(String possivelBC : BxC)
                            if(regras.get(variavel).contains(possivelBC)) {

                                // Passo 7: Se existe nas regras -> guardar na matriz simbolos a esquerda das regras (com espaços) obs: diagonal
                                cyk[tamSubstr - 1][i] = cyk[tamSubstr - 1][i] + variavel;
                            }
                    System.out.println(cyk[tamSubstr - 1][i] + " ");
                }
            }
        }

        for(int i = 0; i < tamCadeia; i++) {
            for (int j = 0; j < tamCadeia; j++) {
                System.out.print(cyk[i][j] + " ");                      // Evita valores null na tabela (podendo concatenar)
            }
            System.out.println();
        }

        List<String> S = Arrays.asList(cyk[tamCadeia - 1][0].split(""));
        if(S.contains(inicial)) return 1;
        return 0;
    }

    public static String[][] criarMatrizCYK(int tamCadeia){
        String[][] cyk = new String[tamCadeia][tamCadeia];
        for(int i = 0; i < tamCadeia; i++) {
            for (int j = 0; j < tamCadeia; j++) {
                cyk[i][j] = "";                      // Evita valores null na tabela (podendo concatenar)
            }
        }
        return cyk;
    }

    public static List<String> produtoCartesiano(List<String> B, List<String> C){
        List<String> BxC = new ArrayList<>();

        for(String b : B)
            for(String c : C)
                BxC.add(b + c);

        return BxC;
    }

    public static void escreverResultados(int resultado, int cadeiaAtual){
        boolean fim = false;
        if(cadeiaAtual == 0) fim = true;

        try(FileWriter fw = new FileWriter("outTesteStatus.txt", true); //true: escrever sem sobreescrever
            BufferedWriter bw = new BufferedWriter(fw);
            PrintWriter out = new PrintWriter(bw))
        {
            out.print(resultado + " ");
            if (fim) out.print("\n"); // Ultima cadeia --> quebra linha
        } catch (IOException e) {
            e.printStackTrace();
        }

        //Escrever matriz
    }
}

