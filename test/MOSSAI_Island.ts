/** @format */

import { ethers } from "hardhat";
const { describe, it } = require("mocha");

describe("MOSSAI_Island", () => {
    describe("MOSSAI_Island", () => {
        it("MOSSAI_Island", async () => {
            const accounts = await ethers.getSigners();



            const MOSSAI_Roles_Cfg = await ethers.deployContract("MOSSAI_Roles_Cfg");
            await MOSSAI_Roles_Cfg.waitForDeployment()


            const MOSSAI_Island_Map = await ethers.deployContract("MOSSAI_Island_Map");
            await MOSSAI_Island_Map.waitForDeployment()




            const MOSSAI_Free_Island_Mint = await ethers.deployContract("MOSSAI_Free_Island_Mint");
            await MOSSAI_Free_Island_Mint.waitForDeployment()


            const MOSSAI_Island = await ethers.deployContract("MOSSAI_Island");
            await MOSSAI_Island.waitForDeployment()



            const Island721Factory = await ethers.deployContract("Island721Factory");
            await Island721Factory.waitForDeployment()



            const Island1155Factory = await ethers.deployContract("Island1155Factory");
            await Island1155Factory.waitForDeployment()


            const IslandAssetsCfg = await ethers.deployContract("IslandAssetsCfg");
            await IslandAssetsCfg.waitForDeployment()



            const Hyperdust_Transaction_Cfg = await ethers.deployContract("Hyperdust_Transaction_Cfg");
            await Hyperdust_Transaction_Cfg.waitForDeployment()

            const Hyperdust_Wallet_Account = await ethers.deployContract("Hyperdust_Wallet_Account");
            await Hyperdust_Wallet_Account.waitForDeployment()



            const MOSSAI_20 = await ethers.deployContract("MOSSAI_20");
            await MOSSAI_20.waitForDeployment()



            const MOSSAI_NFG = await ethers.deployContract("MOSSAI_NFG", ["MOSSAI_NFG", "MOSSAI_NFG"]);
            await MOSSAI_NFG.waitForDeployment()








            await (await MOSSAI_Island_Map.setMOSSAIRolesCfgAddress(MOSSAI_Roles_Cfg.target)).wait()
            await (await MOSSAI_Island_Map.batchAdd([1])).wait()


            await (await MOSSAI_Free_Island_Mint.setMOSSAIIslandAddres(MOSSAI_Island.target)).wait()

            await (await MOSSAI_Island.setContractAddress([MOSSAI_Roles_Cfg.target, MOSSAI_NFG.target, MOSSAI_Island_Map.target, Island721Factory.target, Island1155Factory.target, IslandAssetsCfg.target])).wait()



            await (await IslandAssetsCfg.setContractAddress([Hyperdust_Transaction_Cfg.target, MOSSAI_20.target, Hyperdust_Wallet_Account.target, MOSSAI_Roles_Cfg.target])).wait()



            await (await Hyperdust_Transaction_Cfg.setRolesCfgAddress(MOSSAI_Roles_Cfg.target)).wait()

            await (await Hyperdust_Transaction_Cfg.add('mintNFT', ethers.parseEther('1'))).wait()

            await (await Hyperdust_Wallet_Account.setContractAddress([MOSSAI_Roles_Cfg.target, MOSSAI_20.target])).wait()



            await (await MOSSAI_NFG.setMOSSAIRolesCfgAddress(MOSSAI_Roles_Cfg.target)).wait()


            await (await MOSSAI_NFG.batchAddNFG([1], ['test'])).wait()


        });
    });
});
