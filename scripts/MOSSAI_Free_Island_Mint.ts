/** @format */

import { ethers, run } from "hardhat";

async function main() {
    const contract = await ethers.deployContract("MOSSAI_Free_Island_Mint");
    await contract.waitForDeployment()
    console.info("contractFactory address:", contract.target);


    await (await contract.setContractAddress([
        "0x5d0aD674F5f6682fd6f23D581aE90e9968436392",
        "0xcA19Ba81bdF2d9d1a4EBEba09598265195821982",
        "0x6108a5aC82d15a8034902DcFC20431BD169d2597",
        "0x1a41f86248E33e5327B26092b898bDfe04C6d8b4",
        "0xba09e4f4A54f3dB674C7B1fa729F4986F59FAFB8"
    ])).wait()

}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
