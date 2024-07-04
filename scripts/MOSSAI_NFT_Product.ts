/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  const _MOSSAI_Storage = await ethers.getContractFactory('MOSSAI_Storage')
  const MOSSAI_Storage = await upgrades.deployProxy(_MOSSAI_Storage, [process.env.ADMIN_Wallet_Address])
  await MOSSAI_Storage.waitForDeployment()

  const contract = await ethers.getContractFactory('MOSSAI_NFT_Product')
  const instance = await upgrades.deployProxy(contract, [process.env.ADMIN_Wallet_Address])
  await instance.waitForDeployment()

  console.info('MOSSAI_Storage:', MOSSAI_Storage.target)

  await (await instance.setContractAddress([ethers.ZeroAddress, '0xF13842B9E794A0970DCbCa245B963d3d0d804317', MOSSAI_Storage.target, '0xA3Ef2A67f40601ca2FE781FFFEb3Cd193a50aaEb'])).wait()

  // const MOSSAI_NFT_Market = await ethers.getContractAt("MOSSAI_NFT_Market", "0xa52F3f2d571D069B6A3ce0297Ee9438B21400CDf");

  // await (await MOSSAI_NFT_Market.setMOSSAINFTProductAddress(instance.target)).wait();

  console.info('contractFactory address:', instance.target)
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
