import java.awt.*;

/**
 Esta classe representa a bola usada no jogo. A classe princial do jogo (Pong)
 instancia um objeto deste tipo quando a execução é iniciada.
 */

public class Ball {

    private double cx;
    private double cy;
    private double width;
    private double height;
    private Color color;
    private double ballSpeedY;
    private double ballSpeedX;
    private double speed;

    /**
     Construtor da classe Ball. Observe que quem invoca o construtor desta classe define a velocidade da bola
     (em pixels por millisegundo), mas não define a direção deste movimento. A direção do movimento é determinada
     aleatóriamente pelo construtor.

     @param cx coordenada x da posição inicial da bola (centro do retangulo que a representa).
     @param cy coordenada y da posição inicial da bola (centro do retangulo que a representa).
     @param width largura do retangulo que representa a bola.
     @param height altura do retangulo que representa a bola.
     @param color cor da bola.
     @param speed velocidade da bola (em pixels por millisegundo).
     */

    public Ball(double cx, double cy, double width, double height, Color color, double speed){

        this.cx = cx;
        this.cy = cy;
        this.width = width;
        this.height = height;
        this.color = color;
        this.speed = speed;
        ballSpeedY = speed;
        ballSpeedX = speed;
    }


    /**
     Método chamado sempre que a bola precisa ser (re)desenhada.
     */

    public void draw(){

        GameLib.setColor(color);
        GameLib.fillRect(cx, cy, width, height);
    }

    /**
     Método chamado quando o estado (posição) da bola precisa ser atualizado.

     @param delta quantidade de millisegundos que se passou entre o ciclo anterior de atualização do jogo e o atual.
     */

    public void update(long delta){

        cx = cx + delta * ballSpeedX;
        cy = cy + delta * ballSpeedY;
    }

    /**
     Método chamado quando detecta-se uma colisão da bola com um jogador.

     @param playerId uma string cujo conteúdo identifica um dos jogadores.
     */

    public void onPlayerCollision(String playerId){

        if(playerId == Pong.PLAYER2) ballSpeedX = -Math.abs(ballSpeedX);
        else ballSpeedX = Math.abs(ballSpeedX);
    }

    /**
     Método chamado quando detecta-se uma colisão da bola com uma parede.

     @param wallId uma string cujo conteúdo identifica uma das paredes da quadra.
     */

    public void onWallCollision(String wallId){

        if(wallId == Pong.TOP){
            ballSpeedY = Math.abs(ballSpeedY);
        } else if(wallId == Pong.BOTTOM){
            ballSpeedY = -Math.abs(ballSpeedY);
        } else if(wallId == Pong.LEFT){
            ballSpeedX = Math.abs(ballSpeedX);
        } else if(wallId == Pong.RIGHT){
            ballSpeedX = -Math.abs(ballSpeedX);
        }
    }

    /**
     Método que verifica se houve colisão da bola com uma parede.

     @param wall referência para uma instância de Wall contra a qual será verificada a ocorrência de colisão da bola.
     @return um valor booleano que indica a ocorrência (true) ou não (false) de colisão.
     */

    public boolean checkCollision(Wall wall){

        if(Math.abs((wall.getCy() - wall.getHeight()/2 - height/2) - cy) < 10) return true;        //bottom
        else if(Math.abs((wall.getCy() + wall.getHeight()/2 + height/2) - cy) < 10) return true;   //top
        else if(Math.abs((wall.getCx() + wall.getWidth()/2 + width/2) - cx) < 10) return true;     //left
        else if(Math.abs((wall.getCx() - wall.getWidth()/2 - width/2) - cx) < 10) return true;     //right
        return false;
    }

    /**
     Método que verifica se houve colisão da bola com um jogador.

     @param player referência para uma instância de Player contra o qual será verificada a ocorrência de colisão da bola.
     @return um valor booleano que indica a ocorrência (true) ou não (false) de colisão.
     */

    public boolean checkCollision(Player player){

        double tamPlayerBAIXO = (player.getCy() + player.getHeight()/2);
        double tamPlayerCIMA = (player.getCy() - player.getHeight()/2);

        //se está entre as coods Y do player e se encostou na coord X
        if(cy >= tamPlayerCIMA && cy <= tamPlayerBAIXO){
            if(Math.abs((player.getCx() - player.getWidth()/2 - width/2) - cx) < 10 ||
                    Math.abs((player.getCx() + player.getWidth()/2 + width/2) - cx) < 10) return true;
        }
        return false;
    }

    /**
     Método que devolve a coordenada x do centro do retângulo que representa a bola.
     @return o valor double da coordenada x.
     */

    public double getCx(){

        return cx;
    }

    /**
     Método que devolve a coordenada y do centro do retângulo que representa a bola.
     @return o valor double da coordenada y.
     */

    public double getCy(){

        return cy;
    }

    /**
     Método que devolve a velocidade da bola.
     @return o valor double da velocidade.

     */

    public double getSpeed(){

        return speed;
    }

}
