#'Perform NMDS analysis
#'@description Perform NMDS analysis
#'@param mSetObj Input name of the created mSet Object
#'@param distance Input distance as one of "bray" (default), "manhattan", "canberra", "euclidean", "kulczynski", "jaccard", "gower", "altGower", "morisita", "horn", "mountford", "raup" , "binomial", "chao", "cao", "mahalanobis"
#'@param abundance Set abundance transformation, default is absolute (no change), else relative
#'@param data Which data set to use, normalized (default) or original
#'@author Louisa Normington\email{normingt@ualberta.ca}
#'University of Alberta, Canada
#'License: GNU GPL (>= 2)
#'@export
ord.NMDS <- function(mSetObj=NA, data="false", distance="NULL", abundance="false") { 
    options(error=traceback)

  library("vegan")
  library("dplyr")

  #Obtain mSet dataset
  mSetObj <- .get.mSet(mSetObj)
  if (data=="false") {
    input <- mSetObj$dataSet$norm
  } else {
    input <- mSetObj$dataSet$orig
  }

  metaData <- mSetObj$dataSet$origMeta
  envData <- mSetObj$dataSet$origEnv

  #Obtain numeric data for ordination and categorical data for grouping data
  num_data <- select_if(input, is.numeric) #Numeric data only for NMDS
  
  if (abundance=="false") {
    abundance1 <- "absolute" #Default abundance is absolute and no change is made to data
    num_data1 <- num_data
  } else {
    abundance1 <- "relative"
    num_data1 <- decostand(num_data, method="total") #Alternative option is relative abundance, each value is divided by the column sum
  }
  
  if (distance=="NULL") {
    distance1 <- "bray" #Default distance
  } else {
    distance1 <- distance #USer selected from list "euclidean", "manhattan", "canberra", "bray", "kulczynski", "jaccard", "gower", "altGower", "morisita", "horn", "mountford", "raup" , "binomial", "chao", "cao", "mahalanobis"
  } 

  #Run NMDS for 1D through 5D
  if (ncol(num_data1)<2) {
    #AddErrMsg("Ordination requires atleast 2 variables!")
    stop("Ordination requires at least 2 variables!")
  } 
  if (ncol(num_data1)>=2) {
    nmds1D <- metaMDS(num_data1, maxit=999, trymax=50, dist=distance1, k=1, trace=0)
    nmds2D <- metaMDS(num_data1, maxit=999, trymax=50, dist=distance1, k=2, trace=0)
  }   
  if (ncol(num_data1)>=3) {
    nmds3D <- metaMDS(num_data1, maxit=999, trymax=50, dist=distance1, k=3, trace=0)
  } 
  if (ncol(num_data1)>=4) {
    nmds4D <- metaMDS(num_data1, maxit=999, trymax=50, dist=distance1, k=4, trace=0)
  } 
  if (ncol(num_data1)>=5) {
    nmds5D <- metaMDS(num_data1, maxit=999, trymax=50, dist=distance1, k=5, trace=0)
  } 
  if (ncol(num_data1)>=6) {
    nmds6D <- metaMDS(num_data1, maxit=999, trymax=50, dist=distance1, k=6, trace=0)
  } 
  if (ncol(num_data1)>=7) {
    nmds7D <- metaMDS(num_data1, maxit=999, trymax=50, dist=distance1, k=7, trace=0)
  } 
  if (ncol(num_data1)>=8) {
    nmds8D <- metaMDS(num_data1, maxit=999, trymax=50, dist=distance1, k=8, trace=0)
  } 

  #meta data, used to group samples using colors
  if (is.data.frame(metaData)==FALSE) { #No user uploaded meta data
    metaData1 <- "NA" #If species data had no categorical columns, meta data is NA
    #AddErrMsg("No groupings columns were detected. If this is a mistake, make sure that groupings columns use characters and not numbers. For example, instead ofgrouping data using 1, 2, and 3, use I, II and III.")
    print("No groupings data were detected!")
  } else {  #User uplaoded meta data
    metaData1 <- metaData #Data integrated like weights in correlation module
    if (nrow(metaData1)!=nrow(input)) {
      #AddErrMsg("Your grouping data does not have the same number of rows as your numerical data! Please check that you meta data is correct.")
      stop("Your grouping data does not have the same number of rows as your main data set! Please check that you meta data is correct.")
    }
  }
  
  #environmental data, used to correlate with rows in main data set
  if (is.data.frame(envData)==FALSE) { #No user uplaoded environmental data
    envData1 <- "NA"
  } else {  #User uplaoded environmental data
    envData1 <- envData #User uploaded (like weights in correlation module)
    if (nrow(envData1)!=nrow(input)) {
      #AddErrMsg("Your environmental data does not have the same number of rows as your data set! Please check that you environmental data is correct.")
      stop("Your environmental data does not have the same number of rows as your data set! Please check that you environmental data is correct.")
    }
  }

  #Text box instructions for selecting environmental variables. Text box should be interactive, meaning any change in text alters the result in real time. Default env_text is second column.
  if (is.data.frame(envData1)==TRUE) {
    cat("You uploaded environmental data. Identify environmental variables for NMDS using the column names with commas in between.")
  }
  
  #Set up environmental data using user selected columns
  if (is.data.frame(envData1)==TRUE) { #User uplaoded environmental data
    env_data <- envData1
  } else {
    env_data <- "NA"
  }
  
  #Fit variables to ordination plots for plotting arrows
  var.fit2D <- envfit(nmds2D, num_data1, permutations=999, p.max=NULL)

  #Fit environmental data to ordination plots for plotting arrows
  if (is.data.frame(envData1)==FALSE) { #If environmental data not uploaded
    env.fit2D <- "NA"
    env.fit2D.char <- "NA"
    env.fit2D.num <- "NA"
  } else { #If environmental data uploaded
    env_data_numeric <- select_if(env_data, is.numeric)
    env_data_character <- select_if(env_data, is.character)
    env.fit2D <- envfit(nmds2D, env_data, permutations=999, p.max=NULL)
    if (ncol(env_data_character)>0) { #If categorical variables present
      env.fit2D.char <- envfit(nmds2D, env_data_character, permutations=999, p.max=NULL) #Fit env data to species data
    } else{
      env.fit2D.char <- "NA"
    }
    if (ncol(env_data_numeric)>0) { #If numeric variables present
      env.fit2D.num <- envfit(nmds2D, env_data_numeric, permutations=999, p.max=NULL) #Fit env data to species data
    } else{
      env.fit2D.num <- "NA"
    }
  }

  #Extract scores
  samp.scores2D <- signif(scores(nmds2D, display="sites"), 5)
  if (ncol(num_data) >= 3) {
    samp.scores3D <- signif(scores(nmds3D, display="sites"), 5)
  } else {
    #AddErrMsg("3D scores plot requires atleast 3 numeric variables!")
    warning("3D scores plot requires at least 3 numeric variables!")
  }
  var.scores2D <- signif(scores(nmds2D, display="species"), 5)
  if (ncol(num_data) >= 3) {
    var.scores3D <- signif(scores(nmds3D, display="species"), 5)
  } else {
    #AddErrMsg("3D scores plot requires atleast 3 numeric variables!")
    warning("3D scores plot requires at least 3 numeric variables!")
  }
  
  if (is.data.frame(envData1)==FALSE) { #If environmental data not uploaded
    env.scores2D <- "NA"
  } else { #If environmental data uploaded
    env.scores2D <- signif(scores(env.fit2D, display="vectors"), 5) #Calculate variable scores
  }
  
  #Extract environment scores
  if (is.data.frame(envData1)==FALSE) { #If environmental data not uploaded
    env.scores2D <- "NA"
  } else { #If environmental data uploaded

    #Env scores for numeric env variables--> will be used for plotting arrows
    if (length(env_data_numeric)>0) {
      env.scores2D.num <- signif(scores(env.fit2D, display="vectors"), 5)
    } else {
      env.scores2D.num <- "NA"
    }

    #Env scores for categorical env variables--> will be used for plotting centroids   
    if (length(env_data_character)>0) {
      env.scores2D.char <- signif(scores(env.fit2D, display="factors"), 5)
    } else {
      env.scores2D.char <- "NA"
    }

    #Get env scores for all variables (regardless of type)--> putting it all together
    if (is.matrix(env.scores2D.num)==TRUE) { #Numeric env variables present
      if (is.matrix(env.scores2D.char)==TRUE) { #Categorical env variables present
        env.scores2D <- rbind(env.scores2D.num, env.scores2D.char)
      } else {  #No categorical constraining variables
        env.scores2D <- env.scores2D.num
      }
    } else { #No numeric constraining variables
      env.scores2D <- env.scores2D.char
    }
  }
  
  #Store results in mSetObj$analSet$nmds
  mSetObj$analSet$nmds$nmds1D <- nmds1D
  mSetObj$analSet$nmds$nmds2D <- nmds2D
  if (ncol(num_data1)>=3) {
    mSetObj$analSet$nmds$nmds3D <- nmds3D
  }
  if (ncol(num_data1)>=4) {
    mSetObj$analSet$nmds$nmds4D <- nmds4D
  }
  if (ncol(num_data1)>=5) {
    mSetObj$analSet$nmds$nmds5D <- nmds5D
  }
  if (ncol(num_data1)>=6) {
    mSetObj$analSet$nmds$nmds6D <- nmds6D
  }
  if (ncol(num_data1)>=7) {
    mSetObj$analSet$nmds$nmds7D <- nmds7D
  }
  if (ncol(num_data1)>=8) {
    mSetObj$analSet$nmds$nmds8D <- nmds8D
  }
  mSetObj$analSet$nmds$distance <- distance1 
  mSetObj$analSet$nmds$abundance <- abundance1
  mSetObj$analSet$nmds$num_data <- num_data1
  mSetObj$analSet$nmds$metaData <- metaData1
  mSetObj$analSet$nmds$env_data <- env_data
  mSetObj$analSet$nmds$var.fit2D <- var.fit2D
  mSetObj$analSet$nmds$env.fit2D <- env.fit2D
  mSetObj$analSet$nmds$env.fit2D.char <- env.fit2D.char
  mSetObj$analSet$nmds$env.fit2D.num <- env.fit2D.num
  if (ncol(num_data) >= 3) {
    mSetObj$analSet$nmds$sample.scores3D <- samp.scores3D
    mSetObj$analSet$nmds$var.scores3D <- var.scores3D
  }
  
  #Export tables and text docs into working directory
  write.csv(samp.scores2D, file="nmds_2D_sample_scores.csv", row.names=TRUE)
  write.csv(var.scores2D, file="nmds_2D_variable_scores.csv", row.names=TRUE)
  if (ncol(num_data) >= 3) {
    write.csv(samp.scores3D, file="nmds_3D_sample_scores.csv", row.names=TRUE)
    write.csv(var.scores3D, file="nmds_3D_variable_scores.csv", row.names=TRUE)
  }
  if (is.data.frame(envData1)==TRUE) {
    write.csv(env.scores2D, file="nmds_2D_constraining_variable_scores.csv", row.names=TRUE)
  }

  sink("variable_impact_on_nmds_2D.txt") 
  cat("Variables may significantly impact NMDS\n")
  cat("\nNMDS dimension=2\n\n")
  print(var.fit2D)
  sink()  
  
  sink("constraining_variables_impact_on_nmds_2D.txt") 
  cat("Constraining data may significantly impact NMDS\n")
  cat("\nNMDS dimension=2\n\n")
  print(env.fit2D)
  sink()  
  
  sink("nmds_summary.txt")
  cat("Non-Metric Multidimensional Analysis\n")
  if (abundance=="absolute") { #no transformation
    abundance2 <- "false"
  } else { #Relative abundance transformation
    abundance2 <- "true"
  }
  cat(paste0("\n\nPerform relative abundance transformation: "), abundance2, "\n\n")
  cat("NMDS 1D")
  print(nmds1D)
  cat("NMDS 2D")
  print(nmds2D)
  if (ncol(num_data)>=3){
    cat("NMDS 3D")
    print(nmds3D)
  }
  if (ncol(num_data)>=4){
    cat("NMDS 4D")
    print(nmds4D)
  }  
  if (ncol(num_data)>=5){
    cat("NMDS 5D")
    print(nmds5D)
  }  
  if (ncol(num_data)>=6){
    cat("NMDS 6D")
    print(nmds6D)
  }  
  if (ncol(num_data)>=7){
    cat("NMDS 7D")
    print(nmds7D)
  }  
  if (ncol(num_data)>=8){
    cat("NMDS 8D")
    print(nmds8D)
  }

  cat("\nLengend:\n")
  cat("Site=Samples and Species=Variables\n")
  sink() 
  
  return(.set.mSet(mSetObj))
  
}



#'Produce NMDS 2D ordination plot with and without ellipses/sample labels/metadata options/variable arrows/env data arrows
#'@description Produce NMDS ordination plot with user selected options
#'@param mSetObj Input name of the created mSet Object
#'@param color #Viridis pallete, options include "viridis" (default), "plasma" and "grayscale"
#'@param ellipse Boolean, TRUE to add confidence ellipses, FALSE (default) to not add confidence ellipses
#'@param var_arrows Boolean, TRUE to produce variable arrows, FALSE (default) to produce ordination plot without variable arrows
#'@param env_arrows Boolean, TRUE to produce environmental arrows, FALSE (default) to produce ordination plot without environmental arrows---only appear if env data uploaded
#'@param env_cent Boolean, TRUE to produce display factor environmental data centroids, FALSE (default) to produce ordination plot without environmental centroids
#'@param sampleNames Boolean, TRUE to display data as variable names, FALSE (default) to display data as points
#'@param meta_col_color Meta data column to use for plotting colors, Can be user inputted where options are given to java using function nmds.meta.columns()
#'@param imgName Input the image name
#'@param format Select the image format, "png" or "pdf", default is "png" 
#'@param dpi Input the dpi. If the image format is "pdf", users need not define the dpi. For "png" images, 
#'the default dpi is 72. It is suggested that for high-resolution images, select a dpi of 300.  
#'@param width Input the width, there are 2 default widths. The first, width=NULL, is 10.5.
#'The second default is width=0, where the width is 7.2. Otherwise users can input their own width
#'@author Louisa Normington\email{normingt@ualberta.ca}
#'University of Alberta, Canada
#'License: GNU GPL (>= 2)
#'@export
Plot.NMDS.2D <- function(mSetObj=NA, ellipse="false", var_arrows="false", env_arrows="false", env_cent="false", sampleNames="false", color="NULL", meta_col_color="NULL", imgName, format="png", dpi=72, width=NA) {

  library("vegan")
  library("viridis") 
  
  #Extract necessary objects from mSetObj
  mSetObj <- .get.mSet(mSetObj)
  nmds2D <- mSetObj$analSet$nmds$nmds2D
  metaData <- mSetObj$analSet$nmds$metaData
  env_data <- mSetObj$analSet$nmds$env_data
  num_data <- mSetObj$analSet$nmds$num_data
  var.fit2D <- mSetObj$analSet$nmds$var.fit2D
  env.fit2D.char <- mSetObj$analSet$nmds$env.fit2D.char
  env.fit2D.num <- mSetObj$analSet$nmds$env.fit2D.num
  distance <- mSetObj$analSet$nmds$distance

  #Set plot dimensions
  if(is.na(width)){
    w <- 10.5
  } else if(width==0){
    w <- 7.2
  } else{
    w <- width
  }
  h <- w
  
  #Name plot for download
  imgName <- paste(imgName, "dpi", dpi, ".", format, sep="")
  mSetObj$imgSet$Plot.NMDS.2D <- imgName
  
  #Produce 2D ordination plot
  Cairo::Cairo(file=imgName, unit="in", dpi=dpi, width=w, height=h, type=format, bg="white")
  par(xpd=FALSE, mar=c(5.1, 4.1, 4.1, 2.1))
  if (distance=="euclidean") {
    ordiplot(nmds2D, type="n", xlab="MDS 1", ylab="MDS 2", main="Metric Multidimensional Scaling", yaxt="n") #Empty ordination plot 
  } else {
    ordiplot(nmds2D, type="n", xlab="NMDS 1", ylab="NMDS 2", main="Non-metric Multidimensional Scaling", yaxt="n") #Empty ordination plot 
  }
  axis(2, las=2)
  
  #Plot with and without ellipses/sample labels/metadata options/variable arrows/env data arrows
  if (is.data.frame(metaData)==FALSE || meta_col_color=="No groupings") { #If no meta data

    #Sample display options
    if (sampleNames=="true") { #If display data as lables
      text(nmds2D, display="sites") #Add text for samples
    } else {
      points(nmds2D, display="sites", pch=19) #Otherwise use points
    }
    
    #variable arrow options
    if (var_arrows=="true") { #If variable arrows selected
      plot(var.fit2D, col="darkred")
    }
    
    #env variable arrow options
    if (is.data.frame(env_data)==TRUE) { #If environment data uploaded
      if (env.fit2D.num!="NA") {
        if (env_arrows=="true") { #If environment arrows selected
          plot(env.fit2D.num, col="blue", lwd=2)
        }
      } else {
      #AddErrMsg("Warning: No numeric constraining variables for constraining data arrows.")
      print("Warning: No numeric constraining variables for constraining data arrows.")
      }
      
      #env variable centroid options
      if (env.fit2D.char!="NA") {
        if (env_cent=="true") { #If environment constraints selected
          plot(env.fit2D.char, col="blue", lwd=2)
        }
      } else {
      #AddErrMsg("Warning: No categorical constraining variables for constraining data centroids.")
      print("Warning: No categorical constraining variables for constraining data centroids.")
      }
    }
  } else { #If meta data available
    
    #Set up meta data column to use for colors
    if (meta_col_color=="NULL") { 
      meta_col_color_data <- as.data.frame(as.factor(metaData[,1])) #Default meta data column for labeling with color is the first
      meta_col_color_name <- colnames(metaData)[1]
    } else {
      meta_col_color_data <- as.data.frame(as.factor(metaData[,meta_col_color])) #User inputted meta data column for labeling with colors, options given to java using function nmds.meta.columns() below
      meta_col_color_name <- colnames(metaData[meta_col_color])
    }
    
    #Color options
    n <- nlevels(meta_col_color_data[,1]) #Determine how many different colors are needed based on the levels of the meta data
    if (color=="NULL") { #Default
      colors <- viridis(n) #Assign a color to each level using the viridis pallete (viridis package)
      cols <- colors[meta_col_color_data[,1]] #Color pallete applied for groupings of user's choice    
    } else if (color=="plasma") {
      colors <- plasma(n+1) #Assign a color to each level using the plasma pallete (viridis package)
      cols <- colors[meta_col_color_data[,1]] #Color pallete applied for groupings of user's choice
    } else if (color=="grey") {
      colors <- grey.colors(n, start=0.1, end=0.75) #Assign a grey color to each level (grDevices package- automatically installed)
      cols <- colors[meta_col_color_data[,1]] #Color pallete applied for groupings of user's choice
    } else { 
      colors <- c("black")
      cols <- "black"
    }

    if (sampleNames=="true") { #If display data as lables
      with(metaData, text(nmds2D, display="sites", col=cols, bg=cols)) # DIsplay data as dataname
    } else { #display data as points
      with(metaData, points(nmds2D, display="sites", col=cols, pch=19, bg=cols)) 
    }
   
    #variable arrow options
    if (var_arrows=="true") { #If variable arrows selected
        if (color=="plasma") {
            plot(var.fit2D, col="black")
        } else {
            plot(var.fit2D, col="darkred") 
        }
    }
    
    #env variable arrow options
    if (is.data.frame(env_data)==TRUE) { #If environment data uploaded
      if (env.fit2D.num!="NA") {
        if (env_arrows=="true") { #If environment arrows selected
            if (color=="NULL") {
                plot(env.fit2D.num, col="black", lwd=2)
            } else {
                plot(env.fit2D.num, col="blue", lwd=2)
            }
        }
      } else {
      #AddErrMsg("Warning: No numeric constraining variables for constraining data arrows.")
      print("Warning: No numeric constraining variables for constraining data arrows.")
      }
      
      #env variable centroid options
      if (env.fit2D.char!="NA") {
        if (env_cent=="true") { #If environment constraints selected
            if (color=="NULL") {
                plot(env.fit2D.char, col="black", lwd=2)
            } else {
                plot(env.fit2D.char, col="blue", lwd=2)
            }
        }
      } else {
      #AddErrMsg("Warning: No categorical constraining variables for constraining data centroids.")
      print("Warning: No categorical constraining variables for constraining data centroids.")
      }
    }
    
    #Ellipse options
    if (ellipse=="true") { #if ellipses selected
      with(metaData, ordiellipse(nmds2D, meta_col_color_data[,1], display="sites", kind="sd", draw="polygon", border=colors, lwd=2)) # Include standard deviation ellipses that are the same color as the text.
    }
    
    #Legend
    if (cols!="black") {
        with(metaData, legend("topright", legend=levels(meta_col_color_data[,1]), col=colors, pch=19, title=meta_col_color_name)) # Include legend for colors in figure   
    }
  }
  
  dev.off()
  
  return(.set.mSet(mSetObj))
  
}





#'Produce NMDS 3D ordination plot with and without ellipses/sample labels/metadata options/variable arrows/env data arrows
#'@description Produce NMDS ordination plot with user selected options
#'@param mSetObj Input name of the created mSet Object
#'@param color #Viridis pallete, options include "viridis" (default), "plasma" and "cividis"
#'@param var_arrows Boolean, TRUE to produce variable arrows, FALSE (default) to produce ordination plot without variable arrows
#'@param meta_col_color Meta data column to use for plotting colors, Can be user inputted where options are given to java using function nmds.meta.columns()
#'@param imgName Input the image name
#'@author Louisa Normington\email{normingt@ualberta.ca}
#'University of Alberta, Canada
#'License: GNU GPL (>= 2)
#'@export
Plot.NMDS.3D <- function(mSetObj=NA, color="NULL", var_arrows="false", meta_col_color="NULL", imgName) {
  
  library("viridis")
  library("RJSONIO")
  
  #Extract necessary objects from mSetObj
  mSetObj <- .get.mSet(mSetObj)
  num_data <- mSetObj$analSet$nmds$num_data
  
  if (ncol(num_data) >= 3) {
    nmds3D <- mSetObj$analSet$nmds$nmds3D
  } else {
    #AddErrMsg("3D scores plot requires atleast 3 numeric variables!")
    stop("3D scores plot requires at least 3 numeric variables!")
  }
  metaData <- mSetObj$analSet$nmds$metaData
  samp.scores3D <- mSetObj$analSet$nmds$sample.scores3D
  var.scores3D <- mSetObj$analSet$nmds$var.scores3D
  distance <- mSetObj$analSet$nmds$distance
  
  #Create list to hold plot items
  nmds3D_plot <- list()
  
  if (distance=="euclidean") {
    nmds3D_plot$axis <- paste("MDS", c(1, 2, 3), sep="")
  } else {
    nmds3D_plot$axis <- paste("NMDS", c(1, 2, 3), sep="")
  }

  #Samples (rows)
  sampleCoords <- data.frame(t(as.matrix(samp.scores3D)))
  colnames(sampleCoords) <- NULL
  nmds3D_plot$score$xyz <- sampleCoords
  nmds3D_plot$score$name <- rownames(num_data)
  
  if (is.data.frame(metaData)==FALSE) { #If no meta data
    nmds3D_plot$score$color <- "NA"
    nmds3D_plot$score$point <- "NA"
  } else { #If meta data
    
    #Set up meta data column to use for colors
    if (meta_col_color=="NULL") { 
      meta_col_color_data <- as.data.frame(as.factor(metaData[,1])) #Default meta data column for labeling with color is the first
      meta_col_color_name <- colnames(metaData)[1]
    } else {
      meta_col_color_data <- as.data.frame(as.factor(metaData[,meta_col_color])) #User inputted meta data column for labeling with colors, options given to java using function meta.columns() below
      meta_col_color_name <- meta_col_color
    }

    #Color options
    n <- nlevels(meta_col_color_data[,1]) #Determine how many different colors are needed based on the levels of the meta data

    if (color=="NULL") { #Default
      colors <- viridis(n) #Assign a color to each level using the viridis pallete (viridis package)
      cols <- colors[meta_col_color_data[,1]]
    } else if (color=="plasma") {
      colors <- plasma(n+1) #Assign a color to each level using the plasma pallete (viridis package)
      cols <- colors[meta_col_color_data[,1]]
    } else if (color=="grey") {
      colors <- grey.colors(n, start=0.1, end=0.75) #Assing a grey color to each level (grDevices package- automatically installed)
      cols <- colors[meta_col_color_data[,1]]
    } else { 
      colors <- "black"
      cols <- rep("black", times=n)
    }

    #Assign colors
    nmds3D_plot$score$color <- col2rgb(cols)
  }
  
  #Variables (columns)
  if (var_arrows=="false") {
    nmds3D_plot$scoreVar$xyzVar <- "NA"
    nmds3D_plot$scoreVar$nameVar <- "NA"
    nmds3D_plot$scoreVar$colorVar <- "NA"
  } else {
    variableCoords <- data.frame(t(as.matrix(var.scores3D)))
    colnames(variableCoords) <- NULL
    nmds3D_plot$scoreVar$xyzVar <- variableCoords
    nmds3D_plot$scoreVar$nameVar <- colnames(num_data)
    if (color=="none") {
      nmds3D_plot$scoreVar$colorVar <- col2rgb("black")
    } else {
      nmds3D_plot$scoreVar$colorVar <- col2rgb("darkred")
    }
  }

  #From metaboanalyst, unclear what it does
  if(mSetObj$dataSet$type.cls.lbl=="integer"){
    cls <- as.character(sort(as.factor(as.numeric(unique(mSetObj$dataSet$cls))[mSetObj$dataSet$cls])))
  }else{
    cls <- as.character(mSetObj$dataSet$cls)
  }

  if(all.numeric(cls)){
    cls <- paste("Group", cls)
  }

  nmds3D_plot$score$facA <- cls
  
  imgName <- paste(imgName, ".json", sep="")
  json.obj <- RJSONIO::toJSON(nmds3D_plot, .na='null')
  sink(imgName)
  cat(json.obj)
  sink()
  
  if(!.on.public.web){
    return(.set.mSet(mSetObj))
  }
}




#'Produce NMDS stress plot
#'@description Produce NMDS stress plot (stress is the mismatch between the rank order of distances in the data, and the rank order of distances in the ordination)
#'@param mSetObj Input name of the created mSet Object
#'@param k The dimension of interest
#'@param imgName Input the image name
#'@param format Select the image format, "png" or "pdf", default is "png" 
#'@param dpi Input the dpi. If the image format is "pdf", users need not define the dpi. For "png" images, 
#'the default dpi is 72. It is suggested that for high-resolution images, select a dpi of 300.  
#'@param width Input the width, there are 2 default widths. The first, width=NULL, is 10.5.
#'The second default is width=0, where the width is 7.2. Otherwise users can input their own width
#'@author Louisa Normington\email{normingt@ualberta.ca}
#'University of Alberta, Canada
#'License: GNU GPL (>= 2)
#'@export
Plot.NMDS.stress <- function(mSetObj=NA, k="NULL", imgName, format="png", dpi=72, width=NA) {
  
  library("vegan")

  #Extract necessary objects from mSetObj
  mSetObj <- .get.mSet(mSetObj)

  distance <- mSetObj$analSet$nmds$distance

  if (k=="NULL") {
    k <- 1
    nmds <- mSetObj$analSet$nmds$nmds1D
  } else if (k=="2") {
    nmds <- mSetObj$analSet$nmds$nmds2D
  } else if (k=="3") {
    nmds <- mSetObj$analSet$nmds$nmds3D
  } else if (k=="4") {
    nmds <- mSetObj$analSet$nmds$nmds4D
  } else if (k=="5") {
    nmds <- mSetObj$analSet$nmds$nmds5D
  } else if (k=="6") {
    nmds <- mSetObj$analSet$nmds$nmds6D
  } else if (k=="7") {
    nmds <- mSetObj$analSet$nmds$nmds7D
  } else if (k=="8") {
    nmds <- mSetObj$analSet$nmds$nmds8D
  }
  
  stress <- nmds$stress
  stress_eq <- paste0("Stress Statistic=", signif(stress,2))
  if (distance=="euclidean") {
    main <- "Metric Multidimensional Scaling"
  } else {
    main <- "Non-metric Multidimensional Scaling"
  }

  #Set plot dimensions
  if(is.na(width)){
    w <- 10.5
  } else if(width==0){
    w <- 7.2
  } else{
    w <- width
  }
  h <- w
  
  #Name plot for download
  imgName <- paste(imgName, "dpi", dpi, ".", format, sep="")
  mSetObj$imgSet$Plot.NMDS.stress <- imgName
  
  #Stress plot
  Cairo::Cairo(file=imgName, unit="in", dpi=dpi, width=w, height=h, type=format, bg="white")
  par(xpd=FALSE, mar=c(5.1, 4.1, 6.1, 2.1)) 
  stressplot(nmds, main=paste0(main, "\nDimension ", k,"\nShepard Plot\n\n"), yaxt="n")
  axis(2, las=2)
  mtext(stress_eq, side=3)
  dev.off()

  return(.set.mSet(mSetObj))
}



#'Produce NMDS scree plot
#'@description Produce NMDS stress plot
#'@param mSetObj Input name of the created mSet Object
#'@param imgName Input the image name
#'@param format Select the image format, "png" or "pdf", default is "png" 
#'@param dpi Input the dpi. If the image format is "pdf", users need not define the dpi. For "png" images, 
#'the default dpi is 72. It is suggested that for high-resolution images, select a dpi of 300.  
#'@param width Input the width, there are 2 default widths. The first, width=NULL, is 10.5.
#'The second default is width=0, where the width is 7.2. Otherwise users can input their own width
#'@author Louisa Normington\email{normingt@ualberta.ca}
#'University of Alberta, Canada
#'License: GNU GPL (>= 2)
#'@export
Plot.NMDS.scree <- function(mSetObj=NA, dim_num="NULL", imgName, format="png", dpi=72, width=NA) {
  
  #Extract necessary objects from mSetObj
  mSetObj <- .get.mSet(mSetObj)
  nmds1D <- mSetObj$analSet$nmds$nmds1D
  nmds2D <- mSetObj$analSet$nmds$nmds2D
  num_data <- mSetObj$analSet$nmds$num_data
  distance <- mSetObj$analSet$nmds$distance
  
  if (dim_num=="NULL") {
    dim_numb <- 2
    pcvars <- c(nmds1D[["stress"]], nmds2D[["stress"]])
    cumvars <- c(pcvars[1], pcvars[1]+pcvars[2]) 
  }
  if (dim_num=="3") {
    dim_numb <- 3
    nmds3D <- mSetObj$analSet$nmds$nmds3D
    pcvars <- c(nmds1D[["stress"]], nmds2D[["stress"]], nmds3D[["stress"]])
    cumvars <- c(pcvars[1], pcvars[1]+pcvars[2], pcvars[1]+pcvars[2]+pcvars[3]) 
  }
  if (dim_num=="4") {
    dim_numb <- 4
    nmds3D <- mSetObj$analSet$nmds$nmds3D
    nmds4D <- mSetObj$analSet$nmds$nmds4D
    pcvars <- c(nmds1D[["stress"]], nmds2D[["stress"]], nmds3D[["stress"]], nmds4D[["stress"]])
    cumvars <- c(pcvars[1], pcvars[1]+pcvars[2], pcvars[1]+pcvars[2]+pcvars[3], pcvars[1]+pcvars[2]+pcvars[3]+pcvars[4]) 
  }
  if (dim_num=="5") {
    dim_numb <- 5
    nmds3D <- mSetObj$analSet$nmds$nmds3D
    nmds4D <- mSetObj$analSet$nmds$nmds4D
    nmds5D <- mSetObj$analSet$nmds$nmds5D
    pcvars <- c(nmds1D[["stress"]], nmds2D[["stress"]], nmds3D[["stress"]], nmds4D[["stress"]], nmds5D[["stress"]])
    cumvars <- c(pcvars[1], pcvars[1]+pcvars[2], pcvars[1]+pcvars[2]+pcvars[3], pcvars[1]+pcvars[2]+pcvars[3]+pcvars[4], pcvars[1]+pcvars[2]+pcvars[3]+pcvars[4]+pcvars[5])
  }
  if (dim_num=="6") {
    dim_numb <- 6
    nmds3D <- mSetObj$analSet$nmds$nmds3D
    nmds4D <- mSetObj$analSet$nmds$nmds4D
    nmds5D <- mSetObj$analSet$nmds$nmds5D
    nmds6D <- mSetObj$analSet$nmds$nmds6D
    pcvars <- c(nmds1D[["stress"]], nmds2D[["stress"]], nmds3D[["stress"]], nmds4D[["stress"]], nmds5D[["stress"]], nmds6D[["stress"]])
    cumvars <- c(pcvars[1], pcvars[1]+pcvars[2], pcvars[1]+pcvars[2]+pcvars[3], pcvars[1]+pcvars[2]+pcvars[3]+pcvars[4], pcvars[1]+pcvars[2]+pcvars[3]+pcvars[4]+pcvars[5], pcvars[1]+pcvars[2]+pcvars[3]+pcvars[4]+pcvars[5]+pcvars[6])
  }
  if (dim_num=="7") {
    dim_numb <- 7
    nmds3D <- mSetObj$analSet$nmds$nmds3D
    nmds4D <- mSetObj$analSet$nmds$nmds4D
    nmds5D <- mSetObj$analSet$nmds$nmds5D
    nmds6D <- mSetObj$analSet$nmds$nmds6D
    nmds7D <- mSetObj$analSet$nmds$nmds7D
    pcvars <- c(nmds1D[["stress"]], nmds2D[["stress"]], nmds3D[["stress"]], nmds4D[["stress"]], nmds5D[["stress"]], nmds6D[["stress"]], nmds7D[["stress"]])
    cumvars <- c(pcvars[1], pcvars[1]+pcvars[2], pcvars[1]+pcvars[2]+pcvars[3], pcvars[1]+pcvars[2]+pcvars[3]+pcvars[4], pcvars[1]+pcvars[2]+pcvars[3]+pcvars[4]+pcvars[5], pcvars[1]+pcvars[2]+pcvars[3]+pcvars[4]+pcvars[5]+pcvars[6], pcvars[1]+pcvars[2]+pcvars[3]+pcvars[4]+pcvars[5]+pcvars[6]+pcvars[7])
  }
  if (dim_num=="8") {
    dim_numb <- 8
    nmds3D <- mSetObj$analSet$nmds$nmds3D
    nmds4D <- mSetObj$analSet$nmds$nmds4D
    nmds5D <- mSetObj$analSet$nmds$nmds5D
    nmds6D <- mSetObj$analSet$nmds$nmds6D
    nmds7D <- mSetObj$analSet$nmds$nmds7D
    nmds8D <- mSetObj$analSet$nmds$nmds8D
    pcvars <- c(nmds1D[["stress"]], nmds2D[["stress"]], nmds3D[["stress"]], nmds4D[["stress"]], nmds5D[["stress"]], nmds6D[["stress"]], nmds7D[["stress"]], nmds8D[["stress"]])
    cumvars <- c(pcvars[1], pcvars[1]+pcvars[2], pcvars[1]+pcvars[2]+pcvars[3], pcvars[1]+pcvars[2]+pcvars[3]+pcvars[4], pcvars[1]+pcvars[2]+pcvars[3]+pcvars[4]+pcvars[5], pcvars[1]+pcvars[2]+pcvars[3]+pcvars[4]+pcvars[5]+pcvars[6], pcvars[1]+pcvars[2]+pcvars[3]+pcvars[4]+pcvars[5]+pcvars[6]+pcvars[7], pcvars[1]+pcvars[2]+pcvars[3]+pcvars[4]+pcvars[5]+pcvars[6]+pcvars[7]+pcvars[8])
  }
  
  scree_data <- data.frame(paste("NMDS ", 1:dim_numb), pcvars, cumvars)
  colnames(scree_data) <- c("Dimension", "Stress", "Cumulative Stress")
  write.csv(scree_data, file="nmds_scree_data.csv", row.names=FALSE)
  
  miny<- 0
  maxy<- min(max(cumvars)+0.2, 1);

  if (distance=="euclidean") {
    main <- "Metric Multidimensional Scaling Scree Plot"
  } else {
    main <- "Non-metric Multidimensional Scaling Scree Plot"
  }

  #Set plot dimensions
  if(is.na(width)){
    w <- 10.5
  } else if(width==0){
    w <- 7.2
  } else{
    w <- width
  }
  h <- w*2/3
  
  #Name plot for download
  imgName <- paste(imgName, "dpi", dpi, ".", format, sep="")
  mSetObj$imgSet$Plot.NMDS.scree <- imgName
  
  #Scree plot
  Cairo::Cairo(file=imgName, unit="in", dpi=dpi, width=w, height=h, type=format, bg="white")

  #par(xpd=FALSE, mar=c(5.1, 4.1, 4.1, 2.1)) 
  par(mar=c(5,5,6,3));
  plot(pcvars, type='l', col='blue', main=main, xlab='Number of Dimensions', ylab='Stress', ylim=c(miny, maxy), axes=F)
  text(pcvars, labels =paste(100*round(pcvars,3),'%'), adj=c(-0.3, -0.5), srt=45, xpd=T)
  points(pcvars, col='red');
  
  lines(cumvars, type='l', col='green')
  text(cumvars, labels =paste(100*round(cumvars,3),'%'), adj=c(-0.3, -0.5), srt=45, xpd=T)
  points(cumvars, col='red');
  
  abline(v=1:5, lty=3);
  axis(2);
  axis(1, 1:length(pcvars), 1:length(pcvars));

  dev.off()

  return(.set.mSet(mSetObj))
}




##############################################
##############################################
########## Utilities for web-server ##########
##############################################
##############################################

#'Determine number and names of meta data columns for ordination plotting'
#'@description Java will use the meta data columns to enable user options for selecting meta data for ordination plotting
#'@param mSetObj Input name of the created mSetObject 
#'@author Louisa Normington\email{normingt@ualberta.ca}
#'University of Alberta, Canada
#'License: GNU GPL (>= 2)
#'@export
nmds.meta.columns <- function(mSetObj=NA) {
  
  mSetObj <- .get.mSet(mSetObj)
  metaData <- mSetObj$analSet$nmds$metaData
  if (is.data.frame(metaData)==FALSE) {
    name.all.meta.cols <- "No groupings"
  } else {
    name.all.meta.cols <- c(colnames(metaData), "No groupings")
  }
  return(name.all.meta.cols)
  
}

#'Determine number of possible dimensions for Shepard plot
#'@description Java will use the dimension numbers to enable user options for Shepard plot
#'@param mSetObj Input name of the created mSetObject 
#'@author Louisa Normington\email{normingt@ualberta.ca}
#'University of Alberta, Canada
#'License: GNU GPL (>= 2)
#'@export
nmds.stress.dim <- function(mSetObj=NA) {
  mSetObj <- .get.mSet(mSetObj)
  num_data <- mSetObj$analSet$nmds$num_data
  dim <- ncol(num_data)
  max <- min(dim, 8)
  nmds.stress.dim.opts <- 1:max
  return(nmds.stress.dim.opts)
}

#'Determine number of possible dimensions for scree plot
#'@description Java will use the dimension numbers to enable user options for scree plot
#'@param mSetObj Input name of the created mSetObject 
#'@author Louisa Normington\email{normingt@ualberta.ca}
#'University of Alberta, Canada
#'License: GNU GPL (>= 2)
#'@export
nmds.scree.dim <- function(mSetObj=NA) {
  mSetObj <- .get.mSet(mSetObj)
  num_data <- mSetObj$analSet$nmds$num_data
  dim <- ncol(num_data)
  max <- min(dim, 8)
  nmds.scree.dim.opts <- 2:max
  return(nmds.scree.dim.opts)
}

#'Obtain results'
#'@description Java will use the stored results as needed for the results page
#'@param mSetObj Input name of the created mSetObject 
#'@author Louisa Normington\email{normingt@ualberta.ca}
#'University of Alberta, Canada
#'License: GNU GPL (>= 2)
#'@export
ord.nmds.get.results <- function(mSetObj=NA){
  
  mSetObj <- .get.mSet(mSetObj)
  ord.nmds.result <- c(mSetObj$analSet$nmds)
  return(ord.nmds.result)
  
}