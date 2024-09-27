const path = require("path");
const fs = require("fs");
const solc = require("solc");

const pathToContract = path.resolve(__dirname, "contracts", "index.sol");
const source = fs.readFileSync(pathToContract, "utf8");

const exportData = solc.compile(source, 1).contracts[":Index"];

module.exports = exportData;
