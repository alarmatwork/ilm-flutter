
'use strict';


const { saveStationData } = require('../generic_importer');
const { StationRecord } = require('../generic_importer');

async function importIlmateenistus() {
    var HTMLParser = require('node-html-parser');
    console.log("START importIlmateenistus")
    // const fs = require('fs');
    // let rawdata = fs.readFileSync('tarktee.json');
    // let data = JSON.parse(rawdata);
    //console.log(data.features);
    var request = require("request");
    let counter = 0;    

    let result = await request({
        uri: "http://www.ilmateenistus.ee/ilm/ilmavaatlused/vaatlusandmed/tunniandmed/",

    }, function (error, response, body) {
        
        if (error) {
            console.error("Did not happen: ", error);
        }

        console.log("Got Ilmateenistus.ee content");

        const cheerio = require('cheerio');
        const $ = cheerio.load(body)

        // Find all rows in data table        
        $('.ajx-container').find('tr').each(function (i, elem) {
            
            if (i > 0) {
                let dataColumns = $(this).text().split('\n');

                var stationRecord = {
                    id: "ILMATEENISTUS_" + dataColumns[1].trim(),
                    name: dataColumns[1].trim(),
                    temp: parseNumber(dataColumns[2]),      //Temperatiure field, might be empty in some cases
                    humidity: parseNumber(dataColumns[3]),
                    windDirection: parseNumber(dataColumns[6]),
                    windSpeed: parseNumber(dataColumns[7]),
                    windSpeedMax: parseNumber(dataColumns[8]),
                    airPressure: parseNumber(dataColumns[4]),
                    visibility: parseNumber(dataColumns[13]),
                    updateTimestamp: new Date()
                };

                if (stationRecord.temp > 0) {
                    saveStationData(stationRecord);
                    counter++;
                }
            }
        });
        
        return counter;
    });

    console.log('END importIlmateenistus updated:', counter);
    return counter;
}


function parseNumber(input) {
    //console.log("IN:", input);
    if (!input) {
        return input;
    }
    input = input.replace(',', '.');
    let trimmerInput = input.trim();
    if (trimmerInput === "") {
        return null;
    }
    return parseFloat(trimmerInput);

}

exports.importIlmateenistus = importIlmateenistus;