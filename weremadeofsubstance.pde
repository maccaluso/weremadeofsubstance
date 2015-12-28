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
void setup() 
{
  size(1024, 256);
  smooth();
  all_triangles = new ArrayList<ArrayList<Triangle>> ();
  all_colors = new ArrayList<int[]> ();
  File folder = new File(path_data+folder_images); 
  list_images = folder.list(); //<>//
   //<>//
  for (int indx_photo=0; indx_photo <list_images.length; indx_photo++)
  {
    //here for all dataset
    
    PImage buffer = loadImage(folder_images+list_images[indx_photo]);

    //Extract significant points of the picture
    ArrayList<PVector> vertices = new ArrayList<PVector>();
    EdgeDetector.extractPoints(vertices, buffer, EdgeDetector.SOBEL, 300, 4);

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
  println( all_triangles.size());
}

void draw() {  // draw() loops forever, until stopped
  //
  frameRate(bpm);
  println(indx_image_to_draw);
  if(indx_image_to_draw == list_images.length)
    indx_image_to_draw = 0;
    
  ArrayList<Triangle> current_image =  all_triangles.get(indx_image_to_draw);

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
void keyPressed() {
  bpm = key;
}

//Util function to prune triangles with vertices out of bounds  
boolean vertexOutside(PVector v) { 
  return v.x < 0 || v.x > width || v.y < 0 || v.y > height;
}  