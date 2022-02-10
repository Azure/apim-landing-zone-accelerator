# Enterprise-Scale-APIM Terraform Reference Implementation

## Folder Structure 

```
.
└──reference-implementations/AppGW-IAPIM-Func
    ├── terraform
    │   ├── backend
    │   ├── shared
    │   ├── networking
    │   ├── apim
    │   └── gateway
    ├── backend.tf
    ├── main.tf
    ├── variables.tf
    └── outputs.tf

```
## Naming convention

resource_suffix = ${workloadName}-${environment}-${location}-001

_Resource Group_

    rg-<module>-${resource_suffix} [e.g. rg-shared-apidemo-dev-eastus-001]

_Resource Name Example_

    apim = apim-${resource_suffix}
    app_insights = appi-${resource_suffix}