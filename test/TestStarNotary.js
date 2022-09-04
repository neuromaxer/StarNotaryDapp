const StarNotary = artifacts.require("./StarNotary.sol");

var accounts;
var owner;

contract("StarNotary", async (accs) => {
    accounts = accs;
    owner = accounts[0];
});

it("can Create a Star", async () => {
    contractInstance = await StarNotary.deployed();
    let tokenId = 1;
    await contractInstance.createStar("Regis III", tokenId, { from: owner });
    assert.equal(
        await contractInstance.tokenIdToStarInfo.call(tokenId),
        "Regis III"
    );
});

it("test put up for sale", async () => {
    contractInstance = await StarNotary.deployed();
    let tokenId = 2;
    await contractInstance.createStar("Regis III", tokenId, { from: owner });
    await contractInstance.putStarUpForSale(tokenId, 100, { from: owner });
    assert.equal(await contractInstance.starsForSale.call(tokenId), 100);
});

it("test user buying a star and owner getting funds after sale", async () => {
    contractInstance = await StarNotary.deployed();
    let user1 = accounts[1];
    let tokenId = 3;
    let starPrice = 1000;
    let valueSent = 10000;
    await contractInstance.createStar("Regis III", tokenId, { from: owner });
    await contractInstance.putStarUpForSale(tokenId, starPrice, {
        from: owner,
    });
    let ownerBalancePreTrade = await web3.eth.getBalance(owner);
    await contractInstance.buyStar(tokenId, {
        from: user1,
        value: valueSent,
    });
    let ownerBalancerPostTrade = await web3.eth.getBalance(owner);
    // check ownership has changed to user1
    assert.equal(await contractInstance.ownerOf(tokenId), user1);
    // check that owner received his funds
    assert.equal(
        Number(ownerBalancePreTrade),
        Number(ownerBalancerPostTrade) + Number(starPrice)
    );
});

it("can add the star name and star symbol properly", async () => {
    // 1. create a Star with different tokenId
    //2. Call the name and symbol properties in your Smart Contract and compare with the name and symbol provided
    contractInstance = await StarNotary.deployed();
    let tokenName = await contractInstance.name();
    let tokenSymbol = await contractInstance.symbol();
    assert.equal(tokenName, "Star Notary Token");
    assert.equal(tokenSymbol, "SNT");
});

it("lets 2 users exchange stars", async () => {
    contractInstance = await StarNotary.deployed();
    let user1 = accounts[1];
    let user2 = accounts[2];
    await contractInstance.createStar("Star 1", 10, { from: user1 });
    await contractInstance.createStar("Star 2", 11, { from: user2 });
    await contractInstance.exchangeStars(10, 11, { from: user1 });
    let owner1 = await contractInstance.ownerOf(10);
    let owner2 = await contractInstance.ownerOf(11);
    assert.equal(user1, owner2);
    assert.equal(user2, owner1);
});

it("lets a user transfer a star", async () => {
    contractInstance = await StarNotary.deployed();
    let user1 = accounts[1];
    let user2 = accounts[2];
    await contractInstance.createStar("Star 3", 13, { from: user1 });
    await contractInstance.transferStar(user2, 13, { from: user1 });
    let owner3 = await contractInstance.ownerOf(13);
    assert.equal(user2, owner3);
});

it("lookUptokenIdToStarInfo test", async () => {
    contractInstance = await StarNotary.deployed();
    let user1 = accounts[1];
    await contractInstance.createStar("Star 4", 14, { from: user1 });
    let starName = await contractInstance.lookUptokenIdToStarInfo(14);
    assert.equal(starName, "Star 4");
});
