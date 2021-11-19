pragma solidity ^0.6.0;

interface IExerciceSolution 
{

	function claimTokensOnBehalf() external;

	function tokensInCustody(address callerAddress) external returns (uint256);

}
