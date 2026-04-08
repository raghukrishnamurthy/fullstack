# Nested Blueprint Chaining Experiment

This experiment exists to answer one focused Torque question:

- can one blueprint be used as a grain inside another blueprint, with stable
  input and output handoff?

It is intentionally small so that we learn the nesting syntax and handoff
behavior before chaining the real infrastructure phase blueprints.

## Contract Choice

This experiment is intentionally JSON-string-first.

That means:

- parent blueprint inputs use JSON-formatted strings
- child blueprint outputs use JSON-formatted strings
- nested blueprint handoff is tested using string-safe JSON payloads

This matches the Torque-facing contract style we care about most.

## Experiment Blueprints

- [experiment-blueprint-chain-producer.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/blueprints/experiment-blueprint-chain-producer.yaml)
- [experiment-blueprint-chain-consumer.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/blueprints/experiment-blueprint-chain-consumer.yaml)
- [experiment-blueprint-chain-parent.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/blueprints/experiment-blueprint-chain-parent.yaml)

## Experiment Flow

1. `experiment-blueprint-chain-producer`
   - accepts `deployment_json`, `platform_json`, and `name_prefix`
   - produces:
     - `phase_a_status`
     - `phase_a_payload_json`
     - `phase_a_summary_json`

2. `experiment-blueprint-chain-consumer`
   - accepts producer outputs
   - validates the JSON payload contract
   - produces:
     - `phase_b_status`
     - `phase_b_payload_json`
     - `phase_b_summary_json`

3. `experiment-blueprint-chain-parent`
   - uses both child blueprints as `kind: blueprint` grains
   - passes outputs from the first nested blueprint to the second
   - exports the chained outputs at the parent level

## Why This Shape

This test is small, but it exercises the exact patterns we care about for
later full-stack blueprint orchestration:

- nested blueprint grain syntax
- passing blueprint inputs into child blueprints
- exporting child blueprint outputs back to the parent
- handing one child blueprint output into another child blueprint input
- keeping child blueprints independently runnable
- using JSON-string contracts across blueprint boundaries

## Real-Phase Follow-On

If this experiment works cleanly in Torque, the next chaining experiment should
use the real phase blueprints:

- [infrastructure-network-provisioning-v1.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/blueprints/infrastructure-network-provisioning-v1.yaml)
- [infrastructure-domain-post-validation-v1.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/blueprints/infrastructure-domain-post-validation-v1.yaml)
- [infrastructure-resource-provisioning-v1.yaml](/Users/rkrishn2/Documents/Jarvis_IAC/blueprints/infrastructure-resource-provisioning-v1.yaml)

## Reference

Torque official doc used for the blueprint-grain syntax:

- [The Blueprint Grain | Torque](https://docs.qtorque.io/blueprint-designer-guide/blueprints/blueprint-grain)
