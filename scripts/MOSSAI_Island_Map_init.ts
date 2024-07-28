/** @format */

import { ethers, run, upgrades } from 'hardhat'

import { Database } from '../Database'

async function main() {
  const db = new Database(process.env.db_host, process.env.db_user, process.env.db_name, process.env.db_password)
  await db.connect()
  const rows = await db.query('SELECT * FROM mgn_space_token_uri', [])

  const MOSSAI_Island_Map = await ethers.getContractAt('MOSSAI_Island_Map', '0x998cCb1dF5d0b9599c8067882D75a95889a6914A')

  const batchSize = 300
  for (let i = 0; i < rows.length; i += batchSize) {
    const batch = rows.slice(i, i + batchSize)
    const coordinates = batch.map(item => item.coordinate)

    console.info(coordinates)

    await (await MOSSAI_Island_Map.batchAdd(coordinates)).wait()
  }

  await db.close()
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
