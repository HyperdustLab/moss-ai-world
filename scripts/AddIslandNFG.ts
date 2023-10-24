/** @format */

import { ethers, run } from "hardhat";

import axios from 'axios'





async function main() {


    const MOSSAI_NFG = await ethers.getContractAt("MOSSAI_NFG", "0x66a0dcFF2803124F506d4a8F6D5Fa813629B8Bfa")


    const seeds = []

    const tokenURIS = []

    for (let i = 1; i < 5; i++) {

        seeds.push(i);


        const tokenURIJSON = { "image": "https://vniverse.s3.ap-east-1.amazonaws.com/upload/2023/7/25/13a8e1d9-87bf-45ae-ae00-bc04f088e41a.jpeg", coverImage: "https://vniverse.s3.ap-east-1.amazonaws.com/upload/2023/7/25/13a8e1d9-87bf-45ae-ae00-bc04f088e41a.jpeg", "name": "Island", "description": "Island", "type": "006001", "seed": i }


        const file = new Blob([JSON.stringify(tokenURIJSON)], { type: 'application/json' });

        let formData = new FormData()
        formData.append("file", file, "data.json")


        const { data } = await axios.post('http://127.0.0.1:9999/sys/common/upload', formData, {
            headers: {
                'Content-Type': 'multipart/form-data',
                'X-Access-Token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE2OTgxNjc5NjksInVzZXJuYW1lIjoicm9vdCJ9.Bmr61rFae7Z608ChFc2EE7CjgZBzWvyRwX2k48K61zA'
            }
        })

        if (!data.success) {
            throw data;
        }

        tokenURIS.push(data.result)


    }

    await (await MOSSAI_NFG.batchAddNFG(seeds, tokenURIS)).wait()
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
