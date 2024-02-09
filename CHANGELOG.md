# Changelog

## [0.1.2](https://github.com/ChainSafe/foundry-multichain-deploy/compare/v0.1.1...v0.1.2) (2024-02-09)


### Bug Fixes

* update readme ([#12](https://github.com/ChainSafe/foundry-multichain-deploy/issues/12)) ([fda2ed2](https://github.com/ChainSafe/foundry-multichain-deploy/commit/fda2ed2edd02f1da68e49b367731bc135c494d0b))

## [0.1.1](https://github.com/ChainSafe/foundry-multichain-deploy/compare/v0.1.0...v0.1.1) (2024-02-09)


### Bug Fixes

* call broadcast inside script deploy ([#10](https://github.com/ChainSafe/foundry-multichain-deploy/issues/10)) ([362625d](https://github.com/ChainSafe/foundry-multichain-deploy/commit/362625db54fa2cc9f05fa62b6dbbb28634948a48))

## 0.1.0 (2024-02-09)


### Features

* add CrossChainDeployScript.sol, update the interface with the docstring. ([fd7434c](https://github.com/ChainSafe/foundry-multichain-deploy/commit/fd7434c25c570c8e1b2776b5bd3245ab56a1cc38))
* **wip:** add `value` to `deploy` call so that it gets the payment. ([88bc0b1](https://github.com/ChainSafe/foundry-multichain-deploy/commit/88bc0b1d601e56167d4bdfb6357006fad7121b18))
* **wip:** add `vm.expectCall` to ensure contract calls ([ed494e0](https://github.com/ChainSafe/foundry-multichain-deploy/commit/ed494e0e31eacc21ed25fca229f8b656e9ae41fb))
* **wip:** add generateSalt ([444eba6](https://github.com/ChainSafe/foundry-multichain-deploy/commit/444eba689200f49ed57dfd019817a37218a60e6c))
* **wip:** add integration test, test steps to justfile ([3ce7924](https://github.com/ChainSafe/foundry-multichain-deploy/commit/3ce792438c30acb871c17a57e830906be34e107d))
* **wip:** Add multiple deployment targets & args ([b926e2c](https://github.com/ChainSafe/foundry-multichain-deploy/commit/b926e2cb11d93ab843df8d534ff3d60e500bf8ba))
* **wip:** add support for .env file for the justfile and use it for intergration tests ([b6998f8](https://github.com/ChainSafe/foundry-multichain-deploy/commit/b6998f8538e4c2b9f78dabb7c3721079032854c3))
* **wip:** add unit tests and a mock for adapter ([4c62035](https://github.com/ChainSafe/foundry-multichain-deploy/commit/4c62035dff24755c83567f0717310520b82acf60))
* **wip:** cleanup docstrings, fix typos ([70206c9](https://github.com/ChainSafe/foundry-multichain-deploy/commit/70206c99c8299b4e0d16fb431e19e97a1688187e))
* **wip:** fix argument for constructor and initdata ([b124e3c](https://github.com/ChainSafe/foundry-multichain-deploy/commit/b124e3cab41b8592dbefbee4c30591d4f76ea794))
* **wip:** fix argument for constructor and initdata ([f82c1e5](https://github.com/ChainSafe/foundry-multichain-deploy/commit/f82c1e538646b3cadf1c7dd6f37e5940f5a9e59e))
* **wip:** fix function calls and type for callData ([bd519d5](https://github.com/ChainSafe/foundry-multichain-deploy/commit/bd519d52a3ad4c0a42a99205631fb574f8cac31d))
* **wip:** fix function signature for computeContractAddress, and call it within the deploy function, returning the list of contract addresses ([f219167](https://github.com/ChainSafe/foundry-multichain-deploy/commit/f2191672f1b523cd05b1fc449d29530dd971be49))
* **wip:** foundry init, add interface for CrossChainDeployAdapter ([307845a](https://github.com/ChainSafe/foundry-multichain-deploy/commit/307845a8a9677f836d485832730522147ed6fecd))
* **wip:** implement computeAddressForChain ([fe7a0da](https://github.com/ChainSafe/foundry-multichain-deploy/commit/fe7a0dab4832030625225504e64c18686df08853))
* **wip:** map constructorArgs and initDatas separately as well ([06773c5](https://github.com/ChainSafe/foundry-multichain-deploy/commit/06773c5fb21014ba5bc513ceef8dcfea2261b172))
* **wip:** Move reset steps into a new function so users can choose to reset the deployment networks if they want ([e57869d](https://github.com/ChainSafe/foundry-multichain-deploy/commit/e57869d9a2ea6ab3dac4405f6b7dccdb924597c5))
* **wip:** remove unused domain IDs from the constructor ([be4c339](https://github.com/ChainSafe/foundry-multichain-deploy/commit/be4c339bc6fb761b0da1bd3bb94e6eec4f55e76c))
* **wip:** track deployment targets using an array and store the available deployment targets as a mapping for easier use ([ea929d5](https://github.com/ChainSafe/foundry-multichain-deploy/commit/ea929d57bbc6619187a0372fedaaefb85f7c06ff))
* **wip:** update computeContractAddress fn definition ([716c3de](https://github.com/ChainSafe/foundry-multichain-deploy/commit/716c3de2252d70c037f44b092c246d7d4c82af00))
* **wip:** update justfile with some more planned tools ([40f2c07](https://github.com/ChainSafe/foundry-multichain-deploy/commit/40f2c07aac4d33fb4d518ee42f11071e94eca0f6))
* **wip:** use arrays to store a list of constructor args and init datas instead of a mapping to save gas on explicit conversions ([367fbb9](https://github.com/ChainSafe/foundry-multichain-deploy/commit/367fbb96f8f8ce614133120c2fc4fcc823fdc273))


### Bug Fixes

* warnings and stack too deep errors. move contract name to deploy (from constructor) ([749ef6a](https://github.com/ChainSafe/foundry-multichain-deploy/commit/749ef6a864d950999dc43435a42b04e7869dd7b6))
* **wip:** fix deploy interface definition ([8e33f39](https://github.com/ChainSafe/foundry-multichain-deploy/commit/8e33f39e2a042fcc5d5c01923d941903e5329959))
* **wip:** increment randomness counter ([fd883f4](https://github.com/ChainSafe/foundry-multichain-deploy/commit/fd883f49bd8bf641f883bda7d2d0780a84d37035))
* **wip:** rename functions for uniformity, fix array reset syntax to use delete ([b4685f3](https://github.com/ChainSafe/foundry-multichain-deploy/commit/b4685f3744e9caf064ddfedc4c4394a531a887dc))
* **wip:** typo with interfaces, don't use {} ([6b217ae](https://github.com/ChainSafe/foundry-multichain-deploy/commit/6b217ae213c56dd500d067dfef76ab5ecb9e5549))
* **wip:** use generateSalt instead of asking users to provide the salt ([456569e](https://github.com/ChainSafe/foundry-multichain-deploy/commit/456569e5ef99ffeb9f363a43276a422c6f3c1106))


### Miscellaneous

* add release please ([#8](https://github.com/ChainSafe/foundry-multichain-deploy/issues/8)) ([1944407](https://github.com/ChainSafe/foundry-multichain-deploy/commit/19444077b8e796d279de5dc41ad09fcaa2dcc639))
* release 0.1.0 ([2c6cd39](https://github.com/ChainSafe/foundry-multichain-deploy/commit/2c6cd39f3844869c5e1691ca9acf2f56789e2346))
* rename CrosschainDeployScript file and contract for consistency with upstream ([4c2d7a6](https://github.com/ChainSafe/foundry-multichain-deploy/commit/4c2d7a6d9a0f4bfcfa150898192b43849700f1dc))
* update justfile to not use private key for integration tests. ([b4b6ca5](https://github.com/ChainSafe/foundry-multichain-deploy/commit/b4b6ca548090bc4f1ef575f2896ee1b88a2a6368))
* **wip:** move deployment target check to modifier ([8b12528](https://github.com/ChainSafe/foundry-multichain-deploy/commit/8b125288bcf3d1d770e65f92d5c846db5b19632b))
* **wip:** purge the deployment targets after deploying ([7df5ba6](https://github.com/ChainSafe/foundry-multichain-deploy/commit/7df5ba606177e17fe43b051e19e65b871ef93702))
* **wip:** remove FIXME ([3636d7a](https://github.com/ChainSafe/foundry-multichain-deploy/commit/3636d7a91ca09d35b730fbc09b646a63e76bf7d3))
* **wip:** remove unnecessary custom error situation ([60dedd4](https://github.com/ChainSafe/foundry-multichain-deploy/commit/60dedd4533278cd4c12e6b3b2680d967d7895fe6))
* **wip:** update justfile to use forge's native `watch` flag ([25a70c2](https://github.com/ChainSafe/foundry-multichain-deploy/commit/25a70c26991a30357510488e8b4805fd4ae34880))
