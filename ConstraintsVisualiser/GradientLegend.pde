class GradientLegend {
  float x;
  float y;
  color[] colors;
  String names[];
  String legendName;
  Boolean[] zoneShow;
  Checkbox[] checkboxes;
  boolean movingENC;
  boolean movingDIS;
  float initialENCy;
  float currentENCy;

  public GradientLegend(float x, float y, String legendName, color[] colors, String[] names, Boolean[] zoneShow) {
    this.legendName=legendName;
    this.x=x;
    this.y=y;
    this.colors=colors;
    this.zoneShow=zoneShow;
    this.names=names;
    movingENC=false;
    movingDIS=false;
    checkboxes = new Checkbox[names.length];
    for (int i=0; i<names.length; i++) {
      float modif = 0;
      if (i==1 || i==3 || i==2) {
        modif=-10;
      }
      if (i==4) {
        modif=-20;
      }
      Checkbox c = new Checkbox(x - 20, y+((i)*space)+modif, names[i], 50, zoneShow[i]);
      checkboxes[i]=c;
    }
  }

  int space = 30;

  void drawLegend(boolean showOptions, float ENC, float DIS) {
    
    // Add value of ENC and DIS when showOptions
    for (int i=0; i < checkboxes.length; i++) {
      if (showOptions) {
        if (i==1) {
          checkboxes[i].text = names[i] + " (" + int(ENC *100) + "%)";
        }
        else if (i==3) {
          checkboxes[i].text = names[i] + " (" + int(DIS *100) + "%)";
        }
      } 
      else {
        checkboxes[i].text = names[i];
      }
      checkboxes[i].drawCheckbox(showOptions);
    }

    stroke(0);
    fill(0);
    text(legendName, x, y-5);
    int space = 20;
    noStroke();
    int extraspace = 0;

    fill(colors[0]);
    rect(x, y, 20, 20);
    fill(0);

    fill(colors[1]);
    rect(x, y + 20, 20, (1-ENC)*80);
    if (!showOptions) {
      float degSize = 10;
      float r = red(colors[1]);
      float  ir = (255.0 - r)/degSize;
      float g = green(colors[1]);
      float gr = (255 - g)/degSize;
      float b = blue(colors[1]);
      float br = (255 - b)/degSize;
      for (float grad=degSize; grad>=0; grad--) {
        fill(r+grad*ir, g+grad*gr, b+grad*br);
        rect(x, y + grad+(1-ENC)*80, 20, 18);
      }
    }

    String name = names[1];
    if (showOptions) {
      name = name + " (" + int(ENC *100) + "%)";
    } 
    fill(0);



    for (int i=2; i<colors.length; i++) {
      if (i==2) {
        extraspace = 20;
      }
      fill(colors[i]);

      if(i==3){
        float currentDISy = y+20+(80*(1-DIS));
        rect(x, currentDISy, 20, y+100-currentDISy);
      } else {
        rect(x, y+i*space + extraspace, 20, 20);
      }

      if (!showOptions && i==2) {
        float degSize = 10;
        float r = red(colors[i+1]);
        float  ir = (255.0 - r)/degSize;
        float g = green(colors[i+1]);
        float gr = (255 - g)/degSize;
        float b = blue(colors[i+1]);
        float br = (255 - b)/degSize;
        for (float grad=degSize; grad>=0; grad--) {
          fill(r+((degSize-grad)*ir), g+((degSize-grad)*gr), b+((degSize-grad)*br));
          rect(x, grad+y+i*space-3 + extraspace, 20, 15);
        }
      }


      fill(0);
      name = names[i];
      if (showOptions) {
        if (i==1) {
          name = name + " (" + int(ENC *100) + "%)";
        } 
        else if (i==3) {
          name = name + " (" + int(DIS *100) + "%)";
        }
      }
    }


    if (showOptions) {
      stroke(1);
      fill(zoneColors[1]);
      float ty = y+20+(80*(1-ENC));

      line(x, ty, x+20, ty);
      triangle(x-2, ty-5, x-2, ty+5, x+5, ty);
      triangle(20+x+2, ty-5, 20+x+2, ty+5, 20+x-5, ty);

      fill(zoneColors[3]);
      ty = y+20+(80*(1-DIS));

      stroke(1);

      line(x, ty, x+20, ty);
      triangle(x-2, ty-5, x-2, ty+5, x+5, ty);
      triangle(20+x+2, ty-5, 20+x+2, ty+5, 20+x-5, ty);
    }




    stroke(0);
    noFill();
    rect(x, y, space, 120);
    line(x, y+ space, x + space, y +space);
    line(x, y+ 5*space, x + space, y + 5*space);
    fill(0);
  }

  void mousePressed(float mx, float my) {
    for (Checkbox c : checkboxes) {
      c.mouse(mx, my);
    }
    float currentDISy = y+20+(80*(1-DIS));
    if (!movingENC && mx>=x && mx<=x+20 && my>=currentDISy - 5 && my<=currentDISy +5) {
      movingDIS = true;
    }
    float currentENCy = y+20+(80*(1-ENC));
    if (!movingDIS && mx>=x && mx<=x+20 && my>=currentENCy - 5 && my<=currentENCy +5) {
      movingENC = true;
    }

  }

  void mouseReleased() {
    movingENC = false;
    movingDIS = false;
  }

  void mouseDragged(float mx, float my) {
    if (movingENC && !movingDIS) {
      float newENC = 1-((my-(y+20))/80.0);
      if (newENC>1) {
        ENC=1;
      } 
      else if (newENC<0.5) {
        ENC=0.5;
      } 
      else {
        ENC = newENC;
      }
    }
    if (movingDIS && !movingENC) {
      float newDIS = 1-((my-(y+20))/80.0);
      if (newDIS<0) {
        DIS=0;
      } 
      else if (newDIS>0.5) {
        DIS=0.5;
      } 
      else {
        DIS = newDIS;
      }
    }
  }

  public boolean isSelected(int i) {
    return checkboxes[i].isSelected();
  }
}

