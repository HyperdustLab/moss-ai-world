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
      '0x4AEBF64Edd8C5Fd1f99e88b28fC404Ccd4b1dB67',
      '0x98CeC0Fce2D50c7Bbf05D74afa3078547294587D',
      '0xce284A1468ad9c072f8Ad71BD37d48E396EFdAC9',
      '0xE51f97e053cB027EfD9EE05c4B687C43F4499b42',
      '0x250a7629d076581d3713f016727204341865920C',
      MOSSAI_Storage.target,
      ethers.ZeroAddress,
      '0xF3fEe4ba7FE664cE22379B8090152B95805972FE',
    ])
  ).wait()

  const IHyperAGI_Roles_Cfg = await ethers.getContractAt('IHyperAGI_Roles_Cfg', '0x250a7629d076581d3713f016727204341865920C')

  await (await IHyperAGI_Roles_Cfg.addAdmin(instance.target)).wait()

  await (await MOSSAI_Storage.setServiceAddress(instance.target)).wait()

  await (await instance.setDefParameter('https://s3.hyperdust.io/upload/2024/3/11/e78b4816-4b81-4241-ac19-cb5758f300df.png', 'https://s3.hyperdust.io/upload/2024/3/4/7d012ce0-9bd0-48f1-ba2c-49228936a250.7z', 'db055fa3753903af2075421cd0b9977fa9390f808c46ac628adcb65bc6bbae51')).wait()

  // const Island_Mint = await ethers.getContractAt('Island_Mint', '0x50D9DC9f388A840b77AA7067D6a2AC7c2635578e')
  //
  // await (await Island_Mint.setIslandAddress(instance.target)).wait()

  console.info('contractFactory address:', instance.target)
}

// We recommend this pattern to be able to use async/await everywhere q

// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
