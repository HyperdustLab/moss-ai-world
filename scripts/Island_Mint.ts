/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {



    const Island_Mint = await ethers.getContractFactory("Island_Mint");
    const instance = await upgrades.deployProxy(Island_Mint, [process.env.ADMIN_Wallet_Address]);


    // instance.setContractAddress([
    //     "0x0000000000000000000000000000000000000000",
    //     "0x3812D0341D721F66698228B0b10De0396117499e",
    //     "0x7C94D4145c2d2ad2712B496DF6C27EEA5E0252C2",
    //     "0x1a41f86248E33e5327B26092b898bDfe04C6d8b4",
    //     "0xC31A364A09c85319cFAc88Bb3F8F0dB874acBeFA",
    //     "0x9bDaf3912e7b4794fE8aF2E748C35898265D5615"
    // ])



    // const MOSSAI_Roles_Cfg = await ethers.getContractAt("Hyperdust_Roles_Cfg", "0x9bDaf3912e7b4794fE8aF2E748C35898265D5615")

    // await (await MOSSAI_Roles_Cfg.addAdmin(instance.target)).wait()



    console.info("contractFactory address:", instance.target);

}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
