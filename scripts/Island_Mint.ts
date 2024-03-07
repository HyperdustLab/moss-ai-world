/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {



    const Island_Mint = await ethers.getContractFactory("Island_Mint");
    const instance = await upgrades.deployProxy(Island_Mint, [process.env.ADMIN_Wallet_Address]);


    await (await instance.setContractAddress([
        "0x57B885bD763007B5b89e8cB2D1fD5d7995b5fC31",
        "0x5270b6273fd0E6fA5979EC28c1cB9FE98b8eEBe4",
        "0xe8ADeF97900b154f89417817C6621cd33D39d009",
        "0xfcb8A945DC86D72f906D9C63222Dc470b5A35548",
        "0xCB25085841CD8230d652e99aD240568E21A00F10",
        "0x9bDaf3912e7b4794fE8aF2E748C35898265D5615"
    ])).wait()



    const MOSSAI_Roles_Cfg = await ethers.getContractAt("Hyperdust_Roles_Cfg", "0x9bDaf3912e7b4794fE8aF2E748C35898265D5615")
    const MOSSAI_Island = await ethers.getContractAt("MOSSAI_Island", "0x57B885bD763007B5b89e8cB2D1fD5d7995b5fC31")

    await (await MOSSAI_Roles_Cfg.addAdmin(instance.target)).wait()

    await (await MOSSAI_Island.setIslandMintAddress(instance.target)).wait()



    console.info("contractFactory address:", instance.target);

}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
