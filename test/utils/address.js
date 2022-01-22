// // Contracts
// const Iterable = "0x303B7Ac91E2B94d500a0a892F13374823DdB7A08"; // autoupdated
// const Reward = "0x6A50D15619f68739A77C01859642d77809992E8e"; // autoupdated
// const Token = "0x5E81a027E3128876A666A42aBA6f6E38b20B4F2c"; // autoupdated
// const JoeRouter = "0x60ae616a2155ee3d9a68541ba4544862310933d4"; // from avalanche, forking required
// const Nft = "0x6BdBb69660E6849b98e8C524d266a0005D3655F7";
// const Dai = "0x9B06D17ce54B06dF4A644900492036E3AC384517";
// const PolarWLsale = "0xB5954Fe2c97b8B983Ce83973A4aD87aeFCca7CFB";
// const PolarPUBsale = "0xC2F3d765E49D7f4314aDf4AEe28BB2f2655EaC5A";

// // Addresses from hardhat default ones to allow easier tests

// const Payees = [ // must fit 00_deploy.shares
//     "0x8626f6940e2eb28930efb4cef49b2d1f2c9c1199", // hardhat19
//     "0xdd2fd4581271e230360230f9337d5c0430bf44c0", // hardhat18
//     "0xbda5747bfd65f08deb54cb465eb87d40e51b197e", // hardhat17

// ];
// const Addresses = [
//     "0x2546bcd3c84621e976d8185a91a922ae77ecec30", // supply // hardhat16
//     "0xcd3b766ccdd6ae721141f452c550ca635964ce71", // futurUsePool // hardhat15
//     "0xdf3e18d64bc6a983f673ab319ccae4f1a57c7097", // distributionPool //hardhat14
//     "0x1cbd3b2770909d4e10f157cabc84c7264073c9ec", // lp pool provider //hardhat13
// ];

// module.exports = {
//     Iterable,
//     Reward,
//     Token,
//     JoeRouter,
//     Payees,
//     Addresses,
//     Nft,
//     Dai,
//     PolarWLsale,
//     PolarPUBsale
// }

// Contracts
const Iterable = "0x303B7Ac91E2B94d500a0a892F13374823DdB7A08"; // autoupdated
const Reward = "0x6A50D15619f68739A77C01859642d77809992E8e"; // autoupdated
const Token = "0x6C1c0319d8dDcb0ffE1a68C5b3829Fd361587DB4"; // autoupdated
const JoeRouter = "0x60ae616a2155ee3d9a68541ba4544862310933d4"; // from avalanche, forking required
const Nft = "0xbA83b7f4886AF6276541F9C4369A90e8161dd42A";
const Dai = "0x130966628846bfd36ff31a822705796e8cb8c18d"; //mim contract
const PolarWLsale = "0x370af71894e041a5fFda7C58632Ba3Fe4352EDbB";
const PolarPUBsale = "0xD420a83bF2e3bcCF304d97242983F1e9B5Ad6F30";

// Addresses from hardhat default ones to allow easier tests

const Payees = [ // must fit 00_deploy.shares
    "0xfB7e9E883629eb0D4691D4Dc240b9c57A38888B4", // salty payees wallet
    "0xc1E6e63BbF402D3Ba812784D9E1b692130Ac61bA", // enor
    "0xaDC2cdCEcD0d45033acc62788670C55D45764d24", // 1Frey payess wallet

];

// ["0xfB7e9E883629eb0D4691D4Dc240b9c57A38888B4","0xc1E6e63BbF402D3Ba812784D9E1b692130Ac61bA","0xaDC2cdCEcD0d45033acc62788670C55D45764d24"]
const Addresses = [
    "0x24C835D252Dd8FA19242b7b74A094385f14Beb0f", // supply 
    "0xf128b6Ba7db8532Fa1d98BF2C31fC843B2882605", // futurUsePool 
    "0xAB3b24BA4c5911366C59cC870FAcC25B6ea3a053", // distributionPool 
    "0x15B72F2F0cd37fAde6c734E72485dE0909B1e2A8", // lp pool provider
    "0xfB7e9E883629eb0D4691D4Dc240b9c57A38888B4", // salty payees wallet
    "0xc1E6e63BbF402D3Ba812784D9E1b692130Ac61bA", // enor
    "0xaDC2cdCEcD0d45033acc62788670C55D45764d24", // 1Frey payess wallet

];


// ["0x24C835D252Dd8FA19242b7b74A094385f14Beb0f","0xf128b6Ba7db8532Fa1d98BF2C31fC843B2882605","0xAB3b24BA4c5911366C59cC870FAcC25B6ea3a053","0x15B72F2F0cd37fAde6c734E72485dE0909B1e2A8","0xfB7e9E883629eb0D4691D4Dc240b9c57A38888B4","0xc1E6e63BbF402D3Ba812784D9E1b692130Ac61bA","0xaDC2cdCEcD0d45033acc62788670C55D45764d24"]


module.exports = {
    Iterable,
    Reward,
    Token,
    JoeRouter,
    Payees,
    Addresses,
    Nft,
    Dai,
    PolarWLsale,
    PolarPUBsale
}