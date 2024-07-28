/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  const abiCoder = new ethers.AbiCoder()

  const MOSSAI_Island_NFT = await ethers.deployContract('MOSSAI_721', [process.env.ADMIN_Wallet_Address, 'MOSSAI_Island_NFG', 'MIN'])
  await MOSSAI_Island_NFT.waitForDeployment()

  const _MOSSAI_Storage = ethers.getContractFactory('MOSSAI_Storage')
  const MOSSAI_Storage = await upgrades.deployProxy(_MOSSAI_Storage, [process.env.ADMIN_Wallet_Address])
  await MOSSAI_Storage.waitForDeployment()

  const _MOSSAI_Island_NFG = await ethers.getContractFactory('MOSSAI_Island_NFG')
  const instance = await upgrades.deployProxy(_MOSSAI_Island_NFG, [process.env.ADMIN_Wallet_Address])

  await (await MOSSAI_Storage.setServiceAddress(instance.target)).wait()

  await (await instance.setContractAddress(['0x5745090BFB28C3399223215DfbBb4e729aeF8cFD', MOSSAI_Storage.target, MOSSAI_Island_NFT.target])).wait()

  await (await MOSSAI_Island_NFT.grantRole('0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6', instance.target)).wait()

  const IHyperAGI_Roles_Cfg = await ethers.getContractAt('IHyperAGI_Roles_Cfg', '0x5745090BFB28C3399223215DfbBb4e729aeF8cFD')

  await (await IHyperAGI_Roles_Cfg.addAdmin(instance.target)).wait()

  console.info('MOSSAI_Island_NFT address:', MOSSAI_Island_NFT.target)
  console.info('MOSSAI_Storage address:', MOSSAI_Storage.target)

  console.info('contractFactory address:', instance.target)
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
