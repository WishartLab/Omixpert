#'Perform taxonomic diversity or distinctness indices calculation
#'@description Perform taxonomic diversity or distinctness indices calculation
#'@param mSetObj Input name of the created mSet Object
#'@param data Boolean for which data set to use, normalized (default) or original
#'@param dis Set dissimilarity index, drop down options are "taxa2dist" (default), "euclidean", "manhattan", "binary", or "minkowski"
#'@param match.force Boolean force matching of column names in comm and labels in dis, options are "TRUE" or "FALSE" (default).
#'@param varstep Boolean vary step lengths between successive levels relative to proportional loss of the number of distinct classes, drop down options are "TRUE" or "FALSE" (default). 
#'@param aggme the agglomeration method, drop down options "ward.D", "ward.D2", "single", "complete", "average" (= UPGMA) (default), "mcquitty" (= WPGMA), "median" (= WPGMC) or "centroid" (= UPGMC)
#'@param check Boolean if TRUE, remove all redundant levels which are different for all rows or constant for all rows and regard each row as a different basal taxon (species). If FALSE (default) all levels are retained and basal taxa (species) also must be coded as variables (columns)
#'@author Shiyang Zhao\email{shiyang1@ualberta.ca}
#'University of Alberta, Canada
#'License: GNU GPL (>= 2) ######
#'@export


Taxonomic_div <- function(mSetObj = NA, data = "false", dis = "NULL", match.force = "false", varstep = "false", aggme = "NULL", check = "false") {

  options(errors = traceback)
  
  #library("ade4")
  #library("adegraphics")
  #library(plyr)
  #library(dplyr)
  #library(vegan)
  print("taxonomic")  

  mSetObj <- .get.mSet(mSetObj)

  #data(dune)
  #data(dune.taxon)
  
  #mSetObj$dataSet$norm <- dune
  #mSetObj$dataSet$origMeta <- dune.taxon

  #Extract input from mSetObj
  if (data == "false") { #normalized data as input
    input <- mSetObj$dataSet$norm
  } else { #original data as input
    input <- mSetObj$dataSet$orig
  }

  metaData <- mSetObj$dataSet$origMeta
  #envData <- mSetObj$dataSet$origEnv
  
  #print(metaData)
  #print(input)  
  #input.1 <- t(input)
  #print(input.1)

  cat("Species data has to be numeric")
  input.2 <- select_if(input, is.numeric)
  #input.2 <- as.matrix(input.1)
  #print(input.2)


  #if (match.force == "false") { 
  #  match.force1 = FALSE
  #} else {
  #  match.force1 = TRUE
  #}
  #print(match.force1)  
  match.force1 = TRUE
  print(match.force1)

  if (varstep == "false") {
    varstep1 = FALSE
  } else {
    varstep1 = TRUE
  }
  print(varstep1)
  
  if (check == "false") {
    check1 = FALSE
  } else {
    check1 = TRUE
  }
  print(check1)

  taxdis <- taxa2dist(metaData, varstep = varstep1, check = TRUE)
  #print(taxdis)
  print("taxdis ready")  

  if (dis == "NULL") {
    dis1 = taxdis
  } else if (dis == "euclidean") {
    dis1 = dist(input.2, method = "euclidean")
  } else if (dis == "maximum") {
    dis1 = dist(input.2, method = "maximum")
  } else if (dis == "manhattan") {
    dis1 = dist(input.2, method = "manhattan")
  } else if (dis == "canberra") {
    dis1 = dist(input.2, method = "canberra")
  } else if (dis == "binary") {
    dis1 = dist(input.2, method = "binary")
  } else if (dis == "minkowski") {
    dis1 = dist(input.2, method = "minkowski")
  }
  print(dis1)
  
  if (aggme == "NULL") {
    aggme1 <- "average"
  } else if (aggme == "ward.D") {
    aggme1 <- "ward.D"
  } else if (aggme == "ward.D2") {
    aggme1 <- "ward.D2"
  } else if (aggme == "single") {
    aggme1 <- "single"
  } else if (aggme == "complete") {
    aggme1 <- "complete"
  } else if (aggme == "mcquitty") {
    aggme1 <- "median"
  } else if (aggme == "centroid") {
    aggme1 <- "centroid"
  }
  print(aggme1)

  tr <- hclust(taxdis, method = aggme1)
  print(tr)
  print("after tr")
  abbbb <- vegdist(input.2)
  print(abbbb)
  plottree <- hclust(vegdist(input.2)) #, method = aggme1
  print("aggme1")
  print(aggme1)
  print("plottree")

  taxon <- taxondive(input.2, dis1, match.force = match.force1)
  print("taxon")
  summary.taxon <- summary(taxon)
  print("summary.taxon")
  print("after summary taxon")

  #dtree <- treedist(input.2, tr)
  #print("dtree")
  #print("after dtree")
  #mod <- treedive(input.2, tr)
  #print(mod)
  #print("after mod")
  
  taxontree <- hclust(taxdis)
  print("plottree")  

  mSetObj$analset$taxa2dist$name <- "Distance"
  mSetObj$analset$taxa2dist$taxdis <- taxdis
  mSetObj$analset$taxa2dist$dist <- as.data.frame(as.matrix(mSetObj$analset$taxa2dist$taxdis))
  
  mSetObj$analset$result <- taxon
  print("taxon.result")  

  mSetObj$analset$taxondive$name <- "Indices of Taxonomic Diversity and Distinctness"
  if (dis == "NULL") {
  mSetObj$analset$taxondive$Distance <- "classification table"
  } else {
  mSetObj$analset$taxondive$Distance <- dis1
  }
  print("if dis")

  mSetObj$analset$taxondive$Delta <- summary.taxon[,1]
  mSetObj$analset$taxondive$'Delta*' <- summary.taxon[,2]
  mSetObj$analset$taxondive$'Delta+' <- summary.taxon[,3]
  mSetObj$analset$taxondive$'sd(Delta+)' <- summary.taxon[,4]
  mSetObj$analset$taxondive$'z(Delta+)' <- summary.taxon[,5]
  mSetObj$analset$taxondive$'Pr(>|z|)' <- summary.taxon[,6]
  
  mSetObj$analset$taxondive <- as.data.frame(mSetObj$analset$taxondive)
  names(mSetObj$analset$taxondive) <- c("Name", "Distance", "Delta", "Delta+", "Delta*", 
                                        "sd(Delta+)", "z(Delta+)", "pr(>|z|)")
  #  select(name, Distance, Delta, `Delta*`, `Delta+`, `sd(Delta+)`, `z(Delta+)`, `Pr(>|z|)`)
  print("summary.taxon")

  #mSetObj$analset$treedive <- mod
  #mSetObj$analset$dtree <- as.data.frame(as.matrix(dtree))
  mSetObj$analset$c1 <- tr
  mSetObj$analset$input.2 <- input.2
  mSetObj$analset$plottree <- plottree
  mSetObj$analset$taxontree <- taxontree
  print("read to write csv")  

  write.csv(as.data.frame(mSetObj$analset$taxa2dist$dist), "Taxanomy Distance.csv")
  write.csv(as.data.frame(mSetObj$analset$taxondive), "Taxanomy Indices.csv")
  write.csv(as.data.frame(mSetObj$analset$dtree), "Dissimilarities among trees.csv")
  write.csv(as.data.frame(mSetObj$analset$treedive), "Community Matrix.csv")
  print("wrote csv")  

  return(.set.mSet(mSetObj)) 
  
}  


#'Produce a taxa cluster tree graph 
#'@description Produce a taxa cluster tree graph
#'@param mSetObj Input name of the created mSet Object
#'@param color options include "gray" & "black"(default), "skyblue" & "blue", "hotpink" & "red"
#'@param imgName Input the image name
#'@param format Select the image format, "png" or "pdf", default is "png" 
#'@param dpi Input the dpi. If the image format is "pdf", users need not define the dpi. For "png" images, 
#'the default dpi is 72. It is suggested that for high-resolution images, select a dpi of 300.  
#'@param width Input the width, there are 2 default widths. The first, width=NULL, is 10.5.
#'The second default is width=0, where the width is 7.2. Otherwise users can input their own width
#'@author Shiyang Zhao\email{shiyang1@ualberta.ca}
#'University of Alberta, Canada
#'License: GNU GPL (>= 2)
#'@export

taxa_tree <- function(mSetObj = NA, color = "NULL", imgName, format = "png", dpi = 72, width = NA) {
  
  options(errors = traceback)

  #library(vegan)
  #library(ggplot2)
  #library(ggdendro) not availble for this version of R
  #library(Cairo)
  
  mSetObj <- .get.mSet(mSetObj)
  
  print("get plot_data")
  plot_data <- mSetObj$analset$taxa2dist$taxdis
  print(plot_data)  

  
  if(is.na(width)){
    w <- 10.5
  } else if(width==0){
    w <- 7.2
  } else{
    w <- width
  }
  h <- w
  print("width")  

  #Name plot for download
  imgName <- paste(imgName, "dpi", dpi, ".", format, sep="")
  mSetObj$imgSet$Taxa_Tree_Plot <- imgName
  
  Cairo::Cairo(file=imgName, unit="in", dpi=dpi, width=w, height=h, type=format, bg="white")
  par(xpd=FALSE, mar=c(5.1, 4.1, 4.1, 2.1))
  #abline(0, 1)
  
  if(color=="NULL") { 
    color1 <- c("gray", "black") 
  } else if (color== "blue") { 
    color1 <- c("skyblue", "blue")
  } else if (color == "red") { 
    color1 <- c("hotpink", "red") 
  }
  print(color1)  

  pars <- expand.grid(col = color1, stringsAsFactors = FALSE)
  
  hcd <- as.dendrogram(hclust(plot_data))
  nodePar <- list(lab.cex = 0.6, pch = c(NA, 19), cex = 0.7, col = "blue")
  print("ready to plot")  
 
  plot(hcd, hang = -1, nodePar = nodePar, ylab = "Height", edgePar = list(col = color1, lwd = 2:1), las = 2)
  title(main = "Dendrogram of study species based on taxonomic diversity matrix")
  #title("")
  dev.off()
  return(.set.mSet(mSetObj))
}

#'Produce a scatter graph comparing taxonomic diversity vs. species richness 
#'@description Produce a graph comparing taxonomic diversity vs. species richness
#'@param mSetObj Input name of the created mSet Object
#'@param colorc options include "black"(default), "blue", "red"
#'@param imgName Input the image name
#'@param format Select the image format, "png" or "pdf", default is "png" 
#'@param dpi Input the dpi. If the image format is "pdf", users need not define the dpi. For "png" images, 
#'the default dpi is 72. It is suggested that for high-resolution images, select a dpi of 300.  
#'@param width Input the width, there are 2 default widths. The first, width=NULL, is 10.5.
#'The second default is width=0, where the width is 7.2. Otherwise users can input their own width
#'@author Shiyang Zhao\email{shiyang1@ualberta.ca}
#'University of Alberta, Canada
#'License: GNU GPL (>= 2)
#'@export

taxon_scatter <- function(mSetObj=NA, plot_data = "NULL", colorc="NULL", imgName, format="png", dpi=72, width=NA) {
  #library(vegan)
  #library(ggplot2)
  #library(ggdendro) not availble for this version of R
  #library(Cairo)
  
  mSetObj <- .get.mSet(mSetObj)
  print("start scatter plot")
  scatter_data <- mSetObj$analset$result
  print(scatter_data)

  #Set plot dimensions
  if(is.na(width)){
    w <- 10.5
  } else if(width==0){
    w <- 7.2
  } else{
    w <- width
  }
  h <- w
  print("scatter h/w setup")  

  #Name plot for download
  imgName <- paste(imgName, "dpi", dpi, ".", format, sep="")
  mSetObj$imgSet$Taxa_Scatter_Plot <- imgName
  
  Cairo::Cairo(file=imgName, unit="in", dpi=dpi, width=w, height=h, type=format, bg="white")
  par(xpd=FALSE, mar=c(5, 6.1, 4.1, 2.1))
  #abline(0, 1)
  
  if(colorc == "NULL") { 
    colorc1 <- c("black") 
  } else if (colorc == "blue") { 
    colorc1 <- c("blue")
  } else if (colorc == "red") { 
    colorc1 <- c("red") 
  }
  print(colorc1)  
  #b <- as.numeric(scatter_data$Dplus)
  #print(b)
  #print("just to show the next argument is n")

  #pars <- expand.grid(col = colorc1, stringsAsFactors = FALSE)
  #par(mar=c(5,6,4,1)+.1)

  #windows(width = 20, height = 20)
  #b[ , apply(b, 2, function(x) !any(is.na(x)))]

  #c <- max(b, na.rm = TRUE)
  #c <- select_if(b, !is.na)
  #n <- c + 10
  #max(b)
  #print(max(b))
  #print(n)
  #m <- max(scatter_data$Species)
  #print(m) 
  #plot(scatter_data) labels = T, xaxt = "n", yaxt = "n",
  #plot(scatter_data, ann = F, axes = F, col = colorc1, pch = 1, cex.lab = 1.2)
  #axis(1, labels  = T, at = 0:m, cex.axis = 1, xlab = "Number of Species")
  #axis(2, las = 2, at = seq(0, n, by = 10), labels = T, ylab = "Delta Plus", cex.axis = 1)
  #mtext("Delta+", at = (6, 70))
  #xlab = "Number of Species", 

  m <- max(scatter_data$Species)
  m1 <- min(scatter_data$Species)
  if (m1 > 2) {
    mR = m1 - 2
  } else if (m1 <= 2) {
    mR = 0
  }
  print(mR)

  if (plot_data == "NULL") {
    b <- as.numeric(scatter_data$Dplus)
    mod <- scatter_data
    ylab1 <- "Delta+"
  } else if (plot_data == "Delta") {
    b <- as.numeric(scatter_data$D)
    mod <- scatter_data$D
    ylab1 <- "Delta"
  } else if (plot_data == "Delta*") {
    b <- as.numeric(scatter_data$Dstar)
    mod <- scatter_data$Dstar
    ylab1 <- "Delta*"
  } else if (plot_data == "Lambda+") {
    b <- as.numeric(scatter_data$Lambda)
    mod <- scatter_data$Lambda
    ylab1 <- "Lambda+"
  } 
  #b <- as.numeric(scatter_data$Dplus)
  c <- max(b, na.rm = TRUE)
  maxc = round(c, digits = -1)
  n <- maxc + 10
  print(n)
  b1 <- as.numeric(scatter_data$Dplus)
  c1 <- min(b1, na.rm = T)
  if (c1 > 10) {
    cR = c1 - 10
  } else if (c1 <= 10) {
    cR = 0
  }
  cR1 <- round(cR, digits = -1)
  print(cR1)

  if (n >= 5000) {
    by1 <- 1000 
  } else if (n >= 1000 & n < 5000) {
    by1 <- 500
  } else if (n < 1000 & n >= 500) {
    by1 <- 100
  } else if (n < 500 & n > 150) {
    by1 <- 50
  } else if (n <150 & n >= 30) {
    by1 <- 10
  } else if (n < 30) {
    by1 <- 1
  } 

  plot(mod, ann = F, xaxt = "n", yaxt = "n", col = colorc1, pch = 19, cex.lab = 1.2, ylim = c(cR1, n), xlim = c(mR, m))
  axis(1, labels  = T, at = mR:m, cex.axis = 1)
  axis(2, las = 2, at = seq(cR1, n, by = by1), labels = T, cex.axis = 1)
  title(xlab = "Number of Species")
  title(ylab = ylab1)
  title(main = "Average taxonomic distinctness against number of species")
  #text(mod, labels=rownames(scatter_data),data=mod, cex=0.9, font=2)

  dev.off() 
  
  return(.set.mSet(mSetObj)) 
}

#'Produce a taxonomic heatmap 
#'@description Produce a graph comparing taxonomic diversity vs. species richness
#'@param mSetObj Input name of the created mSet Object
#'@param colord options include "cm.colors(256)"(default), "rainbow(256)", "brewer.pal(8)"
#'@param imgName Input the image name
#'@param format Select the image format, "png" or "pdf", default is "png" 
#'@param dpi Input the dpi. If the image format is "pdf", users need not define the dpi. For "png" images, 
#'the default dpi is 72. It is suggested that for high-resolution images, select a dpi of 300.  
#'@param width Input the width, there are 2 default widths. The first, width=NULL, is 10.5.
#'The second default is width=0, where the width is 7.2. Otherwise users can input their own width
#'@author Shiyang Zhao\email{shiyang1@ualberta.ca}
#'University of Alberta, Canada
#'License: GNU GPL (>= 2)
#'@export

taxon_heatmap <- function(mSetObj=NA, colord="NULL", imgName, format="png", dpi=72, width=NA) {
  #library(vegan)
  #library(ggplot2)
  #library(ggdendro) not availble for this version of R
  #library(Cairo)
  
  mSetObj <- .get.mSet(mSetObj)
  
  input.plot <- mSetObj$analset$input.2
  taxontree <- mSetObj$analset$taxontree
  plottree <- mSetObj$analset$plottree
  print("get ready for heatmap")  

  #Set plot dimensions
  if(is.na(width)){
    w <- 10.5
  } else if(width==0){
    w <- 7.2
  } else{
    w <- width
  }
  h <- w
  print("heatmap h/w setup")

  #Name plot for download
  imgName <- paste(imgName, "dpi", dpi, ".", format, sep="")
  mSetObj$imgSet$Taxa_Heatmap_Plot <- imgName
  
  Cairo::Cairo(file=imgName, unit="in", dpi=dpi, width=w, height=h, type=format, bg="white")
  par(xpd=FALSE, mar=c(5.1, 4.1, 4.1, 2.1))
  #abline(0, 1)
 
  if(colord == "NULL") { 
    colord1 <- cm.colors(256)
  } else if (colord == "rainbow") { 
    colord1 <- rainbow(256)
  } else if (colord == "brewer") { 
    colord1 <- brewer.pal(8)
  }  
  print("colord1 is ready")
  pars <- expand.grid(col = colord1, stringsAsFactors = FALSE)
  
  #windows(width = 20, height = 20)
  tabasco(input.plot, plottree, sp.ind = taxontree, col = colord1)
  
  
  dev.off()
  
  return(.set.mSet(mSetObj))
}






