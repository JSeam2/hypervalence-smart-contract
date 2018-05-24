/**
* TokenAuctionTest
*/

const ArtistToken = artifacts.require("ArtistToken");
const Auction = artifacts.require("TokenAuction");

contract("Auction", accounts => {
	it("Should accept nft on creation", async() => {
		let nft = await ArtistToken.new();
		let auction = await TokenAuction.new(nft.address);
		const nftAddr = await auction.nonFungibleContract;
		assert.equal(nftAddr, nft.address);
	});
});

describe("createAuction", () => {
	let nft, auctionContract, tokens;

	before(async() =>{
		nft = await ArtistToken.new();
		auctionContract = await TokenAuction.new(nft.address);

		await nft.mint("Test", "Test", 2);
		tokens = await nft.tokensOf(account[0]);

		await nft.approve(auctionContract.address, tokens[0]);
		await auctionContract.createAuction(tokens[0], 100);
	});

	it("Should take owership of a token", async => {
		const tokenOwner = await nft.ownerOf(tokens[0]);
		assert.equal(tokenOwner, auctionContract.address);
	});

	it("Should create a new auction", async => {
		const auction = await auctionContract.tokenIdToAuction(tokens[0]);
		assert.equal(auction[0], accounts[0]);
		assert.equal(auction[1].toNumber, 100);
	});
});