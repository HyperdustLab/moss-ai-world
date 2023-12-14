/** @format */

import { ethers, run } from "hardhat";

async function main() {
    const contract = await ethers.deployContract("Hyperdust_Island_Airdrop");
    await contract.waitForDeployment()
    console.info("contractFactory address:", contract.target);


    await (await contract.setContractAddress([
        "0x3cc42e32ea76016CED99b98DEc0FD8D541Dc3B76",
        "0x1a41f86248E33e5327B26092b898bDfe04C6d8b4",
        "0xCe25B74F7C6C26c3A02B61e2eca6f9EBC10CcC17",
        "0xDa3e9fD7d9b447fbaf1383E61458B1FA55Bff94F"
    ])).wait()

}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
