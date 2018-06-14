pragma solidity ^0.4.21;

import "./extensions/TPTTransfer.sol";

contract TrioPeriodicTranster is TPTContributors, TPTSchedules {
    function TrioPeriodicTranster(address _trio) public {
        trioContract = _trio;
    }
}