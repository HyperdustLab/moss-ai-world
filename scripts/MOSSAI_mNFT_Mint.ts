/** @format */

import { ethers, run } from "hardhat";

async function main() {
    const contract = await ethers.deployContract("MOSSAI_mNFT_Mint");
    await contract.waitForDeployment()

    await (await contract.setContractAddress(["0xd5A7E4eFb8Ae98aadE6d0078B3FeCf06c44c55Ae", "0x1a41f86248E33e5327B26092b898bDfe04C6d8b4", "0xcA19Ba81bdF2d9d1a4EBEba09598265195821982", "0x6108a5aC82d15a8034902DcFC20431BD169d2597"])).wait()
    console.info("contractFactory address:", contract.target);

}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
