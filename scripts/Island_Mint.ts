/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {



    const Island_Mint = await ethers.getContractFactory("Island_Mint");
    const instance = await upgrades.deployProxy(Island_Mint, [process.env.ADMIN_Wallet_Address]);


    instance.setContractAddress([
        ethers.ZeroAddress,
        "0x5270b6273fd0E6fA5979EC28c1cB9FE98b8eEBe4",
        "0xe8ADeF97900b154f89417817C6621cd33D39d009",
        "0xfcb8A945DC86D72f906D9C63222Dc470b5A35548",
        "0x33e2f799dCF34df195f34664b243f318EB536B72",
        "0x9bDaf3912e7b4794fE8aF2E748C35898265D5615"
    ])



    const MOSSAI_Roles_Cfg = await ethers.getContractAt("Hyperdust_Roles_Cfg", "0x9bDaf3912e7b4794fE8aF2E748C35898265D5615")

    await (await MOSSAI_Roles_Cfg.addAdmin(instance.target)).wait()



    console.info("contractFactory address:", instance.target);

}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
