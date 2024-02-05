// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {CrosschainDeployScript} from "../../src/CrosschainDeployScript.sol";
import {SimpleContract} from "../SimpleContract.sol";
import {MockCrosschainDeployAdapter} from "../mocks/MockCrosschainDeployAdapter.sol";

contract CrosschainDeployScriptUnitTest is Test {
    address crosschainDeployAdapterAddress;

    // Deploy the mocked crosschain deploy adapter.
    function setUp() public {
        vm.startBroadcast();
        MockCrosschainDeployAdapter mockCrosschainDeployAdapter = new MockCrosschainDeployAdapter();
        vm.stopBroadcast();
        crosschainDeployAdapterAddress = address(mockCrosschainDeployAdapter);
    }

    /**
     * This test checks if we are able to deploy to a _mocked_ local contract,
     * and checks if the call to the mocked contract is performed.
     * It checks the addDeploymentTarget function, and the deploy function.
     */
    function testAddDeploymentTargetAnvil() public {
        CrosschainDeployScript crosschainDeployScript = new CrosschainDeployScript("SimpleContract.sol:SimpleContract");
        // set the constructorArgs and the initData.
        bytes memory constructorArgs = "";
        bytes memory initData = "";
        crosschainDeployScript.setCrosschainDeployContractAddress(crosschainDeployAdapterAddress);
        crosschainDeployScript.addDeploymentTarget("sepolia", constructorArgs, initData);
        uint256 fee = 0.0001 ether;
        vm.deal(msg.sender, fee * 2);
        crosschainDeployScript.deploy{value: fee}(50000, false);
    }
}
