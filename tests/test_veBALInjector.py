import brownie
from brownie import Contract, accounts, chain
import time
import pytest
import json
from random import sample


def test_deploy(deploy):
    return

def test_two_weeks(injector, feeDistributor, owner, keeper, bal, usd, bal_amount=50000*10**18, usd_amount=50000*10**18):
    injector.setTokens([bal, usd])
    assert bal.balanceOf(injector) == 0, "Non-0 BAL balance in collector"
    assert bal.balanceOf(injector) == 0, "Non-0 USD balance in collector"
    assert injector.half(), "Half is false, should be true on first run"
    (ready, foo) = injector.checkUpkeep(0)
    assert ready is False, "Injector shows ready with 0 balances"
    with brownie.reverts("Not ready"):
        injector.performUpkeep(0, {"from": keeper})
    bal.transfer(injector, bal_amount, {"from": owner})
    usd.transfer(injector, usd_amount, {"from": owner})
    (ready, foo) = injector.checkUpkeep(0)
    assert ready, "New and funded injector shows not ready"
    injector.performUpkeep(0, {"from": keeper})
    assert bal.balanceOf(injector) == bal_amount/2, f"Injector has {bal.balanceOf(injector)} which isn't half of {bal_amount}"
    assert usd.balanceOf(injector) == usd_amount/2, f"Injector has {usd.balanceOf(injector)} which isn't half of {usd_amount}"
    assert injector.half() is False, "Half was not flipped after payment"
    (ready, foo) = injector.checkUpkeep(0, )
    assert ready is False, "Injector shows ready directly after run"
    with brownie.reverts("Not ready"):
        injector.performUpkeep(0, {"from": keeper})
    chain.mine()
    chain.sleep(injector.LastRunTimeCurser() + 100 - chain.time())
    chain.mine()
    feeDistributor.checkpointTokens(injector.getTokens(), {"from": keeper})
    feeDistributor.checkpoint({"from": keeper})
    chain.mine()
    (ready, foo) = injector.checkUpkeep(0)
    assert ready, "Injector not ready after sleep."
    injector.performUpkeep(0, {"from": keeper})
    assert bal.balanceOf(injector) == 0, f"Injector has {bal.balanceOf(injector)}.  Should be zero after 2 runs. "
    assert usd.balanceOf(injector) == 0, f"Injector has {usd.balanceOf(injector)}.  Should be zero after 2 runs."
    assert injector.half() is True, "Half was not flipped after payment"
    bal.transfer(injector, bal_amount, {"from": owner})
    usd.transfer(injector, usd_amount, {"from": owner})
    (ready, foo) = injector.checkUpkeep(0)
    assert ready is False, "Injector shows ready directly after first run."
    with brownie.reverts("Not ready"):
        injector.performUpkeep(0, {"from": keeper})


