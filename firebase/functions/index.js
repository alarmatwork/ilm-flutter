const admin = require('firebase-admin');
const functions = require('firebase-functions');
const { saveStationData } = require('./generic_importer');

admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.triggerUpdate = functions.https.onRequest(async (request, response) => {
    const pluginTarktee = require("./plugins/tarktee_importer");
    const pluginIlmateenistus = require("./plugins/ilmateenistus_importer");
    const pluginMiinisadam = require("./plugins/miinisadam_importer");

    let [tarkteeResult, ilmateenistusResult] = await Promise.all([pluginTarktee.importTarktee(), pluginIlmateenistus.importIlmateenistus(), pluginMiinisadam.importMiinisadam()]);

    console.log("All imports DONE");
    response.json({ tarkteeResult: tarkteeResult, ilmateenistusResult: ilmateenistusResult });
});

exports.loadTartkteeLocationsFromXML = functions.https.onRequest(async (request, response) => {
    const tarkteeLocationParser = require("./plugins/tarktee_location_parser");
    const fs = require('fs');
    let xmlString = fs.readFileSync("data/tarktee_locations.xml", "utf8");

    let json = tarkteeLocationParser.parseXml(xmlString);
    let locationData = json.d2LogicalModel.payloadPublication.measurementSiteTable

    console.log("Parsing DONE");
    //Weather Station Info
    let result = {}
    locationData[1].measurementSiteRecord.forEach((record) => {
        result[record.measurementSiteName.values.value.trim()] = record.measurementSiteLocation.pointByCoordinates.pointCoordinates;
    });

   // console.log(result);

    let db = admin.firestore();
    let stationsRef = db.collection('stations');
    let allStations = stationsRef.get()
        .then(snapshot => {
            snapshot.forEach(doc => {

                const data = doc.data();
                let locatonData = result[data['name'].trim()];
                console.log("'", data['name'], "' looking ", locatonData);
                if (locatonData && doc.id.startsWith("TT")) {
                    let stationRecord = {
                        id: doc.id,
                        location: new admin.firestore.GeoPoint(locatonData.latitude, locatonData.longitude)
                    };
                    console.log('Updating: ', stationRecord);
                    saveStationData(stationRecord);
                }

            });
        })
        .catch(err => {
            console.log('Error getting documents', err);
        });

    response.json(result);

});

exports.data = functions.https.onRequest((request, response) => {
    let db = admin.firestore();
    let stationsRef = db.collection('stations');

    let result = {};
    let allStations = stationsRef.get()
        .then(snapshot => {
            snapshot.forEach(doc => {
                result[doc.id] = doc.data();
            });
            response.json(result);
        })
        .catch(err => {
            console.log('Error getting documents', err);
        });


});

exports.scheduledTarkteeUpdate = functions.pubsub.schedule('every 30 minutes').onRun((context) => {
    console.log('Triggering Updates -TarkTee');
    const pluginTarktee = require("./plugins/tarktee_importer");
    let tarkteePromise = pluginTarktee.importTarktee().catch(error => { console.log('caught', err.message); });

    console.log("Update Scheduler finished tarkteeResult: ", tarkteePromise);
    return tarkteePromise;
});


exports.scheduledIlmateenistusUpdate = functions.pubsub.schedule('10 */1 * * *').onRun((context) => {
    console.log('Triggering Updates - Ilmateenistus');
    const pluginIlmateenistus = require("./plugins/ilmateenistus_importer");
    let ilmateenistusPromise = pluginIlmateenistus.importIlmateenistus().catch(error => { console.log('caught', err.message); });

    console.log('Update Scheduler finished ilmateenistusResult: ', ilmateenistusPromise);

    return ilmateenistusPromise;
});


exports.scheduledMiinisadamaUpdate = functions.pubsub.schedule('every 10 minutes').onRun((context) => {
    console.log('Triggering Updates - Miinisadam');
    const plugin = require("./plugins/miinisadam_importer");
    let importPromise = plugin.importMiinisadam().catch(error => { console.log('caught', err.message); });

    console.log('Update Scheduler finished: ', importPromise);

    return importPromise;
});

function getURLParams(url) {
    if (url.indexOf('/') < 0) {
        return []
    }

    const params = url.substring(url.indexOf("/") + 1, url.length).split("/");
    console.log(url + " -> ", params);
    return params;

}