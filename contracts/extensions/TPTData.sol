pragma solidity ^0.4.21;

contract TPTData {
    address public trioContract;

    struct Contributor {
        uint256 next;
        uint256 prev;
        uint256 cid;
        address contributor;
        bytes32 name;
    }
    
    struct ContributorChain {
        uint256 balance;
        uint256 head;
        uint256 tail;
        uint256 index;
        mapping(uint256 => Contributor) nodes; // cid -> Contributor
    }

    struct Schedule {
        uint256 next;
        uint256 prev;
        uint256 sid;
        uint32 timestamp;
        uint256 trio;
    }

    struct ScheduleChain {
        uint256 balance;
        uint256 head;
        uint256 tail;
        uint256 index;
        mapping (uint256 => Schedule) nodes;
    }

    // The contributors chain
    ContributorChain contributorChain;

    // The schedules chains
    mapping (uint256 => ScheduleChain) scheduleChains;

    /**
     * The contributor is valid
     */
    modifier contributorValid(uint256 _cid) {
        require(contributorChain.nodes[_cid].cid == _cid);
        _;
    }

    /**
     * The schedule is valid
     */
    modifier scheduleValid(uint256 _cid, uint256 _sid) {
        require(scheduleChains[_cid].nodes[_sid].sid == _sid);
        _;
    }
}