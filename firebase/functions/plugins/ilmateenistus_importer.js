
'use strict';


const { saveStationData } = require('../generic_importer');
const { StationRecord } = require('../generic_importer');
var parser = require('fast-xml-parser');
var he = require('he');
const { data } = require('..');

var options = {
    attributeNamePrefix: "@_",
    attrNodeName: "attr", //default is 'false'
    textNodeName: "#text",
    ignoreAttributes: true,
    ignoreNameSpace: false,
    allowBooleanAttributes: false,
    parseNodeValue: true,
    parseAttributeValue: false,
    trimValues: true,
    cdataTagName: "__cdata", //default is 'false'
    cdataPositionChar: "\\c",
    parseTrueNumberOnly: false,
    arrayMode: false, //"strict"
    attrValueProcessor: (val, attrName) => he.decode(val, { isAttributeValue: true }),//default is a=>a
    tagValueProcessor: (val, tagName) => he.decode(val), //default is a=>a
    stopNodes: ["parse-me-as-string"]
};

async function fixIlmateenistusLocationsOnce() {
    const fetch = require('node-fetch');
    var encoding = require("encoding");
    const admin = require('firebase-admin');


    let counter = 0;

    let url = "https://www.ilmateenistus.ee/ilma_andmed/xml/observations.php";

    let dataAsJson = {};
    fetch(url).then(response => response.buffer()).then(buffer => {
        try {
            var someEncodedString = encoding.convert(buffer, "utf-8", "iso-8859-1").toString('utf-8');
            //    console.log(someEncodedString);
            var dataAsJson = parser.parse(someEncodedString, options, true);

            //console.log(JSON.stringify(dataAsJson));

            dataAsJson.observations.station.forEach(station => {
              //  console.log(station);
                //  console.log("Got Ilmateenistus.ee content");
                try {


                    var stationRecord = {
                        id: "IT_" + station.name.trim(),
                        name: station.name.trim(),
                        location: new admin.firestore.GeoPoint(station.latitude, station.longitude),
                        temp: station.airtemperature,      //Temperatiure field, might be empty in some cases

                        // windSpeed: parseNumber(dataColumns[7], 1),
                        // windSpeedMax: parseNumber(dataColumns[8], 1),
                        // airPressure: parseNumber(dataColumns[4], 1),
                        // visibility: parseNumber(dataColumns[13], 1000),
                        // precipitationIntensity: parseNumber(dataColumns[12], 1),
                        // updateTimestamp: new Date(),
                        // measuredTimeStamp: new Date(),
                        type: 'ILMATEENISTUS'
                    };

                    if (station.relativehumidity) {
                        stationRecord.humidity = parseNumber(station.relativehumidity, 1);
                    }
                    if (station.windDirection) {
                        stationRecord.windDirection= parseNumber(station.windDirection, 1);
                    }

                   // console.log(JSON.stringify(stationRecord));

                    if (station.airtemperature !== '') {
                        saveStationData(stationRecord);
                        counter++;
                    } else {
                        console.warn("Not saving...", stationRecord);
                    }
                } catch (error) {
                    console.error("Ilmateenistus error happened:", error);
                }

            });



        } catch (error) {
            console.log(error.message)
        }
    }).then(() => {
        console.log(`DONE`);
    });

}

async function importIlmateenistus() {
    var HTMLParser = require('node-html-parser');
    console.log("START importIlmateenistus")
    // const fs = require('fs');
    // let rawdata = fs.readFileSync('tarktee.json');
    // let data = JSON.parse(rawdata);
    //console.log(data.features);

    const fetch = require('node-fetch');

    let counter = 0;

    let url = "http://www.ilmateenistus.ee/ilm/ilmavaatlused/vaatlusandmed/tunniandmed/";

    let settings = { method: "Get" };


    let result = await fetch(url, settings)
        .then((response) => {
            if (response.ok) {
                return response.text();
            } else {

                throw 'There is something wrong: ' + result.error;
            }

        })
        .then((body) => {
            const cheerio = require('cheerio');
            const $ = cheerio.load(body)
            const rawDate = $('.utc-info').text().trim();
            const measuredTimeStampValue = getDate(rawDate);
            // Find all rows in data table        
            $('.ajx-container').find('tr').each(function (i, elem) {

                //  console.log("Got Ilmateenistus.ee content");

                if (i > 0) {
                    try {
                        let dataColumns = $(this).text().split('\n');

                        var stationRecord = {
                            id: "IT_" + dataColumns[1].trim(),
                            name: dataColumns[1].trim(),
                            temp: parseNumber(dataColumns[2], 1),      //Temperatiure field, might be empty in some cases
                            humidity: parseNumber(dataColumns[3], 1),
                            windDirection: parseNumber(dataColumns[6], 1),
                            windSpeed: parseNumber(dataColumns[7], 1),
                            windSpeedMax: parseNumber(dataColumns[8], 1),
                            airPressure: parseNumber(dataColumns[4], 1),
                            visibility: parseNumber(dataColumns[13], 1000),
                            precipitationIntensity: parseNumber(dataColumns[12], 1),
                            updateTimestamp: new Date(),
                            measuredTimeStamp: measuredTimeStampValue,
                            type: 'ILMATEENISTUS'
                        };

                        if (stationRecord.temp) {
                            saveStationData(stationRecord);
                            counter++;
                        } else {
                            console.warn("Not saving...", stationRecord);
                        }
                    } catch (error) {
                        console.error("Ilmateenistus error happened:", error);
                    }
                }
            });

            return counter;
        });

    console.log('END importIlmateenistus updated:', counter, " result:" + result);
    return counter;
}


function parseNumber(input, multiplier) {
    if (!multiplier) {
        multiplier = 1;
    }
    //console.log("IN:", input);
    if (!input) {
        return input;
    }


    input = input.replace(',', '.');
    let trimmerInput = input.trim();
    if (trimmerInput === "") {
        return null;
    }
    return parseFloat(trimmerInput) * multiplier;

}

function getDate(rawDate) {

    let formatted =
        rawDate.substring(10, 14) //year
        + '-'
        + rawDate.substring(7, 9) // month
        + '-'
        + rawDate.substring(4, 6)
        + 'T'
        + rawDate.substring(15, 20)
        + ":00.000Z";

    console.log("Formatted: '" + formatted + "'");

    let parsedDate = Date.parse(formatted);
    // console.log('Parsed: ', parsedDate);
    return new Date(parsedDate);


}

exports.importIlmateenistus = importIlmateenistus;
exports.fixIlmateenistusLocationsOnce = fixIlmateenistusLocationsOnce;