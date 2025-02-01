// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DTPFactory} from "../src/DTPFactory.sol";

contract DTPTest is Test {
    DTPFactory public dtpFactory;

    function setUp() public {
        dtpFactory = new DTPFactory();
    }

    function test_createDTP() public {
        dtpFactory.createDTP("Test DTP", "TDTP", "https://example.com/image.png", address(this));
    }
}
