import processing.sound.*; //<>// //<>// //<>//

import java.util.List; //<>//
import java.util.LinkedList;
import java.util.Arrays;
import java.io.IOException;


int W = 1024, H = 256;
int BACKGROUND_COLOR = 44;
//da settare in base alla visibilità minima del proiettore
int min_alpha = 50, max_alpha = 255;
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
boolean drawing_mode_changed = false;
boolean new_image = true;
float ratio = 1.689;
AudioFeed audio_feed;
int count=0;
int [] indices_visible;
boolean [] indices_sub;
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

}
void setup() 
{
  size(1024, 512);
  background(BACKGROUND_COLOR);
  smooth();

  File folder = new File(path_data+folder_images); 
  list_images = folder.list();
  all_triangles = new ArrayList<ArrayList<Triangle>> ();
  all_colors = new ArrayList<int[]> ();
  triangulate_all_images(all_triangles, all_colors);
}

void draw() {  // draw() loops forever, until stopped
  //
  frameRate(bpm);
  if (indx_image_to_draw == list_images.length)
  {
    indx_image_to_draw = 0;
    all_triangles = new ArrayList<ArrayList<Triangle>> ();
    all_colors = new ArrayList<int[]> ();
    triangulate_all_images(all_triangles, all_colors);
    indx_triangle_to_draw = 0;
  }  
  
  ArrayList<Triangle> current_image = all_triangles.get(indx_image_to_draw);
  int [] current_colors = all_colors.get(indx_image_to_draw);

  if (drawing_mode_changed || new_image)
  {
      drawing_mode_changed = false;
      new_image = false;
      count = current_image.size();
      indices_visible = new int [current_image.size()];
      indices_sub = new boolean[current_image.size()];
      Arrays.fill(indices_sub,false);
  }

  //drawImage(current_image,all_colors.get(temp));
  if (single_image)
  {


    int indx_random = (int)random(0, current_image.size());
    int alpha_random = (int)random(min_alpha, max_alpha); 
    Triangle t = new Triangle();
    t = current_image.get(indx_random); 
    color triangle_color = color(current_colors[indx_random]);    

    drawTriangleAlpha(t, triangle_color, alpha_random);
    indices_visible[indx_random] += alpha_random;
    
    if (indices_visible[indx_random] > 200 &&  !indices_sub[indx_random] )
    {
      
      count--;
      indices_sub[indx_random] = true;
      println(count);
      if (count == 20)
      {
        indx_image_to_draw++;
        new_image = true;
        print("CHANGE");
        background(BACKGROUND_COLOR); //<>//
        delay(1000);
      }
    }
  
     
      
  } else
  {
    //current_image = all_triangles.get(indx_image_to_draw);
    Triangle t = new Triangle();
    beginShape(TRIANGLES);
    t = current_image.get(indx_triangle_to_draw); 
    //  current_colors = all_colors.get(indx_image_to_draw);
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
}
void keyPressed() {
  bpm = key;
  if (key == 'S')
  {
    background(BACKGROUND_COLOR);
    single_image  = !single_image;
    drawing_mode_changed = true;
    indx_image_to_draw++;
    indx_triangle_to_draw = 0;
  }
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
void drawTriangleAlpha(Triangle t, color color_triangle, int alpha_random)
{

  beginShape(TRIANGLES);
  fill(color_triangle, alpha_random);
  stroke(color_triangle, alpha_random);
  vertex(t.p1.x*scale, t.p1.y*scale);
  vertex(t.p2.x*scale, t.p2.y*scale);
  vertex(t.p3.x*scale, t.p3.y*scale);
  endShape();
}