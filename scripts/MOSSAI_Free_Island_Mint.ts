/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {



    const contract = await ethers.getContractFactory("MOSSAI_Free_Island_Mint");
    const instance = await upgrades.deployProxy(contract);
    await instance.waitForDeployment();



    await (await instance.setContractAddress([
        "0x3Bf13fA640240D50298D21240c8B48eF01418384",
        "0xcA19Ba81bdF2d9d1a4EBEba09598265195821982",
        "0xfbdB6d8B4e47c0d546eE0f721BF2EBfE55136E53",
        "0x1a41f86248E33e5327B26092b898bDfe04C6d8b4",
        "0xba09e4f4A54f3dB674C7B1fa729F4986F59FAFB8"
    ])).wait()

    console.info("contractFactory address:", instance.target);


}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
