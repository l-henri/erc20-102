pragma solidity ^0.6.0;

interface IExerciceSolution 
{

	function claimTokensOnBehalf() external;

	function tokensInCustody(address callerAddress) external returns (uint256);

	function withdrawTokens(uint256 amountToWithdraw) external returns (uint256); 

	function depositTokens(uint256 amountToWithdraw) external returns (uint256); 

	function getERC20DepositAddress() external returns (address);
}
