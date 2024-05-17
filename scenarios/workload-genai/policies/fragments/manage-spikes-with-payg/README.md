# Managing spike across PTU instances using PAYG deployments.

## Capability

In this capability, the traffic is routed to the PTU1 instance as the primary backend. When the PTU1 instance returns a 429 Retry response the request is re-submitted to the PAYG1 instance.

## How the policy works

- This capability leverages the APIM [`retry` policy](https://learn.microsoft.com/en-us/azure/api-management/retry-policy)

- The segment in the retry policy will execute **at least once** and when the response is null (request entering first time into the retry segment) then it will be routed to the PTU instance.

- If the PTU instance responds back with 429, then the request will be routed to the PAYG instance.
