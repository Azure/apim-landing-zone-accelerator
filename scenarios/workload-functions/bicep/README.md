# Scenario 2: Azure API Management - Azure Functions as backend  [Bicep]

This is the Bicep-based deployment guide for [Scenario 2: Azure API Management - Azure Functions as backend](../README.md).

## Prerequisites

This scenario requires the completion of the [Azure API Management - Secure Baseline](../apim-baseline/README.md) scenario.

## Steps

Run the following command to deploy the scenarios

```bash
./scripts/bicep/deploy-workload-function.sh
```

Test the hello api using hte generated command from the output

## Troubleshooting

If you see the message `-bash: ./deploy-workload-function.sh: /bin/bash^M: bad interpreter: No such file or directory` when running the script, you can fix this by running the following command:

   ```bash
    sed -i -e 's/\r$//' deploy-workload-function.sh
   ```
