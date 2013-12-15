# INSTALL AND LOAD NEEDED PACKAGES
#
toInstallCandidates <- c("RJDBC", "ggplot2", "reshape2", "plyr")
# check if pkgs are already present
toInstall <- toInstallCandidates[!toInstallCandidates%in%library()$results[,1]] 
if(length(toInstall)!=0)
{install.packages(toInstall, repos = "http://cran.r-project.org")}
# load pkgs
lapply(toInstallCandidates, library, character.only = TRUE)