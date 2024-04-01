/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  const MOSSAI_mNFT_Mint = await ethers.getContractFactory('MOSSAI_mNFT_Mint')

  upgrades.forceImport('0xc4C9D2e1723CF88C5fD92Ff85c1091fb211eBE87', MOSSAI_mNFT_Mint)

  await upgrades.upgradeProxy('0xc4C9D2e1723CF88C5fD92Ff85c1091fb211eBE87', MOSSAI_mNFT_Mint)
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
