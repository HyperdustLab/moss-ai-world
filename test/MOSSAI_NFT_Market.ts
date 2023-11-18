/** @format */

import { ethers } from "hardhat";
const { describe, it } = require("mocha");

import dayjs from 'dayjs'

describe("MOSSAI_NFT_Market", () => {
    describe("MOSSAI_NFT_Market", () => {
        it("MOSSAI_NFT_Market", async () => {
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

            await (await MOSSAI_20.mint(accounts[1].address, ethers.parseEther('100'))).wait()




            const MOSSAI_NFT_Market = await ethers.deployContract("MOSSAI_NFT_Market");
            await MOSSAI_NFT_Market.waitForDeployment()


            const MOSSAI_NFT_Product = await ethers.deployContract("MOSSAI_NFT_Product");
            await MOSSAI_NFT_Product.waitForDeployment()

            const Hyperdust_Transaction_Cfg = await ethers.deployContract("Hyperdust_Transaction_Cfg");
            await Hyperdust_Transaction_Cfg.waitForDeployment()

            const Hyperdust_Node_Mgr = await ethers.deployContract("Hyperdust_Node_Mgr");
            await Hyperdust_Node_Mgr.waitForDeployment()


            await (await Hyperdust_Transaction_Cfg.setContractAddress([MOSSAI_Roles_Cfg.target, Hyperdust_Node_Mgr.target])).wait()


            await (await MOSSAI_NFT_Market.setContractAddress([MOSSAI_NFT_Product.target, Hyperdust_Wallet_Account.target, Hyperdust_Transaction_Cfg.target, MOSSAI_20.target])).wait()
            await (await MOSSAI_NFT_Product.setContractAddress([MOSSAI_NFT_Market.target, MOSSAI_Roles_Cfg.target])).wait()

            await (await MOSSAI_Roles_Cfg.addAdmin(MOSSAI_NFT_Market.target)).wait()


            const MOSSAI_1155 = await ethers.deployContract("MOSSAI_1155", ["test", "test"]);
            await MOSSAI_1155.waitForDeployment()

            await (await MOSSAI_1155.mint(accounts[0].address, 1, 1, "111", "0x")).wait()

            await (await MOSSAI_1155.setApprovalForAll(MOSSAI_NFT_Market.target, true)).wait()

            await (await MOSSAI_NFT_Product.saveNFTProduct(MOSSAI_1155.target, 1, "0x01", 1, ethers.parseEther('0.1'), "0x02")).wait();

            await (await MOSSAI_20.approve(MOSSAI_NFT_Market.target, ethers.parseEther('100'))).wait()

            const tx = await (await MOSSAI_NFT_Market.buyNFTProduct(1, 1, { signer: accounts[1] })).wait()

            for (const log of tx.logs) {

                console.info(log)


            }


        });
    });
});
