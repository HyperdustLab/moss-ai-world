/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {



    const MOSSAI_Storage = await ethers.deployContract("MOSSAI_Storage", [process.env.ADMIN_Wallet_Address]);
    await MOSSAI_Storage.waitForDeployment()



    const contract = await ethers.getContractFactory("MOSSAI_NFT_Product");
    const instance = await upgrades.deployProxy(contract, [process.env.ADMIN_Wallet_Address]);
    await instance.waitForDeployment();


    console.info("Hyperdust_Storage:", MOSSAI_Storage.target)



    await (await instance.setContractAddress([
        "0x741ABa1842783ec1226c1909A2E7F2B7b96b9598",
        '0x9bDaf3912e7b4794fE8aF2E748C35898265D5615',
        '0x243556f469c4b3e784a0892Eb413eDEeee83a78F',
        MOSSAI_Storage.target
    ])).wait()


    const MOSSAI_NFT_Market = await ethers.getContractAt("MOSSAI_NFT_Market", "0x741ABa1842783ec1226c1909A2E7F2B7b96b9598");

    await (await MOSSAI_NFT_Market.setMOSSAINFTProductAddress(instance.target)).wait();


    console.info("contractFactory address:", instance.target);

}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
