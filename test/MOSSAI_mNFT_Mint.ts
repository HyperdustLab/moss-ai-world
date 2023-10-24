/** @format */

import { ethers } from "hardhat";
const { describe, it } = require("mocha");

import dayjs from 'dayjs'

describe("MOSSAI_mNFT_Mint", () => {
    describe("MOSSAI_mNFT_Mint", () => {
        it("MOSSAI_mNFT_Mint", async () => {
            const accounts = await ethers.getSigners();

            const MOSSAI_Roles_Cfg = await ethers.deployContract("MOSSAI_Roles_Cfg");
            await MOSSAI_Roles_Cfg.waitForDeployment()


            const MOSSAI_20 = await ethers.deployContract("MOSSAI_20", ["TEST", "T"]);
            await MOSSAI_20.waitForDeployment()

            const MOSSAI_mNFT_Mint = await ethers.deployContract("MOSSAI_mNFT_Mint");
            await MOSSAI_mNFT_Mint.waitForDeployment()



            const Hyperdust_Wallet_Account = await ethers.deployContract("Hyperdust_Wallet_Account");
            await Hyperdust_Wallet_Account.waitForDeployment()

            await (await Hyperdust_Wallet_Account.setContractAddress([MOSSAI_Roles_Cfg.target, MOSSAI_20.target])).wait()


            await (await MOSSAI_20.mint(accounts[0].address, ethers.parseEther('100'))).wait()




            const MOSSAI_1155 = await ethers.deployContract("MOSSAI_1155", ["test", "test"]);
            await MOSSAI_1155.waitForDeployment()


            await (await MOSSAI_1155.grantRole("0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6", MOSSAI_mNFT_Mint.target)).wait();



            await (await MOSSAI_mNFT_Mint.setContractAddress([MOSSAI_Roles_Cfg.target, MOSSAI_20.target, Hyperdust_Wallet_Account.target])).wait()

            await (await MOSSAI_mNFT_Mint.addMintInfo("tokenURI", ethers.parseEther('100'), MOSSAI_1155.target, 1, 2, 1)).wait()

            await (await MOSSAI_Roles_Cfg.addAdmin(MOSSAI_mNFT_Mint.target)).wait()



            await (await MOSSAI_20.approve(MOSSAI_mNFT_Mint.target, ethers.parseEther('100'))).wait()


            await (await MOSSAI_mNFT_Mint.mint(1, 1)).wait()

        });
    });
});
