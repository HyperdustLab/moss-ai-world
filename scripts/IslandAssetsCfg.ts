/** @format */

import { ethers, run } from "hardhat";

async function main() {
    const contract = await ethers.deployContract("IslandAssetsCfg");
    await contract.waitForDeployment()
    console.info("contractFactory address:", contract.target);


    await (await contract.setContractAddress([
        '0x9EEb20ab68B01ceeB7D3EB11E30dD972A27C93b9',
        '0xc95d7c5B58AF9D9bA0A6a30c428a737B224Dab39',
        '0x41B72CB16A2e89DddA403519A42aa0C386c1A4e7',
        '0x6C34AbF4632BC38e90f5016d784D3ED320Cfad14',
        '0x62aFeD11312a805Be78aDDf49B7C4e81310d2799'
    ])).wait()
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
