// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {CrosschainDeployScript} from "../../src/CrosschainDeployScript.sol";
import {ICrosschainDeployAdapter} from "../../src/interfaces/CrosschainDeployAdapterInterface.sol";
import {SimpleContract} from "../SimpleContract.sol";
import {MockCrosschainDeployAdapter} from "../mocks/MockCrosschainDeployAdapter.sol";

// NOTE: This needs `--fork-url` to run.
contract CrosschainDeployIntegrationTest is Test {
    string constant contractString = "SimpleContract.sol:SimpleContract";
    string[] _deploymentTargets;
    bytes[] _constructorArgs;
    bytes[] _initDatas;
    uint8[] _domainIds;

    modifier isValidChain() {
        require(isValidChainId(block.chainid) == true, "Not a valid chain to test on. Are you using `--fork-url`?");

        _;
    }
    // add a deployment target and deploy

    function testAddDeploymentTargetIntegration() public isValidChain {
        CrosschainDeployScript crosschainDeployScript = new CrosschainDeployScript();
        bytes memory constructorArgs = abi.encode(uint256(1));
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

        _constructorArgs = new bytes[](1);
        _constructorArgs[0] = constructorArgs;
        _initDatas = new bytes[](1);
        _initDatas[0] = initData;
        _domainIds = new uint8[](1);
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
            totalFee += fees[j];
        }

        // expect a `deploy` call to the *upstream* contract
        vm.expectCall(
            address(adapter),
            abi.encodeCall(
                adapter.deploy,
                (_deployByteCode, _gasLimit, _salt, _isUniquePerChain, _constructorArgs, _initDatas, _domainIds, fees)
            )
        );
        crosschainDeployScript.deploy{value: fee}(contractString, _gasLimit, _isUniquePerChain);
    }

    // checks that the chainID is of a chain that our contracts
    // support.
    function isValidChainId(uint256 chainId) private pure returns (bool) {
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
        return true;
    }

    // tests that the contract is deployed and called with varying initData.
    function testDifferentConstructorArgsAndInitDataIntegration() public isValidChain {
        CrosschainDeployScript crosschainDeployScript = new CrosschainDeployScript();

        // setup empty arrays to hold all the inputs to the contract.
        _deploymentTargets = new string[](2);
        _constructorArgs = new bytes[](2);
        _initDatas = new bytes[](2);
        _domainIds = new uint8[](2);

        _deploymentTargets[0] = "sepolia";
        _constructorArgs[0] = abi.encode(uint256(1));
        _initDatas[0] = abi.encodeWithSignature("inc()");
        _domainIds[0] = 2;

        _deploymentTargets[1] = "goerli";
        _constructorArgs[1] = abi.encode(uint256(10));
        _initDatas[1] = abi.encodeWithSignature("add(uint256)", uint256(5));
        _domainIds[1] = 1;

        // loop through these and call `addDeploymentTarget` so that they'll be added in order.
        for (uint8 i = 0; i < _deploymentTargets.length; i++) {
            crosschainDeployScript.addDeploymentTarget(_deploymentTargets[i], _constructorArgs[i], _initDatas[i]);
        }

        // before calling `deploy`, setup everything required to check whether the
        // call to the upstream contract is _actually_ performed.
        ICrosschainDeployAdapter adapter = ICrosschainDeployAdapter(0x85d62AD850B322152BF4ad9147bfBF097DA42217);
        bytes memory _deployByteCode = vm.getCode(contractString);
        uint256 _gasLimit = 5000;
        bool _isUniquePerChain = false;
        // generate a pseudorandom salt and use `setSalt` so that the same value is used in the contract call.
        bytes32 _salt = crosschainDeployScript.generateSalt();
        crosschainDeployScript.setSalt(_salt);

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
            uint256 _fee = fees[j];
            totalFee += _fee;
        }

        // expect a `deploy` call to the *upstream* contract
        vm.expectCall(
            address(adapter),
            abi.encodeCall(
                adapter.deploy,
                (_deployByteCode, _gasLimit, _salt, _isUniquePerChain, _constructorArgs, _initDatas, _domainIds, fees)
            )
        );
        crosschainDeployScript.deploy{value: totalFee}(contractString, _gasLimit, _isUniquePerChain);
    }
}
