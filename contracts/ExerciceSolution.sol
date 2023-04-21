// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./IExerciceSolution.sol";
import "./ERC20Claimable.sol";

contract ExerciceSolution is IExerciceSolution 
{
	ERC20Claimable claimableERC20;
	mapping(address => uint256) public balance;

	constructor(ERC20Claimable _claimableERC20) 
	{
		claimableERC20 = _claimableERC20;
	}

	function claimTokensOnBehalf() external override
	{
		uint256 claimedTokens = claimableERC20.claimTokens();
		balance[msg.sender] += claimedTokens;
	}

	function tokensInCustody(address callerAddress) external override returns (uint256)
	{
		return balance[callerAddress];
	}

	function withdrawTokens(uint256 amountToWithdraw) external override returns (uint256)
	{
		balance[msg.sender] -= amountToWithdraw;
		claimableERC20.transfer(msg.sender, amountToWithdraw);
	}

	function depositTokens(uint256 amountToWithdraw) external override returns (uint256)
	{}

	function getERC20DepositAddress() external override returns (address)
	{}
}
