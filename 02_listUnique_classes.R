## list unique classes

# load libraries
library (sf)

## read data using string encoding
data <- read_sf('./DATA/valPoints_Guianas.shp', options = "ENCODING=WINDOWS-1252")

## extract all unique classes from each year and past into a recipe
recipe <- as.data.frame(NULL)

## list years to process
years <- c(1985, 1986, 1987, 1988, 1989, 1990, 1991, 1992, 1993, 1994,
           1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004,
           2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014,
           2015, 2016, 2017, 2018)

## extract unique classes for each year 
for (i in 1:length(years)) {
  print(paste0('processing the year of ', years[i]))
  temp <- as.data.frame(data[paste0('CLASS_', years[i])])[1]
  temp <- unique(temp)
  colnames(temp)[1] <- 'class'
  ## and bind into recipe 
  recipe <- rbind(temp,recipe)
  rm(temp)
} 

## extract unique values across all the years
LAPIG_classes <- unique(recipe)
print (LAPIG_classes)

## the result is:
## Sin consolidar
## No Observado
## Río, Lago u Océano
## Formación Forestal
## Mosaico de Agricultura y/o Pasto
## Formación Natural No Forestal Inundable
## Área sin Vegetación
## Otra Formación Natural No Forestal
## Manglar
## Error
