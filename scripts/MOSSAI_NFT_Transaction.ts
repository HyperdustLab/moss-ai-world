/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  const _MOSSAI_Storage = await ethers.getContractFactory('MOSSAI_Storage')
  const MOSSAI_Storage = await upgrades.deployProxy(_MOSSAI_Storage, [process.env.ADMIN_Wallet_Address])
  await MOSSAI_Storage.waitForDeployment()

  const contract = await ethers.getContractFactory('MOSSAI_NFT_Transaction')
  const instance = await upgrades.deployProxy(contract, [process.env.ADMIN_Wallet_Address])
  await instance.waitForDeployment()

  console.info('MOSSAI_Storage:', MOSSAI_Storage.target)

  await (await instance.setContractAddress(['0xde265B8AD8F05856fFdca33ECFB504f1778594F5', '0x7a798E8eC045f911684dAa28B38a54b883b9523C', '0x9AbbDA5A44ecAdABcD171FfD338c4D65439edc0F', MOSSAI_Storage.target])).wait()

  const IHyperAGI_Roles_Cfg = await ethers.getContractAt('IHyperAGI_Roles_Cfg', '0xF13842B9E794A0970DCbCa245B963d3d0d804317')

  await (await IHyperAGI_Roles_Cfg.addAdmin(instance.target)).wait()

  const MOSSAI_NFT_Product = await ethers.getContractAt('MOSSAI_NFT_Product', '0xde265B8AD8F05856fFdca33ECFB504f1778594F5')

  await (await MOSSAI_NFT_Product.setNFTMarketAddress(instance.target)).wait()

  console.info('contractFactory address:', instance.target)
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
