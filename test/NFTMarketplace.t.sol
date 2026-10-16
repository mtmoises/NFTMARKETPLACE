// SPDX-License-Identifier: MIT

import "forge-std/Test.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../src/NFTMarketPlace.sol";

pragma solidity 0.8.24;

contract MockNFT is ERC721 {

 constructor() ERC721("MockNFT", "MNFT") {}

 function mint(address to_, uint256 tokenId_) external {
    _mint(to_, tokenId_);

 }

}

contract NFTMarketplaceTest is Test {

    NFTMarketplace MarketPlace;
    MockNFT nft;
    address deployer = vm.addr(1);
    address user = vm.addr(2);
    uint256 public tokenId = 0;

    function setUp() public {
        vm.startPrank(deployer);
        MarketPlace = new NFTMarketplace();
        nft = new MockNFT();
        vm.stopPrank();

        vm.startPrank(user);
       nft.mint(user, 0);
        vm.stopPrank();
    }

       function testMintNFT() public view {
    address ownerOf = nft.ownerOf(0);
    assert(ownerOf == user);
    }
    
      function testShouldRevertIfPriceIsZero() public {
    vm.startPrank(user);

    vm.expectRevert("Price can not be 0");
    MarketPlace.listNFT(address(nft), 0, 0);

    vm.stopPrank();
    }

function testShouldRevertIfNotOwner() public {
    vm.startPrank(user);

    address user2_ = vm.addr(3);
    uint256 tokenId_ = 1;
    nft.mint(user2_, tokenId_);

    vm.expectRevert("You are not the owner of the NFT");
    MarketPlace.listNFT(address(nft), tokenId_, 1);
    vm.stopPrank();
}

  function testListNFTCorrectly() public {
    vm.startPrank(user);
    (address sellerBefore,,,) = MarketPlace.listing(address(nft), tokenId);
    MarketPlace.listNFT(address(nft), tokenId, 1e18);
    (address sellerAfter,,,) = MarketPlace.listing(address(nft), tokenId);
    assert(sellerBefore == address(0) && sellerAfter == user);
    vm.stopPrank();
}

function testListShouldRevertIfNotOwner() public {
    vm.startPrank(user);
    (address sellerBefore,,,) = MarketPlace.listing(address(nft), tokenId);
    MarketPlace.listNFT(address(nft), tokenId, 1e18);
    (address sellerAfter,,,) = MarketPlace.listing(address(nft), tokenId);
    assert(sellerBefore == address(0) && sellerAfter == user);
    vm.stopPrank();

    address user2 = vm.addr(3);
    vm.startPrank(user2);
    vm.expectRevert("You are not the listing owner");
    MarketPlace.cancelList(address(nft), tokenId);
    vm.stopPrank();
}

function testCancelListShouldWorkCorrectly() public {
  vm.startPrank(user);
    (address sellerBefore,,,) = MarketPlace.listing(address(nft), tokenId);
    MarketPlace.listNFT(address(nft), tokenId, 1e18);
    (address sellerAfter,,,) = MarketPlace.listing(address(nft), tokenId);
    assert(sellerBefore == address(0) && sellerAfter == user);

    MarketPlace.cancelList(address(nft), tokenId);
    (address sellerAfter2,,,) = MarketPlace.listing(address(nft), tokenId);
    assert(sellerAfter2 == address(0));

    vm.stopPrank();
}


function testCanNotBuyListedNFT() public {
    address user2 = vm.addr(3);
    vm.startPrank(user2);

    vm.expectRevert("Listing Not exists");
    MarketPlace.buyNFT(address(nft), tokenId);
    
    vm.stopPrank();
}

function testCanNotBuyWithIncorrectPay() public {
    vm.startPrank(user);

    uint256 price = 1e18;
    (address sellerBefore,,,) = MarketPlace.listing(address(nft), tokenId);
    MarketPlace.listNFT(address(nft), tokenId, price);
    (address sellerAfter,,,) = MarketPlace.listing(address(nft), tokenId);
    assert(sellerBefore == address(0) && sellerAfter == user);

    vm.stopPrank();

    address user2 = vm.addr(3);
    vm.startPrank(user2);
    vm.deal(user2, price);

    vm.expectRevert("Incorrect price");
    MarketPlace.buyNFT{value: price - 1}(address(nft), tokenId);
    vm.stopPrank();
}

function testShouldBuyNFTCorrectly() public {
    vm.startPrank(user);

    uint256 price = 1e18;
    (address sellerBefore,,,) = MarketPlace.listing(address(nft), tokenId);
    MarketPlace.listNFT(address(nft), tokenId, price);
    (address sellerAfter,,,) = MarketPlace.listing(address(nft), tokenId);
    assert(sellerBefore == address(0) && sellerAfter == user);

    nft.approve(address(MarketPlace), tokenId);
    vm.stopPrank();

    address user2 = vm.addr(3);
    vm.startPrank(user2);
    vm.deal(user2, price);

    address ownerBefore = nft.ownerOf(tokenId);
    (address sellerBefore2,,,) = MarketPlace.listing(address(nft), tokenId);
    MarketPlace.buyNFT{value: price}(address(nft), tokenId);
    (address sellerAfter2,,,) = MarketPlace.listing(address(nft), tokenId);
    address ownerAfter = nft.ownerOf(tokenId);

    assert(sellerBefore2 == user && sellerAfter2 == address(0));
    assert(ownerBefore == user && ownerAfter == user2);

    vm.stopPrank();
}

function testBuyFailsIfSellerCannotReceive() public {
    vm.startPrank(user);
    MarketPlace.listNFT(address(nft), tokenId, 1e18);
    nft.approve(address(MarketPlace), tokenId);
    vm.stopPrank();

    vm.etch(user, hex"6000FD");

    address user2 = vm.addr(3);
    vm.deal(user2, 1e18);
    vm.startPrank(user2);
    vm.expectRevert();
    MarketPlace.buyNFT{value: 1e18}(address(nft), tokenId);
    vm.stopPrank();
}

}