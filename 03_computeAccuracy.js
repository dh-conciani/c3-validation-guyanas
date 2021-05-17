// accuracy analysis for Guianas - collection 3
// write to: dhemerson.costa@ipam.org.br and joaquim.pereira@ipam.org.br

// list with all classes avaliable to Guianas:
// Sin consolidar
// No Observado
// Río, Lago u Océano
// Formación Forestal
// Mosaico de Agricultura y/o Pasto
// Formación Natural No Forestal Inundable
// Área sin Vegetación
// Otra Formación Natural No Forestal
// Manglar
// Error

// define root path
var root = 'projects/mapbiomas-raisg/COLECCION3/clasificacion-ft';

// define version to filter data
var version = 9;

// define classification regions 
var regions_vec = ee.FeatureCollection([]);

var regioes = ['50201', '50202', '50203', '50204', '50205', '50903', '50904',
               '60208', '60209',
               '80206', '80207'
               ];
               
var anos = [ 
            1985, 1986, 1987, 1988, 1989, 1990, 1991, 1992, 1993, 1994,
            1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004,
            2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014,
            2015, 2016, 2017, 2018
            ];

// define country boundaries (three guyanas)
var guyanas = ee.FeatureCollection([]);

// mosaic images 
var image = ee.ImageCollection(root)
            .filterMetadata('version', 'equals', version)
            //.filterMetadata('pais', 'equals', 'GUIANA_FRANCESA')
            .min();

// load validation points
var assetPoints = ee.FeatureCollection('users/vieiramesquita/MAPBIOMAS/mapbiomas_amazonia_50K_RAISG_plus_Brasil_v6');

// classes from collection 3
var options = {
  'classes': [3, 11, 12, 21, 25, 33],
  'classNames': ['Formación Forestal', 'Formación Natural No Forestal Inundable', 
                 'Otra Formación Natural No Forestal', 'Mosaico de Agricultura y/o Pasto', 
                 'Área sin Vegetación', 'Río, Lago u Océano']
};

// exclude this classes from LAPIG validation points (for col6)
var excludedClasses = [
    "Sin consolidar",
    "No Observado",
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

// define mapbiomas color ramp
var palettes = require('users/mapbiomas/modules:Palettes.js');
var vis = {
    'min': 0,
    'max': 34,
    'palette': palettes.get('classification2')
};

// plot map
Map.addLayer(image.select(['classification_2020']), vis, 'classification');
Map.addLayer(assetPoints, {}, 'points');

