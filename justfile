set shell:=["bash", "-uc"]


# build the contracts
build:
    forge build

# format source
fmt:
    forge fmt

# watches the directory for changes and rebuilds. Needs `watchexec` - https://github.com/watchexec/watchexec. This is useful when developing contracts.
watch-build:
    watchexec just fmt build

deploy-sepolia:
    echo "Unimplemented" >&2
    exit 1

deploy-anvil:
    echo "Unimplemented" >&2
    exit 1
    