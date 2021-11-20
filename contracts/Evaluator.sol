pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./ERC20TD.sol";
import "./ERC20Claimable.sol";
import "./IExerciceSolution.sol";
import "./IERC20Mintable.sol";

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
		// Check the user has some tokens
		require(claimableERC20.balanceOf(msg.sender) > 0, "Sender has no tokens");

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
		require(exerciceProgression[msg.sender][0], "No solution submitted");

		// Checking how many tokens ExerciceSolution holds
		uint256 solutionInitBalance = claimableERC20.balanceOf(address(studentExerciceSolution[msg.sender]));

		// Claiming tokens through ExerciceSolution
		studentExerciceSolution[msg.sender].claimTokensOnBehalf();

		// Verifying ExerciceSolution holds tokens
		uint256 solutionEndBalance = claimableERC20.balanceOf(address(studentExerciceSolution[msg.sender]));
		require(solutionEndBalance - solutionInitBalance == claimableERC20.distributedAmount(), "No claimable tokens minted to ExerciceSolution");

		// Verifying ExerciceSolution kept track of our balance
		studentExerciceSolution[msg.sender].claimTokensOnBehalf();
		require(studentExerciceSolution[msg.sender].tokensInCustody(address(this)) == 2*claimableERC20.distributedAmount(), "Balance of sender not kept in ExerciceSolution");


		// Crediting points
		if (!exerciceProgression[msg.sender][2])
		{
			exerciceProgression[msg.sender][2] = true;
			TDERC20.distributeTokens(msg.sender, 2);
		}
	}

	function ex3_withdrawFromContract()
	public
	{
		// Checking a solution was submitted
		require(exerciceProgression[msg.sender][0], "No solution submitted");

		// Checking how many tokens ExerciceSolution and Evaluator hold
		uint256 solutionInitBalance = claimableERC20.balanceOf(address(studentExerciceSolution[msg.sender]));
		uint256 selfInitBalance = claimableERC20.balanceOf(address(this));
		uint256 amountToWithdraw = studentExerciceSolution[msg.sender].tokensInCustody(address(this));

		// Withdraw tokens through ExerciceSolution
		studentExerciceSolution[msg.sender].withdrawTokens(amountToWithdraw);

		// Verifying tokens where withdrew correctly
		uint256 solutionEndBalance = claimableERC20.balanceOf(address(studentExerciceSolution[msg.sender]));
		uint256 selfEndBalance = claimableERC20.balanceOf(address(this));
		uint256 amountLeft = studentExerciceSolution[msg.sender].tokensInCustody(address(this));

		require(solutionInitBalance - solutionEndBalance== amountToWithdraw, "ExerciceSolution has an incorrect amount of tokens");
		require(selfEndBalance - selfInitBalance == amountToWithdraw, "Evaluator has an incorrect amount of tokens");
		require(amountLeft == 0, "Tokens left held by ExerciceSolution");

		// Crediting points
		if (!exerciceProgression[msg.sender][3])
		{
			exerciceProgression[msg.sender][3] = true;
			TDERC20.distributeTokens(msg.sender, 2);
		}
	}

	function ex4_approvedExerciceSolution()
	public
	{
		// Checking a solution was submitted
		require(exerciceProgression[msg.sender][0], "No solution submitted");

		require(claimableERC20.allowance(msg.sender, address(studentExerciceSolution[msg.sender])) > 0,  "ExerciceSolution no allowed to spend msg.sender tokens");

		// Crediting points
		if (!exerciceProgression[msg.sender][4])
		{
			exerciceProgression[msg.sender][4] = true;
			TDERC20.distributeTokens(msg.sender, 1);
		}
	}

	function ex5_revokedExerciceSolution()
	public
	{
		// Checking a solution was submitted
		require(exerciceProgression[msg.sender][0], "No solution submitted");

		require(claimableERC20.allowance(msg.sender, address(studentExerciceSolution[msg.sender])) == 0, "ExerciceSolution still allowed to spend msg.sender tokens");

		// Crediting points
		if (!exerciceProgression[msg.sender][5])
		{
			exerciceProgression[msg.sender][5] = true;
			TDERC20.distributeTokens(msg.sender, 1);
		}
	}

	function ex6_depositTokens()
	public
	{
		// Checking a solution was submitted
		require(exerciceProgression[msg.sender][0], "No solution submitted");

		uint256 amountToDeposit = 100;

		// Checking how many tokens ExerciceSolution and Evaluator hold
		uint256 solutionInitBalance = claimableERC20.balanceOf(address(studentExerciceSolution[msg.sender]));
		uint256 selfInitBalance = claimableERC20.balanceOf(address(this));
		uint256 amountDeposited = studentExerciceSolution[msg.sender].tokensInCustody(address(this));
		require(selfInitBalance>= amountToDeposit, "Evaluator does not hold enough tokens");

		// Approve student solution to manipulate our tokens
		claimableERC20.increaseAllowance(address(studentExerciceSolution[msg.sender]), amountToDeposit);

		// Deposit tokens in student contract
		studentExerciceSolution[msg.sender].depositTokens(amountToDeposit);

		// Check balances are correct
		uint256 solutionEndBalance = claimableERC20.balanceOf(address(studentExerciceSolution[msg.sender]));
		uint256 selfEndBalance = claimableERC20.balanceOf(address(this));
		uint256 amountLeft = studentExerciceSolution[msg.sender].tokensInCustody(address(this));

		require(solutionEndBalance - solutionInitBalance == amountToDeposit, "ExerciceSolution has an incorrect amount of tokens");
		require(selfInitBalance - selfEndBalance == amountToDeposit, "Evaluator has an incorrect amount of tokens");
		require(amountLeft - amountDeposited == amountToDeposit, "Balance of Evaluator not credited correctly in ExerciceSolution");


		// Crediting points
		if (!exerciceProgression[msg.sender][6])
		{
			exerciceProgression[msg.sender][6] = true;
			TDERC20.distributeTokens(msg.sender, 2);
		}
	}

	function ex7_createERC20()
	public
	{
		// Checking a solution was submitted
		require(exerciceProgression[msg.sender][0], "No solution submitted");

		// Get ExerciceSolutionERC20 address
		address exerciceSolutionERC20 = studentExerciceSolution[msg.sender].getERC20DepositAddress();
		IERC20Mintable ExerciceSolutionERC20 = IERC20Mintable(exerciceSolutionERC20);

		// Check that ExerciceSolution is a minter to ExerciceSolutionERC20
		// Check that we are not a minter to ExerciceSolutionERC20
		require(ExerciceSolutionERC20.isMinter(address(studentExerciceSolution[msg.sender])), "ExerciceSolution is not minter");
		require(!ExerciceSolutionERC20.isMinter(address(this)), "Evaluator is minter");

		// Check that we can not mint ExerciceSolutionERC20 tokens 
		bool wasMintAccepted = false;
		try ExerciceSolutionERC20.mint(address(this), 10000)
		{
			wasMintAccepted = true;
        } 
        catch 
        {
            // This is executed in case revert() was used.
            wasMintAccepted = false;
        }

        require(!wasMintAccepted, "Evaluator was able to mint");

		// Crediting points
		if (!exerciceProgression[msg.sender][7])
		{
			exerciceProgression[msg.sender][7] = true;
			TDERC20.distributeTokens(msg.sender, 2);
		}
	}

	function ex8_depositAndMint()
	public
	{
		// Checking a solution was submitted
		require(exerciceProgression[msg.sender][0], "No solution submitted");

		uint256 amountToDeposit = 100;

		// Checking how many tokens ExerciceSolution and Evaluator hold
		uint256 solutionInitBalance = claimableERC20.balanceOf(address(studentExerciceSolution[msg.sender]));
		uint256 selfInitBalance = claimableERC20.balanceOf(address(this));
		address exerciceSolutionERC20 = studentExerciceSolution[msg.sender].getERC20DepositAddress();
		IERC20Mintable ExerciceSolutionERC20 = IERC20Mintable(exerciceSolutionERC20);
		uint256 amountDeposited = ExerciceSolutionERC20.balanceOf(address(this));
		uint256 initWrappedTotalSupply = ExerciceSolutionERC20.totalSupply();
		require(selfInitBalance>= amountToDeposit, "Evaluator does not hold enough tokens");

		// Approve student solution to manipulate our tokens
		claimableERC20.increaseAllowance(address(studentExerciceSolution[msg.sender]), amountToDeposit);

		// Deposit tokens in student contract
		studentExerciceSolution[msg.sender].depositTokens(amountToDeposit);

		// Check balances are correct
		uint256 solutionEndBalance = claimableERC20.balanceOf(address(studentExerciceSolution[msg.sender]));
		uint256 selfEndBalance = claimableERC20.balanceOf(address(this));
		uint256 amountLeft = ExerciceSolutionERC20.balanceOf(address(this));
		uint256 endWrappedTotalSupply = ExerciceSolutionERC20.totalSupply();

		require(solutionEndBalance - solutionInitBalance == amountToDeposit, "ExerciceSolution has an incorrect amount of tokens");
		require(selfInitBalance - selfEndBalance == amountToDeposit, "Evaluator has an incorrect amount of tokens");
		require(amountLeft - amountDeposited == amountToDeposit, "Balance of Evaluator not credited correctly in ExerciceSolutionErc20");
		require(endWrappedTotalSupply - initWrappedTotalSupply == amountToDeposit, "ExerciceSolutionErc20 were not minted correctly");

		// Crediting points
		if (!exerciceProgression[msg.sender][8])
		{
			exerciceProgression[msg.sender][8] = true;
			TDERC20.distributeTokens(msg.sender, 2);
		}
	}

	function ex9_withdrawAndBurn()
	public
	{
		// Checking a solution was submitted
		require(exerciceProgression[msg.sender][0], "No solution submitted");

		// Checking how many tokens ExerciceSolution and Evaluator hold
		uint256 solutionInitBalance = claimableERC20.balanceOf(address(studentExerciceSolution[msg.sender]));
		uint256 selfInitBalance = claimableERC20.balanceOf(address(this));
		address exerciceSolutionERC20 = studentExerciceSolution[msg.sender].getERC20DepositAddress();
		IERC20Mintable ExerciceSolutionERC20 = IERC20Mintable(exerciceSolutionERC20);
		uint256 amountToWithdraw = ExerciceSolutionERC20.balanceOf(address(this));
		uint256 initWrappedTotalSupply = ExerciceSolutionERC20.totalSupply();

		// Withdraw tokens through ExerciceSolution
		studentExerciceSolution[msg.sender].withdrawTokens(amountToWithdraw);

		// Verifying tokens where withdrew correctly
		uint256 solutionEndBalance = claimableERC20.balanceOf(address(studentExerciceSolution[msg.sender]));
		uint256 selfEndBalance = claimableERC20.balanceOf(address(this));
		uint256 amountLeft = ExerciceSolutionERC20.balanceOf(address(this));
		uint256 endWrappedTotalSupply = ExerciceSolutionERC20.totalSupply();

		require(solutionInitBalance - solutionEndBalance== amountToWithdraw, "ExerciceSolution has an incorrect amount of tokens");
		require(selfEndBalance - selfInitBalance == amountToWithdraw, "Evaluator has an incorrect amount of tokens");
		require(amountLeft == 0, "Tokens still credited ExerciceSolutionErc20");
		require(initWrappedTotalSupply - endWrappedTotalSupply == amountToWithdraw, "ExerciceSolutionErc20 were not burned correctly");

		// Crediting points
		if (!exerciceProgression[msg.sender][9])
		{
			exerciceProgression[msg.sender][9] = true;
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
