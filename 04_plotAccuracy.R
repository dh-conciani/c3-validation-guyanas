## compute accuracy from test datasets
## dhemerson.costa@IPAM.org.br

## read libraries
library (ggplot2)
library (reshape2)
library (dplyr)
library (tidyr)
library (tools)

### USER PARAMETERS #####
## CSV's path
path <- './CSV/'

## color palette
palette <- c('purple', 'green4')

## define type of plot (1= average, 2= by region, 3= average by country)
typePlot <- 1

### DONT CHANGE AFTER THIS LINE #######

## define functions to read data
## parse GEE tables using regex
importTables <- function (x) {
  files <- list.files(x)
  recipe <- as.data.frame(NULL)
  
  for (i in 1:length(files)) {
    tab <- read.csv(paste0(path, files[i]))$result_array
    tab <- as.data.frame(na.omit(gsub("^, $", NA, 
                                      gsub("^$", NA, 
                                           strsplit(gsub("[]]", ")", 
                                                         gsub("[[]", "(",
                                                              substr(x= tab, start= 2, stop= nchar(tab)-1))), 
                                                    split= "[()]", fixed= FALSE)[[1]]))))
    colnames(tab)[1] <- "data"
    tab <- tab %>% separate(data, sep=",", into=c("Region","Year","Accuracy"))
    tab$Level <- file_path_sans_ext(files[i])
    recipe <- rbind(recipe, tab)
  }
  ## replace 0 by NA
  recipe$Accuracy <- as.numeric(recipe$Accuracy)
  recipe[recipe == 0] <- NA
  str(recipe)
  return(recipe)
}

## pre-format data types
formatData <- function(x) {
  #x$Region <- as.factor(as.numeric(x$Region))
  x$Year <- as.factor(as.numeric(x$Year))
  x$Accuracy <- as.numeric(x$Accuracy)
  x$Region = gsub("^50201.0$", "50201", x$Region)
  x$Region = gsub("^50202.0$", "50202", x$Region)
  x$Region = gsub("^50203.0$", "50203", x$Region)
  x$Region = gsub("^50204.0$", "50204", x$Region)
  x$Region = gsub("^50205.0$", "50205", x$Region)
  x$Region = gsub("^50903.0$", "50903", x$Region)
  x$Region = gsub("^50904.0$", "50904", x$Region)
  x$Region = gsub("^60208.0$", "60208", x$Region)
  x$Region = gsub("^60209.0$", "60209", x$Region)
  x$Region = gsub("^80206.0$", "80206", x$Region)
  x$Region = gsub("^80207.0$", "80207", x$Region)

    return(x)
}

## calc average
calcAverage <- function (x) {
  #temp <- subset(x, Level != "COL5")
  temp <- aggregate(x$Accuracy, by=list(x$Level, x$Year), FUN= "mean", na.rm= TRUE, na.action= NULL)
  temp$Region <- as.factor("Average")
  colnames(temp)[1] <- "Level"
  colnames(temp)[2] <- "Year"
  colnames(temp)[3] <- "Accuracy"
  x <- rbind (x, temp)
  return (x)
}

## calc average by region 
calcAverage_byCountry <- function(x) {
  french <- subset(x, Region == '60208' | Region == '60209')
  suriname <- subset(x, Region == '80206' | Region == '80207')
  
  guyana <- subset(x, Region == '50201' | Region == '50202' |
                      Region == '50203' | Region == '50204' |
                      Region == '50205' | Region == '50903' |
                      Region == '50904')
  
  ## calc average
  french <- aggregate(french$Accuracy, by=list(french$Level, french$Year), FUN= "mean",na.rm= TRUE, na.action= NULL)
  french$Country <- "French Guiana"
  suriname <- aggregate(suriname$Accuracy, by=list(suriname$Level, suriname$Year), FUN= "mean", na.rm= TRUE, na.action= NULL)
  suriname$Country <- "Suriname"
  guyana <- aggregate(guyana$Accuracy, by=list(guyana$Level, guyana$Year), FUN= "mean", na.rm= TRUE, na.action= NULL)
  guyana$Country <- "Guyana"
  
  ## bind
  temp <- rbind (french, suriname, guyana)
  
  ## rename cols
  colnames(temp)[1] <- "Level"
  colnames(temp)[2] <- "Year"
  colnames(temp)[3] <- "Accuracy"
  
  return (temp)
}

## import data
acc_data <- calcAverage(formatData(importTables(x= path)))
acc_country <- calcAverage_byCountry(formatData(importTables(x= path)))


## plot all filters by region

#if (typePlot == 1) {
  ## Only Average of all regions
  ggplot (subset(acc_data, Region == "Average"), aes(x=as.factor(Year), y= Accuracy, colour=Level)) +
    facet_wrap(~Region) +
    geom_line(aes(group= Level), size=1, alpha=0.7) +
    scale_colour_manual(values=palette) +
    geom_point(alpha=0.5, aes(pch=Level)) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 75, vjust = 0.5, hjust=0.5)) +
    scale_x_discrete(breaks=c('1985', '1987', '1989', '1991', '1993', '1995', '1997', '1999',
                              '2001', '2003', '2005', '2007', '2009', '2011', '2013', '2015',
                              '2018')) + xlab("Year") 
 
#if (typePlot == 2) {
  ggplot (acc_data, aes(x=as.factor(Year), y= Accuracy, colour=Level)) +
    facet_wrap(~Region) +
    geom_line(aes(group= Level), size=1, alpha=0.7) +
    scale_colour_manual(values=palette) +
    geom_point(alpha=0.5, aes(pch=Level)) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 75, vjust = 0.5, hjust=0.5)) +
    scale_x_discrete(breaks=c('1985', '1987', '1989', '1991', '1993', '1995', '1997', '1999',
                              '2001', '2003', '2005', '2007', '2009', '2011', '2013', '2015',
                              '2018')) + xlab("Year") 
#}

#if (typePlot == 3) {
  ggplot (acc_country, aes(x=as.factor(Year), y= Accuracy, colour=Level)) +
    facet_wrap(~Country) +
    geom_line(aes(group= Level), size=1, alpha=0.7) +
    scale_colour_manual(values=palette) +
    geom_point(alpha=0.5, aes(pch=Level)) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 75, vjust = 0.5, hjust=0.5)) +
    scale_x_discrete(breaks=c('1985', '1987', '1989', '1991', '1993', '1995', '1997', '1999',
                              '2001', '2003', '2005', '2007', '2009', '2011', '2013', '2015',
                              '2018')) + xlab("Year") 
#}
 
## compute mean by region
aggregate(acc_data$Accuracy, by=list(acc_data$Region, acc_data$Level), FUN= "mean", na.rm= TRUE, na.action= NULL)

## compute mean by country
aggregate(acc_country$Accuracy, by=list(acc_country$Country, acc_country$Level), FUN= "mean", na.rm= TRUE, na.action= NULL)

## compute mean by collection
average <- subset(acc_data, Region == "Average")
aggregate(average$Accuracy, by=list(average$Level), FUN= "mean", na.rm= TRUE, na.action= NULL)
