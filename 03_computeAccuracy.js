// accuracy analysis for Guianas - collection 3
// write to: dhemerson.costa@ipam.org.br and joaquim.pereira@ipam.org.br

// list with all classes avaliable to Guianas:
// Sin consolidar
// No Observado
// Não Observado
// Río, Lago u Océano
// Formación Forestal
// Mosaico de Agricultura y/o Pasto
// Formación Natural No Forestal Inundable
// Área sin Vegetación
// Otra Formación Natural No Forestal
// Manglar
// Error

/////////////////////// ~~~~ user parameters ~~~~ ///////////////////////
// define root path
var root = 'projects/mapbiomas-raisg/COLECCION3/clasificacion-ft';

// define version to filter data
var version = 9;

// define label to identify this dataset
var label = 'validation_c3_v' + version; 

//////////// ~~~~ end of user parameters - do not change from this line ~~~~ /////// 

// load LAPIG validation points
var assetPoints = ee.FeatureCollection('users/vieiramesquita/MAPBIOMAS/mapbiomas_amazonia_50K_RAISG_plus_Brasil_v6');

// load classification regions
var raster_regions = ee.Image('projects/mapbiomas-raisg/DATOS_AUXILIARES/RASTERS/clasificacion-regiones-3');

// extract region ID and paste into points
var assetPoints = raster_regions.reduceRegions({
  collection: assetPoints,
  reducer: ee.Reducer.mean(),
  scale: 30,
});

// load collection 3 classification (pre-integration)
var image = ee.ImageCollection(root)
            .filterMetadata('version', 'equals', version)
            .min();
            
// define regions to be processed
var regioes = [50201, 50202, 50203, 50204, 50205, 50903, 50904,
               60208, 60209,
               80206, 80207
               ];

// define years to be processed 
var anos = [ 
            1985, 1986, 1987, 1988, 1989, 1990, 1991, 1992, 1993, 1994,
            1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004,
            2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014,
            2015, 2016, 2017, 2018
            ];

// exclude this classes from LAPIG validation points (for col6)
var excludedClasses = [
    "Sin consolidar",
    "No Observado",
    "Não Observado",
    "Manglar",
    "Error"
];

// define pixel value that corresponds to each LAPIG class for col 3 
var classes = {
  "Formación Forestal": 3,
  "Formación Natural No Forestal Inundable": 11,
  "Otra Formación Natural No Forestal": 12,
  "Mosaico de Agricultura y/o Pasto": 21,
  "Área sin Vegetación": 25,
  "Río, Lago u Océano": 33,
};

// create class dictionary 
classes = ee.Dictionary(classes);

// define mapbiomas color ramp
var palettes = require('users/mapbiomas/modules:Palettes.js');
var vis = {
    'min': 0,
    'max': 34,
    'palette': palettes.get('classification2')
};

// create empty recipe
var recipe_regiao = ee.List([]);
var recipe_ano = ee.List([]);
var recipe_acc = ee.List([]);

//// Get samples for each year and export using for-loop///
for (var Year in anos){
  var year = anos[Year];
  var ano = anos[Year];
  
  var class_GAP = image.select('classification_' + ano);
  var class_GAP = class_GAP.updateMask(class_GAP.neq(0));

  var amostraTotal = ee.FeatureCollection(assetPoints)
      .filterMetadata('POINTEDITE', 'not_equals', 'TRUE')
      .filter(ee.Filter.inList('CLASS_' + ano, excludedClasses).not())
    .map(
        function (feature) {
            return feature.set('year', ano)
                .set('reference', classes.get(feature.get('CLASS_' + ano)));
        }
    );
    
    for (var i_reg=0;i_reg<regioes.length; i_reg++){
      var regiao = regioes[i_reg];
      var limite = raster_regions.updateMask(raster_regions.eq(regiao));
      
      var class_GAP_reg = class_GAP.updateMask(limite);
      
      var pt_reg = amostraTotal.filterMetadata('mean', 'equals', regiao);

      var valida_reg1 = class_GAP_reg.sampleRegions({collection: pt_reg, properties: ['reference'], scale: 30, geometries: false});
      
      // calc accuracy
      var accuracy= valida_reg1.errorMatrix('classification_' + ano,'reference').accuracy();
      
      // update lists
      recipe_regiao = recipe_regiao.add(regiao);
      recipe_ano = recipe_ano.add(ano);
      recipe_acc = recipe_acc.add(accuracy);
      }
}

// create array with results
var result_array = ee.Array.cat([recipe_regiao, recipe_ano, recipe_acc], 1);
print ('result array', result_array);

// convert array into feature
var feature_array = ee.Feature(null, {
  result_array:result_array
});

// export CSV to googleDrive
Export.table.toDrive({
  collection: ee.FeatureCollection(feature_array),
  description: label,
  folder: 'VALIDATION_CSV_C3',
  fileFormat: 'CSV'
});
