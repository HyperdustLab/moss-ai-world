/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {



    const MOSSAI_Storage = await ethers.deployContract("MOSSAI_Storage");
    await MOSSAI_Storage.waitForDeployment()



    const contract = await ethers.getContractFactory("MOSSAI_NFT_Product");
    const instance = await upgrades.deployProxy(contract);
    await instance.waitForDeployment();


    console.info("Hyperdust_Storage:", MOSSAI_Storage.target)



    await (await instance.setContractAddress([
        "0x0000000000000000000000000000000000000000",
        '0x9bDaf3912e7b4794fE8aF2E748C35898265D5615',
        '0xD11F65E5A55Cd7CA459a659734951901c8E57D30',
        MOSSAI_Storage.target
    ])).wait()


    // const MOSSAI_NFT_Market = await ethers.getContractAt("MOSSAI_NFT_Market", "0xa52F3f2d571D069B6A3ce0297Ee9438B21400CDf");

    // await (await MOSSAI_NFT_Market.setMOSSAINFTProductAddress(instance.target)).wait();


    console.info("contractFactory address:", instance.target);

}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
