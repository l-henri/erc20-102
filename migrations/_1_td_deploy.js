
var TDErc20 = artifacts.require("ERC20TD.sol");
var ERC20Claimable = artifacts.require("ERC20Claimable.sol");
var evaluator = artifacts.require("Evaluator.sol");


module.exports = (deployer, network, accounts) => {
    deployer.then(async () => {
        await deployTDToken(deployer, network, accounts); 
        await deployEvaluator(deployer, network, accounts); 
        await setPermissionsAndRandomValues(deployer, network, accounts); 
        await deployRecap(deployer, network, accounts); 
    });
};

async function deployTDToken(deployer, network, accounts) {
	TDToken = await TDErc20.new("TD-ERC20-102-23","TD-ERC20-102-23",web3.utils.toBN("20000000000000000000000000000"))
	ClaimableToken = await ERC20Claimable.new("ClaimableToken23","CLTK-23",web3.utils.toBN("20000000000000000000000000000"))
}

async function deployEvaluator(deployer, network, accounts) {
	Evaluator = await evaluator.new(TDToken.address, ClaimableToken.address)
}

async function setPermissionsAndRandomValues(deployer, network, accounts) {
	await TDToken.setTeacher(Evaluator.address, true)
}

async function deployRecap(deployer, network, accounts) {
	console.log("TDToken " + TDToken.address)
	console.log("ClaimableToken " + ClaimableToken.address)
	console.log("Evaluator " + Evaluator.address)
}


// truffle run verify ERC20TD@0xb79a94500EE323f15d76fF963CcE27cA3C9e32DF --network goerli 
// truffle run verify ERC20Claimable@0xE70AE39bDaB3c3Df5225E03032D31301E2E71B6b --network goerli 
// truffle run verify Evaluator@0x16F3F705825294A55d40D3D34BAF9F91722d6143 --network goerli 
