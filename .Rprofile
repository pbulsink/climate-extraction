options(help_type="html")
options(prompt=">")
options(continue="   +")
# options(prompt=">")
# options(continue="    ")
# options(error=utils::recover) # error loop to find exact location of script error

if(Sys.info()[7]=="rapeek") {
  root<-"C://Users//rapeek.AD3//Dropbox//R//"
} else if (Sys.info()[7]=="ryanpeek") {
  root<-"//Users//ryanpeek//Dropbox/R/"
}


.First <- function(){
	cat("\nYarRRR!\n-------------------\nClimate Extraction\n",sep="")
	cat("-------------------\n\n",sep="")
	  
	if(file.exists(paste(root,"//functions//RWatershedFunctions.r",sep=""))){
	  source(paste(root,"//functions//RWatershedFunctions.r",sep=""))
	  cat("RWatershedFunctions.r was loaded, to view list of current functions type:\n",sep="")
	  cat("print.functions()\n\n",sep="")
	} else {
	  print(cat("no RWatershedFunctions file found, check dir\n",sep=""))
	}	
}


#library(dplyr)
library(ggplot2)
#library(grid)
#library(scales)
#library(tidyr)
#library(reshape)
#library(lubridate)
#library(rmarkdown)
#library(shiny)
#library(shinyapps)

cat("\014")
cat(R.version$version.string,"\n",sep="")
