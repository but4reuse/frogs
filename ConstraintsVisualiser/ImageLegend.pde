class ImageLegend {

  float x;
  float y;
  String legendName;
  Checkbox[] checkboxes;
  PImage[] images;

  public ImageLegend(float x, float y, Boolean[] typeShow) {
    this.x=x;
    this.y=y;
    checkboxes = new Checkbox[3];
    String[] names = new String[] {
      "Formalized", "Inferred", "Undefined"
    };
    for (int i=0; i<names.length; i++) {
      Checkbox c = new Checkbox(x - 20, y+((i)*space), names[i], 60, typeShow[i]);
      checkboxes[i]=c;
    }
    images = new PImage[3];
    images[0] = loadImage("formalized.png");
    images[1] = loadImage("inferred.png");
    images[2] = loadImage("normal.png");
  }

  int space = 30;

  void drawLegend(boolean showOptions) {
    stroke(0);
    fill(0);
    text("Relation types", x, y-5);
    int space = 30;
    for (int i=0; i<3; i++) {
      checkboxes[i].drawCheckbox(showOptions);
      image(images[i], x, y+(i)*space);
    }
  }

  void mouse(float mx, float my) {
    for (Checkbox c : checkboxes) {
      c.mouse(mx, my);
    }
  }

  public boolean isSelected(int i) {
    return checkboxes[i].isSelected();
  }
}

