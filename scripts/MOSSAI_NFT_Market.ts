/** @format */

import { ethers, run } from "hardhat";

async function main() {
    const contract = await ethers.deployContract("MOSSAI_NFT_Market");
    await contract.waitForDeployment()

    await (await contract.setContractAddress(["0x8DDBFD88ca0E588EA4a3B37D055d3F1717B54D48", "0x41B72CB16A2e89DddA403519A42aa0C386c1A4e7", "0xeb43b97d1AE99F28c07d0EA79C467E3ECF2a6A77", "0xeb43b97d1AE99F28c07d0EA79C467E3ECF2a6A77"])).wait()


    const MOSSAI_Roles_Cfg = await ethers.getContractAt("MOSSAI_Roles_Cfg", "0x6C34AbF4632BC38e90f5016d784D3ED320Cfad14")

    await (await MOSSAI_Roles_Cfg.addAdmin(contract.target)).wait()


    const MOSSAI_NFT_Product = await ethers.getContractAt("MOSSAI_NFT_Product", "0x8DDBFD88ca0E588EA4a3B37D055d3F1717B54D48");

    await (await MOSSAI_NFT_Product.setMOSSAINFTMarketAddress(contract.target)).wait();

    console.info("contractFactory address:", contract.target);
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
