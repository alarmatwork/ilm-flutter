function saveStationData(record) {
    const admin = require('firebase-admin');
    let db = admin.firestore();
    console.log("Updating station record: " + JSON.stringify(record));
    let stationRef = db.collection('stations').doc(record.id);
    let resultRef = stationRef.set(record, { merge: true });
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
