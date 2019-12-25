const admin = require('firebase-admin');
const functions = require('firebase-functions');

admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.triggerUpdate = functions.https.onRequest(async (request, response) => {
    const pluginTarktee = require("./plugins/tarktee_importer");
    const pluginIlmateenistus = require("./plugins/ilmateenistus_importer");

    let [tarkteeResult, ilmateenistusResult] = await Promise.all([pluginTarktee.importTarktee(), pluginIlmateenistus.importIlmateenistus()]);

    console.log("All imports DONE");
    response.json({ tarkteeResult: tarkteeResult, ilmateenistusResult: ilmateenistusResult });
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

    console.log('Update Scheduler finished ilmateenistusResult: ',ilmateenistusPromise);

    return ilmateenistusPromise;
});


function getURLParams(url) {
    if (url.indexOf('/') < 0) {
        return []
    }

    const params = url.substring(url.indexOf("/") + 1, url.length).split("/");
    console.log(url + " -> ", params);
    return params;

}