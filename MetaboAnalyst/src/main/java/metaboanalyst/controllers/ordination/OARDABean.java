/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package metaboanalyst.controllers.ordination;

import java.io.File;
import java.io.Serializable;
import java.util.Arrays;
import java.util.List;
import javax.faces.bean.ManagedBean;
import javax.faces.model.SelectItem;
import metaboanalyst.controllers.DownloadBean;
import metaboanalyst.controllers.SessionBean1;
import metaboanalyst.models.User;
import metaboanalyst.rwrappers.OAUtils;

import metaboanalyst.utils.DataUtils;


@ManagedBean(name = "rdaBean")
public class OARDABean implements Serializable {

    private final SessionBean1 sb = (SessionBean1) DataUtils.findBean("sessionBean1");
    
    private User usr = sb.getCurrentUser();
    private String usrName = usr.getName();
    
//    private String fileNMA = "<a target='_blank' href = \"/MetaboAnalyst/resources/users/" + usrName + File.separator + "/rda_scree_data.csv>";
    private String fileScree = "rda_scree_data.csv";
    private String fileScreePath  = "<a target='_blank' href = \"/MetaboAnalyst/resources/users/" + usrName + File.separator + fileScree + "\">" + fileScree + "</a>";
    
    private String fileRowScore = "rda_row_scores.csv";
    private String fileRowScorePath  = "<a target='_blank' href = \"/MetaboAnalyst/resources/users/" + usrName + File.separator + fileRowScore + "\">" + fileRowScore + "</a>";
    
    private String fileEnvScore = "rda_environment_scores.csv";
    private String fileEnvScorePath  = "<a target='_blank' href = \"/MetaboAnalyst/resources/users/" + usrName + File.separator + fileEnvScore + "\">" + fileEnvScore + "</a>";
    
    private String fileColScore = "rda_column_scores.csv";
    private String fileColScorePath  = "<a target='_blank' href = \"/MetaboAnalyst/resources/users/" + usrName + File.separator + fileColScore + "\">" + fileColScore + "</a>";
    
    private boolean doOriginal = false; 
    private boolean doAbundance = false;
    
    private boolean varArrows = false; 
    private boolean sampleNames = false;
    private boolean pointStyle = false;
    
    private String groupCol = "null"; //Grpup color
    private String groupPoint = "null";
    private String color = "null";
    private boolean addEllipse = false;
    
    private String envDataCol = "null";
    private boolean envArrows = false;
    private boolean envCentroid = false;
    
    public String getFileScreePath() {
        return fileScreePath;
    }

    public void setFileScreePath(String fileScreePath) {
        this.fileScreePath = fileScreePath;
    }
    
    public String getFileRowScorePath() {
        return fileRowScorePath;
    }

    public void setFileRowScorePath(String fileRowScorePath) {
        this.fileRowScorePath = fileRowScorePath;
    }
    
    public String getFileEnvScorePath() {
        return fileEnvScorePath;
    }

    public void setFileEnvScorePath(String fileEnvScorePath) {
        this.fileEnvScorePath = fileEnvScorePath;
    }
    
    public String getfileColScorePath() {
        return fileColScorePath;
    }

    public void setFileColScorePath(String fileColScorePath) {
        this.fileColScorePath = fileColScorePath;
    }  
    
    public boolean isdoAbundance() {
        return doAbundance;
    }
    
    public void setdoAbundance(boolean doAbundance) {
        this.doAbundance = doAbundance;
    }
    
    public boolean isdoOriginal() {
        return doOriginal;
    }
    
    public void setdoOriginal(boolean doOriginal) {
        this.doOriginal = doOriginal;
    }
    
    public String getEnvDataCol() {
        return envDataCol;
    }

    public void setEnvDataCol(String envDataCol) {
        this.envDataCol = envDataCol;
    } 
    
    public boolean isVarArrows() {
        return varArrows;
    }
    
    public void setVarArrows(boolean varArrows) {
        this.varArrows = varArrows;
    }   
    
    public boolean isSampleNames() {
        return sampleNames;
    }
    
    public void setSampleNames(boolean sampleNames) {
        this.sampleNames = sampleNames;
    }
    public boolean isPointStyle() {
        return pointStyle;
    }
    
    public void setPointStyle(boolean pointStyle) {
        this.pointStyle = pointStyle;
    }
    
    public boolean isAddEllipse() {
        return addEllipse;
    }
    
    public void setAddEllipse(boolean addEllipse) {
        this.addEllipse = addEllipse;
    }
    
    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }  
    
    public boolean isEnvCentroid() {
        return envCentroid;
    }
    
    public void setEnvCentroid(boolean envCentroid) {
        this.envCentroid = envCentroid;
    }
    
    public boolean isEnvArrows() {
        return envArrows;
    }
    
    public void setEnvArrows(boolean envArrows) {
        this.envArrows = envArrows;
    }    
    public String getGroupPoint() {
        return groupPoint;
    }

    public void setGroupPoint(String groupPoint) {
        this.groupPoint = groupPoint;
    } 
    
    public String getGroupCol() {
        return groupCol;
    }

    public void setGroupCol(String groupCol) {
        this.groupCol = groupCol;
    }

    // ACTION BUTTONS //
    public void rdaUpdate_action() {
        OAUtils.CreateRDA(sb, doAbundance, envDataCol, doOriginal);
        OAUtils.PlotRDA2D(sb, color, varArrows, envArrows, envCentroid, sampleNames, groupCol, pointStyle, groupPoint, addEllipse, sb.getNewImage("ord_rda_2D"), "png", 72, "NULL");   
        OAUtils.PlotRDAScree(sb, sb.getNewImage("ord_rda_scree"), "png", 72, "NULL");
    }

    
}



