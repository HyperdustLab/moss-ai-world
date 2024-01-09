/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {

    const MOSSAI_Island_NFT = await ethers.deployContract("MOSSAI_721", ["MOSSAI_Island_NFG", "MIN"]);
    await MOSSAI_Island_NFT.waitForDeployment()



    const MOSSAI_Storage = await ethers.deployContract("MOSSAI_Storage");
    await MOSSAI_Storage.waitForDeployment()



    const _MOSSAI_Island_NFG = await ethers.getContractFactory("MOSSAI_Island_NFG");
    const instance = await upgrades.deployProxy(_MOSSAI_Island_NFG);

    await (await MOSSAI_Storage.setServiceAddress(instance.target)).wait()

    await (await instance.setContractAddress(["0x9bDaf3912e7b4794fE8aF2E748C35898265D5615", MOSSAI_Storage.target, MOSSAI_Island_NFT.target])).wait()

    await (await MOSSAI_Island_NFT.grantRole("0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6", instance.target)).wait()



    const MOSSAI_Roles_Cfg = await ethers.getContractAt("Hyperdust_Roles_Cfg", "0x9bDaf3912e7b4794fE8aF2E748C35898265D5615")

    await (await MOSSAI_Roles_Cfg.addAdmin(instance.target)).wait()



    console.info("MOSSAI_Island_NFT address:", MOSSAI_Island_NFT.target);
    console.info("MOSSAI_Storage address:", MOSSAI_Storage.target);


    console.info("contractFactory address:", instance.target);
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
