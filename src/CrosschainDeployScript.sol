// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";
import {ICrosschainDeployAdapter} from "./interfaces/CrosschainDeployAdapterInterface.sol";

/**
 * @title Provides a script to allow users to call the multichain deployment contract defined in `CrossChainDeployAdapter` from chainsafe/hardhat-plugin-multichain-deploy, passing it the contract bytecode and constructor arguments.
 * @author ChainSafe Systems
 */
contract CrosschainDeployScript is Script {
    // this is the address of the original contract defined in chainsafe/hardhat-plugin-multichain-deploy
    // this address is the same across all chains
    address private crosschainDeployContractAddress = 0xD72f1165751c3B9C5952B19596A36354ac30FdBd;

    enum Env {
        UNKNOWN,
        TESTNET,
        MAINNET
    }

    struct NetworkIds {
        uint8 InternalDomainId;
        uint256 ChainId;
        Env env;
    }

    // given a string, obtain the domain ID;
    // https://www.notion.so/chainsafe/Testnet-deployment-0483991cf1ac481593d37baf8d48712a
    mapping(string => NetworkIds) private _stringToNetworkIds;
    mapping(uint8 => string) private _domainIdToDeploymentTargets;

    Env env = Env.UNKNOWN;

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
    bytes private contractBytecode;

    uint8 private _randomCounter;

    // use this to store a static value for the salt, one that the user can override using `setSalt`. If set to _anything_ other than 0x00000000000000000000, this will be used as the salt.
    bytes32 private salt = 0x00000000000000000000;

    /**
     * @notice Constructor, takes the contract name.
     */
    constructor() {
        _addNetwork("sepolia", 2, 11155111, Env.TESTNET);
        _addNetwork("cronos-testnet", 5, 338, Env.TESTNET);
        _addNetwork("holesky", 6, 17000, Env.TESTNET);
        _addNetwork("mumbai", 7, 80001, Env.TESTNET);
        _addNetwork("arbitrum-sepolia", 8, 421614, Env.TESTNET);
        _addNetwork("gnosis-chiado", 9, 10200, Env.TESTNET);
        setSalt(generateSalt());
    }

    function _addNetwork(string memory deploymentTarget, uint8 domainId, uint256 chainId, Env environ) private {
        _stringToNetworkIds[deploymentTarget] = NetworkIds(domainId, chainId, environ);
        _domainIdToDeploymentTargets[domainId] = deploymentTarget;
    }

    function _convertDeploymentTargetToNetworkIds(string memory deploymentTarget) private returns (NetworkIds memory) {
        NetworkIds memory deploymentTargetNetworkIds = _stringToNetworkIds[deploymentTarget];
        if (env == Env.UNKNOWN) {
            env = deploymentTargetNetworkIds.env;
        } else {
            require(
                env == deploymentTargetNetworkIds.env,
                "Deployment target is not in the same env as previous deployment targets"
            );
        }
        uint8 deploymentTargetDomainId = deploymentTargetNetworkIds.InternalDomainId;
        require(deploymentTargetDomainId != 0, "Invalid deployment target");
        return deploymentTargetNetworkIds;
    }

    /**
     * Internal function to convert the internal sygma ID to the NetworkId object
     */
    function _convertDomainIdToNetworkIds(uint8 internalDomainId) private returns (NetworkIds memory) {
        string memory deploymentTarget = _domainIdToDeploymentTargets[internalDomainId];
        return _convertDeploymentTargetToNetworkIds(deploymentTarget);
    }

    /**
     * Obtains and stores contract bytecode by artifact path
     * @param artifactPath Contract name in the form of `ContractFile.sol`, if the name of the contract and the file are the same, or `ContractFile.sol:ContractName` if they are different.
     */
    function setContract(string calldata artifactPath) public {
        contractBytecode = vm.getCode(artifactPath);
    }

    function setContractBytecode(bytes calldata _contractBytecode) public {
        contractBytecode = _contractBytecode;
    }

    /**
     * This function will take the network, constructor args and initdata and
     * save these to a mapping.
     */
    function addDeploymentTarget(string memory deploymentTarget, bytes memory constructorArgs, bytes memory initData)
        public
    {
        NetworkIds memory networkIds = _convertDeploymentTargetToNetworkIds(deploymentTarget);
        _domainIds.push(networkIds.InternalDomainId);
        _chainIds.push(networkIds.ChainId);
        _constructorArgs.push(constructorArgs);
        _initDatas.push(initData);
    }

    /**
     * This function takes the Sygma domain ID and replicates the behaviour of `addDeploymentTarget`.
     * These functions can be used alternately, depending on developer preference.
     */
    function addDeploymentTargetByDomainId(uint8 internalDomainId, bytes memory constructorArgs, bytes memory initData)
        public
    {
        NetworkIds memory networkIds = _convertDomainIdToNetworkIds(internalDomainId);
        _domainIds.push(networkIds.InternalDomainId);
        _chainIds.push(networkIds.ChainId);
        _constructorArgs.push(constructorArgs);
        _initDatas.push(initData);
    }

    /**
     * Returns array of bridge fees (one for each deployment target or empty if just current chain deployment)
     */
    function getFees(uint256 gasLimit, bool isUniquePerChain) public view returns (uint256[] memory) {
        require(contractBytecode.length > 0, "Please use setContract or setContractBytecode first");
        return ICrosschainDeployAdapter(crosschainDeployContractAddress).calculateDeployFee(
            contractBytecode, gasLimit, salt, isUniquePerChain, _constructorArgs, _initDatas, _domainIds
        );
    }

    /**
     * Returns total bridge fee
     */
    function getTotalFee(uint256 gasLimit, bool isUniquePerChain) public view returns (uint256) {
        uint256[] memory fees = getFees(gasLimit, isUniquePerChain);
        uint256 totalFee;
        uint256 feesArrayLength = fees.length;
        for (uint256 j = 0; j < feesArrayLength; j++) {
            uint256 fee = fees[j];
            totalFee += fee;
        }
        return totalFee;
    }

    /**
     * @notice this function takes in the contract string, in the form that
     * @notice `forge`'s `getCode` takes it, along with some other parameters and passes
     * @notice it along to the `deploy` function of the `CrossChainDeployAdapter`
     * @notice contract.
     * @param privateKey private key to sign deploy transaction
     * @param gasLimit Contract deploy and init gas.
     * @param isUniquePerChain True to have unique addresses on every chain.
     *   Users call this function and pass only the function call string as
     *   `MyContract.sol:MyContract`. The function call string is then parsed
     *   and the `callData` and `bytesCode` are extracted from it.
     *   and the contract is deployed on the other chains.
     */
    function deploy(uint256 privateKey, uint256[] memory fees, uint256 gasLimit, bool isUniquePerChain)
        public
        payable
        hasDeploymentNetworks
        returns (address[] memory)
    {
        require(contractBytecode.length > 0, "Please use setContract or setContractBytecode first");
        uint256 totalFee;
        for (uint256 j = 0; j < fees.length; j++) {
            totalFee += fees[j];
        }
        vm.startBroadcast(privateKey);
        ICrosschainDeployAdapter(crosschainDeployContractAddress).deploy{value: totalFee}(
            contractBytecode, gasLimit, salt, isUniquePerChain, _constructorArgs, _initDatas, _domainIds, fees
        );
        vm.stopBroadcast();
        if (env == Env.TESTNET) {
            console.log("You can track deployment progress at https://scan.test.buildwithsygma.com/transfer/<txHash>");
        }
        if (env == Env.MAINNET) {
            console.log("You can track deployment progress at https://scan.buildwithsygma.com/transfer/<txHash>");
        }
        address[] memory contractAddresses = new address[](_chainIds.length);
        for (uint256 k = 0; k < _chainIds.length; k++) {
            address contractAddress = ICrosschainDeployAdapter(crosschainDeployContractAddress)
                .computeContractAddressForChain(vm.addr(privateKey), salt, isUniquePerChain, _chainIds[k]);
            contractAddresses[k] = contractAddress;
        }
        resetDeploymentNetworks();
        return contractAddresses;
    }

    // empties the deployment networks added so far. Note that this won't change the contract string.
    function resetDeploymentNetworks() public {
        // purge the deployment targets now.
        delete _chainIds;
        delete _constructorArgs;
        delete _domainIds;
        delete _initDatas;
    }

    // resets the static salt
    function resetSalt() public {
        salt = 0x00000000000000000000;
    }

    // sets the static salt
    function setSalt(bytes32 _salt) public {
        salt = _salt;
    }

    // returns a pseudorandom bytes32 for salt
    function generateSalt() public returns (bytes32) {
        _randomCounter++;
        return keccak256(abi.encodePacked(block.prevrandao, block.timestamp, msg.sender, _randomCounter));
    }

    // check that the user has added deployment networks by calling `addDeploymentNetwork`
    modifier hasDeploymentNetworks() {
        uint256 deploymentNetworksCount = _domainIds.length;
        require(deploymentNetworksCount > 0, "Need to add deployment networks. Use `addDeploymentNetwork` first");
        _;
    }

    /**
     * @notice Computes the address where the contract will be deployed on this chain.
     *     @param sender Address that requested deploy.
     *     @param deploySalt Entropy for contract address generation.
     *     @param isUniquePerChain True to have unique addresses on every chain.
     *     @param deploymentTarget the name of the network onto which to deploy the chain.
     *     @return Address where the contract will be deployed on this chain.
     */
    function computeAddressForChain(
        address sender,
        bytes32 deploySalt,
        bool isUniquePerChain,
        string memory deploymentTarget
    ) external returns (address) {
        NetworkIds memory networkIds = _convertDeploymentTargetToNetworkIds(deploymentTarget);

        return ICrosschainDeployAdapter(crosschainDeployContractAddress).computeContractAddressForChain(
            sender, deploySalt, isUniquePerChain, networkIds.InternalDomainId
        );
    }

    /**
     * This is a function we only need for tests.
     * TODO: Figure out a safer way of keeping this visible.
     */
    function setCrosschainDeployContractAddress(address _crosschainDeployContractAddress) public {
        crosschainDeployContractAddress = _crosschainDeployContractAddress;
    }
}
