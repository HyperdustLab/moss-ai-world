/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  const contract = await ethers.getContractFactory('MOSSAI_Free_Island_Mint')
  const instance = await upgrades.deployProxy(contract, [process.env.ADMIN_Wallet_Address])
  await instance.waitForDeployment()

  await (await instance.setContractAddress(['0xA3Ef2A67f40601ca2FE781FFFEb3Cd193a50aaEb', '0x7a798E8eC045f911684dAa28B38a54b883b9523C', '0x8373Bd7e299F6d61490993EDadfF8D61357964E1', '0xcc897DE5965055e90f6c1948bfe41b7519b81EA8'])).wait()

  const IHyperAGI_Roles_Cfg = await ethers.getContractAt('IHyperAGI_Roles_Cfg', '0xF13842B9E794A0970DCbCa245B963d3d0d804317')

  await (await IHyperAGI_Roles_Cfg.addAdmin(instance.target)).wait()

  console.info('contractFactory address:', instance.target)
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
