function saveStationData(record) {
    try {
        const admin = require('firebase-admin');
        let db = admin.firestore();

        // console.log("Updating station record: " + JSON.stringify(record));
        let stationRef = db.collection('stations').doc(record.id);
        let resultRef = stationRef.set(record).catch((err) => {
            console.error("Error happened with SET with record:", record, error);
        });

        return resultRef;
    }
    catch (exports) {
        console.error("Error happened with record:", record, exports);
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
