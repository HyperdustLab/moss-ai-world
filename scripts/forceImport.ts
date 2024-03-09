import { upgrades, ethers } from "hardhat"

async function main() {
    const MOSSAI_Island = await ethers.getContractFactory("MOSSAI_Island")
    await upgrades.forceImport(
        "0x82cC1Bc1f476C939585BCB46cFd3dA8b2585ee80",
        MOSSAI_Island
    )
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
