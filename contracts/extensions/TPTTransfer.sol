pragma solidity ^0.4.21;

import "./TPTData.sol";
import "./Owned.sol";
import "./TripioToken.sol";
import "./TPTContributors.sol";
import "./TPTSchedules.sol";

contract TPTTransfer is Owned, TPTContributors, TPTSchedules {
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
        uint256[] memory _contributors = contributors();
        for (uint256 i = 0; i < _contributors.length; i++) {
            // cid and contributor address
            uint256 _cid = _contributors[i];
            address _contributor = contributorChain.nodes[_cid].contributor;
            
            // All schedules
            uint256[] memory _schedules = schedules(_cid);
            for (uint256 j = 0; j < _schedules.length; j++) {
                // sid, trio and timestamp
                uint256 _sid = _schedules[j];
                uint256 _trio = scheduleChains[_cid].nodes[_sid].trio;
                uint256 _timestamp = scheduleChains[_cid].nodes[_sid].timestamp;

                // hasn't arrived
                if(_timestamp > now) {
                    break;
                }
                // Transfer TRIO to contributor
                tripio.transfer(_contributor, _trio);

                // Remove schedule of contributor
                uint256[] memory _sids = new uint256[](1);
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
    function totalTransfersInSchedule() external view returns(uint256) {
        // All contributors
        uint256[] memory _contributors = contributors();
        uint256 total = 0;
        for (uint256 i = 0; i < _contributors.length; i++) {
            // cid and contributor address
            uint256 _cid = _contributors[i];            
            // All schedules
            uint256[] memory _schedules = schedules(_cid);
            for (uint256 j = 0; j < _schedules.length; j++) {
                // sid, trio and timestamp
                uint256 _sid = _schedules[j];
                uint256 _timestamp = scheduleChains[_cid].nodes[_sid].timestamp;

                // hasn't arrived
                if(_timestamp < now) {
                    total++;
                }
            }
        }
        return total;
    }
}