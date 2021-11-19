pragma solidity >=0.6.0 <0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Claimable is ERC20 {

	uint256 public distributedAmount = 100002500002300000;
	constructor(string memory name, string memory symbol,uint256 initialSupply) public ERC20(name, symbol) 
	{
	   _mint(msg.sender, initialSupply);
	}

	function claimTokens() public
	{
	  _mint(msg.sender, distributedAmount);
	}

}
