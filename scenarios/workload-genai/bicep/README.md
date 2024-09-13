# Scenario 3: Azure API Management - Gen AI Backend  [Bicep]

This is the Bicep-based deployment guide for [Scenario 3: Azure API Management - Gen AI Backend](../README.md).

## Prerequisites

This scenario requires the completion of the [Azure API Management - Secure Baseline](../../apim-baseline/README.md) scenario.

## Steps

Run the following command to deploy the scenarios

```bash
./scripts/bicep/deploy-workload-genai.sh
```

Test the hello api using hte generated command from the output

## Troubleshooting

If you see the message `-bash: ./deploy-workload-genai.sh: /bin/bash^M: bad interpreter: No such file or directory` when running the script, you can fix this by running the following command:

   ```bash
    sed -i -e 's/\r$//' deploy-workload-genai.sh
   ```
