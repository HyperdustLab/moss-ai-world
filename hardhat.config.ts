/** @format */
require('dotenv').config()
import { HardhatUserConfig } from 'hardhat/config'
import '@nomicfoundation/hardhat-toolbox'
import 'hardhat-gas-reporter'
import '@openzeppelin/hardhat-upgrades'
require('./tasks/extract-metadata')

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.20',
    settings: {
      metadata: {
        useLiteralContent: true,
      },
      optimizer: {
        enabled: true,
        runs: 2000,
        details: {
          yul: true,
          yulDetails: {
            stackAllocation: true,
            optimizerSteps: 'dhfoDgvulfnTUtnIf',
          },
        },
      },
      viaIR: true,
    },
  },
  networks: {
    dev: {
      url: 'HTTP://127.0.0.1:8545',
      accounts: [process.env.PRIVATE_KEY],
      loggingEnabled: true,
      timeout: 50000000, // 增加超时时间到 50000 毫秒
    },
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
      loggingEnabled: true,
    },
    arbitrumSepolia: {
      url: process.env.Arbitrum_Sepolia_Testnet_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
      loggingEnabled: true,
    },
    bvmTest: {
      url: 'https://bitcoin-l2-813183-testnet.tc.l2aas.com/rpc',
      accounts: [process.env.PRIVATE_KEY],
      loggingEnabled: true,
    },
  },
  etherscan: {
    apiKey: {
      sepolia: process.env.ETHERSCAN_API_KEY,
      arbitrumSepolia: process.env.Arbitrum_Sepolia_KEY,
    },
    customChains: [
      {
        network: 'arbitrumSepolia',
        chainId: 421614,
        urls: {
          apiURL: 'https://api-sepolia.arbiscan.io/api',
          browserURL: 'https://sepolia.arbiscan.io/',
        },
      },
    ],
  },
  sourcify: {
    enabled: true,
  },
}

export default config
