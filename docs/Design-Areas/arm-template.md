---
title: generating and validating the ARM template
author: Cenk Caglar (cenkc@microsoft.com) github: cenkms
date: 04/14/2022
---

# Generating the ARM Template

## Process

When we developed this Accelerator using Bicep as an IaC, we considered couple of advantages of the Bicep, one of the main features are easily converting to ARM Templates.

During our deployment face, we added couple of Bicep validation / preflight checks that you can find in our [Action yaml file](https://github.com/Azure/apim-landing-zone-accelerator/blob/main/.github/workflows/es-apim.yml). If those validations passes without any errors, we are deploying the Bicep template. 

### ARM Template generation

If Bicep deploys without any error, we are starting to generate the ARM template as a next Job in GitHub Action.

```yaml
az bicep build --file main.bicep --outfile ../azure-resource-manager/apim-arm.json
```

### Storing the ARM Template

After ARM Template generated, we are creating a branch from the main branch and using the 'run_number' of GitHub Action, and pushing the ARM template to that branch.

Again, you can find the details in [Action yaml file](https://github.com/Azure/apim-landing-zone-accelerator/blob/main/.github/workflows/es-apim.yml)

## Generated ARM Template Validation

There are couple ways to **Validate** an ARM Template;

1. Syntax

2. Behavior

3. Result

4. Intent

5. Success

**Syntax**: For syntax check ```bicep build``` to that validation.

**Behavior**: Again Bicep is taking care of that part, we can implement arm-ttk however Bicep Product Group will implement the features in Bicep slowly,

**Result**: What does the deployment do or do not that may want to aware of. This part cannot be automated, so there is nothing to add as **Validation**

**Intent**: We can run what-if scenarios on the ARM Template however again, it will require human eye, cannot be automated.

**Success**: Since before ARM Template, Bicep template finished successfully (otherwise ARM Template generation step wouldn't work) so we are sure that ARM Template will work, so no need to add any validation on that.

## Result

As a result, since the ARM Template would be generated from the Bicep template, the requirement of the **Validating the ARM Template** is almost zero.
