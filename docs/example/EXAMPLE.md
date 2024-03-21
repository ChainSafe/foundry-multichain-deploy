# Example

> **WARNING**: 
> 
> This folder can be copied as-is to another location and you can work on it.
> Make sure you don't work on this folder *here*. To help you, there's a `just
> copy-example` command *in the root level of this project* that does all this for
> you.
> To prevent creating a submodule link to this own repo, we've chosen to not include the lib folder
> here, so the `copy-example` script does all of this for you.

## Usage

This example uses the starter Foundry contract and shows you how you can deploy
it using the adapter.

From the *root folder* of this repository, run `just copy-example`. **Read the
output message**. It will copy the example code to
`~/multichain-examples/tmp.$random-folder-name/example`. You need to `cd` into
that folder, ignore the code in `src` and focus on the `script/` folder. Ensure
that you've
set the `PRIVATE_KEY` and `CHAIN_RPC_URL` variables in the `.env` file, and run
`just deploy`.

The example has comments to explain what's going on.