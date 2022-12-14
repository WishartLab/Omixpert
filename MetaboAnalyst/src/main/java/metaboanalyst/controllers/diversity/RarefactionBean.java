/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package metaboanalyst.controllers.diversity;

import metaboanalyst.controllers.diversity.*;
import java.io.File;
import java.io.Serializable;
import java.util.Arrays;
import java.util.List;
import javax.faces.bean.ManagedBean;
import javax.faces.model.SelectItem;
import metaboanalyst.controllers.DownloadBean;
import metaboanalyst.controllers.ApplicationBean1;
import metaboanalyst.controllers.SessionBean1;
import metaboanalyst.models.User;
import metaboanalyst.rwrappers.OAUtils;
import metaboanalyst.rwrappers.DiversityUtils;
import metaboanalyst.utils.DataUtils;

/**
 *
 * @author violet
 */
@ManagedBean(name="rarefactionBean") //
public class RarefactionBean implements Serializable {
    
   private final SessionBean1 sb = (SessionBean1) DataUtils.findBean("sessionBean1");
   private final ApplicationBean1 ab = (ApplicationBean1) DataUtils.findBean("applicationBean1");
   
   private User usr = sb.getCurrentUser();
   private String usrName = usr.getName();
   
   //public static final String PROP_SAMPLE_PROPERTY = "sampleProperty";
  // check box
    private boolean doOriginal = false; 
    
    public boolean isdoOriginal() {
        return doOriginal;
    }
    
    public void setdoOriginal(boolean doOriginal) {
        this.doOriginal = doOriginal;
    }
     
   // check box 
    private boolean doSe = false;
    
    public boolean isdoSe() {
        return doSe;
    }

    public void setdoSe(boolean doSe) {
        this.doSe = doSe;
    }
    
    // textbox 
    private String sample = "";
    
    public String getSample() {
        return sample;
    }

    public void setSample(String sample) {
        this.sample = sample;
    }
    
        
    // static dropdown
    private final SelectItem[] type; // in the view, need to present the options //application bean 
    private String typechosen = "NULL";
            
    public SelectItem[] getType() {
        return type;
    }
    
    public String getTypechosen() {
        return typechosen;
    } 

    public void setTypechosen(String typechosen) {
        this.typechosen = typechosen;
    }
    
//    private final SelectItem[] margin;
//    private String marginchosen = "NULL";
//    
//    public SelectItem[] getMargin() {
//        return margin;
//    }
//    
//    public String getMarginchosen() {
//        return marginchosen;
//    } 
//
//    public void setMarginchosen(String marginchosen) {
//        this.marginchosen = marginchosen;
//    }
        
    private String step = "";
    
    public String getStep() {
        return step;
    }

    public void setStep(String step) {
        this.step = step;
    }
    
    
    private final SelectItem[] color;
    private String colorchosen = "NULL";
    
    public SelectItem[] getColor() {
        return color;
    }
    
    public String getColorchosen() {
        return colorchosen;
    } 

    public void setColorchosen(String colorchosen) {
        this.colorchosen = colorchosen;
    }
        
    
    private final SelectItem[] colorb;
    private String colorbchosen = "NULL";
    
    public SelectItem[] getColorb() {
        return colorb;
    }
    
    public String getColorbchosen() {
        return colorbchosen;
    } 

    public void setColorbchosen(String colorbchosen) {
        this.colorbchosen = colorbchosen;
    }

    
    private String filerareresult = "Rarefaction.csv";
    private String filerareresultpath = "<a target='_blank' href = \"/MetaboAnalyst/resources/users/" + usrName + File.separator + filerareresult + "\">" + filerareresult + "</a>";
    
    public String getFilerareresultpath() {
        return filerareresultpath;
    }

    public void setFilerareresultpath(String filerareresultpath) {
        this.filerareresultpath = filerareresultpath;
    }
    
    public RarefactionBean() {
        type = new SelectItem[3];
        type[0] = new SelectItem("NULL", "Species richness");
        type[1] = new SelectItem("Random rarefaction", "Random rarefaction");
        type[2] = new SelectItem("Probability", "Probability");
        
        color = new SelectItem[4];
        color[0] = new SelectItem("NULL", "Default");
        color[1] = new SelectItem("rainbow", "Rainbow");
        color[2] = new SelectItem("heat", "Heat");
        color[3] = new SelectItem("cm", "Cm");
        
//        margin = new SelectItem[2];
//        margin[0] = new SelectItem("NULL", "1");
//        margin[1] = new SelectItem("2", "2");
        
        colorb = new SelectItem[4];
        colorb[0] = new SelectItem("NULL", "Black");
        colorb[1] = new SelectItem("gray", "Gray");
        colorb[2] = new SelectItem("blue", "Blue");
        colorb[3] = new SelectItem("red", "Red");
    }
    
//    public RarefactionBean() {
//        color = new SelectItem[4];
//        color[0] = new SelectItem("NULL", "Rainbow");
//        color[1] = new SelectItem("Viridis", "Viridis");
//        color[2] = new SelectItem("Plasma", "Plasma");
//        color[3] = new SelectItem("manul", colortext);
//    }
    
//    public RarefactionBean() {
//        margin = new SelectItem[2];
//        margin[0] = new SelectItem("NULL", "1");
//        margin[1] = new SelectItem("2", "2");
//    }
    
    // ACTION BUTTON // 
    public void rareCurveUpdate_action() {
        DiversityUtils.CreateRarefactionDiv(sb, doOriginal, typechosen, sample, doSe);       
        DiversityUtils.PlotRarefactionCurveDiversity(sb, step, colorchosen, sb.getNewImage("Rarefaction_Curve_Plot"), "png", 72, "false");
    }
    
    public void rareScatterUpdate_action() {
        DiversityUtils.CreateRarefactionDiv(sb, doOriginal, typechosen, sample, doSe);       
        DiversityUtils.PlotRarefactionPlotDiversity(sb, colorbchosen, sb.getNewImage("Rarefaction_Linear_Plot"), "png", 72, "false");
    }
    
    
}