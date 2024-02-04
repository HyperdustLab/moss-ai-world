/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {



    // Upgrading
    const Island1155Factory = await ethers.getContractFactory("Island1155Factory");
    const upgraded = await upgrades.upgradeProxy("0x81cD3746573C5b6121d19b285D32D7233aEcB11b", Island1155Factory);

}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
