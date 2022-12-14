# This script should be called by server to load actual scripts
# based on the modules user selected
general_files <- c("general_data_utils","general_misc_utils","general_load_libs");

general_stat_files <- c("general_norm_utils","general_proc_utils", "general_data_assumption");
stats_files <- c("stats_chemometrics","stats_classification","stats_clustering", "stats_correlations", "stats_sigfeatures","stats_univariates");
correlation_files <- c("correlation_linear", "correlation_penalized", "correlation_polynomial", "correlation_ml", "correlation_multivariate", "correlation_SVM", "correlation_RF", "correlation_logistic");
dispersal_files <- c("dispersal");
plotting_files <- c("plotting", "plotting_pie", "plotting_bargraph", "plotting_boxplot");
ordination_files <- c("ord_nmds", "ord_pcoa", "ord_cia", "ord_dca", "ord_anosim", "ord_rda", "ord_bray", "ord_cca", "ord_ca", "ord_dca");

diversity_files <- c("div_divindices","div_rarefaction", "div_abundance_dist", "div_accumulation_model", "div_taxonomic", "div_fd", "div_unseen");

taxonomy_files <- c();
cluster_files <- c();
general_anot_files <- "general_anot_utils";

enrich_files <- c("enrich_graphics","enrich_mset","enrich_name_match","enrich_stats");
pathway_files <- c("enrich_mset","enrich_stats","enrich_name_match","enrich_path_graphics","enrich_path_kegg","enrich_path_stats")
integmex_files <- c("enrich_integ","enrich_path_kegg","enrich_stats","enrich_name_match")
biomarker_power_files <- c("biomarker_utils", "power_utils");
time_files <-c("time_asca_heatmap2","time_pca_anova2", "time_mb");
mummichog_files <- c("mummichog", "networks");
metaanal_files <- c("meta_methods", "meta_data_utils");
network_files <- c("networks", "enrich_integ", "enrich_name_match", "gene_fun_utils", "enrich_path_kegg");
other_files <- c("others_batch_check", "others_lipomics", "enrich_name_match");
nmds_files <- c("test-Vegan", "dispersal", "plotting");

nmds_files <- c("test-Vegan","Dispersal");
LoadScripts <- function(module.nm = "nmds"){
    file.sources <- "";

    if(module.nm == "stat"){
        file.sources <- c(general_files, general_stat_files, stats_files);

    }else if(module.nm == "ts"){
        file.sources <- c(general_files, general_stat_files, time_files);
    }else if(module.nm == "pathinteg"){
        file.sources <- c(general_files, general_anot_files, integmex_files);
    }else if(substring(module.nm, 1,4) == "path"){
        file.sources <- c(general_files, general_stat_files, general_anot_files,  pathway_files);
    }else if(substring(module.nm, 1,4) == "mset"){
        file.sources <- c(general_files, general_stat_files, general_anot_files, enrich_files);
    }else if(module.nm == "roc" | module.nm == "power"){
        file.sources <- c(general_files, general_stat_files, biomarker_power_files);
    }else if(module.nm == "utils"){
        file.sources <- c(general_files, other_files);
    }else if(module.nm == "network"){
        file.sources <- c(general_files, general_anot_files, network_files);
    }else if(module.nm == "mummichog"){
        file.sources <- c(general_files, mummichog_files);
    }else if(module.nm == "metadata"){
        file.sources <- c(general_files, general_stat_files, metaanal_files);
    }else if(module.nm == "nmds"){
        file.sources <- c(general_files, general_stat_files, stats_files, nmds_files);
        
    }else if(module.nm == "dispersal"){
        file.sources <- c(general_files, general_stat_files, stats_files, dispersal_files);
        
    }else if(module.nm == "ca"){
        file.sources <- c(general_files, general_stat_files, stats_files, correlation_files);
    
    }else if(module.nm == "plotting"){
        file.sources <- c(general_files, general_stat_files, stats_files, plotting_files);
    
    }else if(module.nm == "ord"){
        file.sources <- c(general_files, general_stat_files, stats_files, ordination_files);

    }else if(module.nm == "diversity"){
        file.sources <- c(general_files, general_stat_files, stats_files, diversity_files);
    
    }else if(module.nm == "cluster"){
        file.sources <- c(general_files, general_stat_files, stats_files, cluster_files);
    
    }else if(module.nm == "taxon"){
        file.sources <- c(general_files, general_stat_files, stats_files, taxonomy_files);

    }else{
        print(paste("Unknown module code: ", module.nm));
    }

    if(file.exists("/home/glassfish/rscripts/metaboanalyst/")){
        file.sources <- paste("/home/glassfish/rscripts/metaboanalyst/", file.sources, ".Rc", sep="");
    }else{
        file.sources <- paste("../../rscripts/metaboanalystr/", file.sources, ".Rc", sep="");
    }

    library(compiler);
    sapply(file.sources,loadcmp,.GlobalEnv);
}

CompileScripts <- function(){
    # detect if this is on the public server with compiled script already
    if(file.exists("/home/glassfish/rscripts/metaboanalyst/")){
        print("Using already compiled R codes on server .... ");
        return("TRUE");
    }else{
        library(compiler);
        print("compiling R codes .... ");
        files <- list.files("../rscripts/metaboanalystr",full.names=TRUE, pattern=".R$");
        for(f in files){
            cmpfile(f, paste(f, "c", sep=""), options=list(suppressAll=TRUE));
        }
        return("TRUE");
    }
}


# some rarely used functions will be loaded only when user explicitly call it to save memory
LoadRareFunctions <- function(module.nm = "spls"){
    if(module.nm == "spls"){
        if(file.exists("/home/glassfish/rscripts/metaboanalyst/")){
            loadcmp("/home/glassfish/rscripts/metaboanalyst/stats_spls.Rc");
        }else{
            loadcmp("../../rscripts/metaboanalystr/stats_spls.Rc");
        }
    }else{
        print(paste("Unknown module code: ", module.nm));
    }
}

LoadReporter <- function(module.nm = "stat"){
    general_files <-"sweave_reporter";
    if(module.nm == "stat"){
        file.sources <- c(general_files, "sweave_report_stats");
    }else if(module.nm == "ts"){
        file.sources <- c(general_files, "sweave_report_time");
    }else if(module.nm == "pathinteg"){
        file.sources <- c(general_files, "sweave_report_integmex");
    }else if(substring(module.nm, 1,4) == "path"){
        file.sources <- c(general_files, "sweave_report_pathway");
    }else if(module.nm == "roc" | module.nm == "power"){
        file.sources <- c(general_files, "sweave_report_biomarker", "sweave_report_power");
    }else if(module.nm == "utils"){
        file.sources <- c(general_files, other_files);
    }else if(substring(module.nm, 1,4) == "mset"){
        file.sources <- c(general_files, "sweave_report_enrichment");
    }else if(module.nm == "network"){
        file.sources <- c(general_files, "sweave_report_network");
    }else if(module.nm == "mummichog"){
        file.sources <- c(general_files, "sweave_report_mummichog");
    }else if(module.nm == "metadata"){
        file.sources <- c(general_files, "sweave_report_meta_analysis");
    }else{
        print(paste("Unknown module code: ", module.nm));
    }

    if(file.exists("/home/glassfish/rscripts/metaboanalyst/")){
        file.sources <- paste("/home/glassfish/rscripts/metaboanalyst/", file.sources, ".Rc", sep="");
    }else{
        file.sources <- paste("../../rscripts/metaboanalystr/", file.sources, ".Rc", sep="");
    }

    sapply(file.sources,loadcmp,.GlobalEnv);
}