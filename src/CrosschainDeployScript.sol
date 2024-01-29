// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {ICrosschainDeployAdapter} from "./interfaces/CrosschainDeployAdapterInterface.sol";

/**
 * @title Provides a script to allow users to call the multichain deployment contract defined in `CrossChainDeployAdapter` from chainsafe/hardhat-plugin-multichain-deploy, passing it the contract bytecode and constructor arguments.
 * @author ChainSafe Systems
 */
contract CrosschainDeployScript is Script {
    // this is the address of the original contract defined in chainsafe/hardhat-plugin-multichain-deploy
    // this address is the same across all chains
    address private constant CROSS_CHAIN_DEPLOY_CONTRACT_ADDRESS = 0x85d62AD850B322152BF4ad9147bfBF097DA42217;

    struct NetworkIds {
        uint8 InternalDomainId;
        uint256 ChainId;
    }

    // given a string, obtain the domain ID;
    // https://www.notion.so/chainsafe/Testnet-deployment-0483991cf1ac481593d37baf8d48712a
    mapping(string => NetworkIds) private _stringToNetworkIds;

    // NOTE: All three of these need to be stored in the same order since they've
    //      a shared index. Storing them in a mapping isn't gas-efficient since I'd
    //      have to loop over these to build these arrays later, and that would not
    //      translate to a `bytes[] memory` object, which is what the contract method needs.
    //      Explicit conversion is a waste of gas.
    // store the domain IDs
    uint8[] private _domainIds;
    // store the constructor args.
    bytes[] private _constructorArgs;
    // store the init datas;
    bytes[] private _initDatas;
    // store the chain ids
    uint256[] private _chainIds;

    uint8 private _randomCounter;

    constructor() {
        _stringToNetworkIds["goerli"] = NetworkIds(1, 5);
        _stringToNetworkIds["sepolia"] = NetworkIds(2, 11155111);
        _stringToNetworkIds["cronos-testnet"] = NetworkIds(5, 338);
        _stringToNetworkIds["holesky"] = NetworkIds(6, 17000);
        _stringToNetworkIds["mumbai"] = NetworkIds(7, 80001);
        _stringToNetworkIds["arbitrum-sepolia"] = NetworkIds(8, 421614);
        _stringToNetworkIds["gnosis-chiado"] = NetworkIds(9, 10200);
    }

    /**
     * This function willl take the network, constructor args and initdata and
     * save these to a mapping (what type?)
     */
    function addDeploymentTarget(string memory deploymentTarget, bytes memory constructorArgs, bytes memory initData)
        public
    {
        NetworkIds memory deploymentTargetNetworkIds = _stringToNetworkIds[deploymentTarget];
        uint8 deploymentTargetDomainId = deploymentTargetNetworkIds.InternalDomainId;
        require(deploymentTargetDomainId != 0, "Invalid deployment target");
        _domainIds.push(deploymentTargetDomainId);
        uint256 deploymentTargetChainId = deploymentTargetNetworkIds.ChainId;
        _chainIds.push(deploymentTargetChainId);
        _constructorArgs.push(constructorArgs);
        _initDatas.push(initData);
    }

    /**
     * @notice this function takes in the contract string, in the form that
     * @notice `forge`'s `getCode` takes it, along with some other parameters and passes
     * @notice it along to the `deploy` function of the `CrossChainDeployAdapter`
     * @notice contract.
     * @param contractString Contract name in the form of `ContractFile.sol`, if the name of the contract and the file are the same, or `ContractFile.sol:ContractName` if they are different.
     * @param gasLimit Contract deploy and init gas.
     * @param isUniquePerChain True to have unique addresses on every chain.
     *   Users call this function and pass only the function call string as
     *   `MyContract.sol:MyContract`. The function call string is then parsed
     *   and the `callData` and `bytesCode` are extracted from it.
     *   and the contract is deployed on the other chains.
     */
    function deploy(string calldata contractString, uint256 gasLimit, bool isUniquePerChain)
        // uint8[] memory destinationDomainIDs
        public
        payable
        hasDeploymentTargets
        returns (address[] memory)
    {
        // We use the contractString to get the bytecode of the contract,
        // reference: https://book.getfoundry.sh/cheatcodes/get-code
        bytes memory deployByteCode = vm.getCode(contractString);
        bytes32 salt = generateSalt();
        uint256[] memory fees = ICrosschainDeployAdapter(CROSS_CHAIN_DEPLOY_CONTRACT_ADDRESS).calculateDeployFee(
            deployByteCode, gasLimit, salt, isUniquePerChain, _constructorArgs, _initDatas, _domainIds
        );
        uint256 totalFee;
        uint256 feesArrayLength = fees.length;
        for (uint256 j = 0; j < feesArrayLength; j++) {
            uint256 fee = fees[j];
            totalFee += fee;
        }
        ICrosschainDeployAdapter(CROSS_CHAIN_DEPLOY_CONTRACT_ADDRESS).deploy{value: totalFee}(
            deployByteCode, gasLimit, salt, isUniquePerChain, _constructorArgs, _initDatas, _domainIds, fees
        );
        address[] memory contractAddresses = new address[](_chainIds.length);
        for (uint256 k = 0; k < _chainIds.length; k++) {
            address contractAddress = ICrosschainDeployAdapter(CROSS_CHAIN_DEPLOY_CONTRACT_ADDRESS)
                .computeContractAddressForChain(msg.sender, salt, isUniquePerChain, _chainIds[k]);
            contractAddresses[k] = contractAddress;
        }
        return contractAddresses;
    }

    // returns a pseudorandom bytes32
    function generateSalt() public returns (bytes32) {
        _randomCounter++;
        return keccak256(abi.encodePacked(block.prevrandao, block.timestamp, msg.sender, _randomCounter));
    }

    // what does this do?
    function encodeInitData() public {}

    modifier hasDeploymentTargets() {
        // check that the user has added deployment networks by calling `addDeploymentTarget`
        uint256 deploymentNetworksCount = _domainIds.length;
        require(deploymentNetworksCount > 0, "Need to add deployment targets. Use `addDeploymentTarget` first");
        _;
    }
    /**
     * @notice Computes the address where the contract will be deployed on this chain.
     *     @param sender Address that requested deploy.
     *     @param salt Entropy for contract address generation.
     *     @param isUniquePerChain True to have unique addresses on every chain.
     *     @param chainId the ID of the chain on which to deploy the contract
     *     @return Address where the contract will be deployed on this chain.
     */

    function computeAddressForChain(address sender, bytes32 salt, bool isUniquePerChain, uint256 chainId)
        external
        view
        returns (address)
    {
        return ICrosschainDeployAdapter(CROSS_CHAIN_DEPLOY_CONTRACT_ADDRESS).computeContractAddressForChain(
            sender, salt, isUniquePerChain, chainId
        );
    }
}
