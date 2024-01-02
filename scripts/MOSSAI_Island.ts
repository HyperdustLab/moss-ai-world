/** @format */

import { ethers, run } from "hardhat";

async function main() {
    const contract = await ethers.deployContract("MOSSAI_Island");
    await contract.waitForDeployment()

    await (await contract.setContractAddress(
        ["0xd5A7E4eFb8Ae98aadE6d0078B3FeCf06c44c55Ae",
            "0xba09e4f4A54f3dB674C7B1fa729F4986F59FAFB8",
            "0xD7efD20E42155295Da5268FC465697354d91fce0",
            "0x8E2219508F5F6160Ba7cc663262c51E97294A061",
            "0x920fC5dBBd6740fb996825Eb6729493e97697CA3",
            "0xcd17a8A93391F90dCc8ba3C2001840723ae5B8C6",
            "0xd5A7E4eFb8Ae98aadE6d0078B3FeCf06c44c55Ae",
            "0x5d0aD674F5f6682fd6f23D581aE90e9968436392"

        ])).wait();

    const MOSSAI_Roles_Cfg = await ethers.getContractAt("MOSSAI_Roles_Cfg", "0xd5A7E4eFb8Ae98aadE6d0078B3FeCf06c44c55Ae")

    await (await MOSSAI_Roles_Cfg.addAdmin(contract.target)).wait()

    await (await MOSSAI_Roles_Cfg.addSuperAdmin(contract.target)).wait()


    await (
        await contract.setDefParameter(
            "https://vniverse.s3.ap-east-1.amazonaws.com/upload/2023/8/10/13e02181-24b5-4e41-8481-4d7bb4886619.jpg",
            "https://s3.mossai.com/upload/2023/10/27/05289452-914d-444f-a4d4-c272367ea649.7z",
            "90a5e1652e499b05e9b9e9f149322220e7110d73900b312cbce45072cef2c35b"
        )
    ).wait();


    // const MOSSAI_Free_Island_Mint = await ethers.getContractAt("MOSSAI_Free_Island_Mint", "0x05eFb34F7F6E2c122ca6Da77257120FB6C9181D6")

    // await (await MOSSAI_Free_Island_Mint.setMOSSAIIslandAddres(contract.target)).wait()

    await (await MOSSAI_Roles_Cfg.addSuperAdmin(contract.target)).wait()



    const batchSize = 50;
    const total = 4;

    for (let i = 1; i <= total; i += batchSize) {
        const end = Math.min(i + batchSize - 1, total);
        await (await contract.migration(i, end)).wait();
    }




    console.info("contractFactory address:", contract.target);
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
