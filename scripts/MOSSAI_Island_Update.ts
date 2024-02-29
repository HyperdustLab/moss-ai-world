/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {


    // Upgrading
    const MOSSAI_Island = await ethers.getContractFactory("MOSSAI_Island");
    const upgraded = await upgrades.upgradeProxy("0x5197De6b2353d4720e08992c938eeb44E4F83206", MOSSAI_Island);




}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
