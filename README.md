# ERC20 102

## Introduction
Welcome! This is an automated workshop that will dive deeper into managing ERC20 tokens. Specifically we will look at patterns using approve() and transferFrom().
It is aimed at developers used to interacting with and writing smart contracts.

## How to work on this TD
The TD has three components:
- An ERC20 token, ticker TD-ERC20-102, that is used to keep track of points 
- An evaluator contract, that is able to mint and distribute TD-ERC20-102 points
- A claimable ERC20 token, that is used to issue tokens and manipulate them

Your objective is to gather as many TD-ERC20-102 points as possible. Please note :
- The `transfer` function of TD-ERC20-102 has been disabled to encourage you to finish the TD with only one address
- In order to receive points, you will have to do execute code in `Evaluator.sol` such that the function `TDERC20.distributeTokens(msg.sender, n);` is triggered, and distributes n points.
- This repo contains an interface `IExerciceSolution.sol`. Your ERC20 contract will have to conform to this interface in order to validate the exercice; that is, your contract needs to implement all the functions described in `IExerciceSolution.sol`. 
- A high level description of what is expected for each exercice is in this readme. A low level description of what is expected can be inferred by reading the code in `Evaluator.sol`.
- The Evaluator contract sometimes needs to make payments to buy your tokens. Make sure he has enough ETH to do so! If not, you can send ETH directly to the contract.
- You can use different contracts to validate different exercices. In order to update the evaluated exercice, call `submitExercice()` in the Evaluator contract.

### Getting to work
- Clone the repo on your machine
- Install the required packages `npm install @openzeppelin/contracts@3.4.1` and `npm install @truffle/hdwallet-provider`
- Copy the content of `example-truffle-config.js` to your truffle config
- Configure a seed for deployment of contracts in your truffle config
- Register for an infura key and set it up in your truffle config
- Download and launch Ganache
- Test that you are able to connect to the rinkeby network with `truffle console`
- Test that you are able to connect to the rinkeby network with `truffle console --network rinkeby`
- To deploy a contract, configure a migration in the [migration folder](migrations). Look at the way the TD is deploy and try to iterate
- Test your deployment in Ganache `truffle migrate`
- Deploy on Rinkeby `truffle migrate --network rinkeby --skip-dry-run`

## Points list
### Setting up
- Create a git repository and share it with the teacher
- Create an Infura account and API Key (1 pts)
- Install and configure truffle (1 pts)
These points will be attributed manually if you do not manage to have your contract interact with the evaluator, or automatically when claiming points.
- Manually claim tokens on claimable ERC20 (1 pts)
- Claim your points by calling `ex1_claimedPoints()` in the evaluator (2 pts)


### Calling another contract from your contract
- Create a contract (ExerciceSolution) that can claim tokens from teacher ERC20. Keep track of addresses who claimed token, and how much in ExerciceSolution.
- Deploy ExerciceSolution and submit it to the evaluator with  `submitExercice()` (1 pts)
- Call `ex2_claimedFromContract` in the evaluator to prove your code work (2 pts)
- Create a function `withdrawTokens()` in ExerciceSolution to withdraw the claimableTokens from the ExerciceSolution to the address that initially claimed them 
- Call `ex3_withdrawFromContract` in the evaluator to prove your code work (2 pts)

### Approve and transferFrom
- Use ERC20 function to allow your contract to manipulate your tokens. Call `ex4_approvedExerciceSolution()` to claim points (1 pts) 
- Use ERC20 to revoke this authorization. Call `ex5_revokedExerciceSolution()` to claim points (1 pts)
- Create a function `depositTokens()` through which a user can deposit claimableTokens in ExerciceSolution, using transferFrom  
- Call `ex6_depositTokens` in the evaluator to prove your code work (2 pts)

### Tracking user deposits with a deposit wrapper ERC20
- Create and deploy an ERC20 (ExerciceSolutionToken) to track user deposit. This ERC20 should be mintable and mint autorization given to ExerciceSolution. 
- Call `ex7_createERC20` in the evaluator to prove your code work (2 pts)
- Update the deposit function so that user balance is tokenized. When a deposit is made in ExerciceSolution, tokens are minted in ExerciceSolutionToken and transfered to the address depositing. 
- Call `ex8_depositAndMint` in the evaluator to prove your code work (2 pts)
- Update the ExerciceSolution withdraw function so that it uses transferFrom() ExerciceSolutionToken, burns these tokens, and returns the claimable tokens 
- Call `ex9_withdrawAndBurn` in the evaluator to prove your code work (2 pts)

### Extra points
Extra points if you find bugs / corrections this TD can benefit from, and submit a PR to make it better.  Ideas:
- Adding a way to check the code of a specific contract was only used once (no copying) 
- Publish the code of the Evaluator on Etherscan using the "Verify and publish" functionnality 

## TD addresses
- TDToken `0x77dAe18835b08A75490619DF90a3Fa5f4120bB2E`
- ClaimableToken `0xb5d82FEE98d62cb7Bc76eabAd5879fa4b29fFE94`
- Evaluator `0x384C00Ff43Ed5376F2d7ee814677a15f3e330705`
