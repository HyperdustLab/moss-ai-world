/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  // const MOSSAI_Storage = await ethers.deployContract("MOSSAI_Storage");
  // await MOSSAI_Storage.waitForDeployment()

  const contract = await ethers.getContractFactory('MOSSAI_mNFT_Mint')
  const instance = await upgrades.deployProxy(contract, [process.env.ADMIN_Wallet_Address])
  await instance.waitForDeployment()

  //   console.info('Hyperdust_Storage:', MOSSAI_Storage.target)

  await (await instance.setContractAddress(['0x9bDaf3912e7b4794fE8aF2E748C35898265D5615', '0x01778569225bA43FFDABF872607e1df2Bc83f102', '0x5270b6273fd0E6fA5979EC28c1cB9FE98b8eEBe4', '0xe8ADeF97900b154f89417817C6621cd33D39d009', '0x9eB0b42C4b3D25829851Bc5DE75F7c58d8795EF5'])).wait()

  const MOSSAI_Storage = await ethers.getContractAt('MOSSAI_Storage', '0x9eB0b42C4b3D25829851Bc5DE75F7c58d8795EF5')

  await (await MOSSAI_Storage.setServiceAddress(instance.target)).wait()

  const Hyperdust_Roles_Cfg = await ethers.getContractAt('Hyperdust_Roles_Cfg', '0x9bDaf3912e7b4794fE8aF2E748C35898265D5615')
  await (await Hyperdust_Roles_Cfg.addAdmin(instance.target)).wait()

  console.info('contractFactory address:', instance.target)
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
