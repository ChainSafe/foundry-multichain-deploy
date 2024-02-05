// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {CrosschainDeployScript} from "../../src/CrosschainDeployScript.sol";
import {ICrosschainDeployAdapter} from "../../src/interfaces/CrosschainDeployAdapterInterface.sol";
import {SimpleContract} from "../SimpleContract.sol";
import {MockCrosschainDeployAdapter} from "../mocks/MockCrosschainDeployAdapter.sol";

// NOTE: This needs `--fork-url` to run.
contract CrosschainDeployIntegrationTest is Test {
    // add a deployment target and deploy
    function testAddDeploymentTargetIntegration() public {
        require(isValidChainID(block.chainid) == true, "Not a valid chain to test on. Are you using `--fork-url`?");
        string memory contractString = "SimpleContract.sol:SimpleContract";
        CrosschainDeployScript crosschainDeployScript = new CrosschainDeployScript(contractString);
        bytes memory constructorArgs = "";
        bytes memory initData = "";
        crosschainDeployScript.addDeploymentTarget("sepolia", constructorArgs, initData);
        uint256 fee = 0.0001 ether;
        // before calling `deploy`, setup everything required to check whether the
        // call to the upstream contract is _actually_ performed.
        ICrosschainDeployAdapter adapter = ICrosschainDeployAdapter(0x85d62AD850B322152BF4ad9147bfBF097DA42217);
        bytes memory _deployByteCode = vm.getCode(contractString);
        uint256 _gasLimit = 5000;
        bool _isUniquePerChain = false;
        // generate a pseudorandom salt and use `setSalt` so that the same value is used in the contract call.
        bytes32 _salt = crosschainDeployScript.generateSalt();
        crosschainDeployScript.setSalt(_salt);

        bytes[] memory _constructorArgs = new bytes[](1);
        _constructorArgs[0] = constructorArgs;
        bytes[] memory _initDatas = new bytes[](1);
        _initDatas[0] = initData;
        uint8[] memory _domainIds = new uint8[](1);
        _domainIds[0] = 2;

        // expect a `calculateDeployFee` call to the *upstream* contract
        vm.expectCall(
            address(adapter),
            abi.encodeCall(
                adapter.calculateDeployFee,
                (_deployByteCode, _gasLimit, _salt, _isUniquePerChain, _constructorArgs, _initDatas, _domainIds)
            )
        );
        uint256[] memory fees = adapter.calculateDeployFee(
            _deployByteCode, _gasLimit, _salt, _isUniquePerChain, _constructorArgs, _initDatas, _domainIds
        );
        uint256 totalFee;
        uint256 feesArrayLength = fees.length;
        for (uint256 j = 0; j < feesArrayLength; j++) {
            uint256 fee = fees[j];
            totalFee += fee;
        }

        // expect a `deploy` call to the *upstream* contract
        vm.expectCall(
            address(adapter),
            abi.encodeCall(
                adapter.deploy,
                (_deployByteCode, _gasLimit, _salt, _isUniquePerChain, _constructorArgs, _initDatas, _domainIds, fees)
            )
        );
        crosschainDeployScript.deploy{value: fee}(_gasLimit, _isUniquePerChain);
    }

    // checks that the chainID is of a chain that our contracts
    // support.
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
