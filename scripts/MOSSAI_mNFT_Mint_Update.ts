/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {



    const Hyperdust_Render_Transcition = await ethers.getContractFactory("MOSSAI_mNFT_Mint");

    const upgraded = await upgrades.upgradeProxy("0x65ccdD0b11A750532D3fcdb5f882e9963047CD52", Hyperdust_Render_Transcition);


    await (await upgraded.setContractAddress([
        "0x9bDaf3912e7b4794fE8aF2E748C35898265D5615",
        "0x1a41f86248E33e5327B26092b898bDfe04C6d8b4",
        "0xe0362E63F734A733dcF7BC002A2FE044AF41b37b",
        "0x7C94D4145c2d2ad2712B496DF6C27EEA5E0252C2",
        "0x9eB0b42C4b3D25829851Bc5DE75F7c58d8795EF5"
    ])).wait()



}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
