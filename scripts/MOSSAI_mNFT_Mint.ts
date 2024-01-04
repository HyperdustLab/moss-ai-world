/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {



    const MOSSAI_Storage = await ethers.deployContract("MOSSAI_Storage");
    await MOSSAI_Storage.waitForDeployment()



    const contract = await ethers.getContractFactory("MOSSAI_mNFT_Mint");
    const instance = await upgrades.deployProxy(contract);
    await instance.waitForDeployment();


    console.info("Hyperdust_Storage:", MOSSAI_Storage.target)


    await (await instance.setContractAddress([
        "0x9bDaf3912e7b4794fE8aF2E748C35898265D5615",
        "0x1a41f86248E33e5327B26092b898bDfe04C6d8b4",
        "0xcA19Ba81bdF2d9d1a4EBEba09598265195821982",
        "0xfbdB6d8B4e47c0d546eE0f721BF2EBfE55136E53",
        MOSSAI_Storage.target
    ])).wait()


    await (await MOSSAI_Storage.setServiceAddress(instance.target)).wait()

    console.info("contractFactory address:", instance.target);

}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
