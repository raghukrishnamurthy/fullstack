# realize_and_deploy_infrastructure_domain_profiles

Domain-profile realization and deploy grain for
`infrastructure-network-provisioning`.

The first real implementation pass in this grain uses the tested
`domain_profile` flow as a coding reference for:

- switch cluster profile creation
- A/B switch profile creation
- policy-bucket attachment
- FI assignment
- deploy-needed checks
- deploy and wait

The current implementation assumes a single FI-pair domain per deployment while
the broader multi-domain naming model is still being refined.
