pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TokenVesting {

    using SafeMath for uint256;

    address public beneficiary;
    uint256 public vestingStart;
    uint256 public vestingDuration;
    uint256 public vestingCliff;
    uint256 public totalTokens;
    IERC20 public token;

    constructor(
        address _beneficiary,
        uint256 _vestingStart,
        uint256 _vestingDuration,
        uint256 _vestingCliff,
        uint256 _totalTokens,
        address _token
    ) {
        require(_beneficiary != address(0), "Invalid beneficiary address");
        require(_vestingDuration > 0, "Vesting duration must be greater than 0");
        require(_totalTokens > 0, "Total tokens must be greater than 0");

        beneficiary = _beneficiary;
        vestingStart = _vestingStart;
        vestingDuration = _vestingDuration;
        vestingCliff = _vestingCliff;
        totalTokens = _totalTokens;
        token = IERC20(_token);
    }

    function release() public {
        require(block.timestamp >= vestingStart.add(vestingCliff), "Tokens cannot be released yet");

        uint256 vestedTokens = totalTokens.mul(block.timestamp.sub(vestingStart)).div(vestingDuration);
        uint256 transferAmount = vestedTokens.sub(token.balanceOf(address(this)));
        require(transferAmount > 0, "No tokens to release");

        require(token.transfer(beneficiary, transferAmount), "Token transfer failed");
    }

    function revoke() public {
        require(msg.sender == beneficiary, "Only beneficiary can revoke tokens");
        require(block.timestamp >= vestingStart.add(vestingDuration), "Vesting period not ended");

        uint256 unreleasedTokens = token.balanceOf(address(this));
        require(unreleasedTokens > 0, "No tokens to revoke");

        require(token.transfer(beneficiary, unreleasedTokens), "Token transfer failed");
    }
}
