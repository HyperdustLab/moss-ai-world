/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  const Island_Mint = await ethers.getContractFactory('Island_Mint')
  const instance = await upgrades.deployProxy(Island_Mint, [process.env.ADMIN_Wallet_Address])
  await (
    await instance.setContractAddress([ethers.ZeroAddress, '0x7a798E8eC045f911684dAa28B38a54b883b9523C', '0x8373Bd7e299F6d61490993EDadfF8D61357964E1', '0x6789334f4f38F625cdAE785DE08bB7f824343e6B', '0xC31A364A09c85319cFAc88Bb3F8F0dB874acBeFA', '0xF13842B9E794A0970DCbCa245B963d3d0d804317'])
  ).wait()

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
