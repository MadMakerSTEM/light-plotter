import processing.serial.*;

Serial port;
String serial;
Table table;

int temp, light;
int time = 0;
static int MAX_TIME = 1000;

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
  size(400,400);

  table = new Table();
  table.addColumn("Time");
  table.addColumn("Temperature");
  table.addColumn("Light");
  port.bufferUntil('\n');
  println("Running...");
}

void draw() {
  drawData();
  if(time > MAX_TIME) {
    saveTable(table, "data/temperature.csv");
    println("Done!");
    exit();
  }
}

void drawData() {
  background(0);
  textAlign(CENTER, CENTER);
  textSize(20);
  text("Temperature: " + temp, width/2, height/2-50);
  text("Light Sensor: " + light, width/2, height/2-25);
  text(MAX_TIME-time + " to go.", width/2, height/2);
  //write max and min light here
}

void storeData() {
  TableRow newRow = table.addRow();
  newRow.setInt("Time", time);
  newRow.setInt("Temperature", temp);
  newRow.setInt("Light", light);
}

void serialEvent(Serial port) {
  try {
    String serial = port.readString();
    serial = trim(serial);
    int[] a = int(split(serial, ','));
    if(a.length >= 2) {
      temp = a[0];
      light = a[1];
    }
    storeData();
    time++;
  }
  catch (Exception e) {
    println("Failed with error...");
    println(e);
    exit();
  }
}