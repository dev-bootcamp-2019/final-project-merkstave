# Bounty dApp
`Job poster` creates bounty, sets reward and activates bounty. Accepting/rejecting submissions.
`Bounty hunter` makes submission for the bounty and gets paid if it's accepted by the job poster.

## UI
Very generic proof-of-concept interface based on Drizzle box.
Known issue: if you switch accounts in Metamask, you'll need to refresh page to make forms work again.

## Requirements
Truffle v5.0.2 (core: 5.0.2)
Solidity v0.5.0 (solc-js)
Ganache CLI v6.1.8 (ganache-core: 2.2.1)
Node v10.15.0

## Setting up local dev environment
Install node on your system. Then `npm install -g truffle` and `npm install -g ganache-cli`.

Fetch back-end dependencies in the project root:
```
npm install
```

Then fetch dependencies for front-end:
```
cd app
npm install
```

## Running local dev environment
Start Ganache
```
ganache-cli
```

Move to the project root and run truffle cmds:
```
truffle compile
truffle migrate
truffle test
```

Then go to front-end dir and start development web-server:
```
cd app
npm start
```