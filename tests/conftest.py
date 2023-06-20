import pytest
import time
from brownie import (
    interface,
    accounts,
    veBalFeeInjector,
    Contract,
network
)
from brownie.exceptions import VirtualMachineError

from dotmap import DotMap
import pytest
import json


##  Accounts
VAULT_ADDRESS = "0xBA12222222228d8Ba445958a75a0704d566BF2C8"
WHALE = VAULT_ADDRESS
BBAUSD_ADDRESS = "0xa13a9247ea42d743238089903570127dda72fe44"
BAL_ADDRESS = "0xba100000625a3754423978a60c9317c58a424e3D"
FEE_DISTRIBUTOR = "0xD3cf852898b21fc233251427c2DC93d3d604F3BB"
ZERO_ADDRESS = "0x0000000000000000000000000000000000000000"


@pytest.fixture()
def whale():
    return VAULT_ADDRESS


@pytest.fixture()
def vault():
    return Contract(VAULT_ADDRESS)


@pytest.fixture()
def caller():
    return accounts[0]

@pytest.fixture()
def owner():
    return accounts[1]


@pytest.fixture()
def feeDistributor():
    return Contract.from_explorer(FEE_DISTRIBUTOR)


@pytest.fixture()
def bal():
    return Contract.from_explorer(BAL_ADDRESS)


@pytest.fixture()
def usd():
    return Contract(BBAUSD_ADDRESS)


@pytest.fixture()
def keeper():
    return accounts[7]

@pytest.fixture()
def injector(deploy):
    return deploy

@pytest.fixture()
def deploy(caller, feeDistributor, bal, usd, whale, owner, keeper):
    """
    Deploys, vault and test strategy, mock token and wires them up.
    """

    bal.transfer(owner, 100000*10**bal.decimals(), {"from": whale})
    usd.transfer(owner, 100000*10**usd.decimals(), {"from": whale})

    helper = veBalFeeInjector.deploy(
        keeper,
        feeDistributor,
        [bal, usd],
        100,
        {"from": caller}
    )
    helper.transferOwnership(owner, {"from": caller})

    print(helper.address)
    return helper
