## Climate NA Extract and Plot
## R Peek 2015

## Extract ClimateNA data from each point that falls within the Humboldt NFWR "Extent_Poly.shp"

# LOAD LIBRARIES and LOCATIONS --------------------------------------------

library(dplyr)
library(stringr)
# library(ggplot2)

fold1 = "./data/processed/CNA_humboldt_near_mid_far/"
fold2 = "./data/processed/CNA_humboldt_Normals_MSY/"
fold3 = "./data/processed/CNA_humboldt_1901-2012MSYT/"
zones = "./data/shps/CA_HUC8_and_all_Region18.shp"
projection = "+proj=longlat +datum=NAD83"
outfolder = "./outputs/Humbolt_Bay/"

# GET FILES AND SPLIT -----------------------------------------------------

# get list of data csvs
filelist1<-list.files(fold1,full.names=F) # near mid far
filelist2<-list.files(fold2,full.names=F) # Humboldt Normals
filelist3<-list.files(fold3,full.names=F) # fwd pred for 1 model

# clip head and tail of filename
filenames1<-str_sub(filelist1,start = 14, end=-5)
filenames2<-str_sub(filelist2,start = 14, end=-5)
filenames3<-str_sub(filelist3,start = 14, end=-5)
filenames1 # modeled near-mid-far
filenames2 # normals
filenames3 # one future predicted model

# get only diff time periods
s2020s<-filenames1[c(grep("202.",filenames1))]
s2050s<-filenames1[c(grep("205.",filenames1))]
s2080s<-filenames1[c(grep("208.",filenames1))]

# names (double check)
s2020s
s2050s
s2080s

# get Normals (all metrics: S=seasonal, M=monthly, Y=ann)
normals.MSY<-filenames3[c(grep("^Normal",filenames2))]
normals.MSY

# MERGE CSVS --------------------------------------------------------------

# function to read and merge files into one dataframe
read_merge_CNA<-function(datafile,dfoutname){
  df<- lapply(paste0(fold,"CNA_humboldt_",datafile,".csv"),
                function(x) {read.csv(file=x, header=T)})
  names(df) <- datafile # assign names to list of dataframes

# Add column with name of model
  for(i in seq_along(df)){
    df[[i]]$modname<-datafile[i]
  }
  
  ### check number of rows/cols per group
  for(i in seq_along(df)){
    cat(names(df[i]), " Rows/Cols=", dim(df[[i]]), "\n")
  }
  
  # use dplyr function to merge the csvs
  dff<-bind_rows(df)
  #print(h(dff))
  print(names(dff))
  assign(x=dfoutname,value = dff,envir = .GlobalEnv)
}

# use the function

# seasonal.2050s
read_merge_CNA(s2020s,"df20s")
# seasonal.2050s
read_merge_CNA(s2050s,"df50s")
# s.2080s
read_merge_CNA(s2080s,"df80s")

# normals.MSY
read_merge_CNA(normals.MSY,"dfnorms.MSY")

# SIMPLE PLOT OF GIVEN VARIABLE -------------------------------------------

selectmod<-as.character(s.2050s[1])

#humboldt<-df50s[df50s$modname==selectmod,]
humboldt<-dplyr::filter(df50s, modname==selectmod)
with(humboldt, plot(Longitude, Latitude, col="maroon",type="p"))


# NON-FUNCTION OF MERGE CSVs ---------------------------------------------

# # seasonal.2080
# dat2080<- lapply(paste0(fold,"CNA_humboldt_",seasonal.2080s,".csv"),function(x) {read.csv(file=x, header=T)})
# names(dat2080) <- seasonal.2080s # assign names to list of dataframes
# 
# # Add column with name of model
# for(i in seq_along(dat2080)){
#   dat2080[[i]]$model<-seasonal.2080s[i]
# }
# 
# ### check number of rows/cols per group
# for(i in seq_along(dat2080)){
#   cat(names(dat2080[i]), " Rows/Cols=", dim(dat2080[[i]]), "\n")
# }
# 
# # use dplyr function to merge the csvs
# df80s<-bind_rows(dat2080)
# h(df80s)
# names(df80s)

# SUMMARIZING -------------------------------------------------------------

# use dplyr magic to calc mean, sd, and se for each variable 
# over the ~400+ grid pts in Humboldt Polygon

# set up standard error function
se<-function(x) {sd(x)/sqrt(length(x))}

df50.mod<-df50s %>% 
  group_by(modname) %>% 
  select(Elevation:RH_at) %>% 
  summarise_each(funs(mean, sd, se))

summary(df50.mod)

df80.mod<-df80s %>% 
  group_by(modname) %>% 
  select(Elevation:RH_at) %>% 
  summarise_each(funs(mean, sd, se))


dfnorms.MSY.mod<-dfnorms.MSY %>% 
  group_by(modname) %>% 
  select(Elevation:RH_at) %>% 
  summarise_each(funs(mean, sd, se))



# PLOTTING ----------------------------------------------------------------

# df50
ggplot(df50.mod, aes(x = PPT_sp_mean, y = Tmax_sp_mean, color = modname)) + geom_point(size = 8) + 
  geom_errorbarh(aes(xmax = PPT_sp_mean + PPT_sp_sd, 
                     xmin = PPT_sp_mean - PPT_sp_sd), height = .1,lwd=1, alpha = .5) +
  geom_errorbar(aes(ymax = Tmax_sp_mean + Tmax_sp_sd, 
                    ymin = Tmax_sp_mean - Tmax_sp_sd), height=0.025, lwd=1, alpha = .5) +
  theme_bw() + labs(list(x = "Mean Spring Precip (mm)", y = "Mean Spring max monthly Temp", title = "ClimateNA 2055")) +
  geom_vline(xintercept = mean(df50.mod$PPT_sp_mean)) + geom_hline(yintercept = mean(df50.mod$Tmax_sp_mean)) 

# df80
ggplot(df80.mod, aes(x = PPT_sp_mean, y = Tmax_sp_mean, color = modname)) + geom_point(size = 8) + 
  geom_errorbarh(aes(xmax = PPT_sp_mean + PPT_sp_sd, 
                     xmin = PPT_sp_mean - PPT_sp_sd), height = .1,lwd=1, alpha = .5) +
  geom_errorbar(aes(ymax = Tmax_sp_mean + Tmax_sp_sd, 
                    ymin = Tmax_sp_mean - Tmax_sp_sd), height=0.04, lwd=1, alpha = .5) +
  theme_bw() + labs(list(x = "Mean Spring Precip (mm)", y = "Mean Spring max monthly Temp", title = "ClimateNA 2085")) +
  geom_vline(xintercept = mean(df80.mod$PPT_sp_mean)) + geom_hline(yintercept = mean(df80.mod$Tmax_sp_mean)) 


# dfNorms
ggplot(dfnorms.MSY.mod, aes(x = PPT_sp_mean, y = Tmax_sp_mean, color = modname)) + geom_point(size = 6) + ylim(c(24,28))+
  geom_errorbarh(aes(xmax = PPT_sp_mean + PPT_sp_sd, 
                     xmin = PPT_sp_mean - PPT_sp_sd), height = 0.02,lwd=1, alpha = .5) +
  geom_errorbar(aes(ymax = Tmax_sp_mean + Tmax_sp_sd, 
                    ymin = Tmax_sp_mean - Tmax_sp_sd), height=0.02, lwd=1, alpha = .5) +
  theme_bw() + labs(list(x = "Mean Spring Precip (mm)", y = "Mean Spring max monthly Temp", title = "ClimateNA Norms")) +
  geom_vline(xintercept = mean(dfnorms.MSY.mod$PPT_sp_mean)) + geom_hline(yintercept = mean(dfnorms.MSY.mod$Tmax_sp_mean)) 


# COMPRESS FILES ----------------------------------------------------------

# ZIP FILES

# fullpath<-file.path("./data/processed/",rivtype)
# fullpath
# list.files(fullpath,recursive=TRUE,full.names=TRUE)
# tar(file.path(fullpath,"reg_v5_tar.tgz"),fullpath,compression='gzip')



# DONE!!

# REMOVE FILES FROM WORKSPACE IF NECESSARY
# rm(list=ls())

