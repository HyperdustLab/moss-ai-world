/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {



    const Hyperdust_Render_Transcition = await ethers.getContractFactory("MOSSAI_mNFT_Mint");

    const upgraded = await upgrades.upgradeProxy("0x65ccdD0b11A750532D3fcdb5f882e9963047CD52", Hyperdust_Render_Transcition);



}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
