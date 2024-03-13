/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {



    const MOSSAI_NFT_Market = await ethers.getContractAt("MOSSAI_NFT_Market", "0x741ABa1842783ec1226c1909A2E7F2B7b96b9598")


    const _MOSSAI_Storage = await ethers.getContractFactory("MOSSAI_Storage")
    const MOSSAI_Storage = await upgrades.deployProxy(_MOSSAI_Storage, [process.env.ADMIN_Wallet_Address])
    await MOSSAI_Storage.waitForDeployment()


    const _MOSSAI_NFT_Product = await ethers.getContractFactory("MOSSAI_NFT_Product")
    const MOSSAI_NFT_Product = await upgrades.deployProxy(_MOSSAI_NFT_Product, [process.env.ADMIN_Wallet_Address])
    await MOSSAI_NFT_Product.waitForDeployment()

    await (await MOSSAI_Storage.setServiceAddress(MOSSAI_NFT_Product.target)).wait()


    await (await MOSSAI_NFT_Market.setMOSSAINFTProductAddress(MOSSAI_NFT_Product.target)).wait()

    await (await MOSSAI_NFT_Product.setContractAddress([
        MOSSAI_NFT_Market.target,
        '0x9bDaf3912e7b4794fE8aF2E748C35898265D5615',
        '0x29E996B43072af9adF3Eb80d55523a34A4d7Add2',
        MOSSAI_Storage.target,
        "0x6F8ba1F7cE4a1743D3b2adF2730B233506ADE2F5"
    ])).wait()

    console.info("MOSSAI_Storage:", MOSSAI_Storage.target)
    console.info("MOSSAI_NFT_Product:", MOSSAI_NFT_Product.target)




}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
