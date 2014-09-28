
class Legend {
  float x;
  float y;
  String legendName;
  color[] colors;
  String[] names;
  Checkbox[] checkboxes;
  
  public Legend(float x, float y, String legendName, color[] colors, String[] names, Boolean[] stakeholderShow){
    this.x=x;
    this.y=y;
    this.legendName=legendName;
    this.colors = colors;
    this.names =names;
    checkboxes = new Checkbox[names.length];
    for(int i=0; i<names.length; i++){
      Checkbox c = new Checkbox(x - 20,y+((i)*space),names[i],50,stakeholderShow[i]);
      checkboxes[i]=c;
    }
  }
  
  int space = 30;
  
  void drawLegend(boolean showOptions) {
    stroke(0);
    fill(0);
    textFont(createFont("Arial", 16));
    text(legendName, x, y-5);
    
    for (int i=0; i<names.length; i++) {
      fill(colors[i]);
      rect(x, y+((i)*space), 20, 20);
      fill(0);
      checkboxes[i].drawCheckbox(showOptions);
    }
  }
  
  void mouse(float mx, float my){
    for (Checkbox c : checkboxes){
      c.mouse(mx,my);
    }
  }
  
  public boolean isSelected(int i){
    return checkboxes[i].isSelected();
  }
}

