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

resourceSuffix = ${workloadName}-${environment}-${location}-001

_Resource Group_

    rg-<module-name>-${resourceSuffix} [e.g. rg-shared-apidemo-dev-eastus-001]

_Resource Name Example_

    apim = apim-${resourceSuffix}
    app_insights = appi-${resourceSuffix}