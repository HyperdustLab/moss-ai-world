/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  const MOSSAI_NFT_Market = await ethers.getContractFactory('MOSSAI_NFT_Market')

  await upgrades.upgradeProxy('0xE71809e2E799c4ac55A7bCbc324896E30fF0F4c2', MOSSAI_NFT_Market)
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
