require('dotenv').config({ path: `./.env.${process.env.NODE_ENV}` });

import HDWalletProvider from 'truffle-hdwallet-provider';
import web3 from 'web3';
const MNEMONIC = process.env.MNEMONIC;
const NODE_API_KEY = process.env.INFURA_KEY || process.env.ALCHEMY_KEY;
const isInfura = !!process.env.INFURA_KEY;
const FACTORY_CONTRACT_ADDRESS = process.env.FACTORY_CONTRACT_ADDRESS;
const NFT_CONTRACT_ADDRESS = process.env.NFT_CONTRACT_ADDRESS;
const OWNER_ADDRESS = process.env.OWNER_ADDRESS;
const NETWORK = process.env.NETWORK;
const NUM_CREATURES = 1;
import fs from 'fs';
import path from 'path';
import { exit } from 'process';

async function main() {
  if (!MNEMONIC || !NODE_API_KEY || !OWNER_ADDRESS || !NETWORK) {
    console.error(
      'Please set a mnemonic, Alchemy/Infura key, owner, network, and contract address.'
    );
    return;
  }

  const network =
    NETWORK === 'mainnet' || NETWORK === 'live' ? 'mainnet' : 'rinkeby';
  const provider = new HDWalletProvider(
    MNEMONIC,
    isInfura
      ? 'https://' + network + '.infura.io/v3/' + NODE_API_KEY
      : 'https://eth-' + network + '.alchemyapi.io/v2/' + NODE_API_KEY
  );
  const web3Instance = new web3(provider);

  const file = fs.readFileSync(
    path.join(
      path.resolve(__dirname, '..', 'build', 'contracts', 'ExampleNFT.json')
    ),
    { encoding: 'utf8' }
  );

  const factoryContract = new web3Instance.eth.Contract(
    JSON.parse(file).abi,
    FACTORY_CONTRACT_ADDRESS,
    { gas: 1000000 }
  );

  // Creatures issued directly to the owner.
  const result = await factoryContract.methods
    .preserveMint(NUM_CREATURES, OWNER_ADDRESS)
    .send({ from: OWNER_ADDRESS });

  console.log('Minted creature. Transaction: ' + result.transactionHash);
}

main()
  .then(() => {
    console.log('Done.');
    exit(0);
  })
  .catch((err) => {
    console.error(err);
    exit(1);
  });
