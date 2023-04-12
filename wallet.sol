//0x85f2d86d40BFB637e610581B2AEf73020A5DC9C9

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TimeLockedWallet {
    using SafeMath for uint256;

    address public owner;
    uint256 public balance;
    uint256 public releaseTime;

    event FundsLocked(uint256 amount, uint256 releaseTime);
    event LockTimeIncreased(uint256 oldReleaseTime, uint256 newReleaseTime);
    event LockTimeDecreased(uint256 oldReleaseTime, uint256 newReleaseTime);

    constructor(uint256 _releaseTime) {
        owner = msg.sender;
        balance = 0;
        releaseTime = _releaseTime;
        emit FundsLocked(balance, releaseTime);
    }

    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw funds.");
        require(block.timestamp >= releaseTime, "Release time has not yet passed.");

        uint256 amount = balance;
        balance = 0;

        (bool success, ) = owner.call{value: amount}("");
        require(success, "Transfer failed.");
    }

    function increaseLockTime(uint256 _extraTime) public {
        require(msg.sender == owner, "Only owner can increase lock time.");
        require(_extraTime > 0, "Extra time must be greater than zero.");
        require(releaseTime > block.timestamp, "Release time has already passed.");
        uint256 oldReleaseTime = releaseTime;
        releaseTime = releaseTime.add(_extraTime);
        emit LockTimeIncreased(oldReleaseTime, releaseTime);
    }

    function decreaseLockTime(uint256 _reduceTime) public {
        require(msg.sender == owner, "Only owner can decrease lock time.");
        require(_reduceTime > 0, "Reduce time must be greater than zero.");
        require(releaseTime > block.timestamp, "Release time has already passed.");
        require(releaseTime.sub(_reduceTime) >= block.timestamp, "Cannot reduce lock time below current time.");
        uint256 oldReleaseTime = releaseTime;
        releaseTime = releaseTime.sub(_reduceTime);
        emit LockTimeDecreased(oldReleaseTime, releaseTime);
    }

    fallback() external payable {
        revert("Ether not accepted.");
    }
}


