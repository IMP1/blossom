package blossom.lang;

import java.util.ArrayList;

public class Label {
    
    public LabelItem<?> labelValue;
    public ArrayList<String> marks;
    
    public Label(LabelItem<?> labelValue, ArrayList<String> marks) {
        this.labelValue = labelValue;
        this.marks = marks;
    }
    
    public boolean hasMark(String name) {
        return marks.contains(name);
    }

}
