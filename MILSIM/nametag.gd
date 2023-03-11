extends Sprite3D


# Called when the node enters the scene tree for the first time.
func _ready():
	if texture != null:
		return
	var vpTexture = ViewportTexture.new()
	vpTexture.viewport_path = "SubViewport"
	set_texture(vpTexture)
	

