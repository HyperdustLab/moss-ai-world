/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  const _Island_Mint = await ethers.getContractFactory('Island_Mint')

  const upgraded = await upgrades.upgradeProxy('0xD18Bd75b4d2311dF45dD846Bb51c077AFAEF55df', _Island_Mint)
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
