/** @format */

import { ethers, run } from "hardhat";

async function main() {
    const contract = await ethers.deployContract("MOSSAI_NFT_Product");
    await contract.waitForDeployment()

    await (await contract.setContractAddress(["0x311ff1729cd41cfc4236df28cF30FcaD32e67D6e", '0x3cc42e32ea76016CED99b98DEc0FD8D541Dc3B76', '0xDa3e9fD7d9b447fbaf1383E61458B1FA55Bff94F'])).wait()


    // const MOSSAI_NFT_Market = await ethers.getContractAt("MOSSAI_NFT_Market", "0x311ff1729cd41cfc4236df28cF30FcaD32e67D6e");

    // await (await MOSSAI_NFT_Market.setMOSSAINFTProductAddress(contract.target)).wait();


    console.info("contractFactory address:", contract.target);



}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
