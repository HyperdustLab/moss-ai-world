/** @format */

import { ethers, run } from "hardhat";

async function main() {
    const contract = await ethers.deployContract("IslandAssetsCfg");
    await contract.waitForDeployment()
    console.info("contractFactory address:", contract.target);


    await (await contract.setContractAddress([
        '0xAb0a5962659e59325ea6A3b0246444FC5e6024e0',
        '0x1a41f86248E33e5327B26092b898bDfe04C6d8b4',
        '0x41B72CB16A2e89DddA403519A42aa0C386c1A4e7',
        '0x6C34AbF4632BC38e90f5016d784D3ED320Cfad14'
    ])).wait()
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
