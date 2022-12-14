#'Clean the data matrix
#'@description Function used in higher functinos to clean data matrix
#'@param ndata Input the data to be cleaned
#'@export
#'
CleanDataMatrix <- function(ndata){
  # make sure no costant columns crop up
  varCol <- apply(data.frame(ndata), 2, var, na.rm=T); # getting an error of dim(X) must have a positive length, fixed by data.frame
  constCol <- (varCol == 0 | is.na(varCol));
  return(ndata[,!constCol, drop=FALSE]); # got an error of incorrect number of dimensions, added drop=FALSE to avoid vector conversion
}


#'BestNormalize
#'@description This function performs column-wise normalization using all methods and selects the "best" (ie highest SW p-value).
#'@usage Normalization(mSetObj, rowNorm)
#'@param mSetObj Input the name of the created mSetObj (see InitDataObjects)
#'@author Louisa Normington \email{normingt@ualberta.ca}
#'University of Alberta, Canada
#'@export
#'
BestNormalize <- function(mSetObj=NA){
 
  mSetObj <- .get.mSet(mSetObj);
  library(dplyr)
  
  if(is.null(mSetObj$dataSet[["procr"]])){
    data<-mSetObj$dataSet$preproc
  }else if(is.null(mSetObj$dataSet[["prenorm"]])){
    data<- mSetObj$dataSet$procr
  }else{
    data<-mSetObj$dataSet$prenorm
  }
   
  numData <- select_if(data, is.numeric)
  colNamesNum <- colnames(numData)
  rowNamesNum <- rownames(data)

  #QuantileNorm
  numDataQuantileNorm <- as.data.frame(QuantileNormalize(numData));
  colnames(numDataQuantileNorm) <- colNamesNum;
  rownames(numDataQuantileNorm) <- rowNamesNum;

  #SumNorm
  numDataSumNorm<-as.data.frame(apply(numData, 2, SumNorm));
  colnames(numDataSumNorm) <- colNamesNum;
  rownames(numDataSumNorm) <- rowNamesNum;

  #MedianNorm
  numDataMedianNorm<-as.data.frame(apply(numData, 2, MedianNorm));
  colnames(numDataMedianNorm) <- colNamesNum;
  rownames(numDataMedianNorm) <- rowNamesNum;

  #BoxNorm 
  if(sum(as.numeric(numData<=0)) > 0){
    numDataBoxNorm<-as.data.frame(apply(numData, 2, YeoNorm));
    numDataBoxNorm <- numDataBoxNorm[1:nrow(data),]
  } else {
    numDataBoxNorm<-as.data.frame(apply(numData, 2, BoxNorm));
  }
  colnames(numDataBoxNorm) <- colNamesNum;
  rownames(numDataBoxNorm) <- rowNamesNum;

  numDataNormList <- list(numData, numDataQuantileNorm, numDataSumNorm, numDataMedianNorm, numDataBoxNorm)
  normNames <- c("NULL", "QuantileNorm", "SumNorm", "MedianNorm", "BoxNorm")

  skewList <- list()
  skewMean <- list()
  for (i in 1:length(numDataNormList)) {
    skewList[[normNames[i]]] <- apply(numDataNormList[[i]], 2, skewTest)
    skewMean[[normNames[i]]] <- mean(skewList[[normNames[i]]])
  }   

  skewMean_unlist <- unlist(skewMean)
  bestNorm <- names(which.min(abs(skewMean_unlist)))
  print(bestNorm)
  mSetObj$dataSet$bestnorm <- bestNorm
  return(.set.mSet(mSetObj));
}



#Extract best normalization name
extractBestNorm <- function(mSetObj=NA) {
  mSetObj <- .get.mSet(mSetObj);
  bestNorm <- mSetObj$dataSet$bestnorm
  return(bestNorm);
}





#'AutoNormOptions
#'@description This function returns the list of radio button options for data normalization
#'@usage Normalization()
#'@author Louisa Normington \email{normingt@ualberta.ca}
#'University of Alberta, Canada
#'
AutoNormOptions <- function(){
  options <- c("NULL", "QuantileNorm", "SumNorm", "MedianNorm", "BoxNorm")
  return(options)
}
 

#'Normalization
#'@description This function performs row-wise normalization, transformation, and
#'scaling of your metabolomic data.
##'@usage Normalization(mSetObj, rowNorm, transNorm, scaleNorm, ref=NULL, ratio=FALSE, ratioNum=20) #I CHANGED THIS 
#'@usage Normalization(mSetObj, rowNorm, transNorm, scaleNorm)
#'@param mSetObj Input the name of the created mSetObj (see InitDataObjects)
#'@param rowNorm Select the option for row-wise normalization, "QuantileNorm" for Quantile Normalization,
#'"ProbNormT" for Probabilistic Quotient Normalization without using a reference sample,
#'"ProbNormF" for Probabilistic Quotient Normalization based on a reference sample,
#'"CompNorm" for Normalization by a reference feature,
#'"SumNorm" for Normalization to constant sum,
#'"MedianNorm" for Normalization to sample median, and
#'"SpecNorm" for Normalization by a sample-specific factor.
#'@param transNorm Select option to transform the data, "LogNorm" for Log Normalization,
#'and "CrNorm" for Cubic Root Transformation.
#'@param scaleNorm Select option for scaling the data, "MeanCenter" for Mean Centering,
#'"AutoNorm" for Autoscaling, "ParetoNorm" for Pareto Scaling, amd "RangeNorm" for Range Scaling.
#'@param ref Input the name of the reference sample or the reference feature, use " " around the name.  
#'@param ratio This option is only for biomarker analysis.
#'@param ratioNum Relevant only for biomarker analysis.  
#'@author Jeff Xia \email{jeff.xia@mcgill.ca}, Jasmine Chong
#'McGill University, Canada
#'@export
#'
Normalization <- function(mSetObj=NA, rowNorm, transNorm, scaleNorm, ref=NULL, ratio=FALSE, ratioNum=20){
 
  mSetObj <- .get.mSet(mSetObj);
  load_dplyr()

  if(is.null(mSetObj$dataSet[["procr"]])){
    data<-mSetObj$dataSet$preproc
  }else if(is.null(mSetObj$dataSet[["prenorm"]])){
    data<- mSetObj$dataSet$procr;
  }else{
    data<-mSetObj$dataSet$prenorm
  }
 
  numData <- select_if(data, is.numeric)
  colNamesNum <- colnames(numData)
  rowNamesNum <- rownames(numData)

  charData <- select_if(data, is.character)
  colNamesChar <- colnames(charData)

  if(is.null(mSetObj$dataSet[["prenorm.cls"]])){ # can be so for regression
    mSetObj$dataSet$prenorm.cls <- mSetObj$dataSet$proc.cls;
  }
 
  cls <- mSetObj$dataSet$prenorm.cls;
 
  # note, setup time factor
  if(substring(mSetObj$dataSet$format,4,5)=="ts"){
    if(exists('prenorm.facA', where = mSetObj$dataSet)){
      nfacA <- mSetObj$dataSet$prenorm.facA;
      nfacB <- mSetObj$dataSet$prenorm.facB;
    }else{
      nfacA <- mSetObj$dataSet$facA;
      nfacB <- mSetObj$dataSet$facB;
    }
   
    mSetObj$dataSet$facA <- nfacA;
    mSetObj$dataSet$facB <- nfacB;
    if(mSetObj$dataSet$design.type =="time" | mSetObj$dataSet$design.type =="time0"){
      # determine time factor and should order first by subject then by each time points
      if(tolower(mSetObj$dataSet$facA.lbl) == "time"){
        time.fac <- nfacA;
        exp.fac <- nfacB;
      }else{
        time.fac <- nfacB;
        exp.fac <- nfacA;
      }
      mSetObj$dataSet$time.fac <- time.fac;
      mSetObj$dataSet$exp.fac <- exp.fac;
    }
  }
 
  # row-wise normalization #CHANGED TO COLUMN-WISE NORMALIZATION FOR WEGAN
  if(rowNorm=="QuantileNorm"){
    numData<-QuantileNormalize(numData);
    # this can introduce constant variables if a variable is
    # at the same rank across all samples (replaced by its average across all)
    #varCol <- apply(numData, 2, var, na.rm=T); #I REMOVED THIS
    #constCol <- (varCol == 0 | is.na(varCol));
    #constNum <- sum(constCol, na.rm=T);
    #if(constNum > 0){
    #  print(paste("After quantile normalization", constNum, "features with a constant value were found and deleted."));
    #  numData <- numData[,!constCol];
    #  colNames <- colnames(numData);
    #  rowNames <- rownames(numData);
    #}
    rownm<-"Quantile Normalization";
  }else if(rowNorm=="GroupPQN"){
    grp.inx <- cls == ref;
    ref.smpl <- apply(numData[grp.inx, ], 2, mean);
    numData<-t(apply(numData, 1, ProbNorm, ref.smpl));
    rownm<-"Probabilistic Quotient Normalization by a reference group";
  }else if(rowNorm=="SamplePQN"){
    ref.smpl <- numData[ref,];
    numData<-t(apply(numData, 1, ProbNorm, ref.smpl));
    rownm<-"Probabilistic Quotient Normalization by a reference sample";
  }else if(rowNorm=="CompNorm"){
    numData<-apply(numData, 2, CompNorm, ref);
    rownm<-"Normalization by a reference variable";
  }else if(rowNorm=="SumNorm"){
    numData<-apply(numData, 2, SumNorm);
    rownm<-"Normalization to constant sum";
  }else if(rowNorm=="MedianNorm"){
    numData<-apply(numData, 2, MedianNorm);
    rownm<-"Normalization to sample median";
  } else if(rowNorm=="BoxNorm"){ #I ADDED THIS
    if(sum(as.numeric(numData<=0)) > 0){
      numData<-as.data.frame(apply(numData, 2, YeoNorm));
      numData <- numData[1:nrow(data),]
    } else {
      numData<-as.data.frame(apply(numData, 2, BoxNorm));
    }
    rownm<-"Box-Cox Normalization";
  }else if(rowNorm=="SpecNorm"){
    if(!exists("norm.vec")){
      norm.vec <- rep(1,nrow(numData)); # default all same weight vec to prevent error
      print("No sample specific information were given, all set to 1.0");
    }
    rownm<-"Normalization by sample-specific factor";
    numData<-numData/norm.vec;
  }else if(rowNorm=='LogNorm'){
      #min.val <- min(abs(numData[numData!=0]))/10; #I REMOVED THIS TO REPLACE WITH LOG10
      #numData<-apply(numData, 2, LogNorm, min.val);
      numData <- apply(numData, 2, log10)
      rownm<-"Log Normalization";
    }else if(rowNorm=='SqNorm'){
      numData <- numData^(1/2);
      rownm<-"Square Root Transformation";
    }else if(rowNorm=='CrNorm'){
      numData <- numData^(1/3);
      #norm.data <- abs(numData)^(1/3); #I REMOVED THIS
      #norm.data[numData<0] <- - norm.data[numData<0];
      #numData <- norm.data;
      rownm<-"Cubic Root Transformation";
    }else{
    # nothing to do
    rownm<-"N/A";
  }
 
  # use apply will lose dimesion info (i.e. row names and colnames)
  rownames(numData)<-rowNamesNum;
  colnames(numData)<-colNamesNum;
 
  # note: row-normed numData is based on biological knowledge, since the previous
  # replacing zero/missing values by half of the min positive (a constant)
  # now may become different due to different norm factor, which is artificial
  # variance and should be corrected again
  #
  # stopped, this step cause troubles
  # minConc<-round(min(data)/2, 5);
  # data[dataSet$fill.inx]<-minConc;
 
  # if the reference by feature, the feature column should be removed, since it is all 1
  if(rowNorm=="CompNorm" && !is.null(ref)){
    inx<-match(ref, colnames(data));
    data<-data[,-inx];
    colNames <- colNames[-inx];
  }
 
  # record row-normed data for fold change analysis (b/c not applicable for mean-centered data)
  mSetObj$dataSet$row.norm <- as.data.frame(CleanData(numData, T, T)); #moved below ratio
 
  # this is for biomarker analysis only (for compound concentration data)
  if(ratio){
    min.val <- min(abs(numData[numData!=0]))/2;
    norm.data <- log2((numData + sqrt(numData^2 + min.val))/2);
    transnm<-"Log Normalization";
    ratio.mat <- CalculatePairwiseDiff(norm.data);
   
    fstats <- Get.Fstat(ratio.mat, cls);
    hit.inx <- rank(-fstats) < ratioNum;  # get top n
   
    ratio.mat <- ratio.mat[, hit.inx];
   
    numData <- cbind(norm.data, ratio.mat);
   
    colNames <- colnames(numData);
    rowNames <- rownames(numData);
    #mSetObj$dataSet$procr <- numData;
    mSetObj$dataSet$use.ratio <- TRUE;
    mSetObj$dataSet$proc.ratio <- numData;

  }else{
    mSetObj$dataSet$use.ratio <- FALSE;
    # transformation
    if(transNorm=='LogNorm'){
      #min.val <- min(abs(numData[numData!=0]))/10; #I REMOVED THIS TO REPLACE WITH LOG10
      #numData<-apply(numData, 2, LogNorm, min.val);
      numData <- apply(numData, 2, log10)
      transnm<-"Log Normalization";
    }else if(transNorm=='SqNorm'){
      numData <- numData^(1/2);
      transnm<-"Square Root Transformation";
    }else if(transNorm=='CrNorm'){
      numData <- numData^(1/3);
      #norm.data <- abs(numData)^(1/3); #I REMOVED THIS
      #norm.data[numData<0] <- - norm.data[numData<0];
      #numData <- norm.data;
      transnm<-"Cubic Root Transformation";
    }else{
      transnm<-"N/A";
    }
  }
 
  # scaling
  if(scaleNorm=='MeanCenter'){
    numData<-apply(numData, 2, MeanCenter);
    scalenm<-"Mean Centering";
  }else if(scaleNorm=='AutoNorm'){
    numData<-apply(numData, 2, AutoNorm);
    scalenm<-"Autoscaling";
  }else if(scaleNorm=='ParetoNorm'){
    numData<-apply(numData, 2, ParetoNorm);
    scalenm<-"Pareto Scaling";
  }else if(scaleNorm=='RangeNorm'){
    numData<-apply(numData, 2, RangeNorm);
    scalenm<-"Range Scaling";
  }else{
    scalenm<-"N/A";
  }
 
  # note after using "apply" function, all the attribute lost, need to add back
  rownames(numData)<-rowNamesNum;
  colnames(numData)<-colNamesNum;
 
  # need to do some sanity check, for log there may be Inf values introduced
  #numData <- CleanData(numData, T, F, F); #I COMMENTED THIS OUT FOR NOW
  #charData <- charData[rownames(numData),] #Adjust character data rows if needed

  if(ratio){
    mSetObj$dataSet$ratio <- CleanData(ratio.mat, T, F)
  }
 
  dataNorm <- cbind(numData, charData)
  colNames <- c(colNamesNum, colNamesChar)
  colnames(dataNorm) <- colNames
  rownames(dataNorm) <- rownames(numData)

  mSetObj$dataSet$norm <- as.data.frame(dataNorm);
  mSetObj$dataSet$cls <- cls;
 
  mSetObj$dataSet$rownorm.method <- rownm;
  mSetObj$dataSet$trans.method <- transnm;
  mSetObj$dataSet$scale.method <- scalenm;
  mSetObj$dataSet$combined.method <- FALSE;
  mSetObj$dataSet$norm.all <- NULL; # this is only for biomarker ROC analysis
  return(.set.mSet(mSetObj));
}

#'Row-wise Normalization
#'@description Row-wise norm methods, when x is a row.
#'Normalize by a sum of each sample, assume constant sum (1000).
# Return: normalized data.
#'Options for normalize by sum median, reference sample,
#'reference variable (compound), or quantile normalization
#'@param x Input data to normalize
#'@author Jeff Xia \email{jeff.xia@mcgill.ca}
#'McGill University, Canada
#'@export
#'
SumNorm<-function(x){
  min.val <- min(abs(x[x!=0]))/10 #I ADDED THIS TO ACCOUNT FOR SUM 0
  if (sum(x, na.rm=T)==0) {
    x/(sum(x, na.rm=T)+min.val);
  } else {
    x/sum(x, na.rm=T);
  }
}

# normalize by median
MedianNorm<-function(x){
  min.val <- min(abs(x[x!=0]))/10 #I ADDED THIS TO ACCOUNT FOR MEDIAN 0
  if (median(x, na.rm=T)==0) {
    x/(median(x, na.rm=T)+min.val);
  } else {
    x/median(x, na.rm=T);
  }
}

# normalize by a reference sample (probability quotient normalization)
# ref should be the name of the reference sample
ProbNorm<-function(x, ref.smpl){
  x/median(as.numeric(x/ref.smpl), na.rm=T)
}

# normalize by a reference reference (i.e. creatinine)
# ref should be the name of the cmpd
CompNorm<-function(x, ref){
  1000*x/x[ref];
}

# perform quantile normalization on the raw data (can be log transformed later by user)
# https://stat.ethz.ch/pipermail/bioconductor/2005-April/008348.html
QuantileNormalize <- function(data){
  #return(t(preprocessCore::normalize.quantiles(t(data), copy=FALSE))); #I REMOVED THIS BC PREPROCESSCORE WAS NOT WORKING WITH R4.0.5
  data_rank <- apply(data,2,rank,ties.method="min")
  data_sorted <- data.frame(apply(data, 2, sort))
  data_mean <- apply(data_sorted, 1, mean)
   
  index_to_mean <- function(my_index, my_mean){
    return(my_mean[my_index])
  }
   
  data_final <- apply(data_rank, 2, index_to_mean, my_mean=data_mean)
  rownames(data_final) <- rownames(data)
  return(data_final)
}


#'Box-Cox normalization
#'@description performs Box-Cox (data must be 0 or positive values)
#'@usage BoxNorm(vec), where vec is a numeric vector (eg column in data frame)
#'@param x is the column being normalized
#'@author Louisa Normington \email{normingt@ualberta.ca}
#'University of Alberta, Canada
#'@export
BoxNorm <- function(vec) {
  library(MASS)
  box <- boxcox(vec~1, lambda = seq(-6,6,0.1), plotit = FALSE) 
  cox <- data.frame(box$x, box$y) # Create a data frame with the results
  cox2 <- cox[with(cox, order(-cox$box.y)),] # Order the new data frame by decreasing y
  lambda <- cox2[1, "box.x"] # Extract that lambda
  vec.trans <- (vec ^ lambda - 1)/lambda
  return(vec.trans)
}


#'Yeo-Johnson normalization
#'@description performs Yeo-Johnson normalization (data can have negative values)
#'@usage YeoNorm(x), where x is a numeric vector (eg column in data frame)
#'@param x is the column being normalized
#'@author Louisa Normington \email{normingt@ualberta.ca}
#'University of Alberta, Canada
#'@export
YeoNorm <- function(x) {
  library(VGAM)
  yeo.johnson(x, lambda=seq(-6,6,0.1))
}


#'Skewness test for normality
#'@usage skewTest(x)
#'@param x is the column being normalized
#'@author Louisa Normington \email{normingt@ualberta.ca}
#'University of Alberta, Canada
#'@export
skewTest <- function(x) {
  skew <- 3*(mean(x)-median(x))/sd(x) #Perform the test
  return(skew)
}


#'Column-wise Normalization
#'@description Column-wise norm methods, when x is a column
#'Options for log, zero mean and unit variance, and
#'several zero mean and variance/SE
#'@param x Input data
#'@param min.val Input minimum value
#'@author Jeff Xia \email{jeff.xia@mcgill.ca}
#'McGill University, Canada

# generalize log, tolerant to 0 and negative values
LogNorm<-function(x, min.val){
  log2((x + sqrt(x^2 + min.val^2))/2)
}

# normalize to zero mean and unit variance
AutoNorm<-function(x){
  min.val <- min(abs(x[x!=0]))/10
  if (sd(x, na.rm=T)==0) {
    (x - mean(x))/(sd(x, na.rm=T)+min.val);
  } else {
    (x - mean(x))/sd(x, na.rm=T);
  }
}

# normalize to zero mean but variance/SE
ParetoNorm<-function(x){
  min.val <- min(abs(x[x!=0]))/10
  if (sd(x, na.rm=T)==0) {
    (x - mean(x))/(sqrt(sd(x, na.rm=T))+min.val);
  } else {
    (x - mean(x))/sqrt(sd(x, na.rm=T));
  }
}

# normalize to zero mean but variance/SE
MeanCenter<-function(x){
  x - mean(x);
}

# normalize to zero mean but variance/SE
RangeNorm<-function(x){
  if(max(x) == min(x)){
    x;
  }else{
    (x - mean(x))/(max(x)-min(x));
  }
}

#'Two plot summary plot: Feature View of before and after normalization
#'@description For each plot, the top is a box plot, bottom is a density plot
#'@usage PlotNormSummary(mSetObj, imgName, format, dpi, width)
#'@param mSetObj Input the name of the created mSetObj (see InitDataObjects)
#'@param imgName Input a name for the plot
#'@param format Select the image format, "png", or "pdf".
#'@param dpi Input the dpi. If the image format is "pdf", users need not define the dpi. For "png" images,
#'the default dpi is 72. It is suggested that for high-resolution images, select a dpi of 300.  
#'@param width Input the width, there are 2 default widths, the first, width = NULL, is 10.5.
#'The second default is width = 0, where the width is 7.2. Otherwise users can input their own width.  
#'@author Jeff Xia \email{jeff.xia@mcgill.ca}, Jasmine Chong
#'McGill University, Canada
#'@export
#'
PlotNormSummary <- function(mSetObj=NA, imgName, format="png", dpi=72, width=NA){
  mSetObj <- .get.mSet(mSetObj);
  imgName = paste(imgName, "dpi", dpi, ".", format, sep="");
  if(is.na(width)){
    w <- 10.5; h <- 12.5;
  }else if(width==0){
    w = 7.2
    h = 9.5
  }else if(width>0){
    w = width
    h = width*1.25
    # w <- 7.2; h <- 9;
  }
 
  mSetObj$imgSet$norm <- imgName
 
  Cairo::Cairo(file = imgName, unit="in", dpi=dpi, width=w, height=h, type=format, bg="white");
  layout(matrix(c(1,2,2,2,3,4,4,4), 4, 2, byrow = FALSE))
 
  # since there may be too many variables, only plot a subsets (50) in box plot
  # but density plot will use all the data
 
  if(is.null(mSetObj$dataSet[["procr"]])){ #I ADDED THIS
    data<-mSetObj$dataSet$preproc
  }else if(is.null(mSetObj$dataSet[["prenorm"]])){
    data<- mSetObj$dataSet$procr
  }else{
    data<-mSetObj$dataSet$prenorm
  } 

  numData <- select_if(data, is.numeric)
  normNumData <- select_if(mSetObj$dataSet$norm, is.numeric)

  pre.inx<-GetRandomSubsetIndex(ncol(numData), sub.num=50);
  namesVec <- colnames(numData[,pre.inx]);
 
  # only get common ones
  nm.inx <- namesVec %in% colnames(normNumData)
  namesVec <- namesVec[nm.inx];
  pre.inx <- pre.inx[nm.inx];
 
  norm.inx<-match(namesVec, colnames(normNumData));
  namesVec <- substr(namesVec, 1, 12); # use abbreviated name
 
  rangex.pre <- range(numData[, pre.inx], na.rm=T);
  rangex.norm <- range(normNumData[, norm.inx], na.rm=T);
 
  x.label<-GetAbundanceLabel(mSetObj$dataSet$type);
  y.label<-GetVariableLabel(mSetObj$dataSet$type);
 
  # fig 1
  op<-par(mar=c(4,7,4,0), xaxt="s");
  plot(density(apply(numData, 2, mean, na.rm=TRUE)), col='darkblue', las =2, lwd=2, main="", xlab="", ylab="");
  mtext("Density", 2, 5);
  mtext("Before Normalization",3, 1)
 
  # fig 2
  op<-par(mar=c(7,7,0,0), xaxt="s");
  boxplot(numData[,pre.inx], names= namesVec, ylim=rangex.pre, las = 2, col="lightgreen", horizontal=T);
  #mtext("Counts", 1, 5); #I REMOVED THIS
 
  # fig 3
  op<-par(mar=c(4,7,4,2), xaxt="s");
  plot(density(apply(normNumData, 2, mean, na.rm=TRUE)), col='darkblue', las=2, lwd =2, main="", xlab="", ylab="");
  mtext("After Normalization",3, 1);
 
  # fig 4
  op<-par(mar=c(7,7,0,2), xaxt="s");
  boxplot(normNumData[,norm.inx], names=namesVec, ylim=rangex.norm, las = 2, col="lightgreen", horizontal=T);
  #mtext("Normalized Counts",1, 5); #I REMOVED THIS
 
  dev.off();
 
  return(.set.mSet(mSetObj));
}

#'Two plot summary plot: Sample View of before and after normalization
#'@description For each plot, the top is a density plot and the bottom is a box plot.
#'@usage PlotSampleNormSummary(mSetObj=NA, imgName, format="png", dpi=72, width=NA)
#'@param mSetObj Input the name of the created mSetObj (see InitDataObjects)
#'@param imgName Input a name for the plot
#'@param format Select the image format, "png", of "pdf".
#'@param dpi Input the dpi. If the image format is "pdf", users need not define the dpi. For "png" images,
#'the default dpi is 72. It is suggested that for high-resolution images, select a dpi of 300.  
#'@param width Input the width, there are 2 default widths, the first, width = NULL, is 10.5.
#'The second default is width = 0, where the width is 7.2. Otherwise users can input their own width.  
#'@author Jeff Xia \email{jeff.xia@mcgill.ca}, Jasmine Chong
#'McGill University, Canada
#'@export

PlotSampleNormSummary <- function(mSetObj=NA, imgName, format="png", dpi=72, width=NA){
 
  mSetObj <- .get.mSet(mSetObj);
  imgName = paste(imgName, "dpi", dpi, ".", format, sep="");
  if(is.na(width)){
    w <- 10.5; h <- 12.5;
  }else if(width == 0){
    w <- 7.2;h <- 9.5;
  }else if(width>0){
    w = width
    h = width*1.25
    # w <- 7.2; h <- 9;
  }
 
  mSetObj$imgSet$summary_norm <-imgName;
 
  Cairo::Cairo(file = imgName, unit="in", dpi=dpi, width=w, height=h, type=format, bg="white");
  #layout(matrix(c(1,1,1,2,3,3,3,4), 4, 2, byrow = FALSE))
  layout(matrix(c(1,2,2,2,3,4,4,4), 4, 2, byrow = FALSE))

  # since there may be too many samples, only plot a subsets (50) in box plot
  # but density plot will use all the data
  if(is.null(mSetObj$dataSet[["procr"]])){
    data<-mSetObj$dataSet$preproc
  }else if(is.null(mSetObj$dataSet[["prenorm"]])){
    data<- mSetObj$dataSet$procr
  }else{
    data<-mSetObj$dataSet$prenorm
  } 
  numData <- select_if(data, is.numeric)
  normNumData <- select_if(mSetObj$dataSet$norm, is.numeric)
  pre.inx<-GetRandomSubsetIndex(nrow(numData), sub.num=50);
  namesVec <- rownames(numData[pre.inx,]);
  # only get common ones
  nm.inx <- namesVec %in% rownames(normNumData)
  namesVec <- namesVec[nm.inx];
  pre.inx <- pre.inx[nm.inx];
  norm.inx<-match(namesVec, rownames(normNumData));
  namesVec <- substr(namesVec, 1, 12); # use abbreviated name
  rangex.pre <- range(numData[pre.inx,], na.rm=T);
  rangex.norm <- range(normNumData[norm.inx,], na.rm=T);
  x.label<-GetAbundanceLabel(mSetObj$dataSet$type);
  y.label<-"Samples";
  # fig 1
  op<-par(mar=c(4,7,4,0), xaxt="s");
  plot(density(apply(numData, 1, mean, na.rm=TRUE)), col='darkblue', las =2, lwd=2, main="", xlab="", ylab="");
  mtext("Density", 2, 5);
  mtext("Before Normalization",3, 1)
  # fig 2
  op<-par(mar=c(7,7,0,0), xaxt="s");
  boxplot(t(numData[pre.inx, ]), names= namesVec, ylim=rangex.pre, las = 2, col="lightgreen", horizontal=T);
 
  # fig 3
  op<-par(mar=c(4,7,4,2), xaxt="s");
  plot(density(apply(normNumData, 1, mean, na.rm=TRUE)), col='darkblue', las=2, lwd =2, main="", xlab="", ylab="");
  mtext("After Normalization",3, 1);

  # fig 4
  op<-par(mar=c(7,7,0,2), xaxt="s");
  boxplot(t(normNumData[norm.inx,]), names=namesVec, ylim=rangex.norm, las = 2, col="lightgreen", ylab="", horizontal=T);
 
  dev.off();
  return(.set.mSet(mSetObj));
}



##############################################
##############################################
########## Utilities for web-server ##########
##############################################
##############################################


#'Remove a group from the data
#'@description This function removes a user-specified group from the data set.
#'This must be performed following data processing and filtering. If the data was normalized prior to removal,
#'you must re-normalize the data.
#'@usage UpdateGroupItems(mSetObj=NA, grp.nm.vec)  
#'@param mSetObj Input the name of the created mSetObj (see InitDataObjects)
#'@param grp.nm.vec Input the name of the group you would like to remove from the data set in quotation marks
#'(ex: "Disease B") The name must be identical to a class label.
#'@author Jeff Xia \email{jeff.xia@mcgill.ca}, Jasmine Chong
#'McGill University, Canada
#'@export
#'
UpdateGroupItems <- function(mSetObj=NA, grp.nm.vec){
 
  mSetObj <- .get.mSet(mSetObj);
  if(is.null(mSetObj$dataSet$filt)){
    data <- mSetObj$dataSet$procr;
    cls <- mSetObj$dataSet$proc.cls;
    if(substring(mSetObj$dataSet$format,4,5)=="ts"){
      facA <- mSetObj$dataSet$proc.facA;
      facB <- mSetObj$dataSet$proc.facB;
    }
  }else{
    data <- mSetObj$dataSet$filt;
    cls <- mSetObj$dataSet$filt.cls;
    if(substring(mSetObj$dataSet$format,4,5)=="ts"){
      facA <- mSetObj$dataSet$filt.facA;
      facB <- mSetObj$dataSet$filt.facB;
    }
  }
 
  hit.inx <- cls %in% grp.nm.vec;
  mSetObj$dataSet$prenorm <- CleanDataMatrix(data[!hit.inx,,drop=FALSE]);
  mSetObj$dataSet$prenorm.cls <- droplevels(factor(cls[!hit.inx]));
 
  if(substring(mSetObj$dataSet$format,4,5)=="ts"){
    mSetObj$dataSet$prenorm.facA <- droplevels(factor(facA[!hit.inx]));
    mSetObj$dataSet$prenorm.facB <- droplevels(factor(facB[!hit.inx]));
  }
 
  AddMsg("Successfully updated the group items!");
  if(.on.public.web){
    .set.mSet(mSetObj);
    return(length(levels(mSetObj$dataSet$prenorm.cls)));
  }else{
    return(.set.mSet(mSetObj));
  }
}

#'Remove samples from user's data
#'@description This function removes samples from the data set. This must be performed following data processing and filtering.
#'If the data was normalized prior to removal, you must re-normalize the data.  
#'@usage UpdateSampleItems(mSetObj=NA, smpl.nm.vec)
#'@param mSetObj Input the name of the created mSetObj (see InitDataObjects)
#'@param smpl.nm.vec Input the name of the sample to remove from the data in quotation marks. The name must be identical to the
#'sample names found in the data set.  
#'@author Jeff Xia \email{jeff.xia@mcgill.ca}, Jasmine Chong
#'McGill University, Canada
#'@export
#'
UpdateSampleItems <- function(mSetObj=NA, smpl.nm.vec){
  mSetObj <- .get.mSet(mSetObj);
  if(is.null(mSetObj$dataSet$filt)){
    data <- mSetObj$dataSet$procr;
    cls <- mSetObj$dataSet$proc.cls;
    if(substring(mSetObj$dataSet$format,4,5)=="ts"){
      facA <- mSetObj$dataSet$proc.facA;
      facB <- mSetObj$dataSet$proc.facB;
    }
  }else{
    data <- mSetObj$dataSet$filt;
    cls <- mSetObj$dataSet$filt.cls;
    if(substring(mSetObj$dataSet$format,4,5)=="ts"){
      facA <- mSetObj$dataSet$filt.facA;
      facB <- mSetObj$dataSet$filt.facB;
    }
  }
 
  hit.inx <- rownames(data) %in% smpl.nm.vec;
  mSetObj$dataSet$prenorm <- CleanDataMatrix(data[!hit.inx,,drop=FALSE]);
  mSetObj$dataSet$prenorm.cls <- as.factor(as.character(cls[!hit.inx]));
  if(substring(mSetObj$dataSet$format,4,5)=="ts"){
    mSetObj$dataSet$prenorm.facA <- as.factor(as.character(facA[!hit.inx]));
    mSetObj$dataSet$prenorm.facB <- as.factor(as.character(facB[!hit.inx]));
  }
 
  AddMsg("Successfully updated the sample items!");
 
  if(.on.public.web){
    .set.mSet(mSetObj);
    return(length(levels(mSetObj$dataSet$prenorm.cls)));
  }else{
    return(.set.mSet(mSetObj));
  }
}

#' Remove feature items
#' @description This function removes user-selected features from the data set.
#' This must be performed following data processing and filtering.
#' If the data was normalized prior to removal, you must re-normalize the data.  
#' @usage UpdateFeatureItems(mSetObj=NA, feature.nm.vec)
#'@param mSetObj Input the name of the created mSetObj (see InitDataObjects)
#' @param feature.nm.vec Input the name of the feature to remove from the data in quotation marks.
#' The name must be identical to the feature names found in the data set.  
#'@author Jeff Xia \email{jeff.xia@mcgill.ca}, Jasmine Chong
#'McGill University, Canada
#'@export
#'
UpdateFeatureItems <- function(mSetObj=NA, feature.nm.vec){
 
  mSetObj <- .get.mSet(mSetObj);
  if(is.null(mSetObj$dataSet$filt)){
    data <- mSetObj$dataSet$procr;
    cls <- mSetObj$dataSet$proc.cls;
    if(substring(mSetObj$dataSet$format,4,5)=="ts"){
      facA <- mSetObj$dataSet$proc.facA;
      facB <- mSetObj$dataSet$proc.facB;
    }
  }else{
    data <- mSetObj$dataSet$filt;
    cls <- mSetObj$dataSet$filt.cls;
    if(substring(mSetObj$dataSet$format,4,5)=="ts"){
      facA <- mSetObj$dataSet$filt.facA;
      facB <- mSetObj$dataSet$filt.facB;
    }
  }
 
  hit.inx <- colnames(data) %in% feature.nm.vec;
  mSetObj$dataSet$prenorm <- CleanDataMatrix(data[,!hit.inx,drop=FALSE]);
  mSetObj$dataSet$prenorm.cls <- cls; # this is the same
 
  AddMsg("Successfully updated the feature items!");
  return(.set.mSet(mSetObj));
}


InitPrenormData <- function(mSetObj=NA){
    mSetObj <- .get.mSet(mSetObj);
    if(is.null(mSetObj$dataSet[["prenorm"]])){
        if(is.null(mSetObj$dataSet[["filt"]])){
            mSetObj$dataSet$prenorm <- mSetObj$dataSet$procr;
            mSetObj$dataSet$prenorm.cls <- mSetObj$dataSet$proc.cls;
            if(substring(mSetObj$dataSet$format,4,5) == "ts"){
                mSetObj$dataSet$prenorm.facA <- mSetObj$dataSet$proc.facA;
                mSetObj$dataSet$prenorm.facB <- mSetObj$dataSet$proc.facB;
            }
        }else{
            mSetObj$dataSet$prenorm <- mSetObj$dataSet$filt;
            mSetObj$dataSet$prenorm.cls <- mSetObj$dataSet$filt.cls;
            if(substring(mSetObj$dataSet$format,4,5)=="ts"){
                mSetObj$dataSet$prenorm.facA <- mSetObj$dataSet$filt.facA;
                mSetObj$dataSet$prenorm.facB <- mSetObj$dataSet$filt.facB;
            }
        }
        .set.mSet(mSetObj)
    }
}

# get the dropdown list for sample normalization view
GetPrenormSmplNms <-function(mSetObj=NA){
  mSetObj <- .get.mSet(mSetObj);
  if(is.null(mSetObj$dataSet[["procr"]])){ #I ADDED THIS
    samples<-rownames(mSetObj$dataSet$preproc)
  }else if(is.null(mSetObj$dataSet[["prenorm"]])){
    samples<- rownames(mSetObj$dataSet$procr)
  }else{
    samples<-rownames(mSetObj$dataSet$prenorm)
  } 
  return(samples);
}

GetPrenormFeatureNms <- function(mSetObj=NA){
  mSetObj <- .get.mSet(mSetObj);
  if(is.null(mSetObj$dataSet[["procr"]])){ #I ADDED THIS
    variables<-colnames(mSetObj$dataSet$preproc)
  }else if(is.null(mSetObj$dataSet[["prenorm"]])){
    variables<- colnames(mSetObj$dataSet$procr)
  }else{
    variables<-colnames(mSetObj$dataSet$prenorm)
  } 
  return(variables);
}

GetPrenormClsNms <- function(mSetObj=NA){
  mSetObj <- .get.mSet(mSetObj);
  return(levels(mSetObj$dataSet$prenorm.cls));
}

########## Utility Functions ###############
GetRandomSubsetIndex<-function(total, sub.num = 50){
  if(total < sub.num){
    1:total;
  }else{
    sample(1:total, sub.num);
  }
}