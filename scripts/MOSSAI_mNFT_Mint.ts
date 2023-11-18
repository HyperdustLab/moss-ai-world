/** @format */

import { ethers, run } from "hardhat";

async function main() {
    const contract = await ethers.deployContract("MOSSAI_mNFT_Mint");
    await contract.waitForDeployment()

    await (await contract.setContractAddress(["0x6C34AbF4632BC38e90f5016d784D3ED320Cfad14", "0xBF99159A5a2Bb18eA43f99D9C0E0c35F897Be74E", "0x41B72CB16A2e89DddA403519A42aa0C386c1A4e7", "0xeb43b97d1AE99F28c07d0EA79C467E3ECF2a6A77"])).wait()
    console.info("contractFactory address:", contract.target);

}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
