# Load balancing across PAYG, PTU instances

## Capability

API Management supports the following load balancing options for backend pools:

- *Round-robin:* By default, requests are distributed evenly across the backends in the pool.
- *Weighted*: Weights are assigned to the backends in the pool, and requests are distributed across the backends based on the relative weight assigned to each backend. Use this option for scenarios such as conducting a blue-green deployment.
- *Priority-based:* Backends are organized in priority groups, and requests are sent to the backends in order of the priority groups. Within a priority group, requests are distributed either evenly across the backends, or (if assigned) according to the relative weight assigned to each backend.

## Examples

### Managing spikes with PAYG

The priority based load balancing policy can be used to manage spikes in traffic by routing traffic to PAYG endpoints when a PTU is out of capacity.
