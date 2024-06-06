/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  const _MOSSAI_Storage = await ethers.getContractFactory('MOSSAI_Storage')
  const MOSSAI_Storage = await upgrades.deployProxy(_MOSSAI_Storage, [process.env.ADMIN_Wallet_Address])
  await MOSSAI_Storage.waitForDeployment()

  const contract = await ethers.getContractFactory('MOSSAI_Island')
  const instance = await upgrades.deployProxy(contract, [process.env.ADMIN_Wallet_Address])
  await instance.waitForDeployment()

  console.info('Hyperdust_Storage:', MOSSAI_Storage.target)

  await (
    await instance.setContractAddress([
      '0x74A6B3D4d0A9a7acC5a4e181d76dc7F0E49A978A',
      '0x7f81A464FaBA5C984ADCA52E3a919B1D73026aBE',
      '0x63798eb3e135CA2543D3136f4E314a9A3e819141',
      '0x3d091D360694a9A488f3CD8A4f0903bCD230083b',
      '0x5745090BFB28C3399223215DfbBb4e729aeF8cFD',
      MOSSAI_Storage.target,
      '0xD18Bd75b4d2311dF45dD846Bb51c077AFAEF55df',
      '0xc49F8d724A33A59d1A95436fC521C94608F06655',
    ])
  ).wait()

  const IHyperAGI_Roles_Cfg = await ethers.getContractAt('IHyperAGI_Roles_Cfg', '0x5745090BFB28C3399223215DfbBb4e729aeF8cFD')

  await (await IHyperAGI_Roles_Cfg.addAdmin(instance.target)).wait()

  await (await MOSSAI_Storage.setServiceAddress(instance.target)).wait()

  await (await instance.setDefParameter('https://s3.hyperdust.io/upload/2024/3/11/e78b4816-4b81-4241-ac19-cb5758f300df.png', 'https://s3.hyperdust.io/upload/2024/3/4/7d012ce0-9bd0-48f1-ba2c-49228936a250.7z', 'db055fa3753903af2075421cd0b9977fa9390f808c46ac628adcb65bc6bbae51')).wait()

  const Island_Mint = await ethers.getContractAt('Island_Mint', '0xD18Bd75b4d2311dF45dD846Bb51c077AFAEF55df')

  await (await Island_Mint.setIslandAddress(instance.target)).wait()

  console.info('contractFactory address:', instance.target)
}

// We recommend this pattern to be able to use async/await everywhere q

// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
