# Business Continuity and Disaster Recovery

## Design Consideration

- Determine the Recovery Time Objective (RTO) and Recovery Point Objective (RPO) for the APIM instance(s) that we want to protect and the value chains they support (consumers &amp; providers). Consider the feasibility of deploying fresh instances or having a hot / cold standby.
- APIM supports multi zone and multi region deployments, based on the requirements these could be enabled just one or both.
- Failover could be automated
  - Multi AZ automatically fails over,
  - Multi region will require a DNS based GLB such as Traffic manager to fail over.
- APIM can be [backed up using its Management REST API](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-disaster-recovery-backup-restore#calling-the-backup-and-restore-operations). Backups expire after 30 days. Be aware of [what APIM does not back up](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-disaster-recovery-backup-restore#what-is-not-backed-up)

## Design Recommendation

- Use automated DevOps pipelines to run backups
- Decide on whether [multi-region deployment](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-deploy-multi-region) is required
