/** @format */

import { ethers, run, upgrades } from "hardhat"

async function main() {
    const _MOSSAI_Storage = await ethers.getContractFactory("MOSSAI_Storage")
    const MOSSAI_Storage = await upgrades.deployProxy(_MOSSAI_Storage, [process.env.ADMIN_Wallet_Address])
    await MOSSAI_Storage.waitForDeployment()


    const contract = await ethers.getContractFactory("MOSSAI_Island")
    const instance = await upgrades.deployProxy(contract, [
        process.env.ADMIN_Wallet_Address
    ])
    await instance.waitForDeployment()

    console.info("Hyperdust_Storage:", MOSSAI_Storage.target)

    await (
        await instance.setContractAddress([
            "0xCB25085841CD8230d652e99aD240568E21A00F10",
            "0x2EBd0de3fD3250c70D4C4beDe1835D53A64Ea490",
            "0x92bf83aF19DE8bbBfC50dD96196668569D0C779a",
            "0x81cD3746573C5b6121d19b285D32D7233aEcB11b",
            "0x9bDaf3912e7b4794fE8aF2E748C35898265D5615",
            "0x4A3b9CaC51082103f1095da4c73a463A355c6D04",
            "0x3beACBDb39626a1e2605bb93Fa79055df013edf7",
            "0x605DC1c559315Cc3ea65E2a6840a5523029d0bbe"
        ])
    ).wait()

    const MOSSAI_Roles_Cfg = await ethers.getContractAt(
        "Hyperdust_Roles_Cfg",
        "0x9bDaf3912e7b4794fE8aF2E748C35898265D5615"
    )

    await (await MOSSAI_Roles_Cfg.addAdmin(instance.target)).wait()

    await (await MOSSAI_Storage.setServiceAddress(instance.target)).wait()

    await (
        await instance.setDefParameter(
            "https://s3.hyperdust.io/upload/2024/3/5/cc33c0ab-1d12-4ad4-93f9-cb34481c85dc.jpg",
            "https://s3.hyperdust.io/upload/2024/3/4/7d012ce0-9bd0-48f1-ba2c-49228936a250.7z",
            "db055fa3753903af2075421cd0b9977fa9390f808c46ac628adcb65bc6bbae51"
        )
    ).wait()

    const Island_Mint = await ethers.getContractAt(
        "Island_Mint",
        "0x7872Db8dCea6E3865C604a9D5dA9C5a2607Bb66a"
    )

    await (await Island_Mint.setMOSSAIIslandAddres(instance.target)).wait()

    console.info("contractFactory address:", instance.target)
}

// We recommend this pattern to be able to use async/await everywhere q

// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
