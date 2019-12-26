
'use strict';

const { saveStationData } = require('../generic_importer');
const { StationRecord } = require('../generic_importer');

async function importTarktee() {
    console.log("START importTarktee")
    // const fs = require('fs');
    // let rawdata = fs.readFileSync('tarktee.json');
    // let data = JSON.parse(rawdata);
    //console.log(data.features);

    const fetch = require('node-fetch');
    let url = "https://tarktee.mnt.ee/tarktee/rest/services/road_weather_stations/MapServer/0/query?f=json&spatialRel=esriSpatialRelIntersects&returnGeometry=true&outFields=*&outSR=3301&where=1=1";

    let settings = { method: "Get" };
    let counter = 0;

    let result = await fetch(url, settings)
        .then(res => res.json())
        .then((data) => {
            data.features.forEach(incoming => {
                try {


                    var record = incoming.attributes;
                    //    console.log("Incoming data: ", record);

                    var stationRecord = {
                        id: 'TT_' + record.objectid + "_" + record.site_name,
                        name: record.site_name,
                        temp: record.air_temp,
                        tempRoad: record.road_temp,
                        humidity: record.air_humidity,
                        windDirection: record.wind_dir,
                        windSpeed: record.wind_speed,
                        updateTimestamp: new Date(),
                        measuredTimeStamp: new Date(record.measurement_time),
                        type: 'TARKTEE'
                    };

                    if (record.air_temp > 0) {
                        saveStationData(stationRecord);
                        counter++;
                    }
                } catch (error) {
                    console.error("Tarktee error happened: ", error);
                }

            });
            return counter;
        });

    console.log('END importTarktee updated:', counter);
    return counter;
}



exports.importTarktee = importTarktee;