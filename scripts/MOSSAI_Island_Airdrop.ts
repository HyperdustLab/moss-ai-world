/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {




    const MOSSAI_Storage = await ethers.deployContract("MOSSAI_Storage", [process.env.ADMIN_Wallet_Address]);
    await MOSSAI_Storage.waitForDeployment()



    const contract = await ethers.getContractFactory("MOSSAI_Island_Airdrop");
    const instance = await upgrades.deployProxy(contract, [process.env.ADMIN_Wallet_Address]);
    await instance.waitForDeployment();

    console.info("Hyperdust_Storage:", MOSSAI_Storage.target)


    // await (await MOSSAI_Storage.setServiceAddress(instance.target)).wait()




    // await (await instance.setContractAddress([
    //     "0x9bDaf3912e7b4794fE8aF2E748C35898265D5615",
    //     "0x01778569225bA43FFDABF872607e1df2Bc83f102",
    //     "0x5197De6b2353d4720e08992c938eeb44E4F83206",
    //     "0xC31A364A09c85319cFAc88Bb3F8F0dB874acBeFA",
    //     "0x656A4a75aCFc6Ab339EF2b18322e9F2E2a0237C7"
    // ])).wait()


    console.info("contractFactory address:", instance.target);




}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
