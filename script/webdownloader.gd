extends Node
#@onready var http=$"../HTTPRequest"
signal model_status
var download_num=0
var libs:Array
func download(link, path):
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(self._on_http_request_request_completed)

	http.set_download_file(path)
	var request = http.request(link)
	if request != OK:
		push_error("Http request error")
		
	

func is_exists(lib):
	return FileAccess.file_exists("user://%s"%lib)

func _ready():
	libs=["mobilefacenet.param",
	"mobilefacenet.bin",
	"RFB-320.bin",
	"RFB-320.param"
	]


func load_model():

	for lib in libs:
		print()
		if not FileAccess.file_exists("user://%s"%lib):
			download("http://192.168.1.115:5000/xiaozhi-godot-client/models/%s"%lib, "user://%s"%lib)
	if libs.all(is_exists):
		print("所有模型都已经加载")
		model_status.emit(true)
	
	
		


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != OK:
		push_error("Download Failed retry")
		$Timer.start(1)
		
	else:
		print("下载完成")
		download_num+=1
		if download_num>=libs.size():
			model_status.emit(true)
		
	pass # Replace with function body.


func _on_face_reg_ready() -> void:
	load_model()
	pass # Replace with function body.
