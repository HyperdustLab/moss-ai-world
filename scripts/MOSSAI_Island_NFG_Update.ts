/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {

    const MOSSAI_Island_NFG = await ethers.getContractFactory("MOSSAI_Island_NFG");

    await upgrades.upgradeProxy("0xCB25085841CD8230d652e99aD240568E21A00F10", MOSSAI_Island_NFG);
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
