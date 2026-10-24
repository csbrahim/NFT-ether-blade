-include .env

.PHONY: all clean build test test-unit test-integration coverage snapshot format anvil install deploy deploy-sepolia mint train frontend help

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

help:
	@echo "EtherBlade — available commands:"
	@echo "  make install            Install dependencies"
	@echo "  make build              Compile contracts"
	@echo "  make test               Run all tests"
	@echo "  make test-unit          Run unit tests only"
	@echo "  make test-integration   Run integration tests only"
	@echo "  make coverage           Coverage (src only)"
	@echo "  make anvil              Start local Anvil"
	@echo "  make deploy             Deploy to Anvil"
	@echo "  make deploy-sepolia     Deploy + verify on Sepolia"
	@echo "  make mint               Mint blade (latest deployment)"
	@echo "  make train              Train blade #0 (latest deployment)"
	@echo "  make frontend           Run Next.js frontend"

all: clean install build test

clean:
	forge clean

install:
	forge install Cyfrin/foundry-devops --no-commit
	forge install foundry-rs/forge-std --no-commit
	forge install OpenZeppelin/openzeppelin-contracts --no-commit

build:
	forge build

test:
	forge test -vvv

test-unit:
	forge test --match-path "test/unit/*" -vvv

test-integration:
	forge test --match-path "test/integration/*" -vvv

coverage:
	forge coverage --no-match-coverage "script/"

snapshot:
	forge snapshot

format:
	forge fmt

anvil:
	anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

NETWORK_ARGS := --rpc-url http://127.0.0.1:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

deploy:
	@forge script script/DeployEtherBlade.s.sol:DeployEtherBlade $(NETWORK_ARGS)

deploy-sepolia:
	@forge script script/DeployEtherBlade.s.sol:DeployEtherBlade \
		--rpc-url $(SEPOLIA_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		--verify \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		-vvvv

mint:
	@forge script script/Interactions.s.sol:MintBladeScript $(NETWORK_ARGS)

train:
	@forge script script/Interactions.s.sol:TrainBladeScript $(NETWORK_ARGS)

frontend:
	cd ether-blade-frontend && npm install && npm run dev