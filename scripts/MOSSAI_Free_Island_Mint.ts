/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  const contract = await ethers.getContractFactory('MOSSAI_Free_Island_Mint')
  const instance = await upgrades.deployProxy(contract, [process.env.ADMIN_Wallet_Address])
  await instance.waitForDeployment()

  await (await instance.setContractAddress(['0x464624655495544E62a8504260cf9Fc9128EbA8C', '0x401f50176C74F0aa49FeF7Aea83eeB349bEABF19', '0x9f106E08EfF47a4E1b3340937A14B465E5B74fff', '0x464C1776f492e54d775fb82e93c13aCCDc8AA633'])).wait()

  const IHyperAGI_Roles_Cfg = await ethers.getContractAt('IHyperAGI_Roles_Cfg', '0x7B33C8D43C52d0c575eACaEcFdAd68487bfB28Ea')

  await (await IHyperAGI_Roles_Cfg.addAdmin(instance.target)).wait()

  console.info('contractFactory address:', instance.target)
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
