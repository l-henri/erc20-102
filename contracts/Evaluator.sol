pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./ERC20TD.sol";
import "./ERC20Claimable.sol";
import "./IExerciceSolution.sol";

contract Evaluator 
{

	mapping(address => bool) public teachers;
	ERC20TD TDERC20;
	ERC20Claimable claimableERC20;

	uint256[20] private randomSupplies;
	string[20] private randomTickers;
 	uint public nextValueStoreRank;


 	mapping(address => mapping(uint256 => bool)) public exerciceProgression;
 	mapping(address => IExerciceSolution) public studentExerciceSolution;
 	mapping(address => bool) public hasBeenPaired;

 	event newRandomTickerAndSupply(string ticker, uint256 supply);
 	event constructedCorrectly(address erc20Address, address claimableERC20Address);
	constructor(ERC20TD _TDERC20, ERC20Claimable _claimableERC20) 
	public 
	{
		TDERC20 = _TDERC20;
		claimableERC20 = _claimableERC20;
		emit constructedCorrectly(address(TDERC20), address(claimableERC20));
	}

	fallback () external payable 
	{}

	receive () external payable 
	{}

	function ex1_claimedPoints()
	public
	{
		// Checking this contract was not used by another group before
		require(claimableERC20.balanceOf(msg.sender) > 0);

		// Crediting points
		if (!exerciceProgression[msg.sender][1])
		{
			exerciceProgression[msg.sender][1] = true;
			TDERC20.distributeTokens(msg.sender, 1);
			TDERC20.distributeTokens(msg.sender, 1);
			TDERC20.distributeTokens(msg.sender, 1);
			TDERC20.distributeTokens(msg.sender, 2);
		}
	}

	function ex2_claimedFromContract()
	public
	{
		// Checking a solution was submitted
		require(exerciceProgression[msg.sender][0]);

		// Checking how many tokens ExerciceSolution holds
		uint256 solutionInitBalance = claimableERC20.balanceOf(address(studentExerciceSolution[msg.sender]));

		// Claiming tokens through ExerciceSolution
		studentExerciceSolution[msg.sender].claimTokensOnBehalf();

		// Verifying ExerciceSolution holds tokens
		uint256 solutionEndBalance = claimableERC20.balanceOf(address(studentExerciceSolution[msg.sender]));
		require(solutionEndBalance - solutionInitBalance == claimableERC20.distributedAmount());

		// Verifying ExerciceSolution kept track of our balance
		studentExerciceSolution[msg.sender].claimTokensOnBehalf();
		require(studentExerciceSolution[msg.sender].tokensInCustody(address(this)) == 2*claimableERC20.distributedAmount());


		// Crediting points
		if (!exerciceProgression[msg.sender][2])
		{
			exerciceProgression[msg.sender][2] = true;
			TDERC20.distributeTokens(msg.sender, 2);
		}
	}







	/* Internal functions and modifiers */ 
	function submitExercice(IExerciceSolution studentExercice)
	public
	{
		// Checking this contract was not used by another group before
		require(!hasBeenPaired[address(studentExercice)]);

		// Assigning passed ERC20 as student ERC20
		studentExerciceSolution[msg.sender] = studentExercice;
		hasBeenPaired[address(studentExercice)] = true;

		if (!exerciceProgression[msg.sender][0])
		{
			exerciceProgression[msg.sender][0] = true;
			TDERC20.distributeTokens(msg.sender, 1);
		}
	}

	modifier onlyTeachers() 
	{

	    require(TDERC20.teachers(msg.sender));
	    _;
	}

	function _compareStrings(string memory a, string memory b) 
	internal 
	pure 
	returns (bool) 
	{
    	return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
	}

	function bytes32ToString(bytes32 _bytes32) 
	public 
	pure returns (string memory) 
	{
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

}
