# realize_infrastructure_chassis_resources

Realization grain for the first `infrastructure-resource-provisioning` slice.

Current scope:

- shared chassis Power policy creation or reconciliation
- shared chassis Thermal policy creation or reconciliation
- one shared chassis profile template
- one derived chassis profile per discovered chassis target
- profile assignment to chassis
- deploy trigger only for derived profiles with pending-change semantics

Current async model:

- use `ConfigContext.ConfigState` as the primary profile-state signal
- use `ConfigContext.InconsistencyReason` as a supplemental pending-change signal
- treat workflow references as optional debug information, not as the base contract

Current lifecycle boundary:

- real resolver input
- real chassis discovery input
- real remote create or reconcile behavior for apply-mode runs
- destroy behavior remains deferred for later coordinated lifecycle work
