Maxim maxi;
AudioPlayer player;
Bubble[] bubbles;
int pos;
boolean bubbling;
boolean bubbleable;

//SETTINGS
int DIAMETER_MIN = 25;
int DIAMETER_MAX = 100;
int SPEED_MIN = 2; //speed of the upward movements
int SPEED_MAX = 10;
int SOUND_SPEED_MIN = 0.1;
int SOUND_SPEED_MAX = 2;
int SPREAD = 20; //how far from the mouse position bubbles are created


void setup() {
  background(0);
  size(600,600);
  frameRate(30); //reduced for better performance
  
  //sound setup
  maxi = new Maxim(this);
  player = maxi.loadFile("bubble.wav");
  player.setLooping(true);
  
  //flag setup
  bubbleable = true;
  bubbling = false;
  
  //bubble array starts empty
  bubbles = new Bubble[0];
}

void draw() {
  //clear the screen, so the bubble drawings don't overlap
  fill(0);
  rect(0,0,height,width);
  
  //bubbles can be created in every 2 'draw() ticks'
  bubbleable = !bubbleable;
  
  //creates bubbles while mouse is pressed
  if(bubbling && bubbleable) {
    //inertia is based on how fast the user is dragging/swiping
    int inertia = mouseX - pmouseX;
    //color is random
    int rgb[] = {round(random(0,255)),round(random(0,255)),round(random(0,255))};
    //diameter is random inside limits
    int diam = round(random(DIAMETER_MIN,DIAMETER_MAX));
    //speed will be inversely proportional to diameter
    int speed = ceil(map(diam, DIAMETER_MAX, DIAMETER_MIN, SPEED_MIN, SPEED_MAX))
    
    //creates a bubble and put it in the array
    bubbles = (Bubble[])append(bubbles, new Bubble(random(mouseX-SPREAD,mouseX+SPREAD),random(mouseY-SPREAD,mouseY+SPREAD), diam, rgb, speed, inertia));
    
    //changes the bubble sound according to the diameter
    player.speed(map(diam,DIAMETER_MIN,DIAMETER_MAX,SOUND_SPEED_MIN,SOUND_SPEED_MAX));
  }
  
  //moves all the bubbles created so far
  for(int i = 0;i < bubbles.length;++i) {
    bubbles[i] = new Bubble(bubbles[i].x,bubbles[i].y,bubbles[i].diameter,bubbles[i].rgb,bubbles[i].speed,bubbles[i].inertia);
  }
  
  //checks for bubbles which are out of the stage
  for(int i = 0;i < bubbles.length;++i) {
    if(bubbles[i].y + bubbles[i].diameter/2 < 0) {
      //if it's out, remove it from the array, overwriting its position with the rest of the array...
      arrayCopy(bubbles, i+1, bubbles, i, bubbles.length-(i+1));
      //...and using shorten() to remove the last unnecessary element
      bubbles = (Bubble[])shorten(bubbles);
    }
  }
}

void mousePressed() {
  bubbling = true;
  player.play();
}

void mouseReleased() {
  bubbling = false;
  player.stop();
}


//class for Bubble objects
public class Bubble {
  public float x;
  public float y;
  public int diameter;
  public int[] rgb;
  public int speed;
  public int inertia;
  
  //constructor
  Bubble(float x, float y, int diameter, int[] rgb, int speed, int inertia) {
    this.speed = speed;
    this.x = x + inertia/5;
    this.y = y - speed;
    this.diameter = diameter;
    this.rgb = rgb;
    
    //reduce the inertia
    if(inertia > 0) {
      --inertia;
    } else if(inertia < 0) {
      ++inertia;
    }
    this.inertia = inertia;
    
    //creates the 'body' of the bubble
    for(int r = diameter; r > 0.8*diameter; --r) {
      noFill();
      
      stroke(rgb[0],rgb[1],rgb[2],map(r, diameter, 0.8*diameter, 70, 0));
      ellipse(x, y, r, r);
    }
      
    //creates the 'reflection' spot on the bubble
    for(int r = 0; r < round(0.4*diameter); ++r) {
      noStroke();
      
      fill(rgb[0],rgb[1],rgb[2],5);
      ellipse(x+0.20*diameter, y-0.20*diameter, r, r);
    }
  }
}

