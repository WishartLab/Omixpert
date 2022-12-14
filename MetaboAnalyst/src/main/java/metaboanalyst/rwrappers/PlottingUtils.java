/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package metaboanalyst.rwrappers;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import metaboanalyst.controllers.SessionBean1;
import org.rosuda.REngine.Rserve.RConnection;
import org.rosuda.REngine.Rserve.RserveException;

import javax.faces.model.SelectItem;
import metaboanalyst.rwrappers.RDataUtils;
import org.primefaces.model.chart.Axis;
import org.primefaces.model.chart.AxisType;
import org.primefaces.model.chart.LineChartModel;
import org.primefaces.model.chart.LineChartSeries;
import org.rosuda.REngine.REXPMismatchException;


public class PlottingUtils {
    
    
    public static void PlotlinearGraph(SessionBean1 sb, String imgName, String format, int dpi, String type, int numlines,
            String colors, int weights, int pchs, String xlab, String ylab, String title, String facA, String facB) {
        try {
            // Calling function from plotting.r
            RConnection RC = sb.getRConnection();
            String rCommand = "plotLinearFunction(NA" + ", \"" + imgName + "\", \"" + format + "\", "
                    + dpi + ", width=NA, \"" + type + "\", \"" + numlines + "\", \"" + colors + "\", \"" + weights + "\", \""  + pchs + "\", \"" 
                    + xlab + "\", \""  + ylab + "\", \""  + title + "\", \""  + facA + "\", \""  + facB + "\")";
            RCenter.recordRCommand(RC, rCommand);
            
            sb.addGraphicsCMD("lin", rCommand);
            
            
            RC.voidEval(rCommand);
            
            
        } catch (RserveException rse) {
            System.out.println(rse);
        }
    } 

    public static void CreatePieChart(SessionBean1 sb, Boolean byRow, Boolean bySum, int columns, String rows, String labels, String colors, String mainTitle, Boolean lgnd) {
        try {
            RConnection RC = sb.getRConnection();
            String rCommand = "pieChart_setup(NA"
                                                + ", \"" + byRow
                                                + "\", \"" + bySum
                                                + "\", " + columns
                                                + ", \"" + rows
                                                + "\", \"" + labels
                                                + "\", \"" + colors
                                                + "\", \"" + mainTitle
                                                + "\", \"" + lgnd
                                                + "\")";
            RCenter.recordRCommand(RC, rCommand);
            RC.voidEval(rCommand);
        } catch (RserveException rse) {
            System.out.println(rse);
        }
    }   

    public static void PlotPieChart(SessionBean1 sb, String imgName, String format, int dpi) {
        try {
            RConnection RC = sb.getRConnection();
            String rCommand = "plotPieChart(NA" + ", \"" + imgName + "\", \"" + format + "\", " + dpi + ", width=NA)";
            RCenter.recordRCommand(RC, rCommand);
            RC.voidEval(rCommand);
        } catch (RserveException rse) {
            System.out.println(rse);
        }
    }

    public static void CreateBarChart(SessionBean1 sb, String byRow, String colNum, String rowNum, String color, String xLab, String yLab, String barLabels, String mainTitle) {
        try {
            RConnection RC = sb.getRConnection();
            String rCommand = "barGraph_setup(NA"
                                                + ", \"" + byRow
                                                + "\", \"" + colNum
                                                + "\", \"" + rowNum
                                                + "\", \"" + color
                                                + "\", \"" + xLab
                                                + "\", \"" + yLab
                                                + "\", \"" + barLabels
                                                + "\", \"" + mainTitle + "\")";
            RCenter.recordRCommand(RC, rCommand);
            RC.voidEval(rCommand);
        } catch (RserveException rse) {
            System.out.println(rse);
        }
    }   
    
    public static void PlotBarChart(SessionBean1 sb, String imgName, String format, int dpi) {
        try {
            RConnection RC = sb.getRConnection();
            String rCommand = "plotBarGraph(NA" + ", \"" + imgName + "\", \"" + format + "\", " + dpi + ", width=NA)";
            RCenter.recordRCommand(RC, rCommand);
            RC.voidEval(rCommand);
        } catch (RserveException rse) {
            System.out.println(rse);
        }
    }
    
    
    
    public static boolean CreateBoxPlot(SessionBean1 sb, String facA, String facB, String facC, String fillColor ,
                          String xlab, String ylab, String legendTitle, String mainTitle, Boolean data) {
        try {
            RConnection RC = sb.getRConnection();
            String rCommand = "boxPlot_setup(NA"
                                                + ", \"" + facA
                                                + "\", \"" + facB
                                                + "\", \"" + facC
                                                + "\", \"" + fillColor
                                                + "\", \"" + xlab
                                                + "\", \"" + ylab
                                                + "\", \"" + legendTitle
                                                + "\", \"" + mainTitle
                                                + "\", \"" + data + "\")";
            
            
            RCenter.recordRCommand(RC, rCommand);
            RC.voidEval(rCommand);
            return true;
        } catch (RserveException rse) {
            System.out.println(rse);
            return false;
        }
    }   
    
    public static void PlotBoxPlot(SessionBean1 sb, String imgName, String format, int dpi) {
        try {
            RConnection RC = sb.getRConnection();
            String rCommand = "plotBoxPlot(NA" + ", \"" + imgName + "\", \"" + format + "\", " + dpi + ", width=NA)";
            RCenter.recordRCommand(RC, rCommand);
            sb.addGraphicsCMD("boxplot", rCommand);
            RC.voidEval(rCommand);
        } catch (RserveException rse) {
            System.out.println(rse);
        }
    }
    
     public static void CreateScatterChart(SessionBean1 sb) {
        try {
            RConnection RC = sb.getRConnection();
            String rCommand = "scatterPlot_setup(NA)";
            RCenter.recordRCommand(RC, rCommand);
            RC.voidEval(rCommand);
        } catch (RserveException rse) {
            System.out.println(rse);
        }
    }   
    
    public static void PlotScatterChart(SessionBean1 sb, String imgName, String format, int dpi) {
        try {
            RConnection RC = sb.getRConnection();
            String rCommand = "plotScatterPlot(NA" + ", \"" + imgName + "\", \"" + format + "\", " + dpi + ", width=NA)";
            RCenter.recordRCommand(RC, rCommand);
            RC.voidEval(rCommand);
        } catch (RserveException rse) {
            System.out.println(rse);
        }
    }   
    
    
    
    // linear get data colums n
    public static String[] GetDataColumns(SessionBean1 sb){
        try {
            RConnection RC = sb.getRConnection();
            String rCommand = "lin.reg.columns(NA)";
            RCenter.recordRCommand(RC, rCommand);
            return RC.eval(rCommand).asStrings();
        } catch (RserveException rse) {
            System.out.println(rse);
        } catch (REXPMismatchException ex) {
            Logger.getLogger(CAUtils.class.getName()).log(Level.SEVERE, null, ex);   /* Currently using CAUtils ..... Need to channnnne to PlottingUtils    */ 
        }
        return null;
    }
    
    public static String[] GetDataColumnsBoxPlt(SessionBean1 sb){
        try {
            RConnection RC = sb.getRConnection();
            String rCommand = "all.columns(NA)";
            RCenter.recordRCommand(RC, rCommand);
            return RC.eval(rCommand).asStrings();
        } catch (RserveException rse) {
            System.out.println(rse);
        } catch (REXPMismatchException ex) {
            Logger.getLogger(CAUtils.class.getName()).log(Level.SEVERE, null, ex);   /* Currently using CAUtils ..... Need to channnnne to PlottingUtils    */ 
        }
        return null;
    }
    public static String[] GetFactorDataColumnsBoxPlt(SessionBean1 sb){
        try {
            RConnection RC = sb.getRConnection();
            String rCommand = "factor.columns(NA)";
            RCenter.recordRCommand(RC, rCommand);
            return RC.eval(rCommand).asStrings();
        } catch (RserveException rse) {
            System.out.println(rse);
        } catch (REXPMismatchException ex) {
            Logger.getLogger(CAUtils.class.getName()).log(Level.SEVERE, null, ex);   /* Currently using CAUtils ..... Need to channnnne to PlottingUtils    */ 
        }
        return null;
    }
    public static String[] GetNumericDataColumnsBoxPlt(SessionBean1 sb){
        try {
            RConnection RC = sb.getRConnection();
            String rCommand = "numeric.columns(NA)";
            RCenter.recordRCommand(RC, rCommand);
            return RC.eval(rCommand).asStrings();
        } catch (RserveException rse) {
            System.out.println(rse);
        } catch (REXPMismatchException ex) {
            Logger.getLogger(CAUtils.class.getName()).log(Level.SEVERE, null, ex);   /* Currently using CAUtils ..... Need to channnnne to PlottingUtils    */ 
        }
        return null;
    }
    
}
