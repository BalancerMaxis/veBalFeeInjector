-include .env


test-injector:
	forge test -vvv --fork-url ${MAINNET_RPC_URL}
