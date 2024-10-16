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
      '0xAa2c95c0E0E46204f9f14D22577aDecb8f80b6e1',
      '0xbE90b9e27267DE230191351cf0206B483A48386C',
      '0x62678BB336Ac6B8fAc3320a31c351EcA8a1D30de',
      '0x95fcC99D26e2FC7d96f233B029AE0b1218E62941',
      '0x7B33C8D43C52d0c575eACaEcFdAd68487bfB28Ea',
      MOSSAI_Storage.target,
      ethers.ZeroAddress,
      '0xB713e3c2aCD99244b8599b2a5bca8036Ac321060',
    ])
  ).wait()

  const IHyperAGI_Roles_Cfg = await ethers.getContractAt('IHyperAGI_Roles_Cfg', '0x7B33C8D43C52d0c575eACaEcFdAd68487bfB28Ea')

  await (await IHyperAGI_Roles_Cfg.addAdmin(instance.target)).wait()

  await (await MOSSAI_Storage.setServiceAddress(instance.target)).wait()

  await (await instance.setDefParameter('https://ipfs.hyperdust.io/ipfs/QmVtWyYm2v1SQ5zhEMiD9xeXHevy53xU2NETtfSzFPNft4?suffix=png', 'https://ipfs.hyperdust.io/ipfs/QmaV5ZC83bD2jGNaySLwUVZpsCBV8zGnQFsW8EYdr1D4Nt?suffix=7z', 'db055fa3753903af2075421cd0b9977fa9390f808c46ac628adcb65bc6bbae51')).wait()

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
