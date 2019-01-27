### Integer overflow/underflow protection
SafeMath library provides protection against overflow/underflow attacks.

### Reentrancy protection & atomic operations
In general whenever I perform any changes on the state, I'm avoiding use of references to the state by introducing temporary variables. That way I'm sure that change is atomic and performed with static values. This is especially important whenever a call to other address is involved (e.g. operations with balance and transfer of funds).