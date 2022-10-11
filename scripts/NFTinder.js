const hre = require("hardhat");
const ContractJson = require("../artifacts/contracts/LensInteractions.sol/LensInteractions.json");
// The ABI is very important -- it's the interface to your contract, including
// the different available functions that are exposed for other contracts,
// accounts, etc. to call.
const abi = ContractJson.abi;

async function main() {
    // Notice that we're using process.env.ALCHEMY_API_KEY to load an
    // environment variable. If you are seeing errors, make sure to go
    // back to Step 12 and 13 to set up the dotenv dependency and .env
    // file correctly!
    const alchemy = new hre.ethers.providers.AlchemyProvider(
        'maticmum',
        process.env.ALCHEMY_API_KEY
    );
    // We're using the same wallet private key for the wallet that you
    // created in Step 6. 
    const userWallet = new hre.ethers.Wallet(process.env.PRIVATE_KEY, alchemy);

    // Get the deployed contract. We need both the specific CONTRACT_ADDRESS
    const Greeter = new hre.ethers.Contract(
        process.env.CONTRACT_ADDRESS,
        abi,
        userWallet
    )

    // We're going to issue two write-transactions to modify the state
    // of the Polygon blockchain via our Greeter smart contract.
    
    // The first transaction sets a new greeting with setGreeting, and then
    // waits for the transaction to be mined before doing a sanity
    // check and checking the new greeting state.
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
});