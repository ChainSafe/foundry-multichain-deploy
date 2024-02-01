// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {CrosschainDeployScript} from "../../src/CrosschainDeployScript.sol";
import {SimpleContract} from "../SimpleContract.sol";
import {MockCrosschainDeployAdapter} from "../mocks/MockCrosschainDeployAdapter.sol";

// NOTE: This needs `--fork-url` to run.
contract CrosschainDeployIntegrationTest is Test {
    // add a deployment target and deploy
    function testAddDeploymentTargetIntegration() public {
        require(isValidChainID(block.chainid) == true, "Not a valid chain to test on. Are you using `--fork-url`?");
        CrosschainDeployScript crosschainDeployScript = new CrosschainDeployScript("SimpleContract.sol:SimpleContract");
        bytes memory constructorArgs = "";
        bytes memory initData = "";
        crosschainDeployScript.addDeploymentTarget("sepolia", constructorArgs, initData);
        uint256 fee = 0.0001 ether;
        crosschainDeployScript.deploy{value: fee}(50000, false);
    }

    function isValidChainID(uint256 chainId) private returns (bool) {
        uint256[] memory _chainIds = new uint256[](7);
        _chainIds[0] = 5;
        _chainIds[1] = 11155111;
        _chainIds[2] = 338;
        _chainIds[3] = 17000;
        _chainIds[4] = 80001;
        _chainIds[5] = 421614;
        _chainIds[6] = 10200;
        for (uint8 i = 0; i < 7; i++) {
            if (chainId == _chainIds[i]) {
                return true;
            }
        }
        return false;
    }
}
