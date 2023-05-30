# veBalFeesInjector
This contract is a meant to be called by a chainlink keeper.  It's purpose is to send the portion of BAL and bb-a-usd fees destine to be paid to veBAL holders directly into the distributor on a weekly basis.

Fee processing rounds are completed by the Maxis every 2 weeks.  This process renders 2 weeks of veBAL fees.  This contract should receive those fees each 2 weeks and then pay it out evenly over a 2 week period.

This contract assumes that the Maxis will ensure that the contract is empty (2 rounds have been run) before sending in more tokens. It should be possible to have a few days of seperation to make this easy.

## Example schedule
Epochs change over at 00:00 GMT as Wednesday becomes Thursday, the injector will fire shortly after that.   

The Maxis process fees every other Friday.

When the Maxis proces fees, the current running epoch has had no injection.

So if the maxi's send in tokes on a Friday, it will be paid out over 2 Wednesdays before the next Friday when tokens are sent in.


# Running the tests
## Brownie
Tritium wrote the initial integration tests in brownie.
to do it on a mac:
```bash
python3.9 -m venv venv
source venv/bin/activate
EXPORT WEB3_INFURA_PROJECT_ID=<infura RPC api key>
EXPORT ETHERSCAN_TOKEN=<mainnet etherscan API key>
pip3 install -r requirements.txt
brownie test
```
## Foundry

mkflow setup this project as foundry and some tests.  Yay. 

https://medium.com/buildbear/web3-beginner-how-to-use-foundry-to-test-an-erc20-contract-with-fuzzing-3f456e8a10f5

To do it on a mac

```bash
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup
forge test


```


# Deployment details
Will be added on deployment.

# Chainlink automation details
Will be added on chainlink configurataion

