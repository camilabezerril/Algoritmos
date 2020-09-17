import java.awt.*;
import java.util.*;
import java.util.Queue;

public class FxBall extends Ball implements IBall {

    private Deque<Double> cxRastro = new LinkedList<>();
    private Deque<Double> cyRastro = new LinkedList<>();

    public FxBall(double cx, double cy, double width, double height, Color color, double speed, double vx, double vy) {

        super(cx, cy, width, height, color, speed, vx, vy);
    }

    public void draw() {

        drawRastro();

        //BOLA
        GameLib.setColor(getColor());
        GameLib.fillRect(getCx(), getCy(), getWidth(), getHeight());
    }

    public void drawRastro() {

        cxRastro.addFirst(getCx());
        cyRastro.addFirst(getCy());

        Iterator it = cxRastro.iterator();
        Iterator it2 = cyRastro.iterator();

        Color escurecer = getColor();

        int i = 0;
        while (it.hasNext() && i != 100) {
            while (it2.hasNext() && i != 100) {
                double cxAtual = (double) it.next();
                double cyAtual = (double) it2.next();

                escurecer = new Color((int)(escurecer.getRed() * 0.98), (int)(escurecer.getGreen() * 0.98), (int)(escurecer.getBlue() * 0.98));
                GameLib.setColor(escurecer);

                GameLib.fillRect(cxAtual, cyAtual, getWidth() - i / 5, getHeight() - i / 5);
                i++;
            }
        }

        //size define o tamanho do deque e portanto, o tamanho do rastro.
        if (cxRastro.size() == 100) {
            GameLib.fillRect(cxRastro.removeLast(), cyRastro.removeLast(), getWidth()- 20, getHeight() - 20);
        }
    }
}
