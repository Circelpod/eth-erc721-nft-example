const ExampleNFT = artifacts.require("ExampleNFT");

// If you want to hardcode what deploys, comment out process.env.X and use
// true/false;
const DEPLOY_ALL = process.env.DEPLOY_ALL;
const DEPLOY_ACCESSORIES_SALE = process.env.DEPLOY_ACCESSORIES_SALE || DEPLOY_ALL;
const DEPLOY_ACCESSORIES = process.env.DEPLOY_ACCESSORIES || DEPLOY_ACCESSORIES_SALE || DEPLOY_ALL;
const DEPLOY_CREATURES_SALE = process.env.DEPLOY_CREATURES_SALE || DEPLOY_ALL;
// Note that we will default to this unless DEPLOY_ACCESSORIES is set.
// This is to keep the historical behavior of this migration.
const DEPLOY_CREATURES = process.env.DEPLOY_CREATURES || DEPLOY_CREATURES_SALE || DEPLOY_ALL || (! DEPLOY_ACCESSORIES);

module.exports = async (deployer, network, addresses) => {
  await deployer.deploy(ExampleNFT);
};