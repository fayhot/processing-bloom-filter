import controlP5.*;

ControlP5 cp5;

PGraphics canvas;

PGraphics brightPass;
PGraphics horizontalBlurPass;
PGraphics verticalBlurPass;

PShader bloomFilter;
PShader blurFilter;

int angle = 0;

final int surfaceWidth = 250;
final int surfaceHeight = 250;

float luminanceFilter = 0.8;
float blurSize = 20;
float sigma = 12;

void setup()
{
  size(1000, 250, P3D);

  addUI();

  canvas = createGraphics(surfaceWidth, surfaceHeight, P3D);
  
  brightPass = createGraphics(surfaceWidth, surfaceHeight, P2D);
  brightPass.noSmooth();

  horizontalBlurPass = createGraphics(surfaceWidth, surfaceHeight, P2D);
  horizontalBlurPass.noSmooth(); 

  verticalBlurPass = createGraphics(surfaceWidth, surfaceHeight, P2D);
  verticalBlurPass.noSmooth(); 

  bloomFilter = loadShader("bloomFrag.glsl");
  blurFilter = loadShader("blurFrag.glsl");
}

void draw()
{
  background(0);

  bloomFilter.set("brightPassThreshold", luminanceFilter);

  blurFilter.set("blurSize", (int)blurSize);
  blurFilter.set("sigma", sigma); 

  canvas.beginDraw();
  render(canvas);
  canvas.endDraw();

  // bright pass
  brightPass.beginDraw();
  brightPass.shader(bloomFilter);
  brightPass.image(canvas, 0, 0);
  brightPass.endDraw();

  // blur horizontal pass
  horizontalBlurPass.beginDraw();
  blurFilter.set("horizontalPass", 1);
  horizontalBlurPass.shader(blurFilter);
  horizontalBlurPass.image(brightPass, 0, 0);
  horizontalBlurPass.endDraw();

  // blur vertical pass
  verticalBlurPass.beginDraw();
  blurFilter.set("horizontalPass", 0);
  verticalBlurPass.shader(blurFilter);
  verticalBlurPass.image(horizontalBlurPass, 0, 0);
  verticalBlurPass.endDraw();

  // draw original
  image(canvas.copy(), 0, 0);
  text("Original", 20, height - 20); 

  // draw bright pass
  image(brightPass, surfaceWidth, 0);
  text("Bright Pass", surfaceWidth + 20, height - 20); 

  image(verticalBlurPass, (surfaceWidth * 2), 0);
  text("Blur", (surfaceWidth * 2) + 20, height - 20); 

  // draw 
  image(canvas, (surfaceWidth * 3), 0);
  blendMode(SCREEN);
  image(verticalBlurPass, (surfaceWidth * 3), 0);
  blendMode(BLEND);
  text("Combined", (surfaceWidth * 3) + 20, height - 20); 

  // fps
  fill(0, 255, 0);
  text("FPS: " + frameRate, 20, 20);
}

void render(PGraphics pg)
{
  pg.background(0, 0);
  pg.stroke(255, 0, 0);

  for (int i = -1; i < 2; i++)
  {
    if (i == -1)
      pg.fill(0, 255, 0);
    else if (i == 0)
      pg.fill(255);
    else
      pg.fill(0, 200, 200);

    pg.pushMatrix();
    // left-right, up-down, near-far
    pg.translate(surfaceWidth / 2 + (i * 50), surfaceHeight / 2, 0);
    pg.rotateX(radians(angle));
    pg.rotateZ(radians(angle));
    pg.box(30);
    pg.popMatrix();
  }

  angle = ++angle % 360;
}

void addUI()
{
  cp5 = new ControlP5(this);

  cp5.addSlider("luminanceFilter")
    .setPosition(200, 5)
    .setRange(0, 1)
    ;

  cp5.addSlider("blurSize")
    .setPosition(400, 5)
    .setRange(0, 100)
    ;

  cp5.addSlider("sigma")
    .setPosition(600, 5)
    .setRange(1, 100)
    ;
}