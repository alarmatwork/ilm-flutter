
'use strict';


const { saveStationData } = require('../generic_importer');
const { StationRecord } = require('../generic_importer');
const windyKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjaSI6MjIwNzUzNywiaWF0IjoxNjA0NzU2MTUxfQ.q1YmK5fC4VqPclnxWykZbXe03hIpqziwfoSgtKTqf0g';
const axios = require('axios');
const { post } = require('request');

async function importMiinisadam() {
    var HTMLParser = require('node-html-parser');
    console.log("START importIlmateenistus")
    // const fs = require('fs');
    // let rawdata = fs.readFileSync('tarktee.json');
    // let data = JSON.parse(rawdata);
    //console.log(data.features);

    const fetch = require('node-fetch');

    let counter = 0;

    let url = "http://on-line.msi.ttu.ee/miinisadam/";

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
            const rawDate = $('#h_last_measurement').text().split('\n')[3].trim();
            const measuredTimeStampValue = getDate(rawDate);

            const windSpeed = parseNumber($('.tuulekiirus').text().split(' ')[0].trim());
            const windSpeedMax = parseNumber($('.tuulepuhang').text().split(' ')[1].trim());
            const temp = parseNumber($('.ohutemp').text().split(' ')[0].trim());
            const waterTemp = parseNumber($('.veetemp').text().split(' ')[0].trim());
            const waveLen = parseNumber($('.laineperiood').text().split(' ')[0].trim());
            const waveHeight = parseNumber($('.laine').text().split(' ')[0].trim());
            const waveMax = parseNumber($('.lainemax').text().split(' ')[1].trim());

            const humidity = parseNumber($('.niiskus').text().split(' ')[0].trim());
            const windDirection = parseNumber($('.tuulesuund').text().replace("°", '').trim());
            const airPressure = parseNumber($('.rohk').text().split(' ')[0].trim());
            const visibility = parseNumber($('.nahtavus').text().split(' ')[0].trim());
            const waterLevel = parseNumber($('.veetase').text().split(' ')[0].trim());

            var stationRecord = {
                id: "MS_0",
                name: 'Miinisadam',
                windSpeed: windSpeed,
                windSpeedMax: windSpeedMax,
                temp: temp,

                humidity: humidity,
                windDirection: windDirection,
                airPressure: airPressure,
                visibility: visibility,

                // precipitationIntensity: parseNumber(dataColumns[12], 1),
                updateTimestamp: new Date(),
                measuredTimeStamp: measuredTimeStampValue,
                type: 'MERI',
                //Water related info
                waterTemp: waterTemp,
                waveLen: waveLen,
                waveHeight: waveHeight,
                waveMax: waveMax,
                waterLevel: waterLevel
            };

            let windyRecord = {
                // stations: [
                //     { stationId: 0, name: "Miinisadam", lat: 59.45528799630199, lon: 24.72721014171839, elevation: 3, tempheight: 3, windheight: 3 },
                // ],
                observations: [
                    { station: 0, dateutc: getFormattedString(rawDate).substr(0, 19), temp: temp, visibility: visibility, mbar: airPressure, wind: windSpeed, winddir: windDirection, gust: windSpeedMax, rh: humidity },
                ]
            }

            console.log("Windy RECORD: " + JSON.stringify(windyRecord));
            console.log(stationRecord);

            if (stationRecord.temp) {
                saveStationData(stationRecord);
                counter++;
            } else {
                console.warn("Not saving...", stationRecord);
            }
            postWindy(windyRecord);
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
    /*
07.11.2020 13:30    
    */
    console.log(`IN DATE: ${rawDate}`);
    let formatted =
        getFormattedString(rawDate);

    console.log("Formatted: '" + formatted + "'");

    let parsedDate = Date.parse(formatted);
    // console.log('Parsed: ', parsedDate);
    return new Date(parsedDate);


}

function getFormattedString(rawDate) {
    return rawDate.substring(6, 10) //year
        + '-'
        + rawDate.substring(3, 5) // month
        + '-'
        + rawDate.substring(0, 2)
        + 'T'
        + ('0' + (parseNumber(rawDate.substring(11, 13)) - 2)).substr(-2)
        + rawDate.substring(13, 16)
        + ":00.000Z";
}

function postWindy(record) {
    axios({
        method: 'post',
        url: 'https://stations.windy.com/pws/update/' + windyKey,
        data: record
    }).then((result) => {
        console.log(`Windy Update: ${result.statusText} ${result.status}`);
    });
}

exports.importMiinisadam = importMiinisadam;