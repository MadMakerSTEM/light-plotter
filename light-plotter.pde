import processing.serial.*;

Serial port;
String serial;
Table table;

int temp, light;
int time = 0;
int lf = 10;
boolean canPlot = true;
static int MAX_TIME = 1000;

static int numPoints = 500;        // number of points on the graph
int currentPoint = 0;
float millis;
float totaltime;
float finaltime;
int timer;
int box = 20;
int offset = 50;            // offset of x-axis, in pixels
int mode = 0;               // mode x, y or z (0, 1,2)
float px, py;
int[] accel = {0, 0, 0};   // array to store accelerometer values
float[] data = new float[numPoints];
float[] xAxis = new float[numPoints];

void setup() {
  printArray(Serial.list());
  String comPort = Serial.list()[0];    // should work on linux
  //String comPort = Serial.list()[Serial.list().length-1];    // select the last, windows and mac
  try {
    port = new Serial(this, comPort, 9600);
  }
  catch (Exception e) {
    println(e);
    println("Exiting! Serial port error! Make sure you choose the correct one in the list above.");
    exit();
  }
  size(800, 600);

  table = new Table();
  table.addColumn("Time");
  table.addColumn("Light");
  port.bufferUntil(lf);
  println("Running...");
}

void draw() {
  drawPlot();
}

void drawPlot() {
  if (canPlot == false) {
    background(255);
    drawBorders();
    for (int i = 1; i < numPoints; i++) {
      line(xAxis[i-1], data[i-1], xAxis[i], data[i]);
    }
  }
  if (currentPoint < numPoints && canPlot == true) {
    background(255);
    drawBorders();
    float x = map(currentPoint, 0, numPoints, box, width-box);
    float y = map(light, 500, 1023, height-box, box+100);      
    data[currentPoint] = y;
    xAxis[currentPoint] = x;
    text("value: " + light, width-box-100, box+20);
    for (int i = 1; i < currentPoint; i++) {
      line(xAxis[i-1], data[i-1], xAxis[i], data[i]);
    }
    currentPoint++;
    totaltime += millis;
    timer = currentPoint;
  } else {
    canPlot = false;
    //saveTable(table, "data/temperature.csv");
    //println("Done!");
  }
}

// Draw the borders and axes
void drawBorders() {
  fill(255);                          // fill box with white
  strokeWeight(1);
  rectMode(CORNERS);                  // first two args are top left, second two bottom right
  rect(box, box, width-box, height-box);
  strokeWeight(2);
  fill(0);                            // make text black
  int x1 = box;
  int x2 = width-box;
  for (int i = 0; i <= 50; i++) {
    float x = lerp(x1, x2, i/50.0);
    for (int j = 1; j < 6; j++) {
      float y = map(j, 0, 5, height-box, box+100);
      point(x, y);
    }
  }
  float output;
  if (canPlot == false) {
    timer = numPoints;
    finaltime = totaltime;
    output = (finaltime*(numPoints/(timer+1)));
  } else {
    timer = currentPoint;
    totaltime = millis;
    output = (totaltime*(numPoints/(timer+1)));
  }
  println(millis);
  float x = map(mouseX, box, width-box, 0, output);
  float y = map(mouseY, height-box, box+100, 500, 1023);
  // String ys = nf(e, 5, 3);
  text("time: " +x, width-box-100, box+40);
  text("y: " +y, width-box-100, box+60);
  textSize(16);
  text("Light Meter", box+5, box+20);
  textSize(12);
  text("Press r to restart", box+5, box+40);
  strokeWeight(1);
  textSize(12);
}

// Reset the plot
void reset() {
  time = 0;
  currentPoint = 0;
  millis = 0;
  canPlot = true;
}

void storeData() {
  TableRow newRow = table.addRow();
  newRow.setInt("Time", time);
  newRow.setInt("Light", light);
}

void serialEvent(Serial port) {
  String serial = "";
  serial = port.readString();
  serial = trim(serial);
  int a[] = int(split(serial, ","));
  if (a.length >= 2) {
    light = a[0];
    millis += a[1];
  }
  println(light);
  try {
    storeData();
    time++;
  }
  catch (Exception e) {
    println("Found and error, continuing... ");
    println(e);
  }
}

void keyPressed() {
  if (key == 'r') {
    reset();
  }
}