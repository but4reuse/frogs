/** Jabier Martinez, prototyping code **/

import java.util.Collections;
import java.util.Random;

String SPLName = "epsConfigs"; //"carExample";

String title;
String[] lines;
String[] featureNames;
String[] featureStakeHolder;
float[][] configsMatrix;
int currentI = 0;
boolean filterIndependent = false;
String requiresText = "";
String excludesText = "";

float ENC = 0.75;
float DIS = 0.25;

float EXCLUDESZONE = 500;
float REQUIRESZONE = 100;
float DISCOURAGESZONE;
float MIDDLEZONE;
float ENCOURAGESZONE;

float rotateRadio;
int[] sh;
color[] stakeHoldersColors;
color[] zoneColors;
String[] stakeHoldersNames;
HashMap<Integer, ArrayList> requires = new HashMap<Integer, ArrayList>();
HashMap<Integer, ArrayList> excludes = new HashMap<Integer, ArrayList>();
String[] zoneNames;
Float[] validContainingF;
float featuresAbsPositions[][]; // i and 0=x 1=y

int WIDTH = 0;
int HEIGHT = 0;

GradientLegend gradientLegend;
Boolean zoneShow[] = new Boolean[5];
Boolean stakeholderShow[];
Boolean typeShow[] = new Boolean[3];

boolean showOptions = false;

Legend stakeholdersLegend;
ImageLegend typeLegend;
FeatureList featureList;

void setup() {
  WIDTH = displayWidth;
  HEIGHT = displayHeight;
  size(WIDTH, HEIGHT);

  // LOADING FILES
  title = loadStrings(SPLName + "_title.txt")[0];

  lines = loadStrings(SPLName + ".txt");
  // Load feature names
  featureNames = split(lines[0], TAB);

  // Load configs matrix
  configsMatrix = new float[lines.length][featureNames.length];
  for (int start = 0; start<lines.length-1; start++) {
    String[] configString = split(lines[start + 1], TAB);
    for (int i = 0; i<featureNames.length; i++) {
      configsMatrix[start][i] = Float.parseFloat(configString[i]);
    }
  }

  // Load rest of the files
  String[] stakeholdersFile = loadStrings(SPLName + "_stakeholders.txt");
  stakeHoldersNames = split(stakeholdersFile[0], TAB);

  String[] shString = split(stakeholdersFile[1], TAB);
  sh = new int[shString.length];
  for (int i=0; i<shString.length; i++) {
    sh[i]= new Integer(shString[i]);
  }
  String[] excludesFile = loadStrings(SPLName + "_excludes.txt");
  for (int i=0; i<excludesFile.length; i++) {
    String[] oneConstraint = split(excludesFile[i], TAB);
    Integer source = new Integer(oneConstraint[0]);
    Integer destination = new Integer(oneConstraint[1]);
    ArrayList l = excludes.get(source);
    if (l==null) {
      l = new ArrayList();
      excludes.put(source, l);
    }
    l.add(destination);
  }
  String[] requiresFile = loadStrings(SPLName + "_requires.txt");
  for (int i=0; i<requiresFile.length; i++) {
    String[] oneConstraint = split(requiresFile[i], TAB);
    Integer source = new Integer(oneConstraint[0]);
    Integer destination = new Integer(oneConstraint[1]);
    ArrayList l = requires.get(source);
    if (l==null) {
      l = new ArrayList();
      requires.put(source, l);
    }
    l.add(destination);
  }

  validContainingF = new Float[featureNames.length];
  String[] validContainingFFile = loadStrings(SPLName + "_validContainingF.txt");
  if (validContainingFFile.length>0) {
    String[] load = split(validContainingFFile[0], TAB);

    for (int i=0; i<load.length; i++) {
      validContainingF[i]= new Float(load[i]);
    }
  }


  rotateRadio = TWO_PI/(featureNames.length-1);

  stakeHoldersColors = new color[6];
  stakeHoldersColors[0] = color(203, 215, 232);
  stakeHoldersColors[1] = color(149, 139, 189);
  stakeHoldersColors[2] = color(147, 184, 213);
  stakeHoldersColors[3] = color(226, 226, 226);
  stakeHoldersColors[4] = color(152, 152, 152);
  stakeHoldersColors[5] = color(180, 180, 180);

  stakeHoldersColors[3] = color(223, 225, 252);
  stakeHoldersColors[4] = color(199, 179, 229);
  stakeHoldersColors[5] = color(187, 224, 253);

  //colorbewer
  //  stakeHoldersColors[0] = color(141,211,199);
  //  stakeHoldersColors[1] = color(255,255,179);
  //  stakeHoldersColors[2] = color(190,186,218);
  //  stakeHoldersColors[3] = color(251,128,114);
  //  stakeHoldersColors[4] = color(128,177,211);
  //  stakeHoldersColors[5] = color(253,180,98);

  zoneColors = new color[5];
  zoneColors[4] = color(255, 0, 0); // excludes
  zoneColors[3] = color(242, 178, 103); // discourages
  zoneColors[2] = color(255, 255, 255); // middle
  zoneColors[1] = color(179, 202, 157); // encourages
  zoneColors[0] = color(19, 166, 50); // implies

  zoneNames = new String[] {
    "Requires", "Encourages", "Independent", "Discourages", "Excludes"
  };

  featuresAbsPositions = new float[featureNames.length][2];

  stakeholderShow = new Boolean[stakeHoldersNames.length];
  for (int is=0; is<stakeHoldersNames.length; is++) {
    stakeholderShow[is]= new Boolean(true);
  }
  stakeholdersLegend = new Legend(WIDTH - 240, 200, "Stakeholder perspectives", stakeHoldersColors, stakeHoldersNames, stakeholderShow);

  for (int is=0; is<3; is++) {
    typeShow[is]= new Boolean(true);
  }
  typeLegend = new ImageLegend(WIDTH - 240, 430, typeShow);

  for (int is=0; is<zoneNames.length; is++) {
    zoneShow[is]= new Boolean(true);
  }
  gradientLegend = new GradientLegend(WIDTH - 240, 570, "Zones", zoneColors, zoneNames, zoneShow);
  featureList = new FeatureList(80, 80, featureNames);
}

void draw() {


  textFont(createFont("Arial", 16));
  background(255);
  smooth();

  // FRoG
  ENCOURAGESZONE = 100 + getDistanceENCDIS(ENC);
  DISCOURAGESZONE = EXCLUDESZONE - 20;
  MIDDLEZONE = DISCOURAGESZONE - getDistanceENCDIS(1-DIS);//DISCOURAGESZONE -100;
  pushMatrix();
  translate(WIDTH/2, HEIGHT/2);

  textSize(16);

  stroke(38, 38, 38);
  fill(255);
  ellipse(EXCLUDESZONE-280, 320, 25, 25);
  fill(0);
  arc(EXCLUDESZONE-280, 320, 25, 25, TWO_PI-HALF_PI, TWO_PI-HALF_PI+ (getConfidence(currentI, 0) * TWO_PI), PIE);
  stroke(0);
  text("Confidence: " + (int)(getConfidence(currentI, 0)*100) + "%", EXCLUDESZONE-260, 325);

  // STAKEHOLDER SEGMENTS
  strokeWeight(50);
  strokeCap(SQUARE);

  noFill();

  int currentIStakeholder = -1;

  // adjust with current i
  int[] sh1 = new int[sh.length];
  for (int i = 1; i < sh.length; i++) {
    sh1[i]=sh[i];
    if (sh[i]>currentI) {
      if (currentIStakeholder == -1) {
        currentIStakeholder = i-1;
      }
      sh1[i]=sh[i]-1;
    }
  }


  for (int i = 0; i <= sh1.length - 2; i++) {
    stroke(stakeHoldersColors[i]);
    if (sh1[i]!=sh1[i+1]) {
      if (i==currentIStakeholder) {
        fill(stakeHoldersColors[i]);
        arc(0, 0, EXCLUDESZONE+130, EXCLUDESZONE+130, (sh1[i] * rotateRadio) - (rotateRadio/2) + QUARTER_PI/50, ((sh1[i+1]-1) * rotateRadio) + (rotateRadio/2) - QUARTER_PI/50);
      } 
      else {
        noFill();
        arc(0, 0, EXCLUDESZONE+100, EXCLUDESZONE+100, (sh1[i] * rotateRadio) - (rotateRadio/2) + QUARTER_PI/50, ((sh1[i+1]-1) * rotateRadio) + (rotateRadio/2) - QUARTER_PI/50);
      }
    }
  }

  stroke(0);
  strokeWeight(1);
  // ZONES
  fill(zoneColors[4]);
  // excludes zone
  ellipse(0, 0, EXCLUDESZONE+20, EXCLUDESZONE+20);
  // 
  // discourages zone
  fill(zoneColors[3]);
  ellipse(0, 0, DISCOURAGESZONE, DISCOURAGESZONE);
  noStroke();

  // Degradate from discourage to middle
  float degSize = 20.0;
  float r = red(zoneColors[3]);
  float ir = (255.0 - r)/degSize;
  float g = green(zoneColors[3]);
  float gr = (255 - g)/degSize;
  float b = blue(zoneColors[3]);
  float br = (255 - b)/degSize;
  for (float grad=degSize; grad>=0; grad--) {
    fill(r+((degSize-grad)*ir), g+((degSize-grad)*gr), b+((degSize-grad)*br));
    ellipse(0, 0, MIDDLEZONE+grad, MIDDLEZONE+grad);
  }

  // middle zone
  fill(zoneColors[2]);
  ellipse(0, 0, MIDDLEZONE, MIDDLEZONE);

  // Degradate from middle to encourage
  //float degSize = 20.0;
  r = red(zoneColors[1]);
  ir = (255.0 - r)/degSize;
  g = green(zoneColors[1]);
  gr = (255 - g)/degSize;
  b = blue(zoneColors[1]);
  br = (255 - b)/degSize;
  for (float grad=degSize; grad>=0; grad--) {
    fill(r+((grad)*ir), g+((grad)*gr), b+((grad)*br));
    ellipse(0, 0, ENCOURAGESZONE+grad, ENCOURAGESZONE+grad);
  }

  // encourages zone
  fill(zoneColors[1]);
  ellipse(0, 0, ENCOURAGESZONE, ENCOURAGESZONE);
  stroke(0);
  // requires zone
  fill(zoneColors[0]);
  ellipse(0, 0, REQUIRESZONE+20, REQUIRESZONE+20);

  noFill();
  requiresText = "";
  excludesText = "";


  int prob1Times = 0;
  int prob0Times = 0;


  float screenx = 0;
  float screeny = 0;

  // FEATURES
  for (int i = 0; i<featureNames.length; i++) {
    if (i!=currentI) {
      // float probability = 1; // distanceMatrix[currentI][i];
      // float inverseProbability = 0; // distanceMatrix[i][currentI];
      float proportion = getProportion(currentI, i);
      float distance = getDistance(proportion);

      if (!shouldBeHide(i, proportion)) {
        fill(255);
        // arrow
        float extra = 0;
        if (proportion==1) {
          extra = 10;
        }

        // strokeWeight(getLineWeight(getConfidence(currentI, i)));
        // affecting other
        line(0, 0, distance - 10 + extra, 0);

        line(distance - 10 + extra, 0, distance - 15 + extra, 5);
        line(distance - 10 + extra, 0, distance - 15 + extra, -5);

        // affecting me
        //        line(0, 0, distance - 10 + extra, 0);
        //        line(REQUIRESZONE/2 - 10, 0,  5 + REQUIRESZONE/2 - 10, 5);
        //        line(REQUIRESZONE/2 - 10, 0,  5 + REQUIRESZONE/2 - 10, -5);
        fill(0);
        strokeWeight(1);
        fill(255);
        // fill(255,236,59); // if redundant

        featuresAbsPositions[i][0]= screenX(distance, 0);
        featuresAbsPositions[i][1]= screenY(distance, 0);

        ellipse(distance, 0, 20, 20);


        // DEFINED CONSTRAINTS
        if (proportion==0 && definedExcludesConstraint(currentI, i)) {
          fill(zoneColors[4]);
          ellipse(distance, 0, 10, 10);
        } 
        else if (proportion==0 && !definedExcludesConstraint(currentI, i)) {
          fill(zoneColors[4]);
          triangle(distance + 5, 0, distance-4, -5, distance-4, 5);
        }
        else if (proportion==1 && definedRequiresConstraint(currentI, i)) {
          fill(zoneColors[0]);
          ellipse(distance, 0, 10, 10);
        }
        else if (proportion==1 && !definedRequiresConstraint(currentI, i)) {
          fill(zoneColors[0]);
          triangle(distance + 5, 0, distance-4, -5, distance-4, 5);
        }
        else if (proportion!=0 && proportion<=DIS && definedDiscouragesConstraint(currentI, i)) { // TODO and defined
          fill(zoneColors[3]);
          ellipse(distance, 0, 10, 10);
        } 
        else if (proportion!=1 && proportion>=ENC && definedEncouragesConstraint(currentI, i)) { // TODO and defined
          fill(zoneColors[1]);
          ellipse(distance, 0, 10, 10);
        }


        fill(0);

        textSize(20);
        float ascent = textAscent();
        //textSize(15);
        float rotat = (i-1)*rotateRadio;
        if (currentI>=i) {
          rotat += rotateRadio;
        }
        if (rotat>HALF_PI && rotat<HALF_PI*3) { //TODO THOSE TO BE ROTATED
          pushMatrix();
          translate(distance+20, 0);
          rotate(PI);
          float textw = textWidth(featureNames[i]);
          text(featureNames[i], - textw, ascent/4);
          popMatrix();
        } 
        else {
          text(featureNames[i], distance + 20, ascent/4);
        }
      }
      rotate(rotateRadio);
    }
  }



  // FEATURE IN THE CENTER
  fill(stakeHoldersColors[currentIStakeholder]);
  noStroke();
  stroke(0);
  ellipse(0, 0, REQUIRESZONE-20, REQUIRESZONE-20);

  fill(0);
  textFont(createFont("Arial Bold", 20)); // 16));
  float textw = textWidth(featureNames[currentI]);
  text(featureNames[currentI], -textw/2, 0);

  popMatrix(); // initial translate

  // Legends
  stakeholdersLegend.drawLegend(showOptions);
  typeLegend.drawLegend(showOptions);
  gradientLegend.drawLegend(showOptions, ENC, DIS);

  // Title
  textFont(createFont("Arial Bold", 50));
  text(title, 50, 50 );

  // Feature list
  featureList.draw(currentI);

  // Buttons
  PImage optionImg = loadImage("options.png");
  textFont(createFont("Arial Bold", 16)); //20));
  String m = "Show Options";
  if (showOptions) {
    optionImg = loadImage("options2.png");
    m = "Hide Options";
  }
  image(optionImg, WIDTH - 240, 30);
  text(m, WIDTH - 240 + 30, 50);

  PImage saveImg = loadImage("save.png");
  image(saveImg, WIDTH - 240, 60);
  text("Save to image", WIDTH - 240 + 30, 80);
}

// Should be hidden?
public boolean shouldBeHide(int i, float proportion) {
  if (!gradientLegend.isSelected(0) && proportion==1) {
    return true;
  }
  if (!gradientLegend.isSelected(1) && proportion!=1 && proportion>ENC) {
    return true;
  }
  if (!gradientLegend.isSelected(2) && (proportion!=0 && proportion!=1 && proportion<=ENC && proportion>=DIS)) {
    return true;
  }
  if (!gradientLegend.isSelected(3) && proportion!=0 && proportion<DIS) {
    return true;
  }
  if (!gradientLegend.isSelected(4) && proportion==0) {
    return true;
  }

  for (int is=0; is<stakeHoldersNames.length; is++) {
    if (!stakeholdersLegend.isSelected(is) && sh[is+1]>i && sh[is]<=i) {
      return true;
    }
  }

  if (!typeLegend.isSelected(0) && (definedExcludesConstraint(currentI, i) || definedRequiresConstraint(currentI, i))) {
    return true;
  }
  if (!typeLegend.isSelected(1) && ((!definedExcludesConstraint(currentI, i) && proportion ==0) || (!definedRequiresConstraint(currentI, i) && proportion ==1))) {
    return true;
  }
  if (!typeLegend.isSelected(2) && !(proportion ==0 || proportion ==1)) {
    return true;
  }

  return false;
}

public float getFeatureCircleSize(Float size) {
  return Math.max(10, size*50);
}


public float getLineWeight(float proportion) {
  return 1 + (5*proportion);
}

public float getDistance(float proportion) {
  return REQUIRESZONE/2 + ((1-proportion)*(EXCLUDESZONE/2 - REQUIRESZONE/2));
}

public float getDistanceENCDIS(float proportion) {
  return REQUIRESZONE/2 + ((1-proportion)*(EXCLUDESZONE/2 - REQUIRESZONE/2 + 100)) - 20;
}

public float getConfidence(int currentI, int i) {
  if (validContainingF[currentI]==null) {
    return 0;
  }
  // existing with current I
  float existing = 0;
  for (int conf = 0; conf < configsMatrix.length; conf ++) {
    if (configsMatrix[conf][currentI]==1) {
      existing = existing + 1.0;
    }
  }
  // println(existing + " " + validContainingF[currentI]);
  return existing/validContainingF[currentI];
}

// P(i|currentI)
public float getProportion(int currentI, int i) {
  float numerator = 0;
  float denominator = 0;
  for (int conf = 0; conf < configsMatrix.length; conf ++) {
    if (configsMatrix[conf][currentI]==1) {
      denominator = denominator + 1.0;
      if (configsMatrix[conf][i]==1) {
        numerator = numerator + 1.0;
      }
    }
  }
  return numerator/denominator;
}

boolean definedExcludesConstraint(int currentI, int i) {
  ArrayList l = excludes.get(currentI);
  if (l!=null && l.contains(i)) {
    return true;
  }
  return false;
}

boolean definedRequiresConstraint(int currentI, int i) {
  ArrayList l = requires.get(currentI);
  if (l!=null && l.contains(i)) {
    return true;
  }
  return false;
}

boolean definedEncouragesConstraint(int currentI, int i) {
  return false;
}

boolean definedDiscouragesConstraint(int currentI, int i) {
  return false;
}

// USER INTERACTIONS
void keyPressed() {
  // println(keyCode);

  if (keyCode == 40) {
    if (currentI<featureNames.length-1) {
      currentI++;
    }
  }
  if (keyCode == 38) {
    if (currentI>0) {
      currentI--;
    }
  }
}


void mousePressed() {
  for (int i=0; i<featureNames.length; i++) {
    if (i!=currentI) {
      float x = featuresAbsPositions[i][0];
      float y = featuresAbsPositions[i][1];
      if (mouseX > x-10 && mouseX < x+10 && mouseY > y-10 && mouseY < y+10) {
        currentI = i;
      }
    }
  }
  if (showOptions) {
    stakeholdersLegend.mouse(mouseX, mouseY);
    typeLegend.mouse(mouseX, mouseY);
    gradientLegend.mousePressed(mouseX, mouseY);
  }
  int sel = featureList.mouse(mouseX, mouseY);
  if (sel!=-1) {
    currentI=sel;
  }
  if (mouseX > WIDTH - 240 && mouseX < WIDTH - 240 + 200 && mouseY > 10 && mouseY < 50) { //30
    showOptions=!showOptions;
  }
  if (mouseX > WIDTH - 240 && mouseX < WIDTH - 240 + 200 && mouseY > 40 && mouseY < 80) { //60
    PImage screenshot = get(0, 0, WIDTH, HEIGHT);
    screenshot.save("savedFrogs/"+featureNames[currentI]+".png");
  }
}

void mouseReleased() {
  gradientLegend.mouseReleased();
}

void mouseDragged() {
  if (showOptions) {
    gradientLegend.mouseDragged(mouseX, mouseY);
  }
}

boolean sketchFullScreen() {
  return true;
}

