/** @format */

import { ethers, run } from "hardhat";

async function main() {
    const contract = await ethers.deployContract("MOSSAI_mNFT_Mint");
    await contract.waitForDeployment()

    await (await contract.setContractAddress(["0x6C34AbF4632BC38e90f5016d784D3ED320Cfad14", "0xc95d7c5B58AF9D9bA0A6a30c428a737B224Dab39", "0x41B72CB16A2e89DddA403519A42aa0C386c1A4e7"])).wait()
    console.info("contractFactory address:", contract.target);

}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
