### Ownership
I'm using OpenZeppelin's `Ownable`, so I could transfer the contract to the other owner in future. It also has convenient functions and modifiers to check if the call performed by the owner of the contract.

### Restricting access
I'm using modifiers `onlyIssuer` and `onlySubmitter` to restrict access to particular actions. Only bounty's issuer can manage the bounty status and accept/reject submissions. And submission can be created by anybody with exception of the bounty's issuer.

### Circuit Breaker
I'm using OpenZippelin's `Pausable` to be able to halt contract's functions if needed. `whenNotPaused` modifier applied to all functions that are changing contract's state.

### Getter methods and handy mappings
Mappings `bountySubmissions`, `userBounties` and `userSubmissions` making it easy to access particular sets of bountites/submissions. In case when we need to output these sets of entities (in UI), we just need to provide two functions: one to get a total amount of entities in the set (e.g. getCountMyBounties()) and the other to iterate over the set with sequential key (e.g. getMyBounty(uint _index)).

### Checks-Effects-Interactions pattern
I'm checking the input data and the current state before performing any actions in the function. I'm making changes to the state only when made sure it's safe to do that. And any interactions (e.g. funds transfer) always has to be performed last.