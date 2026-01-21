// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Counter {
    uint256 private count;
    
    event ValueChanged(uint256 newValue);
    
    function increment() public {
        count += 1;
        emit ValueChanged(count);
    }
    
    function getCount() public view returns (uint256) {
        return count;
    }
}