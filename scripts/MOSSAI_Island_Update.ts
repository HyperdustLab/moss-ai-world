/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  // Upgrading
  const MOSSAI_Island = await ethers.getContractFactory('MOSSAI_Island')
  const upgraded = await upgrades.upgradeProxy('0x3Bf13fA640240D50298D21240c8B48eF01418384', MOSSAI_Island)

  await (
    await upgraded.setContractAddress([
      '0x9bDaf3912e7b4794fE8aF2E748C35898265D5615',
      '0xba09e4f4A54f3dB674C7B1fa729F4986F59FAFB8',
      '0x8F7CD8D1F35459163EEc80034F92958c021aa651',
      '0x8E2219508F5F6160Ba7cc663262c51E97294A061',
      '0x920fC5dBBd6740fb996825Eb6729493e97697CA3',
      '0xcd17a8A93391F90dCc8ba3C2001840723ae5B8C6',
      '0x9bDaf3912e7b4794fE8aF2E748C35898265D5615',
      '0xC955884cbED1DCdf726Dd6CF22AE643273690F2d',
      '0x4A4611b0C26B93BFdfEAaA7B915F68e802F53f90',
    ])
  ).wait()

  await (
    await upgraded.setDefParameter('https://vniverse.s3.ap-east-1.amazonaws.com/upload/2023/8/10/13e02181-24b5-4e41-8481-4d7bb4886619.jpg', 'https://s3.mossai.com/upload/2023/10/27/05289452-914d-444f-a4d4-c272367ea649.7z', '90a5e1652e499b05e9b9e9f149322220e7110d73900b312cbce45072cef2c35b')
  ).wait()

  // const MOSSAI_Free_Island_Mint = await ethers.getContractAt("MOSSAI_Free_Island_Mint", "0x05eFb34F7F6E2c122ca6Da77257120FB6C9181D6")

  // await (await MOSSAI_Free_Island_Mint.setMOSSAIIslandAddres(contract.target)).wait()
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
