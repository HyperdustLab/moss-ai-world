/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {






    const MOSSAI_Storage = await ethers.deployContract("MOSSAI_Storage");
    await MOSSAI_Storage.waitForDeployment()



    const contract = await ethers.getContractFactory("MOSSAI_NFT_Market");
    const instance = await upgrades.deployProxy(contract);
    await instance.waitForDeployment();


    console.info("Hyperdust_Storage:", MOSSAI_Storage.target)


    await (await instance.setContractAddress([
        "0xC5bFF679a2542444D4DAa92149f988de163aA2eA",
        "0xcA19Ba81bdF2d9d1a4EBEba09598265195821982",
        "0xfbdB6d8B4e47c0d546eE0f721BF2EBfE55136E53",
        "0x1a41f86248E33e5327B26092b898bDfe04C6d8b4",
        MOSSAI_Storage.target
    ])).wait()


    const MOSSAI_Roles_Cfg = await ethers.getContractAt("MOSSAI_Roles_Cfg", "0x9bDaf3912e7b4794fE8aF2E748C35898265D5615")

    await (await MOSSAI_Roles_Cfg.addAdmin(instance.target)).wait()


    // const MOSSAI_NFT_Product = await ethers.getContractAt("MOSSAI_NFT_Product", "0xC5bFF679a2542444D4DAa92149f988de163aA2eA");

    // await (await MOSSAI_NFT_Product.setMOSSAINFTMarketAddress(contract.target)).wait();

    console.info("contractFactory address:", instance.target);
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
