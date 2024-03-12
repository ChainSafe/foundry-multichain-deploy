// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {CrosschainDeployScript} from "../../src/CrosschainDeployScript.sol";
import {SimpleContract} from "../SimpleContract.sol";
import {MockCrosschainDeployAdapter} from "../mocks/MockCrosschainDeployAdapter.sol";

contract CrosschainDeployScriptUnitTest is Test {
    MockCrosschainDeployAdapter mockCrosschainDeployAdapter;

    string constant contractString = "SimpleContract.sol:SimpleContract";
    string[] _deploymentTargets;
    bytes[] _constructorArgs;
    bytes[] _initDatas;
    uint8[] _domainIds;

    // Deploy the mocked crosschain deploy adapter.
    function setUp() public {
        vm.startBroadcast();
        mockCrosschainDeployAdapter = new MockCrosschainDeployAdapter();
        vm.stopBroadcast();
    }

    /**
     * This test checks if we are able to deploy to a _mocked_ local contract,
     * and checks if the call to the mocked contract is performed.
     * It checks the addDeploymentTarget function, and the deploy function.
     */
    function testAddDeploymentTargetAnvil() public {
        CrosschainDeployScript crosschainDeployScript = new CrosschainDeployScript();
        // set the constructorArgs and the initData.
        bytes memory constructorArgs = abi.encode(uint256(1));
        bytes memory initData = "";
        crosschainDeployScript.setContract("SimpleContract.sol:SimpleContract");
        crosschainDeployScript.setCrosschainDeployContractAddress(address(mockCrosschainDeployAdapter));
        crosschainDeployScript.addDeploymentTarget("sepolia", constructorArgs, initData);
        uint256 fee = 0.0001 ether;
        (address alice, uint256 key) = makeAddrAndKey("alice");
        vm.deal(alice, fee * 2);
        uint256[] memory fees = new uint256[](0);
        crosschainDeployScript.deploy{value: fee}(key, fees, 50000, false);
    }

    function testDeployRevertsWithNoContractBytecode() public {
        CrosschainDeployScript crosschainDeployScript = new CrosschainDeployScript();
        // set the constructorArgs and the initData.
        bytes memory constructorArgs = abi.encode(uint256(1));
        bytes memory initData = "";
        crosschainDeployScript.addDeploymentTarget("sepolia", constructorArgs, initData);
        (, uint256 key) = makeAddrAndKey("alice");
        uint256[] memory fees = new uint256[](0);
        uint256 fee = 0.0001 ether;
        vm.expectRevert(bytes("Please use setContract or setContractBytecode first"));
        crosschainDeployScript.deploy{value: fee}(key, fees, 50000, false);
    }

    function testGetFeesRevertWithNoContractBytecode() public {
        CrosschainDeployScript crosschainDeployScript = new CrosschainDeployScript();
        // set the constructorArgs and the initData.
        bytes memory constructorArgs = abi.encode(uint256(1));
        bytes memory initData = "";
        crosschainDeployScript.addDeploymentTarget("sepolia", constructorArgs, initData);
        vm.expectRevert(bytes("Please use setContract or setContractBytecode first"));
        crosschainDeployScript.getFees(50000, false);
    }

    function testGetFeesReturns() public {
        CrosschainDeployScript crosschainDeployScript = new CrosschainDeployScript();
        crosschainDeployScript.setCrosschainDeployContractAddress(address(mockCrosschainDeployAdapter));
        // set the constructorArgs and the initData.
        bytes memory constructorArgs = abi.encode(uint256(1));
        bytes memory initData = "";
        crosschainDeployScript.addDeploymentTarget("sepolia", constructorArgs, initData);
        vm.expectRevert(bytes("Please use setContract or setContractBytecode first"));
        crosschainDeployScript.getFees(50000, false);
    }

    function testGetTotalFeeRevertWithNoContractBytecode() public {
        CrosschainDeployScript crosschainDeployScript = new CrosschainDeployScript();
        crosschainDeployScript.setCrosschainDeployContractAddress(address(mockCrosschainDeployAdapter));
        // set the constructorArgs and the initData.
        bytes memory constructorArgs = abi.encode(uint256(1));
        bytes memory initData = "";
        crosschainDeployScript.addDeploymentTarget("sepolia", constructorArgs, initData);
        bytes memory _deployByteCode = vm.getCode(contractString);
        crosschainDeployScript.setContractBytecode(_deployByteCode);
        bytes32 salt = crosschainDeployScript.generateSalt();
        crosschainDeployScript.setSalt(salt);
        _constructorArgs = new bytes[](1);
        _constructorArgs[0] = constructorArgs;
        _initDatas = new bytes[](1);
        _initDatas[0] = initData;
        _domainIds = new uint8[](1);
        _domainIds[0] = 2;
        vm.expectCall(
            address(mockCrosschainDeployAdapter),
            abi.encodeCall(
                mockCrosschainDeployAdapter.calculateDeployFee,
                (_deployByteCode, 50000, salt, false, _constructorArgs, _initDatas, _domainIds)
            )
        );
        crosschainDeployScript.getTotalFee(50000, false);
    }

    // add a deployment target and deploy
    function testAddDeploymentTargetWithArgsAnvil() public {
        CrosschainDeployScript crosschainDeployScript = new CrosschainDeployScript();
        crosschainDeployScript.setCrosschainDeployContractAddress(address(mockCrosschainDeployAdapter));
        bytes memory constructorArgs = abi.encode(uint256(1));
        bytes memory initData = "";
        crosschainDeployScript.addDeploymentTarget("sepolia", constructorArgs, initData);
        uint256 fee = 0.0001 ether;
        bytes memory _deployByteCode = vm.getCode(contractString);
        crosschainDeployScript.setContractBytecode(_deployByteCode);
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
        (, uint256 key) = makeAddrAndKey("alice");
        // expect a `calculateDeployFee` call to the *upstream* contract
        vm.expectCall(
            address(mockCrosschainDeployAdapter),
            abi.encodeCall(
                mockCrosschainDeployAdapter.calculateDeployFee,
                (_deployByteCode, _gasLimit, _salt, _isUniquePerChain, _constructorArgs, _initDatas, _domainIds)
            )
        );
        uint256[] memory fees = crosschainDeployScript.getFees(_gasLimit, _isUniquePerChain);

        uint256 totalFee;
        uint256 feesArrayLength = fees.length;
        for (uint256 j = 0; j < feesArrayLength; j++) {
            totalFee += fees[j];
        }

        // expect a `deploy` call to the *upstream* contract
        vm.expectCall(
            address(mockCrosschainDeployAdapter),
            abi.encodeCall(
                mockCrosschainDeployAdapter.deploy,
                (_deployByteCode, _gasLimit, _salt, _isUniquePerChain, _constructorArgs, _initDatas, _domainIds, fees)
            )
        );
        crosschainDeployScript.deploy{value: fee}(key, fees, _gasLimit, _isUniquePerChain);
    }

    // tests that the contract is deployed and called with varying initData.
    function testDifferentConstructorArgsAndInitDataAnvil() public {
        CrosschainDeployScript crosschainDeployScript = new CrosschainDeployScript();
        crosschainDeployScript.setCrosschainDeployContractAddress(address(mockCrosschainDeployAdapter));
        // setup empty arrays to hold all the inputs to the contract.
        _deploymentTargets = new string[](2);
        _constructorArgs = new bytes[](2);
        _initDatas = new bytes[](2);
        _domainIds = new uint8[](2);

        _deploymentTargets[0] = "sepolia";
        _constructorArgs[0] = abi.encode(uint256(1));
        _initDatas[0] = abi.encodeWithSignature("inc()");
        _domainIds[0] = 2;

        _deploymentTargets[1] = "holesky";
        _constructorArgs[1] = abi.encode(uint256(10));
        _initDatas[1] = abi.encodeWithSignature("add(uint256)", uint256(5));
        _domainIds[1] = 6;

        // loop through these and call `addDeploymentTarget` so that they'll be added in order.
        for (uint8 i = 0; i < _deploymentTargets.length; i++) {
            crosschainDeployScript.addDeploymentTarget(_deploymentTargets[i], _constructorArgs[i], _initDatas[i]);
        }

        // before calling `deploy`, setup everything required to check whether the
        // call to the upstream contract is _actually_ performed.
        bytes memory _deployByteCode = vm.getCode(contractString);
        crosschainDeployScript.setContractBytecode(_deployByteCode);
        uint256 _gasLimit = 5000;
        bool _isUniquePerChain = false;
        // generate a pseudorandom salt and use `setSalt` so that the same value is used in the contract call.
        bytes32 _salt = crosschainDeployScript.generateSalt();
        crosschainDeployScript.setSalt(_salt);

        // expect a `calculateDeployFee` call to the *upstream* contract
        vm.expectCall(
            address(mockCrosschainDeployAdapter),
            abi.encodeCall(
                mockCrosschainDeployAdapter.calculateDeployFee,
                (_deployByteCode, _gasLimit, _salt, _isUniquePerChain, _constructorArgs, _initDatas, _domainIds)
            )
        );
        uint256[] memory fees = crosschainDeployScript.getFees(_gasLimit, _isUniquePerChain);
        uint256 totalFee;
        uint256 feesArrayLength = fees.length;
        for (uint256 j = 0; j < feesArrayLength; j++) {
            uint256 _fee = fees[j];
            totalFee += _fee;
        }

        // expect a `deploy` call to the *upstream* contract
        vm.expectCall(
            address(mockCrosschainDeployAdapter),
            abi.encodeCall(
                mockCrosschainDeployAdapter.deploy,
                (_deployByteCode, _gasLimit, _salt, _isUniquePerChain, _constructorArgs, _initDatas, _domainIds, fees)
            )
        );
        (, uint256 key) = makeAddrAndKey("alice");
        crosschainDeployScript.deploy{value: totalFee}(key, fees, _gasLimit, _isUniquePerChain);
    }

    // Use `addDeploymentTargetByDomainId` to add targets and deploy with anvil
    function testAddDeploymentTargetByDomainIdWithArgsAnvil() public {
        CrosschainDeployScript crosschainDeployScript = new CrosschainDeployScript();
        crosschainDeployScript.setCrosschainDeployContractAddress(address(mockCrosschainDeployAdapter));
        bytes memory constructorArgs = abi.encode(uint256(1));
        bytes memory initData = "";
        crosschainDeployScript.addDeploymentTargetByDomainId(2, constructorArgs, initData);
        uint256 fee = 0.0001 ether;
        bytes memory _deployByteCode = vm.getCode(contractString);
        crosschainDeployScript.setContractBytecode(_deployByteCode);
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
        (, uint256 key) = makeAddrAndKey("alice");
        // expect a `calculateDeployFee` call to the *upstream* contract
        vm.expectCall(
            address(mockCrosschainDeployAdapter),
            abi.encodeCall(
                mockCrosschainDeployAdapter.calculateDeployFee,
                (_deployByteCode, _gasLimit, _salt, _isUniquePerChain, _constructorArgs, _initDatas, _domainIds)
            )
        );
        uint256[] memory fees = crosschainDeployScript.getFees(_gasLimit, _isUniquePerChain);

        uint256 totalFee;
        uint256 feesArrayLength = fees.length;
        for (uint256 j = 0; j < feesArrayLength; j++) {
            totalFee += fees[j];
        }

        // expect a `deploy` call to the *upstream* contract
        vm.expectCall(
            address(mockCrosschainDeployAdapter),
            abi.encodeCall(
                mockCrosschainDeployAdapter.deploy,
                (_deployByteCode, _gasLimit, _salt, _isUniquePerChain, _constructorArgs, _initDatas, _domainIds, fees)
            )
        );
        crosschainDeployScript.deploy{value: fee}(key, fees, _gasLimit, _isUniquePerChain);
    }
}
