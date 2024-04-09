import { HardhatUserConfig } from "hardhat/config";
require("@nomiclabs/hardhat-ethers");
import "@nomicfoundation/hardhat-toolbox-viem";
require("dotenv").config();

const CHAINID = process.env.CHAINID ? Number(process.env.CHAINID) : 80001;

export enum CHAINID_CONFIG {
  ETH_MAINNET = 1,
  MATIC = 137,
  MUMBAI = 80001,
}

export const TEST_URI = {
  [CHAINID_CONFIG.ETH_MAINNET]: process.env.TEST_URI,
  [CHAINID_CONFIG.MATIC]: process.env.TEST_URI,
  [CHAINID_CONFIG.MUMBAI]: process.env.MUMBAI_URI,
};

export default {
  accounts: {
    mnemonic: process.env.TEST_MNEMONIC,
  },
  paths: {
    // sources: "contracts/infrastructure/vaults/",
    deploy: "scripts/deploy",
    deployments: "deployments",
  },

  solidity: {
    compilers: [
      {
        version: "0.8.20",
        settings: {
          optimizer: {
            runs: 125,
            enabled: true,
          },
        },
      },
      {
        version: "0.5.17",
        settings: {
          optimizer: {
            runs: 125,
            enabled: true,
          },
        },
      },
    ],
  },
  networks: {
    hardhat: {
      accounts: {
        mnemonic: process.env.TEST_MNEMONIC,
      },
      hardhat: {
        blockTime: 0,
      },
      chainId: CHAINID,
      allowUnlimitedContractSize: true,
      timeout: 100_000,
    },
    mumbai: {
      url: process.env.MUMBAI_URI,
      chainId: 80001,
      gas: 2100000,
      gasPrice: 8000000000,
      accounts: {
        mnemonic: process.env.MUMBAI_MNEMONIC,
      },
    },
    matic: {
      url: process.env.MATIC_URI,
      chainId: 137,
      accounts: {
        mnemonic: process.env.MATIC_MNEMONIC,
      },
    },
  },
  dodoc: {
    // TODO: issue with description not being generated for parameters of functions where the function has some structs as parameters https://github.com/primitivefinance/primitive-dodoc/pull/39
    runOnCompile: false,
    debugMode: false,
  },
  mocha: {
    timeout: 500000,
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  gasReporter: {
    enabled: true,
  },
};
