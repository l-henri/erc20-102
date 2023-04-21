// Deploying the TD somewhere
// To verify it on Etherscan:
// npx hardhat verify --network sepolia <address> <constructor arg 1> <constructor arg 2>

const hre = require("hardhat");
const Str = require('@supercharge/strings')

async function main() {
  // Deploying contracts
  const ERC20TD = await hre.ethers.getContractFactory("ERC20TD");
  const ERC20Claimable = await hre.ethers.getContractFactory("ERC20Claimable");
  const Evaluator = await hre.ethers.getContractFactory("Evaluator");
  const erc20 = await ERC20TD.deploy("TD-ERC20-102-23","TD-ERC20-102-23",0);
  const erc20claimable = await ERC20TD.deploy("ClaimableToken23","CLTK-23",0);
  
  await erc20.deployed();
  const evaluator = await Evaluator.deploy(erc20.address, erc20claimable.address);
  console.log(
    `ERC20TD deployed at  ${erc20.address}`
  );
  await evaluator.deployed();
  console.log(
    `Evaluator deployed at ${evaluator.address}`
  );
  await erc20claimable.deployed();
  console.log(
    `erc20claimable deployed at ${erc20claimable.address}`
  );
    // Setting the teacher
    await erc20.setTeacher(evaluator.address, true)

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
