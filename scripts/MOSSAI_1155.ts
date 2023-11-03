/** @format */

import { ethers } from "hardhat";

async function main() {


  const contract = await ethers.deployContract("MOSSAI_1155", ["MOSSAI 1155", "MOSSAI"]);
  await contract.waitForDeployment()
  console.info("contractFactory address:", contract.target);


  await (await contract.grantRole("0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6", "0x05eFb34F7F6E2c122ca6Da77257120FB6C9181D6")).wait();



}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
