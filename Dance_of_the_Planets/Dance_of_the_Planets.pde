String[] planetNames = {
  "Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"
};

//these years are represented in earth days
float[] planetYears = {
  87.969, 224.701, 365.256, 686.980, 4332.6, 10759.2, 30685, 60190
};

//an orbit radius is the distance of a planet's center to the sun, in 10^6 km
float[] planetOrbitRadius = {
  57.91, 108.21, 149.60, 227.92, 778.57, 1433.5, 2872.46, 4495.1
};

//background image
PImage bg;
//we'll use this image to register the drawings through time
PImage dance;

//controls
RadioButtons planetButtons;
CheckBox showPlanets;
Button clearButton;
Slider speedSlider;
Slider alphaSlider;

//images of the planets
PImage [] planetImages;

//variables used to control the drawings
int customAlpha;
float customSpeed;
Boolean displayPlanets, firstChoice, secondChoice;
Boolean displayFirstChoice, displaySecondChoice, clearing;
int planet1, planet2, timeCount;

//instances of Planet, a class which contains information about a planet's radius and speed(year) 
Planet p1, p2;


void setup() {
  size(800, 600);
  frameRate(30);
  
  //displayPlanets set to false means that no drawing is being made
  displayPlanets = false;
  
  //we need an initial loading of the background...
  bg = loadImage("bg.jpg");
  image(bg);
  //... and a copy of some pixels to be used in the draw() function
  dance = get(width-height,0,height,height);
  
  //loading the planets' images
  planetImages = new PImage[planetNames.length];
  planetImages[0] = loadImage("mercury.png");
  planetImages[1] = loadImage("venus.png");
  planetImages[2] = loadImage("earth.png");
  planetImages[3] = loadImage("mars.png");
  planetImages[4] = loadImage("jupiter.png");
  planetImages[5] = loadImage("saturn.png");
  planetImages[6] = loadImage("uranus.png");
  planetImages[7] = loadImage("neptune.png");
  
  //creating the controls
  planetButtons = new RadioButtons(planetNames.length, 10, 30, 100, 30, VERTICAL); 
  planetButtons.setNames(planetNames);
  
  showPlanets = new CheckBox("Show Planets", 10, 460, 100, 16);
  showPlanets.setActiveColor(color(0,255,0));
  showPlanets.setInactiveColor(color(0));
  showPlanets.set(true);
  
  clearButton = new Button("Reset", 10, 490, 100, 20);
  
  speedSlider = new Slider("Speed", 100, 60, 600, 10, height-70, 150,20, HORIZONTAL);
  alphaSlider = new Slider("Alpha", 10, 10, 100, 10, height-40, 150,20, HORIZONTAL); 
  
  //setting up the variables
  timeCount = 0;//timeCount is used to determine the angles of the planets' movements
  firstChoice = true;//firstChoice indicates that the first planet is to be chosen
  displayFirstChoice = false;//this is a flag to show whether a first planet was chosen or not
  displaySecondChoice = false;//this is a flag to show whether a second planet was chosen or not
  clearing = false;//this is a flag which tells the system to clear the drawing
}

void draw() {
  timeCount++;//as timeCount progresses, the angles of the planets in their orbits change as well 
  
  //draw the interface
  image(bg);
  text("Select two planets:", 10, 20);
  
  //if a first planet was selected, show this on the screen
  if(displayFirstChoice) {
    fill(100);
    rect(planetButtons.buttons[planet1].pos.x, planetButtons.buttons[planet1].pos.y, planetButtons.buttons[planet1].extents.x, planetButtons.buttons[planet1].extents.y);
    fill(200);
    text("1", planetButtons.buttons[planet1].pos.x+90, planetButtons.buttons[planet1].pos.y+25);
  }
  //if a second planet was selected, show this on the screen
  if(displaySecondChoice) {
    fill(100);
    rect(planetButtons.buttons[planet2].pos.x, planetButtons.buttons[planet2].pos.y, planetButtons.buttons[planet2].extents.x, planetButtons.buttons[planet2].extents.y);
    fill(200);
    text("2", planetButtons.buttons[planet2].pos.x+90, planetButtons.buttons[planet2].pos.y+25);
  }
  
  //display buttons and toggles
  planetButtons.display();
  showPlanets.display();
  clearButton.display();
  
  //check if the sliders are under interaction
  if(mousePressed) {
    speedSlider.mouseDragged();
    alphaSlider.mouseDragged();
  }
  //set variables according to the slider values. This first one is a inversely valued variable
  customSpeed = map(speedSlider.get(), 60, 600, 600, 60); 
  customAlpha = (int)alphaSlider.get();
  
  //display sliders
  speedSlider.display();
  alphaSlider.display();
  
  
  //check if it's time to draw
  if(displayPlanets && !clearing) {
    //set the speed and position of planets according to the speed slider 
    p1.year = (planetYears[p1.ref]/planetYears[p2.ref]) * customSpeed;
    p2.year = customSpeed;
    p1.updatePos();
    p2.updatePos();
    
    //place what was drawn so far, before a new line drawing
    image(dance,width-height,0);
    //trace line between planets
    pushMatrix();
    translate(height/2 + (width-height), height/2);
    stroke(255,255,255,customAlpha);//customAlpha comes from the alpha slider
    line(p1.pX,p1.pY,p2.pX,p2.pY);//this line is traced between the selected planets
    popMatrix();
    
    //update the dance image with what was drawn so far
    dance = get(width-height,0,height,height);
    
    //if planets' images are to be shown...
    if(showPlanets.get()) {
      p1.display();
      p2.display();
    }
  } else {
    //if it's not time to draw, just keep the scene clear
    dance = get(width-height,0,height,height);
    clearing = false;
  }
}

void mouseReleased() {
  planetButtons.mouseReleased();
  
  //first check if a selection is not empty
  if(planetButtons.get() != -1) {
    //then check if the first choice is being made
    if(firstChoice && planetButtons.buttons[planetButtons.get()].isClicked()) {
      planet1 = planetButtons.get();//set a reference to the first planet
      displayPlanets = false;
      firstChoice = false;
      displayFirstChoice = true;
      displaySecondChoice = false;
    } else if(planetButtons.get() != planet1 && planetButtons.buttons[planetButtons.get()].isClicked()) {
      //or check if the second choice is being made
      planet2 = planetButtons.get();//set a reference to the second planet
      createPlanets();//create the planets and start drawing
      displayPlanets = true;
      firstChoice = true;
      displaySecondChoice = true;
    }
  }
  
  //if the clear button is pressed, then the drawing will be erased
  if(clearButton.isClicked()) {
    clearing = true;
    timeCount = 0;
  }
  
  //check whether the system must show the planets' images
  if(showPlanets.isClicked()) {
    showPlanets.toggle();
  }
}

//instantiate the planets
void createPlanets() {
  int innerp = planet1;
  int outerp = planet2;
  //decide which one will be the inner and the outer in the drawing
  if(planetOrbitRadius[planet2] < planetOrbitRadius[planet1]) {
    innerp = planet2;
    outerp = planet1;
  }
  
  //calculate the ratios of the distances and speeds
  float orbitRatio = (planetOrbitRadius[innerp]/planetOrbitRadius[outerp]) * (height*0.45);
  float yearRatio = (planetYears[innerp]/planetYears[outerp]) * customSpeed;
  
  //create the planets
  p1 = new Planet(innerp, yearRatio, orbitRatio);
  p2 = new Planet(outerp, customSpeed, height*0.45);
  
  //set timeCount to zero to start from 0º
  timeCount = 0;
}


//Planet class has information about a planet's speed and orbit radius
class Planet {
  int ref;
  float year;
  float radius;
  float pX;
  float pY;
  float pAngle;
  
  Planet(int _ref, float _year, float _radius) {
    ref = _ref;
    year = _year;
    radius = _radius;
  }
  
  //calculate new position on its circular orbit
  void updatePos() {
    pAngle = TWO_PI * timeCount/year;
    pX = cos(pAngle)*radius;
    pY = sin(pAngle)*radius;
  }
  
  //display the planet's image on screen
  void display() {
    pushMatrix();
    translate(height/2 + (width-height), height/2);
    image(planetImages[ref],pX-planetImages[ref].width/2,pY-planetImages[ref].height/2);
    popMatrix();
  }
}


//this class extends a Widget class from GUI library
//basically, it implements a toggle control, independent from the one used for the RadioButtons component
class CheckBox extends Widget {
  boolean on = false;
  color onColor;
  color offColor;

  CheckBox(String nm, int x, int y, int w, int h)
  {
    super(nm, x, y, w, h);
  }

  boolean get()
  {
    return on;
  }

  void setActiveColor(color c) {
    onColor = c;
  }
  
  void setInactiveColor(color c) {
    offColor = c;
  }
  
  void set(boolean val)
  {
    on = val;
  }

  void display() {
    pushStyle();
    stroke(lineColor);
    if(on) {
      fill(onColor);
    } else {
      fill(offColor);
    }
    rect(pos.x + extents.x - extents.y, pos.y, extents.y, extents.y);

    fill(lineColor);
    textAlign(LEFT, CENTER);
    text(name, pos.x, pos.y + 0.5* extents.y);
    popStyle();
  }
  
  void toggle()
  {
    set(!on);
  }

  boolean mouseReleased()
  {
    if (super.isClicked())
    {
      toggle();
      return true;
    }
    return false;
  }
}

int HORIZONTAL = 0;
int VERTICAL   = 1;
int UPWARDS    = 2;
int DOWNWARDS  = 3;

class Widget
{

  
  PVector pos;
  PVector extents;
  String name;

  color inactiveColor = color(60, 60, 100);
  color activeColor = color(100, 100, 160);
  color bgColor = inactiveColor;
  color lineColor = color(255);
  
  
  
  void setInactiveColor(color c)
  {
    inactiveColor = c;
    bgColor = inactiveColor;
  }
  
  color getInactiveColor()
  {
    return inactiveColor;
  }
  
  void setActiveColor(color c)
  {
    activeColor = c;
  }
  
  color getActiveColor()
  {
    return activeColor;
  }
  
  void setLineColor(color c)
  {
    lineColor = c;
  }
  
  color getLineColor()
  {
    return lineColor;
  }
  
  String getName()
  {
    return name;
  }
  
  void setName(String nm)
  {
    name = nm;
  }


  Widget(String t, int x, int y, int w, int h)
  {
    pos = new PVector(x, y);
    extents = new PVector (w, h);
    name = t;
    //registerMethod("mouseEvent", this);
  }

  void display()
  {
  }

  boolean isClicked()
  {
    if (mouseX > pos.x && mouseX < pos.x+extents.x 
      && mouseY > pos.y && mouseY < pos.y+extents.y)
    {
      //println(mouseX + " " + mouseY);
      return true;
    }
    else
    {
      return false;
    }
  }
  
  public void mouseEvent(MouseEvent event)
  {
    //if (event.getFlavor() == MouseEvent.PRESS)
    //{
    //  mousePressed();
    //}
  }
  
  
  boolean mousePressed()
  {
    return isClicked();
  }
  
  boolean mouseDragged()
  {
    return isClicked();
  }
  
  
  boolean mouseReleased()
  {
    return isClicked();
  }
}

class Button extends Widget
{
  PImage activeImage = null;
  PImage inactiveImage = null;
  PImage currentImage = null;
  color imageTint = color(255);
  
  Button(String nm, int x, int y, int w, int h)
  {
    super(nm, x, y, w, h);
  }
  
  void setImage(PImage img)
  {
    setInactiveImage(img);
    setActiveImage(img);
  }
  
  void setInactiveImage(PImage img)
  {
    if(currentImage == inactiveImage || currentImage == null)
    {
      inactiveImage = img;
      currentImage = inactiveImage;
    }
    else
    {
      inactiveImage = img;
    }
  }
  
  void setActiveImage(PImage img)
  {
    if(currentImage == activeImage || currentImage == null)
    {
      activeImage = img;
      currentImage = activeImage;
    }
    else
    {
      activeImage = img;
    }
  }
  
  void setImageTint(color c)
  {
    imageTint = c;
  }

  void display()
  {
    if(currentImage != null)
    {
      //float imgHeight = (extents.x*currentImage.height)/currentImage.width;
      float imgWidth = (extents.y*currentImage.width)/currentImage.height;
      
      
      pushStyle();
      imageMode(CORNER);
      //tint(imageTint);
      image(currentImage, pos.x, pos.y, imgWidth, extents.y);
      stroke(bgColor);
      noFill();
      rect(pos.x, pos.y, imgWidth,  extents.y);
      //noTint();
      popStyle();
    }
    else
    {
      pushStyle();
      stroke(lineColor);
      noFill();
      rect(pos.x, pos.y, extents.x, extents.y);
  
      fill(lineColor);
      textAlign(CENTER, CENTER);
      text(name, pos.x + 0.5*extents.x, pos.y + 0.5* extents.y);
      popStyle();
    }
  }
  
  boolean mousePressed()
  {
    if (super.mousePressed())
    {
      bgColor = activeColor;
      if(activeImage != null)
        currentImage = activeImage;
      return true;
    }
    return false;
  }
  
  boolean mouseReleased()
  {
    if (super.mouseReleased())
    {
      bgColor = inactiveColor;
      if(inactiveImage != null)
        currentImage = inactiveImage;
      return true;
    }
    return false;
  }
}

class Toggle extends Button
{
  boolean on = false;

  Toggle(String nm, int x, int y, int w, int h)
  {
    super(nm, x, y, w, h);
  }


  boolean get()
  {
    return on;
  }

  void set(boolean val)
  {
    on = val;
    if (on)
    {
      bgColor = activeColor;
      if(activeImage != null)
        currentImage = activeImage;
    }
    else
    {
      bgColor = inactiveColor;
      if(inactiveImage != null)
        currentImage = inactiveImage;
    }
  }

  void toggle()
  {
    set(!on);
  }

  
  boolean mousePressed()
  {
    return super.isClicked();
  }

  boolean mouseReleased()
  {
    if (super.mouseReleased())
    {
      toggle();
      return true;
    }
    return false;
  }
}

class RadioButtons extends Widget
{
  public Toggle [] buttons;
  
  RadioButtons (int numButtons, int x, int y, int w, int h, int orientation)
  {
    super("", x, y, w*numButtons, h);
    buttons = new Toggle[numButtons];
    for (int i = 0; i < buttons.length; i++)
    {
      int bx, by;
      if(orientation == HORIZONTAL)
      {
        bx = x+i*(w+5);
        by = y;
      }
      else
      {
        bx = x;
        by = y+i*(h+5);
      }
      buttons[i] = new Toggle("", bx, by, w, h);
    }
  }
  
  void setNames(String [] names)
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(i >= names.length)
        break;
      buttons[i].setName(names[i]);
    }
  }
  
  void setImage(int i, PImage img)
  {
    setInactiveImage(i, img);
    setActiveImage(i, img);
  }
  
  void setAllImages(PImage img)
  {
    setAllInactiveImages(img);
    setAllActiveImages(img);
  }
  
  void setInactiveImage(int i, PImage img)
  {
    buttons[i].setInactiveImage(img);
  }

  
  void setAllInactiveImages(PImage img)
  {
    for (int i = 0; i < buttons.length; i++)
    {
      buttons[i].setInactiveImage(img);
    }
  }
  
  void setActiveImage(int i, PImage img)
  {
    buttons[i].setActiveImage(img);
  }
  
  
  
  void setAllActiveImages(PImage img)
  {
    for (int i = 0; i < buttons.length; i++)
    {
      buttons[i].setActiveImage(img);
    }
  }

  void set(String buttonName)
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].getName().equals(buttonName))
      {
        buttons[i].set(true);
      }
      else
      {
        buttons[i].set(false);
      }
    }
  }
  
  int get()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].get())
      {
        return i;
      }
    }
    return -1;
  }
  
  String getString()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].get())
      {
        return buttons[i].getName();
      }
    }
    return "";
  }

  void display()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      buttons[i].display();
    }
  }

  boolean mousePressed()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].mousePressed())
      {
        return true;
      }
    }
    return false;
  }
  
  boolean mouseDragged()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].mouseDragged())
      {
        return true;
      }
    }
    return false;
  }

  boolean mouseReleased()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].mouseReleased())
      {
        for(int j = 0; j < buttons.length; j++)
        {
          if(i != j)
            buttons[j].set(false);
        }
        buttons[i].set(true);
        return true;
      }
    }
    return false;
  }
}

class Slider extends Widget
{
  float minimum;
  float maximum;
  float val;
  int textWidth = 60;
  int orientation = HORIZONTAL;

  Slider(String nm, float v, float min, float max, int x, int y, int w, int h, int ori)
  {
    super(nm, x, y, w, h);
    val = v;
    minimum = min;
    maximum = max;
    orientation = ori;
    if(orientation == HORIZONTAL)
      textWidth = 60;
    else
      textWidth = 20;
  }

  float get()
  {
    return val;
  }

  void set(float v)
  {
    val = v;
    val = constrain(val, minimum, maximum);
  }

  void display()
  {
    pushStyle();
    textAlign(LEFT, TOP);
    fill(lineColor);
    text(name, pos.x, pos.y);
    stroke(lineColor);
    noFill();
    if(orientation ==  HORIZONTAL){
      rect(pos.x+textWidth, pos.y, extents.x-textWidth, extents.y);
    } else {
      rect(pos.x, pos.y+textWidth, extents.x, extents.y-textWidth);
    }
    noStroke();
    fill(bgColor);
    float sliderPos; 
    if(orientation ==  HORIZONTAL){
        sliderPos = map(val, minimum, maximum, 0, extents.x-textWidth-4); 
        rect(pos.x+textWidth+2, pos.y+2, sliderPos, extents.y-4);
    } else if(orientation ==  VERTICAL || orientation == DOWNWARDS){
        sliderPos = map(val, minimum, maximum, 0, extents.y-textWidth-4); 
        rect(pos.x+2, pos.y+textWidth+2, extents.x-4, sliderPos);
    } else if(orientation == UPWARDS){
        sliderPos = map(val, minimum, maximum, 0, extents.y-textWidth-4); 
        rect(pos.x+2, pos.y+textWidth+2 + (extents.y-textWidth-4-sliderPos), extents.x-4, sliderPos);
    };
    popStyle();
  }

  
  boolean mouseDragged()
  {
    if (super.mouseDragged())
    {
      if(orientation ==  HORIZONTAL){
        set(map(mouseX, pos.x+textWidth, pos.x+extents.x-4, minimum, maximum));
      } else if(orientation ==  VERTICAL || orientation == DOWNWARDS){
        set(map(mouseY, pos.y+textWidth, pos.y+extents.y-4, minimum, maximum));
      } else if(orientation == UPWARDS){
        set(map(mouseY, pos.y+textWidth, pos.y+extents.y-4, maximum, minimum));
      };
      return true;
    }
    return false;
  }

  boolean mouseReleased()
  {
    if (super.mouseReleased())
    {
      if(orientation ==  HORIZONTAL){
        set(map(mouseX, pos.x+textWidth, pos.x+extents.x-10, minimum, maximum));
      } else if(orientation ==  VERTICAL || orientation == DOWNWARDS){
        set(map(mouseY, pos.y+textWidth, pos.y+extents.y-10, minimum, maximum));
      } else if(orientation == UPWARDS){
        set(map(mouseY, pos.y+textWidth, pos.y+extents.y-10, maximum, minimum));
      };
      return true;
    }
    return false;
  }
}

class MultiSlider extends Widget
{
  Slider [] sliders;

  MultiSlider(String [] nm, float min, float max, int x, int y, int w, int h, int orientation)
  {
    super(nm[0], x, y, w, h*nm.length);
    sliders = new Slider[nm.length];
    for (int i = 0; i < sliders.length; i++)
    {
      int bx, by;
      if(orientation == HORIZONTAL)
      {
        bx = x;
        by = y+i*h;
      }
      else
      {
        bx = x+i*w;
        by = y;
      }
      sliders[i] = new Slider(nm[i], 0, min, max, bx, by, w, h, orientation);
    }
  }

  void set(int i, float v)
  {
    if(i >= 0 && i < sliders.length)
    {
      sliders[i].set(v);
    }
  }
  
  float get(int i)
  {
    if(i >= 0 && i < sliders.length)
    {
      return sliders[i].get();
    }
    else
    {
      return -1;
    }
    
  }

  void display()
  {
    for (int i = 0; i < sliders.length; i++)
    {
      sliders[i].display();
    }
  }

  
  boolean mouseDragged()
  {
    for (int i = 0; i < sliders.length; i++)
    {
      if(sliders[i].mouseDragged())
      {
        return true;
      }
    }
    return false;
  }

  boolean mouseReleased()
  {
    for (int i = 0; i < sliders.length; i++)
    {
      if(sliders[i].mouseReleased())
      {
        return true;
      }
    }
    return false;
  }
}


