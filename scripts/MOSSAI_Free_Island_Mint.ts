/** @format */

import { ethers, run } from "hardhat";

async function main() {
    const contract = await ethers.deployContract("MOSSAI_Free_Island_Mint");
    await contract.waitForDeployment()
    console.info("contractFactory address:", contract.target);


    await (await contract.setContractAddress([
        "0xF0C9b366C06cd940E995493149a4e045724273f6",
        "0x41B72CB16A2e89DddA403519A42aa0C386c1A4e7",
        "0xeb43b97d1AE99F28c07d0EA79C467E3ECF2a6A77",
        "0x1CF7f55C216b28BC14Bf663d49D95d5F68446bed"
    ])).wait()

}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
