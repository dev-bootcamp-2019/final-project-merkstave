### Integer overflow/underflow protection
SafeMath library provides protection against overflow/underflow attacks.

### Reentrancy protection & atomic operations
In general whenever I perform any changes on the state, I'm avoiding use of references to the contract's state storage by introducing temporary variables. That way I'm sure that change is atomic and performed with local variables. This is especially important whenever a call to other address is involved (e.g. operations with balance and transfer of funds).

### Safety against Block Gas Limit attacks
I'm not using any loops in the contract to avoid unbound iteration. Access to arrays in mappings is limited to using only static keys without any iteration in the functions.