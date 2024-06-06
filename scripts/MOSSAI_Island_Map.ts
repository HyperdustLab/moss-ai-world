/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  const _MOSSAI_Storage = await ethers.getContractFactory('MOSSAI_Storage')
  const MOSSAI_Storage = await upgrades.deployProxy(_MOSSAI_Storage, [process.env.ADMIN_Wallet_Address])
  await MOSSAI_Storage.waitForDeployment()

  const contract = await ethers.getContractFactory('MOSSAI_Island_Map')
  const instance = await upgrades.deployProxy(contract, [process.env.ADMIN_Wallet_Address])
  await instance.waitForDeployment()

  console.info('Hyperdust_Storage:', MOSSAI_Storage.target)

  await (await MOSSAI_Storage.setServiceAddress(instance.target)).wait()

  await (await instance.setContractAddress(['0x5745090BFB28C3399223215DfbBb4e729aeF8cFD', MOSSAI_Storage.target])).wait()

  console.info('contractFactory address:', instance.target)
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
