# Usage tracking of tokens

## Capability

In this setup, you can track the usage of your APIs by sending token usage data to Application Insights or Azure Event Hub. By adding custom dimension of SubscriptionId, TokenUsage, OperationName, RequestId in the Application Insights (or Event Hub), you can track the token usage by specific dimensions.

## Using Application Insights

In MSFT build 2024, a new policy to track the token usage as metric was launched. [This policy](https://learn.microsoft.com/en-us/azure/api-management/azure-openai-emit-token-metric-policy) allows APIM to log token count metrics (Total Tokens, Prompt Tokens and Completion Tokens) to the customer's Azure Application Insights metrics tied to the customer's APIM resource.

A KQL Query to list the token consumption by the subscription id is as follows:

```kql
customMetrics
| extend subId = tostring(parse_json(customDimensions).SubscriptionId)
| summarize totalValueSum = sum(valueSum) by name, subId

```

This policy supports streaming endpoints in Azure OpenAI.

## Using Azure Event Hub

### Azure EventHub over Custom Metrics to Azure Monitor

It is also possible to track the token consumption by sending the token count as a metrics to the Azure monitor.

With Azure EventHub adds the following advantages:

- It is possible to track some additional context (in form of text) other than just numbers like in metrics.
- The event streams will be near real time, in comparison to Azure monitor.
- Varied opportunities to consume the data from EventHub for further processing, like Azure Stream Analytics, Azure Functions, Logic Apps, etc.

### How the policy works

- Azure OpenAI response will contain the token usage data. This policy extracts the token usage data from the response and sends it to Azure Event Hub.
- This policy fragment needs to be included in the `outbound` section of the APIM policy.

### Caveats

- This policy only applies to non-streaming requests.