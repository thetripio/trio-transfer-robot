pragma solidity ^0.4.21;

contract TPTData {
    address public trioContract;

    struct Contributor {
        uint32 next;
        uint32 prev;
        uint32 cid;
        address contributor;
        bytes32 name;
    }
    
    struct ContributorChain {
        uint32 balance;
        uint32 head;
        uint32 tail;
        uint32 index;
        mapping(uint32 => Contributor) nodes; // cid -> Contributor
    }

    struct Schedule {
        uint32 next;
        uint32 prev;
        uint32 sid;
        uint32 timestamp;
        uint256 trio;
    }

    struct ScheduleChain {
        uint32 balance;
        uint32 head;
        uint32 tail;
        uint32 index;
        mapping (uint32 => Schedule) nodes;
    }

    // The contributors chain
    ContributorChain contributorChain;

    // The schedules chains
    mapping (uint32 => ScheduleChain) scheduleChains;

    /**
     * The contributor is valid
     */
    modifier contributorValid(uint32 _cid) {
        require(contributorChain.nodes[_cid].cid == _cid);
        _;
    }

    /**
     * The schedule is valid
     */
    modifier scheduleValid(uint32 _cid, uint32 _sid) {
        require(scheduleChains[_cid].nodes[_sid].sid == _sid);
        _;
    }
}