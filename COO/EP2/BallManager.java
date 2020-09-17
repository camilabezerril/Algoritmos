import java.awt.Color;
import java.lang.reflect.*;

import java.util.*;
import java.util.concurrent.*;

/**
 Classe que gerencia uma ou mais bolas presentes em uma partida. Esta classe é a responsável por instanciar
 e gerenciar a bola principal do jogo (aquela que existe desde o ínicio de uma partida), assim como eventuais
 bolas extras que apareçam no decorrer da partida. Esta classe também deve gerenciar a interação da(s) bola(s)
 com os alvos, bem como a aplicação dos efeitos produzidos para cada tipo de alvo atingido.
 */

public class BallManager {

    /**
     Atributos criados para o EP
     */

    private double vOriginal = 0;

    private boolean colisaoRed = false;
    private boolean colisaoYellow = false;
    private long inicioYSpeed = 0;
    private IBall ballHit = null;

    private List<IBall> bolas = new ArrayList<>();
    //Foi usado um ConcurrentHashMap para evitar ConcurrentModificationException
    private Map<IBall, Long> tempoSpeed = new ConcurrentHashMap<>();
    private Map<IBall, Long> tempoDuplicator = new ConcurrentHashMap<>();
    private Map<IBall, Long> tempoDarker = new HashMap<>();

    /**
     Atributo privado que representa a bola principal do jogo.
     */

    private IBall theBall = null;

    /**
     Atributo privado que representa o tipo (classe) das instâncias de bola que serão criadas por esta classe.
     */

    private Class<?> ballClass = null;

    /**
     Construtor da classe BallManager.

     @param className nome da classe que define o tipo das instâncias de bola que serão criadas por esta classe.
     */

    public BallManager(String className){

        try{
            ballClass = Class.forName(className);
        }
        catch(Exception e){

            System.out.println("Classe '" + className + "' não reconhecida... Usando 'Ball' como classe padrão.");
            ballClass = Ball.class;
        }
    }

    /**
     Recebe as componetes x e y de um vetor, e devolve as componentes x e y do vetor normalizado (isto é, com comprimento igual a 1.0).

     @param x componente x de um vetor que representa uma direção.
     @param y componente y de um vetor que represetna uma direção.

     @return array contendo dois valores double que representam as componentes x (índice 0) e y (índice 1) do vetor normalizado (unitário).
     */
    private double [] normalize(double x, double y){

        double length = Math.sqrt(x * x + y * y);

        return new double [] { x / length, y / length };
    }

    /**
     Cria uma instancia de bola, a partir do tipo (classe) cujo nome foi passado ao construtor desta classe.
     O vetor direção definido por (vx, vy) não precisa estar normalizado. A implemntação do método se encarrega
     de fazer a normalização.

     @param cx coordenada x da posição inicial da bola (centro do retangulo que a representa).
     @param cy coordenada y da posição inicial da bola (centro do retangulo que a representa).
     @param width largura do retangulo que representa a bola.
     @param height altura do retangulo que representa a bola.
     @param color cor da bola.
     @param speed velocidade da bola (em pixels por millisegundo).
     @param vx componente x do vetor (não precisa ser unitário) que representa a direção da bola.
     @param vy componente y do vetor (não precisa ser unitário) que representa a direção da bola.
     */

    private IBall createBallInstance(double cx, double cy, double width, double height, Color color, double speed, double vx, double vy){

        IBall ball = null;
        double [] v = normalize(vx, vy);

        try{
            Constructor<?> constructor = ballClass.getConstructors()[0];
            ball = (IBall) constructor.newInstance(cx, cy, width, height, color, speed, v[0], v[1]);
        }
        catch(Exception e){

            System.out.println("Falha na instanciação da bola do tipo '" + ballClass.getName() + "' ... Instanciando bola do tipo 'Ball'");
            ball = new Ball(cx, cy, width, height, color, speed, v[0], v[1]);
        }

        return ball;
    }

    /**
     Cria a bola principal do jogo. Este método é chamado pela classe Pong, que contem uma instância de BallManager.

     @param cx coordenada x da posição inicial da bola (centro do retangulo que a representa).
     @param cy coordenada y da posição inicial da bola (centro do retangulo que a representa).
     @param width largura do retangulo que representa a bola.
     @param height altura do retangulo que representa a bola.
     @param color cor da bola.
     @param speed velocidade da bola (em pixels por millisegundo).
     @param vx componente x do vetor (não precisa ser unitário) que representa a direção da bola.
     @param vy componente y do vetor (não precisa ser unitário) que representa a direção da bola.
     */

    public void initMainBall(double cx, double cy, double width, double height, Color color, double speed, double vx, double vy){

        theBall = createBallInstance(cx, cy, width, height, color, speed, vx, vy);
        vOriginal = speed;
    }

    /**
     Método que desenha todas as bolas gerenciadas pela instância de BallManager.
     Chamado sempre que a(s) bola(s) precisa ser (re)desenhada(s).
     */

    public void draw(){

        theBall.draw();

        if(!bolas.isEmpty()){
            for(IBall ball : bolas)
                ball.draw();
        }
    }

    /**
     Método que atualiza todas as bolas gerenciadas pela instância de BallManager, em decorrência da passagem do tempo.

     @param delta quantidade de millisegundos que se passou entre o ciclo anterior de atualização do jogo e o atual.
     */

    public void update(long delta){

        theBall.update(delta);

        if(!bolas.isEmpty()){
            for(IBall ball : bolas)
                ball.update(delta);
        }
    }

    /**
     Método que processa as colisões entre as bolas gerenciadas pela instância de BallManager com uma parede.

     @param wall referência para uma instância de Wall para a qual será verificada a ocorrência de colisões.
     @return um valor int que indica quantas bolas colidiram com a parede (uma vez que é possível que mais de
     uma bola tenha entrado em contato com a parede ao mesmo tempo).
     */

    public int checkCollision(Wall wall){

        int hits = 0;

        if(theBall.checkCollision(wall)) hits++;

        if(!bolas.isEmpty()){
            for(IBall ball : bolas)
                if(ball.checkCollision(wall)) hits++;
        }

        return hits;
    }

    /**
     Método que processa as colisões entre as bolas gerenciadas pela instância de BallManager com um player.

     @param player referência para uma instância de Player para a qual será verificada a ocorrência de colisões.
     */

    public void checkCollision(Player player){

        theBall.checkCollision(player);

        if(!bolas.isEmpty()){
            for(IBall ball : bolas)
                ball.checkCollision(player);
        }
    }

    /**
     Método que processa as colisões entre as bolas gerenciadas pela instância de BallManager com um alvo.

     @param target referência para uma instância de Target para a qual será verificada a ocorrência de colisões.
     */

    public void checkCollision(Target target){

        /**
         * CHECA COLISÕES E ATIVA EFEITOS
         **/

        colisaoYellow = theBall.checkCollision(target);

        if(!bolas.isEmpty()){
            for(IBall ball : bolas){
                colisaoRed = ball.checkCollision(target);
                if(colisaoRed){
                    ballHit = ball;
                    break;
                }
            }
        }

        if (colisaoRed || colisaoYellow) onTargetCollision(target);

        /**
         * CHECA SE OS EFEITOS DEVEM ACABAR DEVIDO À DURAÇÃO
         **/

        if(theBall.getSpeed() != vOriginal){
            long fimSpeed = System.currentTimeMillis();
            if(fimSpeed - inicioYSpeed >= BoostTarget.BOOST_DURATION){
                theBall.setSpeed(vOriginal);
            }
        }

        if(!bolas.isEmpty() && !tempoSpeed.isEmpty()){
            long fimSpeed = System.currentTimeMillis();
            for (Map.Entry<IBall, Long> e : tempoSpeed.entrySet()) {
                if(fimSpeed - e.getValue() >= BoostTarget.BOOST_DURATION){
                    e.getKey().setSpeed(vOriginal);
                    tempoSpeed.remove(e.getKey());
                }
            }
        }

        long tDarkerBall = 0;
        long tempoBola;
      
        if(!bolas.isEmpty() && !tempoDuplicator.isEmpty()){
            long fimDuplicar = System.currentTimeMillis();
            for (Map.Entry<IBall, Long> e : tempoDuplicator.entrySet()) {
                tempoBola = fimDuplicar - e.getValue();

                if(tempoBola >= DuplicatorTarget.EXTRA_BALL_DURATION){
                    bolas.remove(e.getKey());
                    if(tempoSpeed.containsKey(e.getKey())) tempoSpeed.remove(e.getKey());
                    if(tempoDarker.containsKey(e.getKey())) tempoDarker.remove(e.getKey());
                    tempoDuplicator.remove(e.getKey());
                }

                //Bola começa a desaparecer com 80% da duração atingida
                //intervalo devido ao long não ser um número exato
                if(tempoBola >= DuplicatorTarget.EXTRA_BALL_DURATION * 0.8 && tempoBola <= DuplicatorTarget.EXTRA_BALL_DURATION * 0.8 + 10){
                    tempoDarker.put(e.getKey(), tempoBola);
                }

                //controla desaparecimento da bola
                if(tempoDarker.containsKey(e.getKey())) tDarkerBall = tempoDarker.get(e.getKey());
                if(tDarkerBall != 0 && tempoBola >= tDarkerBall) {
                    Color cor = e.getKey().getColor();
                    Color escurecer = new Color((int)(cor.getRed() * 0.99),(int)(cor.getGreen() * 0.99),(int)(cor.getBlue() * 0.99));
                    e.getKey().setColor(escurecer);

                    //tempoDarker controla para que a bola não escureça de uma vez só, e sim de tempos em tempos.
                    //duração específica da cor vermelha para que suma no tempo certo (qualquer tempo colocado em extra ball duration).
                    tempoDarker.replace(e.getKey(), tDarkerBall + (long) (DuplicatorTarget.EXTRA_BALL_DURATION * 0.002));
                }
            }
        }
    }


    public void onTargetCollision(Target target){

        if(target instanceof BoostTarget){
            long inicio = System.currentTimeMillis();

            if(colisaoYellow && theBall.getSpeed() == vOriginal){
                double vYellow = theBall.getSpeed() * BoostTarget.BOOST_FACTOR;
                theBall.setSpeed(vYellow);
                inicioYSpeed = inicio;

            } else if (colisaoRed && ballHit.getSpeed() == vOriginal){
                double vRed = ballHit.getSpeed() * BoostTarget.BOOST_FACTOR;
                ballHit.setSpeed(vRed);
                //A inserção ocorre num hashmap pois a lista bola pode ser constantemente mudada
                tempoSpeed.put(ballHit, inicio);
            }
        }

        if(target instanceof DuplicatorTarget){
            long inicio = System.currentTimeMillis();

            double vx = 0.85 + Math.random() * 0.15;
            double vy = Math.sqrt(1.0 - vx * vx);
            if(Math.random() < 0.5) vx = -vx;

            if(colisaoYellow){
                IBall yellowHit = createBallInstance(theBall.getCx(), theBall.getCy(), 20, 20, Color.RED, vOriginal, vx, vy);
                bolas.add(yellowHit);
                tempoDuplicator.put(yellowHit, inicio);

            } else if (colisaoRed){
                IBall redHit = createBallInstance(ballHit.getCx(), ballHit.getCy(), 20, 20, Color.RED, vOriginal, vx, vy);
                bolas.add(redHit);
                tempoDuplicator.put(redHit, inicio);
            }
        }
    }
}
