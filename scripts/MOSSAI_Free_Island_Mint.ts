/** @format */

import { ethers, run } from "hardhat";

async function main() {
    const contract = await ethers.deployContract("MOSSAI_Free_Island_Mint");
    await contract.waitForDeployment()
    console.info("contractFactory address:", contract.target);


    await (await contract.setContractAddress([
        "0xCe25B74F7C6C26c3A02B61e2eca6f9EBC10CcC17",
        "0x2EBDe3e744d0a870a17A2d51fd9079f14BF2137B",
        "0xAb0a5962659e59325ea6A3b0246444FC5e6024e0",
        "0x01778569225bA43FFDABF872607e1df2Bc83f102",
        "0xDa3e9fD7d9b447fbaf1383E61458B1FA55Bff94F"
    ])).wait()

}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
