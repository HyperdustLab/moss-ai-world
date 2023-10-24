/** @format */

import { ethers, run } from "hardhat";

async function main() {
    const contract = await ethers.deployContract("MOSSAI_Free_Island_Mint");
    await contract.waitForDeployment()
    console.info("contractFactory address:", contract.target);


    await (await contract.setMOSSAIIslandAddres("0x21Da158ace650241F8e77A44A0C1d67323eAfa17")).wait()
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
