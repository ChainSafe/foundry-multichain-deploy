set shell:=["bash", "-uc"]
set dotenv-load

# build the contracts
build:
    forge build --via-ir

# format source
fmt:
    forge fmt

# run unit tests
test:
    forge test --via-ir --no-match-test Integration

# run integration tests, needs --fork-url
integration-test:
    set -x
    forge test --via-ir --mt Integration --fork-url $INTEGRATION_FORK_URL -vvv

# watches the directory for changes and rebuilds.
watch-build:
    forge build --via-ir --watch

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