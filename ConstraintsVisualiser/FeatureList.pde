class FeatureList {

  float x;
  float y;
  String[] featureNames;

  public FeatureList(float x, float y, String[] names) {
    this.x=x;
    this.y=y;
    this.featureNames=names;
  }

  int space = 30;

  public void draw(int currentI) {
    textFont(createFont("Arial Bold", 22));
    text("Features", x-30, y);

    for (int i=0; i<featureNames.length; i++) {
      if (i==currentI) {
        textFont(createFont("Arial Bold", 16)); //20));
        text(">>>", x-30, y+space+(i*space));
      } 
      else {
        textFont(createFont("Arial", 16));
      }
      text(featureNames[i], x, y+space+(i*space));
    }
    textFont(createFont("Arial", 20));// 16));
  }

  // -1 if nothing
  public int mouse(float mx, float my) {
    for (int i=0;i<featureNames.length;i++) {
      if (mx>=x && mx<=x+250 && my>=y+space+(i*space)-20 && my<=y+space+(i*space)+20) {
        return i;
      }
    }
    return -1;
  }
}

