/** @format */

import { ethers } from 'hardhat'

async function main() {
  const abiCoder = new ethers.AbiCoder()

  const contract = await ethers.deployContract('MOSSAI_1155', [process.env.ADMIN_Wallet_Address, 'MOSSAI 1155', 'MOSSAI'])
  await contract.waitForDeployment()
  console.info('contractFactory address:', contract.target)

  await (await contract.grantRole('0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6', '0x7028141A2BCc684f2204cE7DE4f5C0806b86F987')).wait()

  const initializeData = abiCoder.encode(['address', 'string', 'string'], [process.env.ADMIN_Wallet_Address, 'MOSSAI 1155', 'MOSSAI'])

  console.info('initializeData:', initializeData)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
