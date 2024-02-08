// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.8.20;

contract SimpleContract {
    uint256 public count;

    constructor(uint256 _count) {
        count = _count;
    }

    function get() public view returns (uint256) {
        return count;
    }

    function inc() public {
        count++;
    }

    function add(uint256 _value) public {
        count += _value;
    }
}
