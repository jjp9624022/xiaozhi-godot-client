extends Node2D


@onready var face_de = GodotUltraFace.new()
@onready var face_re = FaceRecognizer.new()
@onready var cam=WebcamCapture.new()
# 人脸数据库 {name: 特征向量}
var draw_faces = []
var known_faces = {
	"leweng": PackedFloat32Array([]),
	"yangye": PackedFloat32Array([])
}

# 摄像头相关
var camera:Sprite2D
var viewport
var viewport_texture
var timer

# 人脸检测参数
const RESIZE_WIDTH = 320
const RESIZE_HEIGHT = 240
const DETECTION_THRESHOLD = 0.7
const RECOGNITION_THRESHOLD = 0.75

func _ready():
	# 初始化模型
	#init_models()
	# 初始化摄像头
	init_camera()
	
	# 设置定时器处理帧
	timer = Timer.new()
	timer.wait_time = 1  # 100ms间隔
	timer.timeout.connect(_process_frame)
	add_child(timer)
	timer.start()

func init_models():
	
	var detect_param=OS.get_user_data_dir()+"/RFB-320.param"
	var detect_model=OS.get_user_data_dir()+"/RFB-320.bin"
	# 人脸检测模型初始化
	#var detect_param = get_app_dir().path_join("models/ultra/RFB-320.param")
	#var detect_model = get_app_dir().path_join("models/ultra/RFB-320.bin")
	var detect_ok = await face_de.init(detect_model, detect_param, RESIZE_WIDTH, RESIZE_HEIGHT, true)
	print("detect_param_path",detect_param)
	print("检测器加载状态: ", detect_ok)
	
	face_de.set_score_threshold(DETECTION_THRESHOLD)
	face_de.set_thread_num(4)
	var recog_param =OS.get_user_data_dir()+"/mobilefacenet.param"
	var recog_model =OS.get_user_data_dir()+"/mobilefacenet.bin"
	# 人脸识别模型初始化
	#var recog_param = get_app_dir().path_join("models/facenet/mobilefacenet.param")
	#var recog_model = get_app_dir().path_join("models/facenet/mobilefacenet.bin")
	var recog_ok = face_re.init(recog_model, recog_param, true)
	print("识别器加载状态: ", recog_ok)
	
	face_re.set_thread_num(2)
	
	# 构建人脸数据库（示例）
	build_face_database()
	init_camera()
func get_app_dir():
	if OS.has_feature("editor"):
		# 编辑器模式下返回项目根目录
		return ProjectSettings.globalize_path("res://")
	
	# 导出后返回可执行文件所在目录
	var exe_path = OS.get_executable_path().get_base_dir()
	
	
	# 处理 macOS .app 包的特殊情况
	if exe_path.ends_with(".app/Contents/MacOS/" + exe_path.get_file()):
		return exe_path.get_base_dir().get_base_dir().get_base_dir()
	
	return exe_path.get_base_dir()
# 构建人脸数据库（实际使用时需要替换为您的图片路径）
func build_face_database():
	var person1_img = preload("res://face/leweng.jpg").get_image()

	var person1_buffer = person1_img.save_jpg_to_buffer()
	known_faces["leweng"] = face_re.get_feature(person1_buffer)
	
	var person2_img = preload("res://face/yangye.jpg").get_image()
	var person2_buffer = person2_img.save_jpg_to_buffer()
	known_faces["yangye"] = face_re.get_feature(person2_buffer)
	print("数据库添加成功")
pass

func init_camera():
	cam.open_camera(1)
	if cam.is_open():
		print("摄像头已经成功打开")
	pass



func _process_frame():
	
	# 获取当前帧图像
	var img:Image =cam.get_frame()
	#print(img.get_data_size())
	if img==null:
		print("无法获取照片")
		return
	## 转换为JPEG缓冲区
	var jpeg_buffer = img.save_jpg_to_buffer()
	#print(jpeg_buffer.size())
	
	# 检测人脸
	var faces = face_de.detect_frome_jpeg_buffer(jpeg_buffer)
	#print("faces",faces)
	# 清除之前的绘制
	faces=faces.filter(func(number): return number.score>0.2)
	queue_redraw()

	
	
	# 处理检测到的人脸
	for face in faces:  # 每5个元素表示一个人脸
		var x = face.x1
		var y = face.y1
		var width = face.x2
		var height = face.y2
		var confidence = face.score
		
		# 创建人脸区域矩形
		var face_rect = Rect2i(x, y, width, height)
		
		# 裁剪人脸区域
		var face_img = img.get_region(face_rect)
		var face_buffer = face_img.save_jpg_to_buffer()
		
		# 提取特征
		var feature = face_re.get_feature(face_buffer)
		
		# 识别人脸
		var identity = "Unknown"
		var max_similarity = 0.0
		
		for name in known_faces:
			if known_faces[name].size() == 0:  # 跳过空特征
				continue
				
			var similarity = face_re.calcul_similar(feature, known_faces[name])
			if similarity > max_similarity and similarity > RECOGNITION_THRESHOLD:
				max_similarity = similarity
				identity = name
		
		# 存储绘制信息
		draw_faces.append({
			"rect": face_rect,
			"name": identity,
			"confidence": confidence,
			"similarity": max_similarity
		})
	

# 存储要绘制的人脸信息


func _draw():
	# 绘制检测结果
	for face in draw_faces:
		var rect = face["rect"]
		var name = face["name"]
		var confidence = face["confidence"]
		var similarity = face["similarity"]
		
		# 绘制人脸框
		draw_rect(rect, Color.GREEN, false, 2.0)
		
		# 绘制识别结果
		var text = "%s\nDet: %.1f%%\nRec: %.1f%%" % [
			name, 
			confidence * 100, 
			similarity * 100
		]
		
		var text_position = Vector2(rect.position.x, rect.position.y - 60)
		draw_string(ThemeDB.fallback_font, text_position, text, 
				   HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.YELLOW)

# 清理资源
func _exit_tree():
	pass
	#if face_de:
		#face_de.free()
	#if face_re:
		#face_re.free()
	#if timer:
		#timer.stop()

# 测试按钮功能
func _on_recognize_button_pressed():
	var img = Image.load_from_file("res://test_img/test2.jpg")
	var buf = img.save_jpg_to_buffer()
	var result = face_re.get_feature(buf)
	print("特征向量大小: ", result.size())


func _on_detect_button_pressed() -> void:
	var img_url = ProjectSettings.globalize_path("res://test_img/test.jpg")
	var result = face_de.detect(img_url)
	print("文件检测结果: ", result)
	pass # Replace with function body.


func _on_webdownloader_model_status(status) -> void:
	if status:
		init_models()
	pass # Replace with function body.
