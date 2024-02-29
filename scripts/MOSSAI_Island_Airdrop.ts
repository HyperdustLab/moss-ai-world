/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {




    const MOSSAI_Storage = await ethers.deployContract("MOSSAI_Storage", [process.env.ADMIN_Wallet_Address]);
    await MOSSAI_Storage.waitForDeployment()



    const contract = await ethers.getContractFactory("MOSSAI_Island_Airdrop");
    const instance = await upgrades.deployProxy(contract, [process.env.ADMIN_Wallet_Address]);
    await instance.waitForDeployment();

    console.info("Hyperdust_Storage:", MOSSAI_Storage.target)


    await (await MOSSAI_Storage.setServiceAddress(instance.target)).wait()




    await (await instance.setContractAddress([
        "0x9bDaf3912e7b4794fE8aF2E748C35898265D5615",
        "0xfcb8A945DC86D72f906D9C63222Dc470b5A35548",
        "0x8ea625319f7F7357E699EE222Fd826F8F5749a71",
        "0x33e2f799dCF34df195f34664b243f318EB536B72",
        MOSSAI_Storage.target
    ])).wait()


    console.info("contractFactory address:", instance.target);




}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
