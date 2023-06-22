//SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "forge-std/Test.sol";
import "../../contracts/veBalFeeInjector.sol";


contract veBalFeeInjectorTest is Test {

    // state variables
    veBalFeeInjector public injector;

    address feeDistributor = 0xD3cf852898b21fc233251427c2DC93d3d604F3BB;
    address BAL = 0xba100000625a3754423978a60c9317c58a424e3D;
    address WETH =0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address TETHER = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    uint256 toMint = 100e18;

    // setup
    function setUp() public {
        IERC20[] memory managedTokens = new IERC20[](2);
        managedTokens[0] = IERC20(BAL);
        managedTokens[1] = IERC20(WETH);

        uint256 minAmount = uint256(100);

        injector = new veBalFeeInjector(address(3), feeDistributor, managedTokens, minAmount);
    }

    // tests
    function test_IsPausable() public {
        assertFalse(injector.paused(), "Injector should not be paused");
        injector.pause();
        assertTrue(injector.paused(), "Injector should be paused");
        vm.expectRevert("Pausable: paused");
        injector.payFees();
    }

    // From deployment BAL & WETH are managed tokens
    function test_SetTokensWithNoNewTokens() public {
        IERC20[] memory newManagedTokens = new IERC20[](2);
        newManagedTokens[0] = IERC20(BAL);
        newManagedTokens[1] = IERC20(WETH);
        injector.setTokens(newManagedTokens);


        deal(BAL, address(injector), toMint);
        deal(WETH, address(injector), toMint);

        injector.payFees();
        for (uint i = 0; i < injector.getTokens().length; i++) {
            assertTrue(injector.getTokens()[i] == address(newManagedTokens[i]), "Tokens should be the same");
            assertEq(newManagedTokens[i].balanceOf(address(injector)), toMint/2, "Balance should be half of toMint");
        }
    }

    function test_SetTokensWithPartialNewTokens() public {
        IERC20[] memory newManagedTokens = new IERC20[](3);
        newManagedTokens[0] = IERC20(BAL);
        newManagedTokens[1] = IERC20(WETH);
        newManagedTokens[2] = IERC20(TETHER);
        injector.setTokens(newManagedTokens);

        deal(BAL, address(injector), toMint);
        deal(WETH, address(injector), toMint);
        deal(TETHER, address(injector), toMint);

        injector.payFees();
        for (uint i = 0; i < injector.getTokens().length; i++) {
            assertTrue(injector.getTokens()[i] == address(newManagedTokens[i]), "Tokens should be the same");
            assertEq(newManagedTokens[i].balanceOf(address(injector)), toMint/2, "Balance should be half of toMint");
        }
    }

    function test_SetTokensWithAllNewTokens() public {
        address bbaUsd = 0xfeBb0bbf162E64fb9D0dfe186E517d84C395f016;
        address dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

        IERC20[] memory newManagedTokens = new IERC20[](2);
        newManagedTokens[0] = IERC20(bbaUsd);
        newManagedTokens[1] = IERC20(dai);
        injector.setTokens(newManagedTokens);

        deal(bbaUsd, address(injector), toMint);
        deal(dai, address(injector), toMint);
        deal(TETHER, address(injector), toMint);

        injector.payFees();
        for (uint i = 0; i < injector.getTokens().length; i++) {
            assertTrue(injector.getTokens()[i] == address(newManagedTokens[i]), "Tokens should be the same");
            assertEq(newManagedTokens[i].balanceOf(address(injector)), toMint/2, "Balance should be half of toMint");
        }
    }

    function test_checkUpkeepAllTokensOverMin() public {
        address bbaUsd = 0xfeBb0bbf162E64fb9D0dfe186E517d84C395f016;
        address dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

        IERC20[] memory newManagedTokens = new IERC20[](2);
        newManagedTokens[0] = IERC20(bbaUsd);
        newManagedTokens[1] = IERC20(dai);
        injector.setTokens(newManagedTokens);

        (bool upkeepNeeded, ) = injector.checkUpkeep(bytes(""));
        assertFalse(upkeepNeeded);

        // false due to threshold not met
        deal(bbaUsd, address(injector), 10);
        deal(dai, address(injector), 10);

        (upkeepNeeded, ) = injector.checkUpkeep(bytes(""));
        assertFalse(upkeepNeeded);


        // true due to threshold met
        deal(bbaUsd, address(injector), 200e19);
        deal(dai, address(injector), 200e19);

        (upkeepNeeded, ) = injector.checkUpkeep(bytes(""));
        assertTrue(upkeepNeeded);
    }

        function test_checkUpkeepSomeTokensOverMin() public {
        
        address bbaUsd = 0xfeBb0bbf162E64fb9D0dfe186E517d84C395f016;
        address dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

        IERC20[] memory newManagedTokens = new IERC20[](2);
        newManagedTokens[0] = IERC20(bbaUsd);
        newManagedTokens[1] = IERC20(dai);
        injector.setTokens(newManagedTokens);

        (bool upkeepNeeded, ) = injector.checkUpkeep(bytes(""));
        assertFalse(upkeepNeeded);

        // false due to threshold not met
        deal(bbaUsd, address(injector), 10);
        deal(dai, address(injector), 10);

        (upkeepNeeded, ) = injector.checkUpkeep(bytes(""));
        assertFalse(upkeepNeeded);


        // simulate Tokens being added at different times
        deal(bbaUsd, address(injector), 200e19);
        //deal(dai, address(injector), 200e19);

        (upkeepNeeded, ) = injector.checkUpkeep(bytes(""));
        // see requirement here: https://github.com/BalancerMaxis/veBalFeeInjector/pull/9#discussion_r1236993920
        // Therefore we only want to run if both tokens are present.
        assertFalse(upkeepNeeded);
    }

}