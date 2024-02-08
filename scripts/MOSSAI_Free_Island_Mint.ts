/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {



    const contract = await ethers.getContractFactory("MOSSAI_Free_Island_Mint");
    const instance = await upgrades.deployProxy(contract, [process.env.ADMIN_Wallet_Address]);
    await instance.waitForDeployment();



    // await (await instance.setContractAddress([
    //     "0x5197De6b2353d4720e08992c938eeb44E4F83206",
    //     "0x3812D0341D721F66698228B0b10De0396117499e",
    //     "0x7C94D4145c2d2ad2712B496DF6C27EEA5E0252C2",
    //     "0x1a41f86248E33e5327B26092b898bDfe04C6d8b4",
    //     "0xD11F65E5A55Cd7CA459a659734951901c8E57D30"
    // ])).wait()

    console.info("contractFactory address:", instance.target);


}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
