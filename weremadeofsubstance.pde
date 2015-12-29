import processing.sound.*; //<>// //<>//

import java.util.List; //<>// //<>//
import java.util.LinkedList;
import java.io.IOException;

int W = 1024, H = 256;

int bpm = 25;
ArrayList<ArrayList<Triangle>> all_triangles;
ArrayList<int[]> all_colors;
int indx_triangle_to_draw =0;
int indx_image_to_draw = 0;
float scale = 1;
String folder_images = "1024x256/";
String path_data = "/Users/riccardospezialetti/Desktop/PROCESSING/workspace_processing/weremadeofsubstance/data/";
String []list_images;
boolean single_image = false;
boolean reload = true;
float ratio = 1.689;
AudioFeed audio_feed;

void triangulate_all_images(ArrayList<ArrayList<Triangle>> all_triangles, ArrayList<int[]> all_colors)
{
  
  
  for (int indx_photo=0; indx_photo <list_images.length; indx_photo++)
  {
    int edge_factor = (int)random(4, 30);
    println("FACTOR is for "+indx_photo +" is " + edge_factor);
    //here for all dataset
    if (list_images[indx_photo].contains(".jpg"))
    {
      PImage buffer = loadImage(folder_images+list_images[indx_photo]);
      //Extract significant points of the picture
      ArrayList<PVector> vertices = new ArrayList<PVector>();
      EdgeDetector.extractPoints(vertices, buffer, EdgeDetector.SOBEL, 300, edge_factor);

      //Add some points in the border of the canvas to complete all space
      for (float i = 0, h = 0, v = 0; i<=1; i+=.05, h = W*i, v = H*i) {
        vertices.add(new PVector(h, 0));
        vertices.add(new PVector(h, H));
        vertices.add(new PVector(0, v));
        vertices.add(new PVector(W, v));
      }

      //Get the triangles using qhull algorithm. 
      //The algorithm is a custom refactoring of Triangulate library by Florian Jennet  
      ArrayList<Triangle> triangles = new ArrayList<Triangle>();
      new Triangulator().triangulate(vertices, triangles);

      //Prune triangles with vertices outside of the canvas.
      Triangle t = new Triangle();
      for (int i=0; i < triangles.size(); i++) {
        t = triangles.get(i); 
        if (vertexOutside(t.p1) || vertexOutside(t.p2) || vertexOutside(t.p3)) triangles.remove(i);
      }

      //Get colors from the triangle centers
      int tSize = triangles.size();
      int [] temp_colors = new int[tSize*3];
      PVector c = new PVector();
      for (int i = 0; i < tSize; i++) {
        c = triangles.get(i).center();
        temp_colors[i] = buffer.get(int(c.x), int(c.y));
      }

      all_triangles.add(triangles);
      all_colors.add(temp_colors);
    }
    //println( all_triangles.size());
  }
  reload = false;
}
void setup() 
{
  size(1024, 512);
  background(0);
  smooth();

  File folder = new File(path_data+folder_images); 
  list_images = folder.list();
  all_triangles = new ArrayList<ArrayList<Triangle>> ();
  all_colors = new ArrayList<int[]> ();
  triangulate_all_images(all_triangles, all_colors);
}

void draw() {  // draw() loops forever, until stopped
  //
  if (indx_image_to_draw == list_images.length)
  {
    indx_image_to_draw = 0;
    reload = true;
  }  
  if (reload)
  {

    all_triangles = new ArrayList<ArrayList<Triangle>> ();
    all_colors = new ArrayList<int[]> ();
    triangulate_all_images(all_triangles, all_colors);
    indx_triangle_to_draw = 0;
  }


  frameRate(bpm);
  //println(indx_image_to_draw);


  ArrayList<Triangle> current_image;
  //drawImage(current_image,all_colors.get(temp));
  if (single_image)
  {
    int temp=4;
    current_image =  all_triangles.get(temp);
    drawImageRandomAlpha(current_image, all_colors.get(temp));
  } else
  {
    current_image = all_triangles.get(indx_image_to_draw);
    Triangle t = new Triangle();
    beginShape(TRIANGLES);
    t = current_image.get(indx_triangle_to_draw); 
    int [] current_colors = all_colors.get(indx_image_to_draw);
    fill(current_colors[indx_triangle_to_draw]);
    stroke(current_colors[indx_triangle_to_draw]);
    vertex(t.p1.x*scale, t.p1.y*scale);
    vertex(t.p2.x*scale, t.p2.y*scale);
    vertex(t.p3.x*scale, t.p3.y*scale);
    endShape();
    indx_triangle_to_draw++;
    if (indx_triangle_to_draw == current_image.size())
    {
      indx_image_to_draw++;
      indx_triangle_to_draw =0;
    }
  }
  
  rect(30, 20, 55, 55, 7);
}
void keyPressed() {
  bpm = key;
  if (key == 'R')
    reload = true;
}

//Util function to prune triangles with vertices out of bounds  
boolean vertexOutside(PVector v) { 
  return v.x < 0 || v.x > width || v.y < 0 || v.y > height;
}  

void drawImage(ArrayList<Triangle> image_to_draw, int [] colors)
{
  for (int indx_triangle=0; indx_triangle<image_to_draw.size(); indx_triangle++ )
  {
    Triangle t = new Triangle();
    t = image_to_draw.get(indx_triangle); 
    beginShape(TRIANGLES);
    fill(colors[indx_triangle]);
    stroke(colors[indx_triangle]);
    vertex(t.p1.x*scale, t.p1.y*scale);
    vertex(t.p2.x*scale, t.p2.y*scale);
    vertex(t.p3.x*scale, t.p3.y*scale);
    endShape();
  }
}
void drawImageRandomAlpha(ArrayList<Triangle> image_to_draw, int [] colors)
{
  int indx_random = (int)random(0, image_to_draw.size());
  float alpha_random = random(20, 180);  
  Triangle t = new Triangle();

  beginShape(TRIANGLES);
  t = image_to_draw.get(indx_random); 
  fill(colors[indx_random], alpha_random);
  stroke(colors[indx_random], alpha_random);

  vertex(t.p1.x*scale, t.p1.y*scale);
  vertex(t.p2.x*scale, t.p2.y*scale);
  vertex(t.p3.x*scale, t.p3.y*scale);
  endShape();
}