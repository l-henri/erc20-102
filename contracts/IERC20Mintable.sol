pragma solidity ^0.6.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20Mintable is IERC20 
{

	function setMinter(address minterAddress, bool isMinter)  external;

	function mint(address toAddress, uint256 amount)  external;

	function isMinter(address minterAddress) external returns (bool);
}
