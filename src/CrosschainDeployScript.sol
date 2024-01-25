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

    // given a string, obtain the domain ID;
    // https://www.notion.so/chainsafe/Testnet-deployment-0483991cf1ac481593d37baf8d48712a

    error Unimplemented(string message);

    mapping(string => uint8) private _stringToDeploymentNetwork;
    // store the domain IDs
    uint8[] private _deploymentNetworks;

    constructor() {
        _stringToDeploymentNetwork["goerli"] = 1;
        _stringToDeploymentNetwork["sepolia"] = 2;
        _stringToDeploymentNetwork["rhala"] = 3; // unimplemented as of today;
        _stringToDeploymentNetwork["base-goerli"] = 4; // unimplemented as of today;
        _stringToDeploymentNetwork["cronos-testnet"] = 5;
        _stringToDeploymentNetwork["holesky"] = 6;
        _stringToDeploymentNetwork["mumbai"] = 7;
        _stringToDeploymentNetwork["arbitrum-sepolia"] = 8;
        _stringToDeploymentNetwork["gnosis-chaido"] = 9;
        _stringToDeploymentNetwork["holesky"] = 6;
    }

    /**
     * This function willl take the network, constructor args and initdata and
     * save these to a mapping (what type?)
     */
    function addDeploymentTarget(string memory deploymentTarget) public {
        uint8 deploymentTargetDomainId = _stringToDeploymentNetwork[deploymentTarget];
        require(deploymentTargetDomainId != 0, "Invalid deployment target");
        if ((deploymentTargetDomainId == 3) || (deploymentTargetDomainId == 4)) {
            revert Unimplemented("That domain isn't implemented yet");
        }

        _deploymentNetworks.push(deploymentTargetDomainId);
        // TODO: what else does this need to do?
    }

    /**
     * @notice this function takes in the contract string, in the form that
     * @notice `forge`'s `getCode` takes it, along with some other parameters and passes
     * @notice it along to the `deploy` function of the `CrossChainDeployAdapter`
     * @notice contract.
     * @param contractString Contract name in the form of `ContractFile.sol`, if the name of the contract and the file are the same, or `ContractFile.sol:ContractName` if they are different.
     * @param gasLimit Contract deploy and init gas.
     * @param salt Entropy for contract address generation.
     * @param isUniquePerChain True to have unique addresses on every chain.
     * @param constructorArgs Bytes to add to the deployBytecode, or empty, one per chain.
     * @param initDatas Bytes to send to the contract after deployment, or empty, one per chain.
     *
     *   Users call this function and pass only the function call string as
     *   `MyContract.sol:MyContract`. The function call string is then parsed
     *   and the `callData` and `bytesCode` are extracted from it.
     *   and the contract is deployed on the other chains.
     */
    function deploy(
        string calldata contractString,
        uint256 gasLimit,
        bytes32 salt,
        bool isUniquePerChain,
        bytes[] memory constructorArgs,
        bytes[] memory initDatas
    )
        // uint8[] memory destinationDomainIDs
        public
        payable
    {
        require(_deploymentNetworks.length > 0, "Need to add deployment targets. Use `addDeploymentTarget` first");
        // We use the contractString to get the bytecode of the contract,
        // reference: https://book.getfoundry.sh/cheatcodes/get-code
        bytes memory deployByteCode = vm.getCode(contractString);
        uint256[] memory fees = ICrosschainDeployAdapter(CROSS_CHAIN_DEPLOY_CONTRACT_ADDRESS).calculateDeployFee(
            deployByteCode, gasLimit, salt, isUniquePerChain, constructorArgs, initDatas, _deploymentNetworks
        );
        uint256 totalFee;
        uint256 feesArrayLength = fees.length;
        for (uint256 i = 0; i < feesArrayLength;) {
            uint256 fee = fees[i];
            totalFee += fee;
            unchecked {
                ++i;
            }
        }

        ICrosschainDeployAdapter(CROSS_CHAIN_DEPLOY_CONTRACT_ADDRESS).deploy{value: totalFee}(
            deployByteCode, gasLimit, salt, isUniquePerChain, constructorArgs, initDatas, _deploymentNetworks, fees
        );
    }

    // what does this do?
    function encodeInitData() public {}

    // what does this do?
    function getDeploymentFee() public {}

    /**
     * @notice Computes the address where the contract will be deployed on this chain.
     *     @param sender Address that requested deploy.
     *     @param salt Entropy for contract address generation.
     *     @param isUniquePerChain True to have unique addresses on every chain.
     *     @return Address where the contract will be deployed on this chain.
     */
    function computeAddressForChain(address sender, bytes32 salt, bool isUniquePerChain)
        external
        view
        returns (address)
    {
        // QUESTION: *is* this a view? It's calling another contract, isn't it?

        return ICrosschainDeployAdapter(CROSS_CHAIN_DEPLOY_CONTRACT_ADDRESS).computeContractAddressForChain(
            sender, salt, isUniquePerChain
        );
    }
}
