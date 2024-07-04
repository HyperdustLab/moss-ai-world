/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  const _MOSSAI_Storage = await ethers.getContractFactory('MOSSAI_Storage')
  const MOSSAI_Storage = await upgrades.deployProxy(_MOSSAI_Storage, [process.env.ADMIN_Wallet_Address])
  await MOSSAI_Storage.waitForDeployment()

  // const MOSSAI_Storage = await ethers.getContractAt('MOSSAI_Storage', '0x4165B41f1880cC54ac31b529e5a0a2ca25f924c1')

  const contract = await ethers.getContractFactory('MOSSAI_Island')
  const instance = await upgrades.deployProxy(contract, [process.env.ADMIN_Wallet_Address])
  await instance.waitForDeployment()

  console.info('Hyperdust_Storage:', MOSSAI_Storage.target)

  await (
    await instance.setContractAddress([
      '0x6789334f4f38F625cdAE785DE08bB7f824343e6B',
      '0x998cCb1dF5d0b9599c8067882D75a95889a6914A',
      '0xfc4E8E43E17B3d9bD05038E24D20cAACBe3eF97b',
      '0x4ad5C6047f8f49f465dF18FfE2F5B15c730918c5',
      '0xF13842B9E794A0970DCbCa245B963d3d0d804317',
      MOSSAI_Storage.target,
      '0x50D9DC9f388A840b77AA7067D6a2AC7c2635578e',
      '0x74BD810D6C5978cdd35873ee64244F563b78Bc6e',
    ])
  ).wait()

  const IHyperAGI_Roles_Cfg = await ethers.getContractAt('IHyperAGI_Roles_Cfg', '0x5745090BFB28C3399223215DfbBb4e729aeF8cFD')

  await (await IHyperAGI_Roles_Cfg.addAdmin(instance.target)).wait()

  await (await MOSSAI_Storage.setServiceAddress(instance.target)).wait()

  await (await instance.setDefParameter('https://s3.hyperdust.io/upload/2024/3/11/e78b4816-4b81-4241-ac19-cb5758f300df.png', 'https://s3.hyperdust.io/upload/2024/3/4/7d012ce0-9bd0-48f1-ba2c-49228936a250.7z', 'db055fa3753903af2075421cd0b9977fa9390f808c46ac628adcb65bc6bbae51')).wait()

  const Island_Mint = await ethers.getContractAt('Island_Mint', '0x50D9DC9f388A840b77AA7067D6a2AC7c2635578e')

  await (await Island_Mint.setIslandAddress(instance.target)).wait()

  console.info('contractFactory address:', instance.target)
}

// We recommend this pattern to be able to use async/await everywhere q

// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
