pragma solidity ^0.4.21;

import "./TPTData.sol";
import "./Owned.sol";

contract TPTSchedules is TPTData, Owned {
    function TPTSchedules() public {
        
    }

    /**
     * This emits when schedules are inserted
     */
    event SchedulesInserted(uint256 _cid, uint32[] _timestamps, uint256[] _trios);

    /**
     * This emits when schedules are removed
     */
    event SchedulesRemoved(uint _cid, uint256[] _sids);

    /**
     * Record TRIO transfer schedule to  `_contributor`
     * @param _cid The contributor
     * @param _timestamps The transfer timestamps
     * @param _trios The transfer trios
     */
    function insertSchedules(uint256 _cid, uint32[] _timestamps, uint256[] _trios) 
        external 
        onlyOwner 
        contributorValid(_cid) {
        require(_timestamps.length > 0 && _timestamps.length == _trios.length);
        for (uint256 i = 0; i < _timestamps.length; i++) {
            uint256 prev = 0;
            uint256 next = 0;
            uint256 sid = scheduleChains[_cid].index + 1;
            if (scheduleChains[_cid].balance == 0) {
                scheduleChains[_cid] = ScheduleChain(1, sid, sid, sid);
                scheduleChains[_cid].nodes[sid] = Schedule(0, 0, sid, _timestamps[i], _trios[i]);
            } else {
                scheduleChains[_cid].index = sid;
                scheduleChains[_cid].balance++;
                prev = scheduleChains[_cid].tail;
                while(scheduleChains[_cid].nodes[prev].timestamp > _timestamps[i] && prev != 0) {
                    prev = scheduleChains[_cid].nodes[prev].prev;
                }
                if (prev == 0) {
                    next = scheduleChains[_cid].head;
                    scheduleChains[_cid].nodes[sid] = Schedule(next, 0, sid, _timestamps[i], _trios[i]);
                    scheduleChains[_cid].nodes[next].prev = sid;
                    scheduleChains[_cid].head = sid;
                } else {
                    next = scheduleChains[_cid].nodes[prev].next;
                    scheduleChains[_cid].nodes[sid] = Schedule(next, prev, sid, _timestamps[i], _trios[i]);
                    scheduleChains[_cid].nodes[prev].next = sid;
                    if (next == 0) {
                        scheduleChains[_cid].tail = sid;
                    }
                }
            }
        }

        // Event
        emit SchedulesInserted(_cid, _timestamps, _trios);
    }

    /**
     * Remove schedule by `_cid` and `_sids`
     * @param _cid The contributor's id
     * @param _sids The schedule's ids
     */
    function removeSchedules(uint _cid, uint256[] _sids) 
        public 
        onlyOwner 
        contributorValid(_cid) {
        uint256 next = 0;
        uint256 prev = 0;
        uint256 sid;
        for (uint256 i = 0; i < _sids.length; i++) {
            sid = _sids[i];
            next = scheduleChains[_cid].nodes[sid].next;
            prev = scheduleChains[_cid].nodes[sid].prev;
            if (next == 0) {
                if(prev != 0) {
                    scheduleChains[_cid].nodes[prev].next = 0;
                    delete scheduleChains[_cid].nodes[sid];
                    scheduleChains[_cid].tail = prev;
                }else {
                    delete scheduleChains[_cid];
                }
            } else {
                if (prev == 0) {
                    scheduleChains[_cid].head = next;
                    scheduleChains[_cid].nodes[next].prev = 0;
                    delete scheduleChains[_cid].nodes[sid];
                } else {
                    scheduleChains[_cid].nodes[prev].next = next;
                    scheduleChains[_cid].nodes[next].prev = prev;
                    delete scheduleChains[_cid].nodes[sid];
                }
            }
            if(scheduleChains[_cid].balance > 0) {
                scheduleChains[_cid].balance--;
            }   
        }

        // Event
        emit SchedulesRemoved(_cid, _sids);
    }

    /**
     * Return all the schedules of `_cid`
     * @param _cid The contributor's id 
     * @return All the schedules of `_cid`
     */
    function schedules(uint256 _cid) 
        public 
        contributorValid(_cid) 
        view 
        returns(uint256[]) {
        uint256 count;
        uint256 index;
        uint256 next;
        index = 0;
        next = scheduleChains[_cid].head;
        count = scheduleChains[_cid].balance;
        if (count > 0) {
            uint256[] memory result = new uint256[](count);
            while(next != 0 && index < count) {
                result[index] = scheduleChains[_cid].nodes[next].sid;
                next = scheduleChains[_cid].nodes[next].next;
                index++;
            }
            return result;
        } else {
            return new uint256[](0);
        }
    }

    /**
     * Return the schedule by `_cid` and `_sid`
     * @param _cid The contributor's id
     * @param _sid The schedule's id
     * @return The schedule
     */
    function schedule(uint256 _cid, uint256 _sid) 
        public
        scheduleValid(_cid, _sid) 
        view 
        returns(uint32, uint256) {
        return (scheduleChains[_cid].nodes[_sid].timestamp, scheduleChains[_cid].nodes[_sid].trio);
    }
}