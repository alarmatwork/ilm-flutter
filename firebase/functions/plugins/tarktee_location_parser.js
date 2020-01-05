
function parseXml(xmlString) {
    var parser = require('fast-xml-parser');
    var he = require('he');
    
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
        localeRange: "", //To support non english character in tag/attribute values.
        parseTrueNumberOnly: false,
        arrayMode: false, //"strict"
        attrValueProcessor: (val, attrName) => he.decode(val, { isAttributeValue: true }),//default is a=>a
        tagValueProcessor: (val, tagName) => he.decode(val), //default is a=>a
        stopNodes: ["parse-me-as-string"]
    };

    

    // if (parser.validate(xmlData) === true) { //optional (it'll return an object in case it's not valid)
    //     var jsonObj = parser.parse(xmlData, options);
    // }

    // Intermediate obj
    var tObj = parser.getTraversalObj(xmlString, options);
    json =  parser.convertToJson(tObj, options);
   // console.log(JSON.stringify(json));

    return json;
}

exports.parseXml = parseXml;