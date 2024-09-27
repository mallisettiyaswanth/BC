const assert = require("assert");
const ganache = require("ganache");
const { Web3 } = require("web3");
const web3 = new Web3(ganache.provider());
const { interface, bytecode } = require("./compile");

let accounts;
let index;

beforeEach(async () => {
  accounts = await web3.eth.getAccounts();
});

describe("Index", () => {
  it("deploys a contract", async () => {
    index = await new web3.eth.Contract(JSON.parse(interface))
      .deploy({ data: bytecode, arguments: [] })
      .send({ from: accounts[0], gas: "1000000" });
  });

  it("has a default message", async () => {
    j;
    const indexValue = await index.methods.getIndexValue().call();
    assert.equal(indexValue, 0);
  });

  it("set index values", async () => {
    await index.methods.setIndexValue(1).send({ from: accounts[0] });
    const indexValue = await index.methods.getIndexValue().call();
    assert.equal(indexValue, 1);
  });
});
