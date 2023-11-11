/** @format */

import { ethers, run } from "hardhat";

async function main() {
    const contract = await ethers.deployContract("MOSSAI_NFT_Product");
    await contract.waitForDeployment()

    await (await contract.setContractAddress(["0x2320c7bd7DBE345A67dec593C8d0e00Bb9e930A8", '0x6C34AbF4632BC38e90f5016d784D3ED320Cfad14', '0x66a0dcFF2803124F506d4a8F6D5Fa813629B8Bfa'])).wait()


    const MOSSAI_NFT_Market = await ethers.getContractAt("MOSSAI_NFT_Market", "0x4380b6aB29e0949AAf81B595381Cd3262B183B2b");

    await (await MOSSAI_NFT_Market.setMOSSAINFTProductAddress(contract.target)).wait();


    console.info("contractFactory address:", contract.target);



}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
