// read mapbiomas amazonia validation points
var assetPoints = ee.FeatureCollection('users/vieiramesquita/MAPBIOMAS/mapbiomas_amazonia_50K_RAISG_plus_Brasil_v6');

// filter points for each country
var guyana = assetPoints.filterMetadata('COUNTRY', 'equals', 'Guyana');
var suriname = assetPoints.filterMetadata('COUNTRY', 'equals', 'Suriname');
var french = assetPoints.filterMetadata('COUNTRY', 'equals', 'Guayana Francesa');

// merge into a new dataset
var data = guyana.merge(suriname).merge(french);

// inspect
print (data.size());
Map.addLayer(data);

// export as shp to gDrive
Export.table.toDrive({
  collection: data, 
  description: 'valPoints_Guianas', 
  fileNamePrefix: 'valPoints_Guianas', 
  folder: 'TEMP',
  fileFormat: 'SHP'
});
