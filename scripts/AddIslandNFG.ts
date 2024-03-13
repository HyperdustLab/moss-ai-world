/** @format */

import { ethers, run } from "hardhat"

async function main() {
    const MOSSAI_Island_NFG = await ethers.getContractAt(
        "MOSSAI_Island_NFG",
        "0x29E996B43072af9adF3Eb80d55523a34A4d7Add2",
    )

    let seeds = []

    let tokenURIS = []

    let locations = []

    let seed = 6800

    for (let i = 1801; i <= 1884; i++) {
        tokenURIS.push(`https://s3.hyperdust.io/island/${i}.json`)

        locations.push(i)
        seeds.push(seed)

        seed++

        if (i % 100 === 0 || i % 100 < 100) {
            await (
                await MOSSAI_Island_NFG.batchAddNFG(seeds, tokenURIS, locations)
            ).wait()

            console.info(seeds, tokenURIS, locations)
            seeds = []
            tokenURIS = []
            locations = []
        }
    }
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
