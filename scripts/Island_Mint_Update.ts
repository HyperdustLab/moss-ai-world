/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {



    const Hyperdust_Render_Transcition = await ethers.getContractFactory("Island_Mint");

    const upgraded = await upgrades.upgradeProxy("0xed8069499F24e24101b04cdf5A740e6BEED825B1", Hyperdust_Render_Transcition);

    upgraded.setContractAddress([
        "0x5197De6b2353d4720e08992c938eeb44E4F83206",
        "0xe0362E63F734A733dcF7BC002A2FE044AF41b37b",
        "0x7C94D4145c2d2ad2712B496DF6C27EEA5E0252C2",
        "0x1a41f86248E33e5327B26092b898bDfe04C6d8b4",
        "0xC31A364A09c85319cFAc88Bb3F8F0dB874acBeFA",
        "0x9bDaf3912e7b4794fE8aF2E748C35898265D5615"
    ])



   
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
