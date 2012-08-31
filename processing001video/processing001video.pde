import processing.video.*;

Capture cam;
int width;
int height;
float[][] kernel = { { -1, -1, -1 },
                     { -1,  9, -1 },
                     { -1, -1, -1 } };
int what =0;
PImage lastImage;
                     



PImage edgeDetection(PImage img) {
  PImage edgeImg = createImage(img.width, img.height, RGB);
  // Loop through every pixel in the image.
  for (int y = 1; y < img.height-1; y++) { // Skip top and bottom edges
    for (int x = 1; x < img.width-1; x++) { // Skip left and right edges
      float sum = 0; // Kernel sum for this pixel
      for (int ky = -1; ky <= 1; ky++) {
        for (int kx = -1; kx <= 1; kx++) {
          // Calculate the adjacent pixel for this kernel point
          int pos = (y + ky)*img.width + (x + kx);
          // Image is grayscale, red/green/blue are identical
          float val = red(img.pixels[pos]);
          // Multiply adjacent pixels based on the kernel values
          sum += kernel[ky+1][kx+1] * val;
        }
      }
      // For this pixel in the new image, set the gray value
      // based on the sum from the kernel
      edgeImg.pixels[y*img.width + x] = color(sum);
    }
  }
  return edgeImg;
}

PImage switchColors(PImage img) {

  int index = 0;
  PImage switchImg = createImage(img.width, img.height, RGB);

  int maxPixel = 0;
  int lastPixel = 0;
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int pixelColor = img.pixels[index];
      int r = (pixelColor >> 16) & 0xff;
      int g = (pixelColor >> 8) & 0xff;
      int b = pixelColor & 0xff;
      int swap=0;
      int colore=0;
      if (r> g && r>b) {
        swap = r;
        r = b;
        b= swap;
      }
      colore= 0xFF000000 | (r << 16) | (g << 8) | b;
      if (maxPixel < img.pixels[index]) {
        maxPixel = img.pixels[index];
      }
      if (index % 50 != 0 ) {
        //int r = (int) random(255);
        //cam.pixels[index]=lastPixel;
      } else {
        lastPixel = img.pixels[index];
      }
      switchImg.pixels[index] = colore;
      index++;
    }
    
  }
  return switchImg;
}

PImage detectMotion(PImage img) {
  int index = 0;
  int soglia=50;
  PImage newImg = createImage(img.width, img.height, RGB);
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int pixelColor = img.pixels[index];
      int lastPixelColor=0xFF000000;
      lastPixelColor = lastImage.pixels[index];

      
      int newPixelColor = 0;

      int r = (pixelColor >> 16) & 0xff;
      int g = (pixelColor >> 8) & 0xff;
      int b = pixelColor & 0xff;
      int rl = (lastPixelColor >> 16) & 0xff;
      int gl = (lastPixelColor >> 8) & 0xff;
      int bl = lastPixelColor & 0xff;
      int diffR = abs(r-rl);
      int diffG = abs(g-gl);
      int diffB = abs(b-bl);
      if ( (diffR<soglia) || (diffG<soglia) || (diffB<soglia) ) {
        //newPixelColor = 0xFF000000;
        newPixelColor = 0xFF000000 | (diffR << 16) | (diffG << 8) | diffB;
        //newPixelColor = 0xFF000000 | (rl << 16) | (gl << 8) | bl;
      } else {
        newPixelColor = pixelColor;
      }
      newImg.pixels[index] = newPixelColor;
      index++;
    }
    
  }
  arraycopy(img.pixels, lastImage.pixels);
  //lastImage = img;
  return newImg;
}



void setup() {
  width=640;
  height = 480;
  size(width, height);
  lastImage = createImage(width, height, RGB);
  //lastImage
  //cam = new Capture(this, 320, 240);
  
  //String[] devices = Capture.list();
  //println(devices);
  


  // Opens the settings page for this capture device.
 cam = new Capture(this, width, height);
  //cam.settings();
}

void keyPressed()
{
  // if the key is between 'A'(65) and 'z'(122)
  if( key == '1') {
    what=1;
  } else if (key == '2') {
    what=2;
  } else {
    what=0;
  }
}
void draw() {
  long maxPixel=0;
  int lastPixel = 0;
  if (cam.available() == true) {
    cam.read();
    cam.loadPixels();
    PImage newImage;
    if (what == 1) {
      newImage = edgeDetection(cam);
    } else if (what == 2) {
      newImage = detectMotion(cam);
      //System.out.println("AAA:"+random(100));
    } else {
      newImage = switchColors(cam);
    }
    //PImage newImage = edgeDetection(cam);
    //PImage newImage = switchColors(cam);

    /*

    */
    
    
    image(newImage, 0, 0);
    // The following does the same, and is faster when just drawing the image
    // without any additional resizing, transformations, or tint.
    //set(0, 0, cam);
  }
  //System.out.println("Max pixel:"+ lastPixel);
} 
