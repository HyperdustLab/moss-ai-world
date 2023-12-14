/** @format */

import { ethers, run } from "hardhat";

async function main() {
    const contract = await ethers.deployContract("MOSSAI_NFT_Market");
    await contract.waitForDeployment()

    await (await contract.setContractAddress(["0xc524FffffFA78620Af367bAd67AD887eA6da5246", "0x2EBDe3e744d0a870a17A2d51fd9079f14BF2137B", "0xAb0a5962659e59325ea6A3b0246444FC5e6024e0", "0x1a41f86248E33e5327B26092b898bDfe04C6d8b4"])).wait()


    const MOSSAI_Roles_Cfg = await ethers.getContractAt("MOSSAI_Roles_Cfg", "0x3cc42e32ea76016CED99b98DEc0FD8D541Dc3B76")

    await (await MOSSAI_Roles_Cfg.addAdmin(contract.target)).wait()


    const MOSSAI_NFT_Product = await ethers.getContractAt("MOSSAI_NFT_Product", "0xc524FffffFA78620Af367bAd67AD887eA6da5246");

    await (await MOSSAI_NFT_Product.setMOSSAINFTMarketAddress(contract.target)).wait();

    console.info("contractFactory address:", contract.target);
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
