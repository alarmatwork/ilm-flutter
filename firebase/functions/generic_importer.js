function saveStationData(record) {
    try {
        const admin = require('firebase-admin');
        let db = admin.firestore();
        
        // console.log("Updating station record: " + JSON.stringify(record));
        let stationRef = db.collection('stations').doc(record.id);
        let resultRef = stationRef.set(record, { merge: true }).catch((err) => {
            console.error("Error happened with SET with record:", record, err);
        });

        return resultRef;
    }
    catch (error) {
        console.error("Error happened with record:", record, error);
    }
}

class StationRecord {
    constructor(id, air_temp, timestamp, name) {
        this.temp = air_temp;
        this.id = id;
        this.updateTimestamp;
        this.name;
    }
}

exports.saveStationData = saveStationData;
exports.StationRecord = StationRecord;
