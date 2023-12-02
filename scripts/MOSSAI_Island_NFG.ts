/** @format */

import { ethers, run } from "hardhat";

async function main() {
    const contract = await ethers.deployContract("MOSSAI_Island_NFG");
    await contract.waitForDeployment()

    await (await contract.setMOSSAIRolesCfgAddress("0x6C34AbF4632BC38e90f5016d784D3ED320Cfad14")).wait();


    // const MOSSAI_Island = await ethers.getContractAt("MOSSAI_Island", "0xB058ac8eF6B5f3e20E3A8fF1d283F2eed22A45d8")


    // await (await MOSSAI_Island.setIslandNFGAddress(contract.target)).wait();


    console.info("contractFactory address:", contract.target);
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
