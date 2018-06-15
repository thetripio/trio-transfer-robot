pragma solidity ^0.4.21;

import "./extensions/TPTTransfer.sol";

contract TrioPeriodicTransfer is TPTTransfer {
    function TrioPeriodicTransfer(address _trio) public {
        trioContract = _trio;
    }
}