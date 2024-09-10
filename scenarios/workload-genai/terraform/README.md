# Scenario 3: Azure API Management - Gen AI Backend  [Terraform]

This is the Terraform-based deployment guide for [Scenario 3: Azure API Management - Gen AI Backend](../README.md).

## Prerequisites

This scenario requires the completion of the [Azure API Management - Secure Baseline](../../apim-baseline/README.md) scenario ([using the terraform-based deployment](../../apim-baseline/terraform/README.md)).

## Steps

Run the following command to deploy the scenarios

```bash
./scripts/terraform/deploy-workload-genai.sh
```

Test the hello api using the generated command from the output

## Troubleshooting

If you see the message `-bash: ./deploy-workload-genai.sh: /bin/bash^M: bad interpreter: No such file or directory` when running the script, you can fix this by running the following command:

   ```bash
    sed -i -e 's/\r$//' deploy-workload-genai.sh
   ```
