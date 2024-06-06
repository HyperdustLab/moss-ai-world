/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  const Island_Mint = await ethers.getContractFactory('Island_Mint')
  const instance = await upgrades.deployProxy(Island_Mint, [process.env.ADMIN_Wallet_Address])
  await (
    await instance.setContractAddress([ethers.ZeroAddress, '0xb2342E1Bf4B4e0d340B97F5CdD8Fd9Cf24525D26', '0x859133fA725Cd252FD633E0Bc9ef7BbA270d6BE7', '0x74A6B3D4d0A9a7acC5a4e181d76dc7F0E49A978A', '0xC31A364A09c85319cFAc88Bb3F8F0dB874acBeFA', '0x5745090BFB28C3399223215DfbBb4e729aeF8cFD'])
  ).wait()

  const IHyperAGI_Roles_Cfg = await ethers.getContractAt('IHyperAGI_Roles_Cfg', '0x5745090BFB28C3399223215DfbBb4e729aeF8cFD')

  await (await IHyperAGI_Roles_Cfg.addAdmin(instance.target)).wait()

  console.info('contractFactory address:', instance.target)
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
