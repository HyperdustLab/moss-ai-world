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

  await (await instance.setContractAddress(['0x62655C96fd517DFA283d617Ea0666c1b5b4467EA', '0x401f50176C74F0aa49FeF7Aea83eeB349bEABF19', '0x9f106E08EfF47a4E1b3340937A14B465E5B74fff', MOSSAI_Storage.target])).wait()

  const IHyperAGI_Roles_Cfg = await ethers.getContractAt('IHyperAGI_Roles_Cfg', '0x7B33C8D43C52d0c575eACaEcFdAd68487bfB28Ea')

  await (await IHyperAGI_Roles_Cfg.addAdmin(instance.target)).wait()

  const MOSSAI_NFT_Product = await ethers.getContractAt('MOSSAI_NFT_Product', '0x62655C96fd517DFA283d617Ea0666c1b5b4467EA')

  await (await MOSSAI_NFT_Product.setNFTMarketAddress(instance.target)).wait()

  console.info('contractFactory address:', instance.target)
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
