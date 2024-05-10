# GenAI Gateway using APIM

- [GenAI Gateway using APIM](#genai-gateway-using-apim)
  - [Introduction](#introduction)
  - [Getting Started](#getting-started)
    - [Pre-requisites](#pre-requisites)
    - [Deploy GenAI Workload](#deploy-genai-workload)
  - [Architecture Diagram](#architecture-diagram)
  - [GenAI Gateway capabilities](#genai-gateway-capabilities)


## Introduction

A "GenAI Gateway" serves as an intelligent interface/middleware that dynamically balances incoming traffic across backend resources to achieve optimizing resource utilization. In addition to load balancing, GenAI Gateway can be equipped with extra capabilities to address the challenges around billing, monitoring etc.

To read more about considerations when implementing a GenAI Gateway, see [this article](https://learn.microsoft.com/ai/playbook/technology-guidance/generative-ai/dev-starters/genai-gateway/).

This accelerator contains APIM policies showing how to implement different [GenAI Gateway capabilities](#gateway-capabilities) in APIM, along with code to enable you to deploy the policies and see them in action.

## Getting Started

### Pre-requisites

[Follow this instructions](./../readme.md) and setup APIM baseline.

### Deploy GenAI Workload

```bash
./scripts/deploy-apim-genai.sh
```

## Architecture Diagram

> TODO: Show an architectural diagram containing EventHub, Private OpenAI endpoints, APIM.

## GenAI Gateway capabilities

This repo currently contains the policies showing how to implement these GenAI Gateway capabilities:

| Capability                                                                      | Description                                                             |
| ------------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| [Load balancing (round-robin)](./capabilities/load-balancing-round-robin/Readme.md) | Load balance traffic across PAYG endpoints using round-robin algorithm. |
| [Managing spikes with PAYG](./capabilities/manage-spikes-with-payg/README.md) | Manage spikes in traffic by routing traffic to PAYG endpoints when a PTU is out of capacity. |
| [Adaptive rate limiting](./capabilities/rate-limiting/README.md) | Dynamically adjust rate-limits applied to different workloads|
| [Tracking token usage](./capabilities/usage-tracking//README.md) | Record the token consumption for usage tracking and attribution|
