# Business Continuity and Disaster Recovery
## Design Consideration
- What are the RTO and RPO for the impacted APIM instance(s) and the value chains they support (consumers & providers). Deploying a fresh instance runs through a lot of wall clock time (40-60 minutes) Having a cold standby might be beneficial.  
    - Will many teams move to the same region(s) once a disaster is declared?
        - Will they all use Azure DevOps to deploy (and thus create a large queue) of deployment jobs
- How is the fail-over orchestrated (and if so by whom)? 
    - Are consumers and providers aware or should this be transparent (from connectivity perspective, performance may be impacted)
- Is the failover manual or automated?
- Are multiple APIM gateway instances (already) deployed in different regions
- How to fail back when the disaster is relieved

