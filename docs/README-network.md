# Devon APIM Sandbox – Network Topology

## What this diagram shows

| Element+++                                      | Purpose+                                          | CAF Design Area+                |
| ----------------------------------------------- | ------------------------------------------------- | ------------------------------- |
| **VNet + Internal Subnet**+               | Hosts the APIM instance in*internal*mode.       | Network topology & connectivity |
| **Azure API Management (Developer SKU)**+ | API gateway under test; no public IP.             | Platform automation             |
| **Application Gateway (WAF)**+            | Optional ingress controller for external clients. | Security                        |
| **Azure Key Vault (private endpoint)**+   | Stores certs, Back-end secrets.                   | Security & governance           |
| **Log Analytics + Application Insights**+ | Central diagnostics & telemetry.                  | Operations baseline             |
| **Private DNS Zone**+                     | Resolvesto private IP.                            | Network topology                |

## Next actions

1. Deploy sandbox via Landing-Zone Accelerator (see `<span data-slate-node="text"><span data-slate-leaf="true"><span data-slate-string="true">/docs/README-sandbox.md</span></span></span>` ).
2. Validate private-link DNS resolution inside VNet.
3. Add Functions or Storage back-end into “Optional Future Zone” when required.
