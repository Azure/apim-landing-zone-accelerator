# Deploy APIM baseline

Update the [.env](./.env) file for the environment variables

```ini
AZURE_LOCATION='eastus'
RESOURCE_NAME_PREFIX='apimdemo'
ENVIRONMENT_TAG='dev'
RANDOM_IDENTIFIER=''
APPGATEWAY_FQDN='apim.example.com'
CERT_TYPE='selfsigned'
```

RANDOM_IDENTIFIER - If not specified, a random 3 character string will be generated and appended to the RESOURCE_NAME_PREFIX

CERT_TYPE can be either `selfsigned` or `custom`.

- selfsigned will create a self-signed certificate for the APPGATEWAY_FQDN
- custom will use an existing certificate in pfx format that needs to be available in the [certs](./bicep/gateway/certs) folder

Run the following command to deploy the APIM baseline

```bash
./scripts/deploy-apim-baseline.sh
```

Test the echo api using hte generated command from the output


# Deploy functions workload

Requires APIM baseline to be deployed

Run the following command to deploy the APIM baseline

```bash
./scripts/deploy-workload-function.sh
```

Test the hello api using hte generated command from the output


# Deploy openai workload

Requires APIM baseline to be deployed