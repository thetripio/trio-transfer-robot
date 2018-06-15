pragma solidity ^0.4.21;

import "./TPTData.sol";
import "./Owned.sol";

contract TPTContributors is TPTData, Owned {
    function TPTContributors() public {
        
    }

    /**
     * This emits when contributors are added
     */
    event ContributorsAdded(address[] indexed _contributors);

    /**
     * This emits when contributors are removed
     */
    event ContributorsRemoved(uint256[] indexed _cids);


    /**
     * Record `_contributor`
     */
    function _pushContributor(address _contributor) internal {
        require(_contributor != address(0));
        uint256 prev = 0;
        uint256 cid = contributorChain.index + 1;
        if (contributorChain.balance == 0) {
            contributorChain = ContributorChain(1, cid, cid, cid);
            contributorChain.nodes[cid] = Contributor(0, 0, cid, _contributor);
        } else {
            contributorChain.index = cid;
            prev = contributorChain.tail;
            contributorChain.balance++;

            contributorChain.nodes[cid] = Contributor(0, prev, cid, _contributor);
            contributorChain.nodes[prev].next = cid;
            contributorChain.tail = cid;
        }
    }

    /**
     * Remove contributor by `_cid`
     */
    function _removeContributor(uint _cid) internal contributorValid(_cid) {
        require(_cid != 0);
        uint256 next = 0;
        uint256 prev = 0;
        require(contributorChain.nodes[_cid].cid == _cid);
        next = contributorChain.nodes[_cid].next;
        prev = contributorChain.nodes[_cid].prev;
        if (next == 0) {
            if(prev != 0) {
                contributorChain.nodes[prev].next = 0;
                delete contributorChain.nodes[_cid];
                contributorChain.tail = prev;
            }else {
                delete contributorChain.nodes[_cid];
                delete contributorChain;
            }
        } else {
            if (prev == 0) {
                contributorChain.head = next;
                contributorChain.nodes[next].prev = 0;
                delete contributorChain.nodes[_cid];
            } else {
                contributorChain.nodes[prev].next = next;
                contributorChain.nodes[next].prev = prev;
                delete contributorChain.nodes[_cid];
            }
        }
        if(contributorChain.balance > 0) {
            contributorChain.balance--;
        }
    }

    /**
     * Record `_contributors`
     * @param _contributors The contributor
     */
    function addContributors(address[] _contributors) external onlyOwner {
        for(uint256 i = 0; i < _contributors.length; i++) {
            _pushContributor(_contributors[i]);
        }

        // Event
        emit ContributorsAdded(_contributors);
    }

    /**
     * Remove contributor by `_cids`
     * @param _cids The contributor's ids
     */
    function removeContributors(uint256[] _cids) external onlyOwner {
        for(uint256 i = 0; i < _cids.length; i++) {
            _removeContributor(_cids[i]);
        }

        // Event
        emit ContributorsRemoved(_cids);
    }

    /**
     * Returns all the contributors
     * @return All the contributors
     */
    function contributors() public view returns(uint256[]) {
        uint256 count;
        uint256 index;
        uint256 next;
        index = 0;
        next = contributorChain.head;
        count = contributorChain.balance;
        if (count > 0) {
            uint256[] memory result = new uint256[](count);
            while(next != 0 && index < count) {
                result[index] = contributorChain.nodes[next].cid;
                next = contributorChain.nodes[next].next;
                index++;
            }
            return result;
        } else {
            return new uint256[](0);
        }
    }

    /**
     * Return the contributor by `_cid`
     * @return The contributor
     */
    function contributor(uint _cid) external view returns(address) {
        return contributorChain.nodes[_cid].contributor;
    }  
}