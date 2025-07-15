extends Node

const SERVER_URL = "ws://192.168.0.243:23333"

@onready var  _client:WebSocketClient = WebSocketClient.new()
var _session_id := "your_session_id"  # 替换为实际会话ID或动态生成
signal state
func _ready():
	# 连接信号
	_client.connection_established.connect(_on_connected)
	_client.connection_closed.connect(_on_closed)
	_client.connection_error.connect(_on_error)
	_client.data_received.connect(_on_data)
	
	# 初始化连接
	var err = _client.connect_to_url(SERVER_URL)
	if err != OK:
		push_error("Failed to connect to server")

func _process(delta):
	_client.poll()

# region 消息发送方法
func send_hello():
	var msg = {
		"type": "hello",
		"version": 1,
		"transport": "websocket",
		"audio_params": {
			"format": "opus",
			"sample_rate": 16000,
			"channels": 1,
			"frame_duration": 60
		}
	}
	_send_json(msg)

func send_listen(state: String, mode: String):
	var msg = {
		"type": "listen",
		"session_id": _session_id,
		"state": state,
		"mode": mode
	}
	_send_json(msg)

func send_abort(reason: String):
	var msg = {
		"type": "abort", 
		"session_id": _session_id,
		"reason": reason
	}
	_send_json(msg)

func send_wake_word(text: String):
	var msg = {
		"type": "listen",  # 根据协议要求使用 listen 类型
		"session_id": _session_id,
		"state": "detect",
		"text": text
	}
	_send_json(msg)

func send_iot(descriptors = null, states = null):
	var msg = {
		"type": "iot",
		"session_id": _session_id
	}
	if descriptors: msg["descriptors"] = descriptors
	if states: msg["states"] = states
	_send_json(msg)
# endregion

# region 网络事件处理
func _on_connected(protocol = ""):
	print("WebSocket connected")
	send_hello()

func _on_closed():
	print("Connection closed")

func _on_error():
	push_error("Connection error")

func _on_data():
	var data = _client.get_peer().get_packet().get_string_from_utf8()
	var json = JSON.parse_string(data)
	_handle_server_message(json)
# endregion

func _send_json(msg: Dictionary):
	var json_str = JSON.stringify(msg)
	_client.get_peer().put_packet(json_str.to_utf8_buffer())
	
func _send_data(msg:Dictionary):
	var data:PackedByteArray=JSON.to_native(msg.data)
	_client.send(data)
# 在UI按钮点击事件中调用
func _on_start_listen_button_pressed():
	send_listen("start", "manual")

func _on_stop_listen_button_pressed():
	send_listen("stop", "manual")

func _on_send_iot_state_pressed():
	var sample_state = {
		"temperature": 25.5,
		"humidity": 60
	}
	send_iot(null, sample_state)

func _handle_server_message(msg: Dictionary):
	match msg.get("type"):
		"hello": 
			state.emit("hello")
			print("Hello acknowledged:", msg)
		"listen":
			print("Listen status:", msg.get("status"))
		"abort":
			print("Abort acknowledged")
		"iot_response":
			print("IoT update received")
		_:
			print("Unknown message type:", msg)
