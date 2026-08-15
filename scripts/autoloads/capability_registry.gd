extends Node

signal capability_changed(
	capability: StringName,
	is_active: bool
)

var _providers_by_capability: Dictionary = {}


func register_provider(
	capability: StringName,
	provider: Node
) -> void:
	if not is_instance_valid(provider):
		push_warning("Cannot register an invalid provider.")
		return

	var was_active := has_capability(capability)
	var provider_id := provider.get_instance_id()
	var providers: Dictionary

	if _providers_by_capability.has(capability):
		providers = _providers_by_capability[capability]
	else:
		providers = {}

	providers[provider_id] = true
	_providers_by_capability[capability] = providers

	var is_active := has_capability(capability)

	if was_active != is_active:
		capability_changed.emit(capability, is_active)


func unregister_provider(
	capability: StringName,
	provider: Node
) -> void:
	if not _providers_by_capability.has(capability):
		return

	if not is_instance_valid(provider):
		push_warning("Cannot unregister an invalid provider.")
		return

	var was_active := has_capability(capability)
	var provider_id := provider.get_instance_id()
	var providers: Dictionary = \
		_providers_by_capability[capability]

	providers.erase(provider_id)

	if providers.is_empty():
		_providers_by_capability.erase(capability)
	else:
		_providers_by_capability[capability] = providers

	var is_active := has_capability(capability)

	if was_active != is_active:
		capability_changed.emit(capability, is_active)


func has_capability(capability: StringName) -> bool:
	if not _providers_by_capability.has(capability):
		return false

	var providers: Dictionary = \
		_providers_by_capability[capability]

	return not providers.is_empty()


func get_provider_count(capability: StringName) -> int:
	if not _providers_by_capability.has(capability):
		return 0

	var providers: Dictionary = \
		_providers_by_capability[capability]

	return providers.size()
