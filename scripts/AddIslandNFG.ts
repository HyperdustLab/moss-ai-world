/** @format */

import { ethers, run } from "hardhat";


async function main() {


    const MOSSAI_Island_NFG = await ethers.getContractAt("MOSSAI_Island_NFG", "0xc31b08A89c94fa26f9C3eF1eDC65c84e6F5ce411");


    let seeds = []

    let tokenURIS = []

    let locations = []

    let seed = 5000;

    for (let i = 1; i <= 1000; i++) {


        tokenURIS.push(`https://s3.hyperdust.io/island/${i}.json`);

        locations.push(i);
        seeds.push(seed);

        seed++;

        if (i % 100 === 0) {

            await (await MOSSAI_Island_NFG.batchAddNFG(seeds, tokenURIS, locations)).wait()

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
    console.error(error);
    process.exitCode = 1;
});
