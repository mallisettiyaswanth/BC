// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.4.17;

contract Index  {
    uint256 public value;


    function Index() public {
        value = 0;
    }

    function getIndexValue() public view returns(uint256) {
        return value;
    }

    function setIndexValue(uint256 _value) public {
        value = _value;
    }
}
