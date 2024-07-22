# Rate limiting using Tokens consumed per request

In Azure OpenAI, the rate limiting policy is based on the number of tokens consumed by the requests. In this example, there are samples of simple rate limiting by tokens and adaptive rate limiting scenarios.

## Rate limiting by tokens

Rate limiting by tokens is implemented in 2 ways here. One using `azure-openai-token-limit` and the other using `rate-limit-by-key`

1. Policy reference: [`rate-limiting-by-tokens.xml`](./rate-limiting-by-tokens.xml)

    In MSFT build 2024, a new policy to rate limit by tokens for both streaming and non-streaming Azure OpenAI endpoints was launched. [This policy](https://learn.microsoft.com/en-us/azure/api-management/azure-openai-token-limit-policy) allows you to set rate limits based on the number of tokens consumed by the requests.

2. Policy reference: [`rate-limiting-workaround.xml`](./rate-limiting-workaround.xml)

   In scenarios, where the new rate limiting policy is not available, or if you are interacting with the non AOAI endpoints, it's worth considering the existing rate limiting policy in APIM.

   **Example scenarios**

   - Rate limiting a DallE endpoint with the number of images. The request to the DallE endpoint, will contain the number of images that needs to be returned in the response. This information can be parsed and can be used to increment the counter.
   - Rate limiting a non Azure OpenAI endpoint, where the response structure contains the token usage but in a different format.

    **Caveats**

   - This policy only applies to non-streaming requests.
   - It operates reactively, meaning it doesn't preemptively calculate tokens but instead waits for requests to breach the rate limit before blocking subsequent requests.

## Adaptive rate limiting

Policy reference: [`adaptive-rate-limiting.xml`](./adaptive-rate-limiting.xml)

In this setup, multiple services have their own rate limits. They start with default limits but can increase them dynamically within a set maximum if there's spare capacity due to low usage by other services.

**Explanation**
   The rate-limit-by-key policy in Azure API Management (APIM) is a powerful tool for controlling access to your APIs based on the number of tokens consumed. Here's a step-by-step breakdown of how it operates:

   1. **Token Consumption**: When a client makes a request to your API, the response includes information about the tokens consumed by that specific request. These tokens represent the resources utilized by the request, such as data transfer or processing.
   2. **Incrementing Rate Limit Counters**: The policy extracts the token consumption data from the response and increments the corresponding rate limit counters. These counters track the usage of resources and enforce the defined rate limits.
   3. **Global Rate Limit Counter**: In this example, there's a global rate limit counter set to the maximum rate limit initially. With each request, this counter decreases based on the tokens consumed. It resets at regular intervals, typically every 60 seconds, ensuring that the rate limits are enforced consistently over time.
   4. **Dynamic Local Counters**: Alongside the global counter, there are dynamic local counters (triggered for specific request if the conditions are met) with different default rate limits. These counters can be adjusted based on the availability of the global rate limit counter. If there's spare capacity due to low usage by other services, these local counters can increase within a set maximum threshold, allowing services to temporarily access more resources.
