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
     * @param destinationDomainIDs Sygma Domain IDs of target chains.
     *
     *   Users call this function and pass only the function call string as
     *   `MyContract.sol:MyContract`. The function call string is then parsed
     *   and the `callData` and `bytesCode` are extracted from it.
     *   and the contract is deployed on the other chains.
     */
    function deployContractOnOtherChains(
        string calldata contractString,
        uint256 gasLimit,
        bytes32 salt,
        bool isUniquePerChain,
        bytes[] memory constructorArgs,
        bytes[] memory initDatas,
        uint8[] memory destinationDomainIDs
    ) public payable {
        // We use the contractString to get the bytecode of the contract,
        // reference: https://book.getfoundry.sh/cheatcodes/get-code
        // FIXME: I get `type memory cannot be implicitly converted to calldata`
        bytes memory deployByteCode = vm.getCode(contractString);
        uint256[] memory fees = ICrosschainDeployAdapter(CROSS_CHAIN_DEPLOY_CONTRACT_ADDRESS).calculateDeployFee(
            deployByteCode, gasLimit, salt, isUniquePerChain, constructorArgs, initDatas, destinationDomainIDs
        );
        ICrosschainDeployAdapter(CROSS_CHAIN_DEPLOY_CONTRACT_ADDRESS).deploy(
            deployByteCode, gasLimit, salt, isUniquePerChain, constructorArgs, initDatas, destinationDomainIDs, fees
        );
    }
}
