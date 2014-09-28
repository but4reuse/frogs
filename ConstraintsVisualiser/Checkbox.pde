class Checkbox {

  float x;
  float y;
  Boolean control;
  String text;
  float separation;

  public Checkbox(float x, float y, String text, float separation, Boolean control) {
    this.x=x;
    this.y=y;
    this.control=control;
    this.text=text;
    this.separation=separation;
  }

  public void drawCheckbox(boolean showCheckbox) {
    textFont(createFont("Arial", 16));
    if(showCheckbox){
    PImage checked = loadImage("checkboxYes.png");
    if (!control) {
      checked = loadImage("checkboxNo.png");
    }
    image(checked, x, y);
    }
    text(text, x + separation, y + 16);
  }

  public boolean isSelected() {
    return control;
  }

  public void mouse(float mx, float my) {
    if (mx>=x&&mx<=x+16&&my>=y&&my<=y+16) {
      control = !control;
    }
  }
}

