/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  const _MOSSAI_Storage = await ethers.getContractFactory('MOSSAI_Storage')
  const MOSSAI_Storage = await upgrades.deployProxy(_MOSSAI_Storage, [process.env.ADMIN_Wallet_Address])
  await MOSSAI_Storage.waitForDeployment()

  const contract = await ethers.getContractFactory('MOSSAI_Island_Airdrop')
  const instance = await upgrades.deployProxy(contract, [process.env.ADMIN_Wallet_Address])
  await instance.waitForDeployment()

  console.info('Hyperdust_Storage:', MOSSAI_Storage.target)

  await (await MOSSAI_Storage.setServiceAddress(instance.target)).wait()

  await (await instance.setContractAddress(['0x250a7629d076581d3713f016727204341865920C', '0xe05599cA89aA8Af73Ef688350800B1444543aF6D', '0x4AEBF64Edd8C5Fd1f99e88b28fC404Ccd4b1dB67', MOSSAI_Storage.target])).wait()

  console.info('contractFactory address:', instance.target)
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
