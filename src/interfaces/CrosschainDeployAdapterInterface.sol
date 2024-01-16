// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.8.20;

/**
 * @title Provides an interface to the CrosschainDeployAdapter from chainsafe/hardhat-plugin-multichain-deploy
 * @author ChainSafe Systems.
 * @notice The original contract in question is intended to be used with the Bridge contract and Permissionless Generic Handler
 */
interface ICrosschainDeployAdapter {
    function deploy(
        bytes calldata deployBytecode,
        uint256 gasLimit,
        bytes32 salt,
        bool isUniquePerChain,
        bytes[] memory constructorArgs,
        bytes[] memory initDatas,
        uint8[] memory destinationDomainIDs,
        uint256[] memory fees
    ) external payable;

    function computeContractAddressForChain(address sender, bytes32 salt, bool isUniquePerChain)
        external
        view
        returns (address);

    function calculateDeployFee(
        bytes calldata deployBytecode,
        uint256 gasLimit,
        bytes32 salt,
        bool isUniquePerChain,
        bytes[] memory constructorArgs,
        bytes[] memory initDatas,
        uint8[] memory destinationDomainIds
    ) external view returns (uint256[] memory fees);
}
