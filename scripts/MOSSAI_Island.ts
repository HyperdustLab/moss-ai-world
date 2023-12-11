/** @format */

import { ethers, run } from "hardhat";

async function main() {
    const contract = await ethers.deployContract("MOSSAI_Island");
    await contract.waitForDeployment()

    await (await contract.setContractAddress(
        ["0x6C34AbF4632BC38e90f5016d784D3ED320Cfad14",
            "0x24788117ce2E2BBfAfC27c6433FBB5144A8D15A2",
            "0x9bDaf3912e7b4794fE8aF2E748C35898265D5615",
            "0xAA928F4DE19cDd08E6971e721E69A720684e3ac7",
            "0x5d64e70A0e8719b7FAbD456e9B9deAD42Fb73Da4",
            "0x2FE14B0A0e0F7AA307Fd0a7999336c7A78D86bec",
            "0x6C34AbF4632BC38e90f5016d784D3ED320Cfad14"])).wait();

    const MOSSAI_Roles_Cfg = await ethers.getContractAt("MOSSAI_Roles_Cfg", "0x6C34AbF4632BC38e90f5016d784D3ED320Cfad14")

    await (await MOSSAI_Roles_Cfg.addAdmin(contract.target)).wait()



    await (
        await contract.setDefParameter(
            "https://vniverse.s3.ap-east-1.amazonaws.com/upload/2023/8/10/13e02181-24b5-4e41-8481-4d7bb4886619.jpg",
            "https://vniverse.s3.ap-east-1.amazonaws.com/upload/2023/8/11/d073bdc7-8440-4479-9d84-8b357a0fe7cf.7z",
            "875c03eba7bd71e564ed657e9f6ed97132c230a1e5073422bb410624d0ac1766"
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
