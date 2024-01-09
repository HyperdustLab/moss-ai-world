/** @format */

import { ethers, upgrades } from "hardhat";
const { describe, it } = require("mocha");

describe("MOSSAI_Island", () => {
    describe("MOSSAI_Island", () => {
        it("MOSSAI_Island", async () => {
            const accounts = await ethers.getSigners();



            const _Hyperdust_Roles_Cfg = await ethers.getContractFactory("Hyperdust_Roles_Cfg");
            const Hyperdust_Roles_Cfg = await upgrades.deployProxy(_Hyperdust_Roles_Cfg);

            const MOSSAI_Token = await ethers.deployContract("MOSSAI_20", ["test", "test"]);
            await MOSSAI_Token.waitForDeployment()



            const _MOSSAI_Island_Map = await ethers.getContractFactory("MOSSAI_Island_Map");
            const MOSSAI_Island_Map = await upgrades.deployProxy(_MOSSAI_Island_Map);

            const MOSSAI_Island_Map_Data = await ethers.deployContract("MOSSAI_Storage");
            await MOSSAI_Island_Map_Data.waitForDeployment()

            await (await MOSSAI_Island_Map_Data.setServiceAddress(MOSSAI_Island_Map.target)).wait()




            const _MOSSAI_Free_Island_Mint = await ethers.getContractFactory("MOSSAI_Free_Island_Mint");
            const MOSSAI_Free_Island_Mint = await upgrades.deployProxy(_MOSSAI_Free_Island_Mint);



            const _MOSSAI_Island = await ethers.getContractFactory("MOSSAI_Island");
            const MOSSAI_Island = await upgrades.deployProxy(_MOSSAI_Island);



            const MOSSAI_Island_Data = await ethers.deployContract("MOSSAI_Storage");
            await MOSSAI_Island_Data.waitForDeployment()

            await (await MOSSAI_Island_Data.setServiceAddress(MOSSAI_Island.target)).wait()



            const _Island721Factory = await ethers.getContractFactory("Island721Factory");
            const Island721Factory = await upgrades.deployProxy(_Island721Factory);




            const _Island1155Factory = await ethers.getContractFactory("Island1155Factory");
            const Island1155Factory = await upgrades.deployProxy(_Island1155Factory);


            const _Hyperdust_Transaction_Cfg = await ethers.getContractFactory("Hyperdust_Transaction_Cfg");
            const Hyperdust_Transaction_Cfg = await upgrades.deployProxy(_Hyperdust_Transaction_Cfg);


            const Hyperdust_Wallet_Account = await ethers.deployContract("Hyperdust_Wallet_Account");
            await Hyperdust_Wallet_Account.waitForDeployment()



            const MOSSAI_721 = await ethers.deployContract("MOSSAI_721", ["TEST", "TEST"]);
            await MOSSAI_721.waitForDeployment()




            const _MOSSAI_Island_NFG = await ethers.getContractFactory("MOSSAI_Island_NFG");
            const MOSSAI_Island_NFG = await upgrades.deployProxy(_MOSSAI_Island_NFG);

            await (await MOSSAI_721.grantRole("0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6", MOSSAI_Island_NFG.target)).wait()


            const MOSSAI_Island_NFG_Data = await ethers.deployContract("MOSSAI_Storage");
            await MOSSAI_Island_NFG_Data.waitForDeployment()

            await (await MOSSAI_Island_NFG_Data.setServiceAddress(MOSSAI_Island_NFG.target)).wait()





            const Hyperdust_Node_Mgr = await ethers.deployContract("Hyperdust_Node_Mgr");
            await Hyperdust_Node_Mgr.waitForDeployment()



            const _Island_Mint = await ethers.getContractFactory("Island_Mint");
            const Island_Mint = await upgrades.deployProxy(_Island_Mint);




            await (await Island_Mint.setContractAddress([MOSSAI_Island.target,
            Hyperdust_Wallet_Account.target,
            Hyperdust_Transaction_Cfg.target,
            MOSSAI_Token.target,
            MOSSAI_Island_NFG.target,
            Hyperdust_Roles_Cfg.target
            ])).wait()




            await (await MOSSAI_Island_NFG.setContractAddress([Hyperdust_Roles_Cfg.target, MOSSAI_Island_NFG_Data.target, MOSSAI_721.target])).wait()

            await (await MOSSAI_Island_Map.setMOSSAIRolesCfgAddress(Hyperdust_Roles_Cfg.target)).wait()
            await (await MOSSAI_Island_Map.setMOSSAIStorageAddress(MOSSAI_Island_Map_Data.target)).wait()
            await (await MOSSAI_Island_Map.batchAdd([1])).wait()


            await (await MOSSAI_Free_Island_Mint.setContractAddress([MOSSAI_Island.target, Hyperdust_Wallet_Account.target, Hyperdust_Transaction_Cfg.target, MOSSAI_Token.target, MOSSAI_721.target])).wait()

            console.info("Island_Mint: ", Island_Mint.target)

            await (await MOSSAI_Island.setContractAddress(
                [MOSSAI_Island_NFG.target,
                MOSSAI_Island_Map.target,
                Island721Factory.target,
                Island1155Factory.target,
                Hyperdust_Roles_Cfg.target,
                    "0x0000000000000000000000000000000000000000",
                MOSSAI_Island_Data.target,
                Island_Mint.target])).wait()


            const _IslandMintAddress = await MOSSAI_Island._IslandMintAddress();

            console.info("_IslandMintAddress:", _IslandMintAddress)




            await (await Hyperdust_Transaction_Cfg.setContractAddress([Hyperdust_Roles_Cfg.target, Hyperdust_Node_Mgr.target])).wait()


            await (await Hyperdust_Transaction_Cfg.add('mintNFT', 30000)).wait()

            await (await Hyperdust_Wallet_Account.setContractAddress([Hyperdust_Roles_Cfg.target, MOSSAI_Token.target])).wait()



            await (await MOSSAI_Island_NFG.setMOSSAIRolesCfgAddress(Hyperdust_Roles_Cfg.target)).wait()


            await (await MOSSAI_Island_NFG.batchAddNFG([1], ['test'], [1])).wait()



            await (await Hyperdust_Roles_Cfg.addAdmin(MOSSAI_Free_Island_Mint.target)).wait()
            await (await Hyperdust_Roles_Cfg.addAdmin(MOSSAI_Island.target)).wait()
            await (await Hyperdust_Roles_Cfg.addAdmin(Island_Mint.target)).wait()



            await (await MOSSAI_Token.mint(accounts[0].address, ethers.parseEther('111'))).wait()

            await (await MOSSAI_Token.approve(MOSSAI_Free_Island_Mint.target, ethers.parseEther('111'))).wait()


            await (await MOSSAI_Free_Island_Mint.mintIsland(1, ["test1", "test2"], ["test1", "test2"])).wait()


            await MOSSAI_Island.getIsland(1)

            await (await MOSSAI_Token.approve(Island_Mint.target, ethers.parseEther('111'))).wait()

            await (await Island_Mint.mint721(1, "test")).wait()
            await (await Island_Mint.mint1155(1, 1, 1000, "test")).wait()



            await (await MOSSAI_Island.updateErc721Address(1, "test", "test")).wait();
            await (await MOSSAI_Island.updateErc1155Address(1, "test", "test")).wait();



        });
    });
});
