/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {


    // Upgrading
    const MOSSAI_Island = await ethers.getContractFactory("MOSSAI_Island");
    const upgraded = await upgrades.upgradeProxy("0x57B885bD763007B5b89e8cB2D1fD5d7995b5fC31", MOSSAI_Island);




}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
