import ch.bildspur.vision.*;
import ch.bildspur.vision.result.*;

import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PImage;
import processing.video.Capture;
import processing.sound.*;

SoundFile file;
Capture cam;

DeepVision deepVision = new DeepVision(this);
YOLONetwork yolo;
ResultList<ObjectDetectionResult> detections;

int textSize = 12;

public void setup() {
  size(640, 480);

  colorMode(HSB, 360, 100, 100);

  println("creating model...");
  yolo = deepVision.createYOLOv4Tiny();

  println("loading yolo model...");
  yolo.setup();

  cam = new Capture(this, "pipeline:autovideosrc");
  cam.start();
}

public void draw() {
  background(55);

  if (cam.available()) {
    cam.read();
  }

  image(cam, 0, 0);

  if (cam.width == 0) {
    return;
  }

  yolo.setConfidenceThreshold(0.2f);
  detections = yolo.run(cam);

  
  File f = new File(this.dataPath(""));
  String[] list = f.list();
  strokeWeight(3f);
  textSize(textSize);
  int delay = 5000;

  for (ObjectDetectionResult detection : detections) {
    int hue = (int)(360.0 / yolo.getLabels().size() * detection.getClassId());
    String detectiontext = detection.getClassName();

    noFill();
    stroke(hue, 80, 100);
    rect(detection.getX(), detection.getY(), detection.getWidth(), detection.getHeight());

    fill(hue, 80, 100);
    rect(detection.getX(), detection.getY() - (textSize + 3), textWidth(detection.getClassName()) + 4, textSize + 3);

    fill(0);
    textAlign(LEFT, TOP);
    text(detection.getClassName(), detection.getX() + 2, detection.getY() - textSize - 3);
    if(detectiontext.equals("person") == true){
      
      file = new SoundFile(this, list[(int)(random(list.length))]);
      file.play();
      delay = ceil(file.duration())*1000;
      delay(delay);
    }
    println(delay);

  }

  surface.setTitle("Webcam YOLO Test - FPS: " + Math.round(frameRate));
}
