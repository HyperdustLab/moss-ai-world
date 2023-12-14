/** @format */

import { ethers, run } from "hardhat";

async function main() {
    const contract = await ethers.deployContract("MOSSAI_Island");
    await contract.waitForDeployment()

    await (await contract.setContractAddress(
        ["0x3cc42e32ea76016CED99b98DEc0FD8D541Dc3B76",
            "0xDa3e9fD7d9b447fbaf1383E61458B1FA55Bff94F",
            "0x61A205bc2c94aDd1565cD29803EF53D9a20F10dA",
            "0xad20ce3a9dce85708074BD7a0E6F4b355151e040",
            "0x920fC5dBBd6740fb996825Eb6729493e97697CA3",
            "0xb16B5c14425853cd36E6671D7240B290D3c1B039",
            "0x3cc42e32ea76016CED99b98DEc0FD8D541Dc3B76"])).wait();

    const MOSSAI_Roles_Cfg = await ethers.getContractAt("MOSSAI_Roles_Cfg", "0x3cc42e32ea76016CED99b98DEc0FD8D541Dc3B76")

    await (await MOSSAI_Roles_Cfg.addAdmin(contract.target)).wait()



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

    console.info("contractFactory address:", contract.target);
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
