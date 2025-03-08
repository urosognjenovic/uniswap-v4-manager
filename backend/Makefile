include .env

build:
	forge build

deploy-pc:
	@rpc_url="$$(make --no-print-directory get-rpc-url network=$(network))"; \
	forge script script/PoolController.s.sol:DeployPoolController --rpc-url "$$rpc_url" --account testAccount --via-ir --broadcast

deploy-and-verify-pc:
	@rpc_url="$$(make --no-print-directory get-rpc-url network=$(network))"; \
	forge script script/PoolController.s.sol:DeployPoolController --rpc-url "$$rpc_url" --account testAccount --via-ir --verify --etherscan-api-key ${ETHERSCAN_API_KEY} --broadcast

get-rpc-url:
	@case "$(network)" in \
		ethereum-sepolia) echo "${ETH_SEPOLIA_RPC_URL}" ;; \
		ethereum-mainnet) echo "${ETH_MAINNET_RPC_URL}" ;; \
		*) echo "Error: Unknown network: $(network)"; exit 1 ;; \
	esac