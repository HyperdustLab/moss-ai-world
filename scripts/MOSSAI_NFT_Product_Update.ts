/** @format */

import { ethers, run, upgrades } from "hardhat"

async function main() {
    const _MOSSAI_NFT_Product =
        await ethers.getContractFactory("MOSSAI_NFT_Product")

    await upgrades.upgradeProxy(
        "0x569E97c2f5d0d0c51E04ffd5637D6a09e43C6c9D",
        _MOSSAI_NFT_Product,
    )
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
