/** @format */

import { ethers } from "hardhat";

async function main() {


  const contract = await ethers.deployContract("Island_721", ["0x7872Db8dCea6E3865C604a9D5dA9C5a2607Bb66a", "Island_721", "TEST"]);
  await contract.waitForDeployment()
  console.info("contractFactory address:", contract.target);


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
