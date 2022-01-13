const ExampleTest = artifacts.require("ExampleNFT");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("ExampleTest", function (accounts) {
  it("should total supply equal 0", async function () {
    const instance = await ExampleTest.deployed();
    const totalSupply = await instance.getTotalSupply.call();
    console.log("totalSupply:", totalSupply);
    return assert.equal(totalSupply.toNumber(), 0);
  });
});
