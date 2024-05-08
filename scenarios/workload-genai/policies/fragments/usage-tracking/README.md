# Usage tracking using Azure Event Hub

## Capability

In this setup, you can track the usage of your APIs by sending token usage data to Azure Event Hub. Message sent to event hub includes, SubscriptionId, TokenUsage, OperationName, RequestId.

### Azure EventHub over Custom Metrics to Azure Monitor

It is also possible to track the token consumption by sending the token count as a metrics to the Azure monitor.

But Azure EventHub adds the following advantages:

- It is possible to track some additional context (in form of text) other than just numbers like in metrics.
- The event streams will be near real time, in comparison to Azure monitor.
- Varied opportunities to consume the data from EventHub for further processing, like Azure Stream Analytics, Azure Functions, Logic Apps, etc.

## How the policy works

- Azure OpenAI response will contain the token usage data. This policy extracts the token usage data from the response and sends it to Azure Event Hub.
- This policy fragment needs to be included in the `outbound` section of the APIM policy.

### Caveats

- This policy only applies to non-streaming requests.
