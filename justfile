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

deploy-anvil: build
    echo "Unimplemented" >&2
    exit 1
    
deploy-sepolia: build
    echo "Unimplemented" >&2
    exit 1


# Builds locally using docker (useful for debugging dependency issues)
docker-build:
    echo "Unimplemented" >&2
    exit 1

docker-test: docker-build
    echo "Unimplemented" >&2
    exit 1