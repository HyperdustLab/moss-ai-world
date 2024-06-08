/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  const _MOSSAI_NFT_Product = await ethers.getContractFactory('MOSSAI_NFT_Product')

  await upgrades.upgradeProxy('0xF76de0Db8323840DCB8c03c7BB6218112325c376', _MOSSAI_NFT_Product)
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
