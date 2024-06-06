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

  await (await instance.setContractAddress(['0xF76de0Db8323840DCB8c03c7BB6218112325c376', '0xb2342E1Bf4B4e0d340B97F5CdD8Fd9Cf24525D26', '0x859133fA725Cd252FD633E0Bc9ef7BbA270d6BE7', MOSSAI_Storage.target])).wait()

  const IHyperAGI_Roles_Cfg = await ethers.getContractAt('IHyperAGI_Roles_Cfg', '0x5745090BFB28C3399223215DfbBb4e729aeF8cFD')

  await (await IHyperAGI_Roles_Cfg.addAdmin(instance.target)).wait()

  const MOSSAI_NFT_Product = await ethers.getContractAt('MOSSAI_NFT_Product', '0xF76de0Db8323840DCB8c03c7BB6218112325c376')

  await (await MOSSAI_NFT_Product.setNFTMarketAddress(instance.target)).wait()

  console.info('contractFactory address:', instance.target)
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
