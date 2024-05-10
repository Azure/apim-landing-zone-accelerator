# Load balancing across PAYG, PTU instances

## Capability

There are 2 different flavours of load balancing implemented: simple round robin and weighted round robin.

## How the policy works

### Simple Round Robin

- All the pool of endpoints are defined as an array.
- Each time a request is received the counter is incremented and persisted
- The counter value is used to select the endpoint from the array (using `random_value % backend_count`).
- The selected endpoint is then used to route the request.

### Weighted Round Robin

- All the pool of endpoints are defined as an `JArray` along with the weights for each endpoint.
- A random number is generated from 0 to the sum of all the weights.
- The endpoint is selected based on the random number generated, which is then used to route the request.
- There is no persistence of the counter in this case.