/** @format */

import { ethers, run } from "hardhat";

async function main() {
    const contract = await ethers.deployContract("MOSSAI_NFT_Product");
    await contract.waitForDeployment()

    await (await contract.setContractAddress(["0x311ff1729cd41cfc4236df28cF30FcaD32e67D6e", '0x6C34AbF4632BC38e90f5016d784D3ED320Cfad14', '0x24788117ce2E2BBfAfC27c6433FBB5144A8D15A2'])).wait()


    const MOSSAI_NFT_Market = await ethers.getContractAt("MOSSAI_NFT_Market", "0x311ff1729cd41cfc4236df28cF30FcaD32e67D6e");

    await (await MOSSAI_NFT_Market.setMOSSAINFTProductAddress(contract.target)).wait();


    console.info("contractFactory address:", contract.target);



}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
