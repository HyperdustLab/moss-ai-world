/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {






    const MOSSAI_Storage = await ethers.deployContract("MOSSAI_Storage", [process.env.ADMIN_Wallet_Address]);
    await MOSSAI_Storage.waitForDeployment()



    const contract = await ethers.getContractFactory("MOSSAI_NFT_Market");
    const instance = await upgrades.deployProxy(contract, [process.env.ADMIN_Wallet_Address]);
    await instance.waitForDeployment();


    console.info("Hyperdust_Storage:", MOSSAI_Storage.target)


    // await (await instance.setContractAddress([
    //     "0x8d4C83A551e646b13E9e16556c29604Bb3F71b1c",
    //     "0x3812D0341D721F66698228B0b10De0396117499e",
    //     "0x7C94D4145c2d2ad2712B496DF6C27EEA5E0252C2",
    //     "0x1a41f86248E33e5327B26092b898bDfe04C6d8b4",
    //     MOSSAI_Storage.target
    // ])).wait()


    // const MOSSAI_Roles_Cfg = await ethers.getContractAt("Hyperdust_Roles_Cfg", "0x9bDaf3912e7b4794fE8aF2E748C35898265D5615")

    // await (await MOSSAI_Roles_Cfg.addAdmin(instance.target)).wait()


    // const MOSSAI_NFT_Product = await ethers.getContractAt("MOSSAI_NFT_Product", "0x8d4C83A551e646b13E9e16556c29604Bb3F71b1c");

    // await (await MOSSAI_NFT_Product.setMOSSAINFTMarketAddress(instance.target)).wait();

    console.info("contractFactory address:", instance.target);
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
