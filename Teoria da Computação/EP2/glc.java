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
            Scanner ler = new Scanner(new FileReader(new File("inp-glc.txt")));

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
            Scanner ler = new Scanner(new FileReader(new File("inp-cadeias.txt")));

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
        String[][] cyk = new String[tamCadeia][tamCadeia];

        StringBuilder addVariaveis = new StringBuilder();

        // Trata substrings de tamanho 1
        for(int j = 0; j < tamCadeia; j++){
            for (String variavel : variaveis){
                if(regras.get(variavel).contains(cadeia.get(j))){
                    addVariaveis.append(variavel);
                    addVariaveis.append(" ");
                }
            }
            cyk[0][j] = addVariaveis.toString();
            addVariaveis.delete( 0, addVariaveis.length());
        }

        // Passo 1: Definir o tamanho de substring atual
        for(int tamSubstr = 2; tamSubstr < tamCadeia + 1; tamSubstr++){       // Tamanho das substrings

            // Passo: 2: Definir o inicio da substring atual
            for(int i = 0; i < tamCadeia - tamSubstr + 1; i++){                       // Avança 1 para ler nova substring (cadeia.get(i) -> inicio)
                int j = i + tamSubstr - 1;                                // Posição do final desta nova substring (para saber até onde ler)

                // Passo: 3: Splitar substring atual
                for(int k = i; k < j; k++){

                    try {
                        // Passo 4: Procurar resultados anteriores dado uma parte do split (esquerda ou direita)
                        List<String> B = Arrays.asList(cyk[k - i][i].split(" "));                                  // Procura resultados anteriores com a primeira parte do split
                        List<String> C = Arrays.asList(cyk[j - (k + 1)][k + 1].split(" "));                        // Procura resultados anteriores com a segunda parte do split

                        // Passo 5: Produto Cartesiano B x C
                        List<String> BxC = produtoCartesiano(B, C);

                        // Passo 6: Checar se B x C produziu variaveis que existem nas regras
                        for (String variavel : variaveis)
                            for (String possivelBC : BxC)
                                if (regras.get(variavel).contains(possivelBC)) {

                                    // Passo 7: Se existe nas regras -> guardar na matriz simbolos a esquerda das regras
                                    addVariaveis.append(" ");
                                    addVariaveis.append(variavel);
                                }
                    } catch (NullPointerException e){
                        //null pointer: Não há nenhuma variável neste local da matriz
                    }

                    String temp = addVariaveis.toString();

                    if(cyk[tamSubstr - 1][i] == null) cyk[tamSubstr - 1][i] = temp;
                    else {
                        cyk[tamSubstr - 1][i] = cyk[tamSubstr - 1][i] + temp;

                        Set<String> tiraDuplicatas = new HashSet<>(Arrays.asList(cyk[tamSubstr - 1][i].split(" ")));

                        cyk[tamSubstr - 1][i] = "";
                        for(String elemento : tiraDuplicatas)
                            cyk[tamSubstr - 1][i] = cyk[tamSubstr - 1][i] + " " + elemento;
                    }

                    addVariaveis.delete( 0, addVariaveis.length());
                }
            }
        }

        System.out.println();
        System.out.println("Matriz: ");
        for(int i = 0; i < tamCadeia; i++) {
            for (int j = 0; j < tamCadeia; j++) {
                if(cyk[i][j] != null && cyk[i][j].equals(" ")) System.out.print("0 | ");
                else if(cyk[i][j] != null && cyk[i][j].length() > 0) System.out.print(cyk[i][j] + " | ");                      // Evita valores null na tabela (podendo concatenar)
                else if (cyk[i][j] == null) System.out.print("x | ");
                else System.out.print("0 | "); // Faz parte do triangulo, porém é nulo (sem variáveis)
            }
            System.out.println();
        }

        List<String> S = Arrays.asList(cyk[tamCadeia - 1][0].split(" "));
        if(S.contains(inicial)) return 1;
        return 0;
    }

    public static List<String> produtoCartesiano(List<String> B, List<String> C){
        List<String> BxC = new ArrayList<>();

        for(String b : B)
            for(String c : C) {
                //System.out.println("b: " + b + " ; c: " + c);
                BxC.add(b + c);
            }

        return BxC;
    }

    public static void escreverResultados(int resultado, int cadeiaAtual){
        boolean fim = false;
        if(cadeiaAtual == 0) fim = true;

        try(FileWriter fw = new FileWriter("out-status.txt", true); //true: escrever sem sobreescrever
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

