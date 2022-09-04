import StarNotaryArtifact from "../../build/contracts/StarNotary.json" assert { type: "json" };

const App = {
    web3: null,
    account: null,
    meta: null,

    connectMetaMask: async function () {
        // best practice is to connect MetaMask on a click, not on page load
        if (window.ethereum) {
            App.web3 = new Web3(window.ethereum);
            let mm_accs = await App.web3.eth.requestAccounts();
            console.log(mm_accs);
        } else {
            console.warn(
                "No web3 detected. Falling back to HTTP://127.0.0.1:7545. Remove this fallback when deploying live"
            );
            App.web3 = new Web3(
                new Web3.providers.HttpProvider("HTTP://127.0.0.1:7545")
            );
        }
        App.start();
    },

    start: async function () {
        const { web3 } = this;

        try {
            // get contract instance
            const networkId = await web3.eth.net.getId();
            const deployedNetwork = StarNotaryArtifact.networks[networkId];
            this.meta = new web3.eth.Contract(
                StarNotaryArtifact.abi,
                deployedNetwork.address
            );

            // get accounts
            const accounts = await web3.eth.getAccounts();
            this.account = accounts[0];
        } catch (error) {
            console.error("Could not connect to contract or chain.");
        }
    },

    setStatus: function (message) {
        const status = document.getElementById("status");
        status.innerHTML = message;
    },

    createStar: async function () {
        const { createStar } = this.meta.methods;
        const name = document.getElementById("starName").value;
        const id = document.getElementById("starId").value;
        await createStar(name, id).send({ from: this.account });
        App.setStatus("New Star Owner is " + this.account + ".");
    },

    // Implement Task 4 Modify the front end of the DAPP
    lookUp: async function () {
        const { lookUptokenIdToStarInfo } = this.meta.methods;
        let tokenId = document.getElementById("lookid").value;
        let starName = await lookUptokenIdToStarInfo(tokenId).call({
            from: this.account,
        });
        App.setStatus(`Star Name for token ID ${tokenId} is: ` + starName);
    },
};

window.App = App;
