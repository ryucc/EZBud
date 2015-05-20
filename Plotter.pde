import processing.core.PApplet;
import grafica.*;

class Plotter {
  private final int[]   SCREEN_DIM   = new int[]   {750, 250};
  private final float   FRAME_RATE   = 120;
  private final int     BACKGROUND   = 255;
  
  private final float[] PANEL1_POS   = new float[] { 50,  50};
  private final float[] PANEL1_DIM   = new float[] {650, 150};
  private final float[] PANEL2_POS   = new float[] {750,  50};
  private final float[] PANEL2_DIM   = new float[] {200, 150};

  private final int     PLOT_TIME    = 5;
  private final int     PLOT_NUM     = 3;
  private final int     PLOT_Y_LIM   = 384;
  
  private final float   FPS_INTERVAL = 1;
  private final float   LEGEND_X0    = 0.05;
  private final float   LEGEND_X     = 0.075;
  private final float   LEGEND_Y0    = 0.1;

  //
  private PApplet parent;
  private Data    data;
  
  private float startTime;
  private float lastTime;
  
  private float lastFPSTime;
  private int   frame;
  private float fps;
  
  private GPlot plot;
  
  //
  public Plotter(PApplet parent, Data data) {
    this.parent = parent;
    this.data = data;
    
    parent.frameRate(FRAME_RATE);
    parent.size(SCREEN_DIM[0], SCREEN_DIM[1]);
    parent.background(BACKGROUND);
    
    // Plot 1
    plot = new GPlot(parent);
    plot.setDim(PANEL1_DIM);
    plot.setPos(PANEL1_POS[0], PANEL1_POS[1]);    
    plot.setMar(0, 0, 0, 0);    
    plot.setAxesOffset(0);
    plot.setTicksLength(-5);
    plot.setLineColor((0xff << 24) + 0xff);
    plot.setXLim(0, PLOT_TIME);
    plot.setYLim(-PLOT_Y_LIM, +PLOT_Y_LIM);
    plot.getXAxis().setDrawTickLabels(false);
    plot.setTitleText("Accelerometer Readings");
    
    for(int i = 0; i < PLOT_NUM; i++) {
      plot.addLayer(GetName(i), new GPointsArray());
      plot.getLayer(GetName(i)).setLineColor((0xff << 24) + (0xff << (8 * i)));
    }
    
    // Plot 2
    
    // Initialize
    startTime = (float) millis() / 1000;
    lastTime = 0;
    
    lastFPSTime = 0;
    frame = 0;
    fps = FRAME_RATE;
  }
  
  public void draw() {
    // Update
    float curTime = (float) millis() / 1000 - startTime;
    float pastTime = curTime - PLOT_TIME;
    
    // Point
    GLayer gLayer;
    for(int i = 0; i < PLOT_NUM; i++) {
      gLayer = plot.getLayer(GetName(i));
      gLayer.addPoint(curTime, data.acc[i]);
      if(curTime > PLOT_TIME) {
        while(gLayer.getPointsRef().get(0).getX() < pastTime)
          gLayer.removePoint(0);
      }
    }
    
    // Axes
    plot.setXLim(pastTime, curTime);
    
    // Legend
    String[] legendName = new String[PLOT_NUM + 1];
    float[]  legendXPos = new float[PLOT_NUM + 1];
    float[]  legendYPos = new float[PLOT_NUM + 1];
    legendName[0] = "";
    legendXPos[0] = LEGEND_X0;
    legendYPos[0] = LEGEND_Y0;
    for(int i = 0; i < PLOT_NUM; i++) {
      legendName[i + 1] = GetName(i);
      legendXPos[i + 1] = LEGEND_X0 + i * LEGEND_X;
      legendYPos[i + 1] = LEGEND_Y0;
    }
    
    // FPS
    if(curTime > lastFPSTime + FPS_INTERVAL) {
      fps = frame / (curTime - lastFPSTime);
      lastFPSTime = curTime;
      frame = 0;
    }
    else 
      ++frame;
      
    // Finalize
    lastTime = curTime;
    
    // Draw
    parent.background(BACKGROUND);
    parent.fill(0xff << 24);
    parent.text(String.format("%.2f", fps) + " fps", 10, 15);
    
    plot.beginDraw();
    plot.drawBackground();
    plot.drawBox();
    plot.drawXAxis();
    plot.drawYAxis();
    plot.drawTitle();
    plot.drawLines();
    plot.drawLegend(legendName, legendXPos, legendYPos);
    plot.endDraw();
  }
  
  private String GetName(int num) {
    return Character.toString((char)('x' + num));
  }
}

