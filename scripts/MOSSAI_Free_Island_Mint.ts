/** @format */

import { ethers, run } from "hardhat";

async function main() {
    const contract = await ethers.deployContract("MOSSAI_Free_Island_Mint");
    await contract.waitForDeployment()
    console.info("contractFactory address:", contract.target);


    await (await contract.setContractAddress([
        "0xCe25B74F7C6C26c3A02B61e2eca6f9EBC10CcC17",
        "0x2EBDe3e744d0a870a17A2d51fd9079f14BF2137B",
        "0xAb0a5962659e59325ea6A3b0246444FC5e6024e0",
        "0x1a41f86248E33e5327B26092b898bDfe04C6d8b4"
    ])).wait()

}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
