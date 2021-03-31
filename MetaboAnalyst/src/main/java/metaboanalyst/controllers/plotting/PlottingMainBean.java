/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package metaboanalyst.controllers.plotting;

import metaboanalyst.controllers.SessionBean1;
import metaboanalyst.rwrappers.ChemoMetrics;
import metaboanalyst.rwrappers.Classifying;
import metaboanalyst.rwrappers.Clustering;
import metaboanalyst.rwrappers.Dispersal;
import metaboanalyst.rwrappers.Ordiantion;
import metaboanalyst.rwrappers.RCenter;
import metaboanalyst.rwrappers.RDataUtils;
import metaboanalyst.rwrappers.SigVarSelect;
import metaboanalyst.rwrappers.UniVarTests;
import metaboanalyst.rwrappers.PlottingUtils;
import metaboanalyst.utils.DataUtils;
import java.io.Serializable;
import javax.faces.bean.ManagedBean;
import javax.faces.context.FacesContext;
import org.primefaces.context.RequestContext;
/**
 *
 * @author leif
 */
// All functions being called from plotting.r via PlottingUtils.java
@ManagedBean(name = "plottingMainBean")
public class PlottingMainBean implements Serializable {
    private final SessionBean1 sb = (SessionBean1) DataUtils.findBean("sessionBean1");
    
    public void performDefaultAnalysis(String pageID) {
        System.out.print(" Currently printing at performDefaultAnalysis");
        System.out.print(sb);
        if (!sb.isAnalInit(pageID)) {
            if (!FacesContext.getCurrentInstance().isPostback()) {
                System.out.print(" pageID");

                //sb.registerPage(pageID);
                switch (pageID) {
                    case "plotting":
                        doDefaultLinear();
                        
                        break;
                        
                    case "linear":
                        doDefaultLinear();
                        break;
                    case "boxplot":
                        
                        break;
                    case "bargraph":
                        doDefaultBetaDisper();
                        break;
                }
            }
        }
    }

    private void doDefaultLinear(){       
        PlottingUtils.PlotlinearGraph(sb, sb.getCurrentImage("lin"), "png", 72, 
                "p", 1, "black", 1, 19, "x axis", "y axis", "Linear Plot Title", "NULL", "NULL");     
    }
    
    
    
    
    private void doDefaultBetaDisper() {       
        
        Dispersal.InitBetaDisper(sb);
        Dispersal.PlotBetaDisper(sb, sb.getNewImage("betadisper"), "png", 72, dispersalBgdNum);
        
    }
    
    private int dispersalBgdNum = 5;

    public int getDispersalBgdNum() {
        return dispersalBgdNum;
    }

    public void setDispersalBgdNum(int dispersalBgdNum) {
        this.dispersalBgdNum = dispersalBgdNum;
    } 
//    public String dispersalBgdBtn_action() {
//        Dispersal.PlotBGD(sb, sb.getNewImage("bgd"), "png", 72, dispersalBgdNum);
//        RequestContext.getCurrentInstance().scrollTo("ac:form2:screePane");
//        return null;
//    }
//    

    public String dispersalBealsBtn_action() {
          System.out.print("dispersalBeals button action  -dispersalBean");
//        Dispersal.PlotBealsSummary
//        ChemoMetrics.PlotPCAPairSummary(sb, sb.getNewImage("pca_pair"), "png", 72, dispersalBgdNum);
//        RequestContext.getCurrentInstance().scrollTo("ac:form1:pairPane");
        return null;
    }
    
    
    
}

