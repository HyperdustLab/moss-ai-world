import { ethers } from 'hardhat'
import fs from 'fs'
import path from 'path'
import util from 'util'

const readdir = util.promisify(fs.readdir)
const readFile = util.promisify(fs.readFile)

async function main() {
  const MOSSAI_Island_NFG = await ethers.getContractAt('MOSSAI_Island_NFG', '0x74A6B3D4d0A9a7acC5a4e181d76dc7F0E49A978A')

  const directoryPath = 'D:\\island'

  // 用于存储文件名和seed属性的数组
  let seeds = []
  let locations = []
  let uris = []

  try {
    const files = await readdir(directoryPath)

    for (const file of files) {
      // 获取文件名，不包括后缀
      const fileName = path.parse(file).name
      locations.push(parseInt(fileName))

      uris.push('https://s3.hyperdust.io/island/' + fileName + '.json')

      // 读取文件内容
      const filePath = path.join(directoryPath, file)
      const data = await readFile(filePath, 'utf8')

      // 解析JSON字符串并获取seed属性
      const json = JSON.parse(data)
      const seed = json.seed
      seeds.push(seed)
    }
  } catch (err) {
    console.log('Error:', err)
  }

  const batchSize = 100
  for (let i = 0; i < seeds.length; i += batchSize) {
    const seedsBatch = seeds.slice(i, i + batchSize)
    const locationsBatch = locations.slice(i, i + batchSize)
    const urisBatch = uris.slice(i, i + batchSize)

    console.info(seedsBatch, urisBatch, locationsBatch)

    // Assuming the contract has a method `batchAdd` that takes arrays of seeds, locations, and uris
    await (await MOSSAI_Island_NFG.batchAddNFG(seedsBatch, urisBatch, locationsBatch)).wait()
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
