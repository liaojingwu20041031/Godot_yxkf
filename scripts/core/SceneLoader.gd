extends Node

signal scene_loaded
signal scene_loading(progress: float)

var is_loading: bool = false
var loading_path: String = ""

func load_scene(path: String):
	if is_loading:
		return
	is_loading = true
	loading_path = path
	ResourceLoader.load_threaded_request(path)

func _process(delta):
	if not is_loading:
		return

	var progress = []
	var status = ResourceLoader.load_threaded_get_status(loading_path, progress)

	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			scene_loading.emit(progress[0])
		ResourceLoader.THREAD_LOAD_LOADED:
			var scene = ResourceLoader.load_threaded_get(loading_path)
			get_tree().change_scene_to_packed(scene)
			is_loading = false
			loading_path = ""
			scene_loaded.emit()
		ResourceLoader.THREAD_LOAD_FAILED:
			is_loading = false
			loading_path = ""
			push_error("Failed to load scene: " + loading_path)

func load_scene_immediate(path: String):
	get_tree().change_scene_to_file(path)
