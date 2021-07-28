# Network Topology and Connectivity
## Design Considerations
- Decide if the Gateway should be deployed to an internal network 
- Decide if the APIs are accessible externally or internally
- Decide if there should be multiple gateways deployed (and how these are load balanced) e.g. by using AppGateway
- Decide if the network setup requires cross region connectivity
- Decide if private end point connectivity is required
- Decide how to connect to on-prem workloads
- Decide how to connect to external (3rd party) workloads
## Design Recommendations
- Deploy the gateway in a vnet to allow access to backend services in the network
- Consider deploying the APIM in internal network integrated with App Gateway for external access 
- VNet peering provides great performance in a region but has a scalability limit of max 500 networks, if you require more workloads to be connected, use hub spoke or PLE
- When used in internal mode, make it easy for consumers to onboard (connect) to you APIM platform, hence provide an open network path (either through upstream hub) or NSG setup to remove friction when connecting to APIM
