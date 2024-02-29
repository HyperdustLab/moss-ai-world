/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {



    const contract = await ethers.getContractFactory("MOSSAI_Free_Island_Mint");
    const instance = await upgrades.deployProxy(contract, [process.env.ADMIN_Wallet_Address]);
    await instance.waitForDeployment();



    await (await instance.setContractAddress([
        "0x8ea625319f7F7357E699EE222Fd826F8F5749a71",
        "0x5270b6273fd0E6fA5979EC28c1cB9FE98b8eEBe4",
        "0xe8ADeF97900b154f89417817C6621cd33D39d009",
        "0xfcb8A945DC86D72f906D9C63222Dc470b5A35548",
        "0x33e2f799dCF34df195f34664b243f318EB536B72"
    ])).wait()

    console.info("contractFactory address:", instance.target);


}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
