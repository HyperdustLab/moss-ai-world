/** @format */

import { ethers, run, upgrades } from "hardhat"

async function main() {
    // Upgrading
    const _MOSSAI_Island = await ethers.getContractFactory("MOSSAI_Island")
    const MOSSAI_Island = await upgrades.upgradeProxy(
        "0x6F8ba1F7cE4a1743D3b2adF2730B233506ADE2F5",
        _MOSSAI_Island,
    )

    await (
        await MOSSAI_Island.setHyperdustSpaceAddress(
            "0x0779f2687f0eb4EA70acA2A065eAdE9aFb0F24bF",
        )
    ).wait()
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
