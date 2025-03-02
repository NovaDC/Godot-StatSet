@tool

class_name HiddenStatsTools

#TODO once novatools are updates, use that instead of these

static func instaniatae_named(name:String) -> Object:
	if ClassDB.class_exists(name) and ClassDB.is_class_enabled(name):
		return ClassDB.instantiate(name)
	
	var found := ProjectSettings.get_global_class_list().filter(func(d): return d["class"] == name)
	if found.size() == 1: #its non ambigous where this class is defined... (even though yes godot wont allow it to happen, jsut for safety)
		var candidate:String = found[0]["path"]
		if ResourceLoader.exists(candidate, "Script"):
			name = candidate
	
	if ResourceLoader.exists(name, "Script"):
		var loaded := load(name)
		if loaded != null:
			return loaded.new()

	if ResourceLoader.exists(name, "PackedScene"):
		var loaded := load(name)
		if loaded != null and loaded.can_instantiate():
			return loaded.instantiate()

	return null

# Note when both include scrit paths and include script class names are set, the script path and name for the exact same script will be included duplicitously!
static func get_classes_inheriting(name:String, include_script_paths := false, include_script_class_names := true) -> PackedStringArray:
	var found := ClassDB.get_inheriters_from_class(name)
	if name not in found:
		found.append(name)
	var amount_added:int = found.size()
	while amount_added > 0: #we dont knwo the order these scripts are comming in, and we want to get the inheritors recursivley...
		amount_added = 0
		for d in ProjectSettings.get_global_class_list():
			if d["base"] in found:
				var added := false
				if include_script_paths and d.has("path") and d["path"] not in found:
					found.append(d["path"])
					added = true
				if include_script_class_names and d.has("class") and d["class"] not in found:
					found.append(d["class"])
					added = true
				if added:
					amount_added += 1
	while found.find(name) > -1:
		found.remove_at(found.find(name))
	return found

static func get_class_name(object:Object) -> String: #get the string of the name this instan class is of
	var script:Script= object.get_script()
	if script != null:
		var script_name := script.get_global_name()
		if not script_name.is_empty():
			return script_name
	return object.get_class()

static func object_signal_unhook(object:Object, signal_mappings:Dictionary, strict := false, null_unsets := true) -> bool:
	if object == null:
		return false
	
	var any_unset := false
	
	for sig_name in signal_mappings.keys():
		if sig_name is Signal:
			sig_name = sig_name.get_name()
		if not object.has_signal(sig_name):
			assert(not strict, "Signal named %s not found on object %s" % [sig_name, object])
		else:
			var callable_list = null
			if signal_mappings[sig_name] is Callable:
				callable_list = [signal_mappings[sig_name]]
			elif signal_mappings[sig_name] is Array:
				callable_list = signal_mappings[sig_name]
			
			if callable_list == null:
				if not null_unsets:
					continue
				for c in object.get_signal_connection_list(sig_name).map(func (d): return d["callable"]):
					any_unset = true
					object.disconnect(sig_name, c)
			
			for callable in callable_list:
				callable = callable as Callable
				if callable != null and object.is_connected(sig_name, callable):
					any_unset = true
					object.disconnect(sig_name, callable)
	
	return any_unset

static func object_signal_hook(object:Object, signal_mappings:Dictionary, strict := false) -> bool:
	if object == null:
		return false
	
	var any_set := false
	
	for sig_name in signal_mappings.keys():
		if sig_name is Signal:
			sig_name = sig_name.get_name()
		if not object.has_signal(sig_name):
			assert(not strict, "Signal named %s not found on object %s" % [sig_name, object])
		else:
			var callable_list = null
			if signal_mappings[sig_name] is Callable:
				callable_list = [signal_mappings[sig_name]]
			elif signal_mappings[sig_name] is Array:
				callable_list = signal_mappings[sig_name]
			
			if callable_list == null:
				continue
			
			for callable in callable_list:
				callable = callable as Callable
				if callable != null and not object.is_connected(sig_name, callable):
					any_set = true
					object.connect(sig_name, callable)
	
	return any_set

static func object_signal_transfer(old_object:Object, new_object:Object, signal_mappings:Dictionary, strict := false) -> bool:
	var any_changed := false
	if object_signal_unhook(old_object, signal_mappings, strict, false):
		any_changed = true
	if object_signal_hook(new_object, signal_mappings, strict):
		any_changed = true
	return any_changed
