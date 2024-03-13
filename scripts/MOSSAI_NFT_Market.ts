/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {


    const _MOSSAI_Storage = await ethers.getContractFactory("MOSSAI_Storage")
    const MOSSAI_Storage = await upgrades.deployProxy(_MOSSAI_Storage, [process.env.ADMIN_Wallet_Address])
    await MOSSAI_Storage.waitForDeployment()


    const contract = await ethers.getContractFactory("MOSSAI_NFT_Market");
    const instance = await upgrades.deployProxy(contract, [process.env.ADMIN_Wallet_Address]);
    await instance.waitForDeployment();


    console.info("Hyperdust_Storage:", MOSSAI_Storage.target)


    await (await instance.setContractAddress([
        "0x569E97c2f5d0d0c51E04ffd5637D6a09e43C6c9D",
        "0x5270b6273fd0E6fA5979EC28c1cB9FE98b8eEBe4",
        "0xe8ADeF97900b154f89417817C6621cd33D39d009",
        "0xfcb8A945DC86D72f906D9C63222Dc470b5A35548",
        MOSSAI_Storage.target
    ])).wait()


    const MOSSAI_Roles_Cfg = await ethers.getContractAt("Hyperdust_Roles_Cfg", "0x9bDaf3912e7b4794fE8aF2E748C35898265D5615")

    await (await MOSSAI_Roles_Cfg.addAdmin(instance.target)).wait()


    const MOSSAI_NFT_Product = await ethers.getContractAt("MOSSAI_NFT_Product", "0x569E97c2f5d0d0c51E04ffd5637D6a09e43C6c9D");

    await (await MOSSAI_NFT_Product.setMOSSAINFTMarketAddress(instance.target)).wait();

    console.info("contractFactory address:", instance.target);
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
