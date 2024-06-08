/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  const contract = await ethers.getContractFactory('MOSSAI_Free_Island_Mint')
  const instance = await upgrades.deployProxy(contract, [process.env.ADMIN_Wallet_Address])
  await instance.waitForDeployment()

  await (await instance.setContractAddress(['0x2BE7F5D660967cEc585d2acbEB10230Bb731172A', '0xb2342E1Bf4B4e0d340B97F5CdD8Fd9Cf24525D26', '0x859133fA725Cd252FD633E0Bc9ef7BbA270d6BE7', '0xc4ab9379C819CD6fd5A9bA20804B7Ae16404c140'])).wait()

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
