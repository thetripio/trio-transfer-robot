pragma solidity ^0.4.21;

import "./TripioToken.sol";
import "./TPTContributors.sol";
import "./TPTSchedules.sol";

contract TPTTransfer is TPTContributors, TPTSchedules {
    function TPTTransfer() public {
        
    }

    /**
     * This emits when transfer 
     */
    event AutoTransfer(address indexed _to, uint256 _trio);

    /**
     * This emits when 
     */
    event AutoTransferCompleted();

    /**
     * Withdraw TRIO TOKEN balance from contract account, the balance will transfer to the contract owner
     */
    function withdrawToken() external onlyOwner {
        TripioToken tripio = TripioToken(trioContract);
        uint256 tokens = tripio.balanceOf(address(this));
        tripio.transfer(owner, tokens);
    }

    /**
     * Auto Transfer All Schedules
     */
    function autoTransfer() external onlyOwner {
        // TRIO contract
        TripioToken tripio = TripioToken(trioContract);
        
        // All contributors
        uint32[] memory _contributors = contributors();
        for (uint32 i = 0; i < _contributors.length; i++) {
            // cid and contributor address
            uint32 _cid = _contributors[i];
            address _contributor = contributorChain.nodes[_cid].contributor;
            
            // All schedules
            uint32[] memory _schedules = schedules(_cid);
            for (uint32 j = 0; j < _schedules.length; j++) {
                // sid, trio and timestamp
                uint32 _sid = _schedules[j];
                uint256 _trio = scheduleChains[_cid].nodes[_sid].trio;
                uint32 _timestamp = scheduleChains[_cid].nodes[_sid].timestamp;

                // hasn't arrived
                if(_timestamp > now) {
                    break;
                }
                // Transfer TRIO to contributor
                tripio.transfer(_contributor, _trio);

                // Remove schedule of contributor
                uint32[] memory _sids = new uint32[](1);
                _sids[0] = _sid;
                removeSchedules(_cid, _sids);
                emit AutoTransfer(_contributor, _trio);
            }
        }

        emit AutoTransferCompleted();
    }

    /**
     * Is there any transfer in schedule
     */
    function totalTransfersInSchedule() external view returns(uint32, uint256) {
        // All contributors
        uint32[] memory _contributors = contributors();
        uint32 total = 0;
        uint256 amount = 0;
        for (uint32 i = 0; i < _contributors.length; i++) {
            // cid and contributor address
            uint32 _cid = _contributors[i];            
            // All schedules
            uint32[] memory _schedules = schedules(_cid);
            for (uint32 j = 0; j < _schedules.length; j++) {
                // sid, trio and timestamp
                uint32 _sid = _schedules[j];
                uint32 _timestamp = scheduleChains[_cid].nodes[_sid].timestamp;
                if(_timestamp < now) {
                    total++;
                    amount += scheduleChains[_cid].nodes[_sid].trio;
                }
            }
        }
        return (total,amount);
    }
}