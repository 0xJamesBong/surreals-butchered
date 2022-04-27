pragma solidity ^0.8.2;

contract Set {
    bytes32[] public items;

    // 1-based indexing into the array. 0 represents non-existence.
    mapping(bytes32 => uint256) indexOf;

    function add(bytes32 value) public {
        if (indexOf[value] == 0) {
            items.push(value);
            indexOf[value] = items.length;
        }
    }

    function remove(bytes32 value) public {
        uint256 index = indexOf[value];

        require(index > 0);

        // move the last item into the index being vacated
        bytes32 lastValue = items[items.length - 1];
        items[index - 1] = lastValue;  // adjust for 1-based indexing
        indexOf[lastValue] = index;

        items.length -= 1;
        indexOf[value] = 0;
    }

    function contains(bytes32 value) public view returns (bool) {
        return indexOf[value] > 0;
    }

    function count() public view returns (uint256) {
        return items.length;
    }
}
