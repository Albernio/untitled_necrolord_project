extends Node

## Emitted when a capability changes between active and inactive.
##
## `capability` identifies the affected power, such as "bone_bolt".
## `is_active` is true when at least one provider remains operational.
signal capability_changed(
	capability: StringName,
	is_active: bool
)

# Stores every registered provider grouped by capability.
#
# Example:
# {
#     "bone_bolt": {
#         forge_instance_id: true
#     }
# }
var _providers_by_capability: Dictionary = {}

## Registers a node as a provider of a capability.
##
## Registering the same node more than once does not create duplicates.
## The signal is emitted only if the capability changes from inactive
## to active.
func register_provider(
	capability: StringName,
	provider: Node
) -> void:
	# Reject deleted, missing, or otherwise invalid nodes.
	if not is_instance_valid(provider):
		push_warning("Cannot register an invalid provider.")
		return

	# Remember whether the capability was active before registration.
	var was_active := has_capability(capability)

	# Every Godot object has a unique instance ID.
	# We use it to prevent duplicate provider registrations.
	var provider_id := provider.get_instance_id()

	# This dictionary will contain all providers for this capability.
	var providers: Dictionary

	# Reuse the existing provider dictionary when one already exists.
	if _providers_by_capability.has(capability):
		providers = _providers_by_capability[capability]
	else:
		# This is the first provider registered for this capability.
		providers = {}

	# Add this provider. Assigning the same ID again has no effect
	# on the total number of entries.
	providers[provider_id] = true

	# Store the updated provider dictionary.
	_providers_by_capability[capability] = providers

	# Check whether the capability is now active.
	var is_active := has_capability(capability)

	# Notify listeners only when the overall active state changed.
	#
	# Adding the first provider changes false to true and emits.
	# Adding another provider while already active does not emit.
	if was_active != is_active:
		capability_changed.emit(capability, is_active)


## Removes a node as a provider of a capability.
##
## The capability remains active if another registered provider still
## exists. The signal is emitted only if removing this provider changes
## the capability from active to inactive.
func unregister_provider(
	capability: StringName,
	provider: Node
) -> void:
	# Nothing needs to be removed if this capability is unknown.
	if not _providers_by_capability.has(capability):
		return

	# Reject deleted, missing, or otherwise invalid nodes.
	if not is_instance_valid(provider):
		push_warning("Cannot unregister an invalid provider.")
		return

	# Remember whether the capability was active before removal.
	var was_active := has_capability(capability)

	# Obtain the same unique ID used during registration.
	var provider_id := provider.get_instance_id()

	# Retrieve all providers currently supplying this capability.
	var providers: Dictionary = \
		_providers_by_capability[capability]

	# Remove this provider.
	# Dictionary.erase() safely does nothing if the ID is absent.
	providers.erase(provider_id)

	# Remove the entire capability entry when no providers remain.
	if providers.is_empty():
		_providers_by_capability.erase(capability)
	else:
		# Otherwise, store the remaining providers.
		_providers_by_capability[capability] = providers

	# Check whether the capability is still active.
	var is_active := has_capability(capability)

	# Notify listeners only when removing the provider caused the
	# capability to become inactive.
	if was_active != is_active:
		capability_changed.emit(capability, is_active)


## Returns true when at least one node currently provides the capability.
##
## Example:
## `CapabilityRegistry.has_capability(&"bone_bolt")`
func has_capability(capability: StringName) -> bool:
	# An unregistered capability cannot be active.
	if not _providers_by_capability.has(capability):
		return false

	# Retrieve the providers registered for this capability.
	var providers: Dictionary = \
		_providers_by_capability[capability]

	# The capability is active when the provider dictionary is not empty.
	return not providers.is_empty()


## Returns the number of nodes currently providing a capability.
##
## This is useful for debugging and for mechanics that may scale with
## the number of surviving provider buildings.
func get_provider_count(capability: StringName) -> int:
	# An unknown capability has no providers.
	if not _providers_by_capability.has(capability):
		return 0

	# Retrieve all registered providers.
	var providers: Dictionary = \
		_providers_by_capability[capability]

	# Each dictionary entry represents one unique provider node.
	return providers.size()
