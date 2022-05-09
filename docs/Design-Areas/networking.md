# Network Topology and Connectivity

## Design Considerations

- Decide if the APIs are accessible externally or internally
- Decide if there should be multiple gateways deployed (and how these are load balanced) e.g. by using AppGateway
- Decide if the network setup requires cross region connectivity
- Decide if private end point connectivity is required
- Decide how to connect to external (3rd party) workloads
- Decide whether [virtual network connection](https://docs.microsoft.com/en-us/azure/api-management/api-management-using-with-vnet?tabs=stv2#enable-vnet-connection) is required and the access type for virtual network connection ([external](https://docs.microsoft.com/en-us/azure/api-management/api-management-using-with-vnet?tabs=stv2#enable-vnet-connection) or [internal](https://docs.microsoft.com/en-us/azure/api-management/api-management-using-with-internal-vnet)).
- Decide whether connectivity to on-premises or multi-cloud environments is required.
- Decide if [multi-region deployment](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-deploy-multi-region) is required to service geographically distributed API consumers.
- Consider using a load balancing solution such as [Application Gateway](https://docs.microsoft.com/en-us/azure/application-gateway/overview) or [Azure Front Door](https://docs.microsoft.com/en-us/azure/frontdoor/front-door-overview).

## Design Recommendations

- Use [Application Gateway for external access of an internal APIM instance](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-integrate-internal-vnet-appgateway)
- Use Azure Front Door for multi-region deployment
- Ensure [required ports](https://docs.microsoft.com/en-us/azure/api-management/api-management-using-with-vnet?tabs=stv2#required-ports) (ie. 80, 443) are open between the calling client and the backend APIM gateway
- Deploy the gateway in a vnet to allow access to backend services in the network
- VNet peering provides great performance in a region but has a scalability limit of max 500 networks, if you require more workloads to be connected, use [hub spoke](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke?tabs=cli) or PLE
- When used in internal mode, make it easy for consumers to onboard (connect) to you APIM platform, hence provide an open network path (either through upstream hub) or NSG setup to remove friction when connecting to APIM
