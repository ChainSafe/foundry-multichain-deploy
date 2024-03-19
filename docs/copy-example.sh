#!/usr/bin/env bash
set -e
set -u
# Make a temporary directory and store its path in a variable
orig_dir=$(pwd)
temp_dir=$(mktemp -d -u)
temp_dirname=$(basename $temp_dir)
example_working_dir="${HOME}/multichain-examples/${temp_dirname}/"
mkdir -p $example_working_dir
echo "Copying example to $example_working_dir"
# Copy ./docs/example to that directory
cp -r $PWD/example $example_working_dir
# CD to the new example directory
cd $example_working_dir/example
# Run forge init
cp .env.example .env
forge init --no-commit --force .
# Run forge install
forge install --no-commit git@github.com:ChainSafe/foundry-multichain-deploy.git
cp $orig_dir/example/src/Counter.sol src/Counter.sol
cp $orig_dir/example/script/Counter.s.sol src/Counter.s.sol
cp $orig_dir/example/test/Counter.t.sol test/Counter.t.sol
# Run forge build
forge build
echo "WARNING: This (${example_working_dir}) is in your home folder and could take up a lot of space if you've done this multiple times. Make sure you delete the folder whenever you're done. Alternately run \`just clean-examples\` and you're good to go." >&2
echo "Run \'cd ${example_working_dir}example\`, set the PRIVATE_KEY and CHAIN_RPC_URL in .env file and then run 'just --choose'"