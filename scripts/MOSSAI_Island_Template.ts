/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {


    const MOSSAI_Storage = await ethers.deployContract("MOSSAI_Storage");
    await MOSSAI_Storage.waitForDeployment()

    const contract = await ethers.getContractFactory("MOSSAI_Island_Template");
    const instance = await upgrades.deployProxy(contract);
    await instance.waitForDeployment();


    console.info("Hyperdust_Storage:", MOSSAI_Storage.target)


    await (await MOSSAI_Storage.setServiceAddress(instance.target)).wait()


    await (await instance.setMOSSAIRolesCfgAddress("0x9bDaf3912e7b4794fE8aF2E748C35898265D5615")).wait()
    await (await instance.setMOSSAIStorageAddress(MOSSAI_Storage.target)).wait()



    console.info("contractFactory address:", instance.target);
}




// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
