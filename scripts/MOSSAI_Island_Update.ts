/** @format */

import { ethers, run, upgrades } from "hardhat"

async function main() {
    // Upgrading
    const MOSSAI_Island = await ethers.getContractFactory("MOSSAI_Island")
    await upgrades.upgradeProxy(
        "0x9C3e908AA9346D24bf86D12F350A2f2d05351DE3",
        MOSSAI_Island
    )
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
