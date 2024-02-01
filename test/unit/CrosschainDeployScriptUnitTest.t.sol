// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {CrosschainDeployScript} from "../../src/CrosschainDeployScript.sol";
import {SimpleContract} from "../SimpleContract.sol";
import {MockCrosschainDeployAdapter} from "../mocks/MockCrosschainDeployAdapter.sol";

contract CrosschainDeployScriptUnitTest is Test {
    address crosschainDeployAdapterAddress;

    // first start the dependent contract if we're on Anvil
    function setUp() public {
        vm.startBroadcast();
        MockCrosschainDeployAdapter mockCrosschainDeployAdapter = new MockCrosschainDeployAdapter();
        vm.stopBroadcast();
        crosschainDeployAdapterAddress = address(mockCrosschainDeployAdapter);
    }

    // add a deployment target and deploy
    function testAddDeploymentTargetAnvil() public {
        CrosschainDeployScript crosschainDeployScript = new CrosschainDeployScript("SimpleContract.sol:SimpleContract");
        bytes memory constructorArgs = "";
        bytes memory initData = "";
        crosschainDeployScript.setCrosschainDeployContractAddress(crosschainDeployAdapterAddress);
        crosschainDeployScript.addDeploymentTarget("sepolia", constructorArgs, initData);
        uint256 fee = 0.0001 ether;
        vm.deal(msg.sender, fee * 2);
        crosschainDeployScript.deploy{value: fee}(50000, false);
    }
}
