/** @format */

import { ethers, run, upgrades } from "hardhat"

async function main() {
    const MOSSAI_Storage = await ethers.deployContract("MOSSAI_Storage", [
        process.env.ADMIN_Wallet_Address,
    ])
    await MOSSAI_Storage.waitForDeployment()

    const contract = await ethers.getContractFactory("MOSSAI_Island_Airdrop")
    const instance = await upgrades.deployProxy(contract, [
        process.env.ADMIN_Wallet_Address,
    ])
    await instance.waitForDeployment()

    console.info("Hyperdust_Storage:", MOSSAI_Storage.target)

    await (await MOSSAI_Storage.setServiceAddress(instance.target)).wait()

    await (
        await instance.setContractAddress([
            "0x9bDaf3912e7b4794fE8aF2E748C35898265D5615",
            "0xfcb8A945DC86D72f906D9C63222Dc470b5A35548",
            "0x82cC1Bc1f476C939585BCB46cFd3dA8b2585ee80",
            "0xCB25085841CD8230d652e99aD240568E21A00F10",
            MOSSAI_Storage.target,
        ])
    ).wait()

    console.info("contractFactory address:", instance.target)
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
