extends HBoxContainer

@export var bus_name : String = "Master"
var busIdx

# Called when the node enters the scene tree for the first time.
func _ready():
	$VolumeSlider.drag_ended.connect(_on_volume_slider_drag_ended)
	$VolumeBusLabel.text = bus_name + " volume: "

	busIdx = AudioServer.get_bus_index(bus_name)
	var vol_db : float = AudioServer.get_bus_volume_db(busIdx)
	if busIdx != -1:
		$VolumeSlider.value = db_to_linear(vol_db)
	else:
		printerr("Volume Adjuster needs correct bus name: " + self.name + " in " + owner.name)
	

func _on_volume_slider_drag_ended(valueChanged : bool):
	var new_vol_db = linear_to_db($VolumeSlider.value)
	AudioServer.set_bus_volume_db(busIdx, new_vol_db)
	
