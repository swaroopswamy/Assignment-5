pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TimeLockedWallet {
    using SafeMath for uint256;

    address public owner;
    uint256 public balance;
    uint256 public releaseTime;

    constructor(uint256 _releaseTime) {
        owner = msg.sender;
        balance = 0;
        releaseTime = _releaseTime;
    }

    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw funds.");
        require(block.timestamp >= releaseTime, "Release time has not yet passed.");

        uint256 amount = balance;
        balance = 0;

        
    }

    function increaseLockTime(uint256 _extraTime) public {
        require(msg.sender == owner, "Only owner can increase lock time.");
        releaseTime = releaseTime.add(_extraTime);
    }

    function decreaseLockTime(uint256 _reduceTime) public {
        require(msg.sender == owner, "Only owner can decrease lock time.");
        require(releaseTime > block.timestamp, "Release time has already passed.");
        require(releaseTime.sub(_reduceTime) >= block.timestamp, "Cannot reduce lock time below current time.");

        releaseTime = releaseTime.sub(_reduceTime);
    }
}