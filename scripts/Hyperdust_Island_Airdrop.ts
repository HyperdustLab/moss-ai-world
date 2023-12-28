/** @format */

import { ethers, run } from "hardhat";

async function main() {
    const contract = await ethers.deployContract("Hyperdust_Island_Airdrop");
    await contract.waitForDeployment()
    console.info("contractFactory address:", contract.target);


    await (await contract.setContractAddress([
        "0xd5A7E4eFb8Ae98aadE6d0078B3FeCf06c44c55Ae",
        "0x1a41f86248E33e5327B26092b898bDfe04C6d8b4",
        "0x5d0aD674F5f6682fd6f23D581aE90e9968436392",
        "0xba09e4f4A54f3dB674C7B1fa729F4986F59FAFB8"
    ])).wait()





}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
