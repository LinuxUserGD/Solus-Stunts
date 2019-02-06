# Copyright © 2017 Hugo Locurcio and contributors - MIT License

extends Control

# The preset to use when starting the project
# 0: Low
# 1: Medium
# 2: High
# 3: Ultra
const default_preset = 2

const display_resolutions = [
	Vector2(1024, 600),
	Vector2(1024, 768),
	Vector2(1152, 864),
	Vector2(1280, 720),
	Vector2(1280, 768),
	Vector2(1280, 800),
	Vector2(1280, 1024),
	Vector2(1360, 768),
	Vector2(1366, 768),
	Vector2(1440, 900),
	Vector2(1536, 864),
	Vector2(1600, 900),
	Vector2(1680, 1050),
	Vector2(1920, 1080),
	Vector2(1920, 1200),
	Vector2(2560, 1080),
	Vector2(2560, 1440),
	Vector2(2560, 1440),
	Vector2(3440, 1440),
	Vector2(3840, 2160),
]

const mix_target_presets = [
	"Stereo", "Surround", "Center"
]

const preset_descriptions = [
	"For low-end PCs with integrated graphics, as well as mobile devices.",
	"For mid-range PCs with slower dedicated graphics.",
	"For recent PCs with mid-range dedicated graphics, or older PCs with high-end graphics.",
	"For recent PCs with high-end dedicated graphics.",
]

const presets = [
	# Low
	{
		"environment/glow_enabled": [false, "Disabled"],
		"environment/ss_reflections_enabled": [false, "Disabled"],
		"environment/ssao_enabled": [false, "Disabled"],
		"environment/ssao_blur": [Environment.SSAO_BLUR_1x1, ""],
		"environment/ssao_quality": [Environment.SSAO_QUALITY_LOW, ""],
		"rendering/quality/anisotropic_filter_level": [2, "2×"],
		"rendering/quality/filters/msaa": [Viewport.MSAA_2X, "2×"],
		"rendering/quality/voxel_cone_tracing/high_quality": [false, "Low-quality"],
	},

	# Medium
	{
		"environment/glow_enabled": [false, "Disabled"],
		"environment/ss_reflections_enabled": [false, "Disabled"],
		"environment/ssao_enabled": [false, "Disabled"],
		"environment/ssao_blur": [Environment.SSAO_BLUR_1x1, ""],
		"environment/ssao_quality": [Environment.SSAO_QUALITY_LOW, ""],
		"rendering/quality/anisotropic_filter_level": [8, "8×"],
		"rendering/quality/filters/msaa": [Viewport.MSAA_2X, "2×"],
		"rendering/quality/voxel_cone_tracing/high_quality": [false, "Low-quality"],
	},

	# High
	{
		"environment/glow_enabled": [true, "Enabled"],
		"environment/ss_reflections_enabled": [false, "Disabled"],
		"environment/ssao_enabled": [true, "Medium-quality"],
		"environment/ssao_blur": [Environment.SSAO_BLUR_1x1, ""],
		"environment/ssao_quality": [Environment.SSAO_QUALITY_LOW, ""],
		"rendering/quality/anisotropic_filter_level": [16, "16×"],
		"rendering/quality/filters/msaa": [Viewport.MSAA_4X, "4×"],
		"rendering/quality/voxel_cone_tracing/high_quality": [false, "Low-quality"],
	},

	# Ultra
	{
		"environment/glow_enabled": [true, "Enabled"],
		"environment/ss_reflections_enabled": [true, "Enabled"],
		"environment/ssao_enabled": [true, "High-quality"],
		"environment/ssao_blur": [Environment.SSAO_BLUR_2x2, ""],
		"environment/ssao_quality": [Environment.SSAO_QUALITY_MEDIUM, ""],
		"rendering/quality/anisotropic_filter_level": [16, "16×"],
		"rendering/quality/filters/msaa": [Viewport.MSAA_8X, "8×"],
		"rendering/quality/voxel_cone_tracing/high_quality": [true, "High-quality"],
	},
]

onready var root = $"/root/lobby3D"
onready var environment = root.get_environment()

onready var GraphicsBlurb = $"Panel/GraphicsBlurb"
onready var GraphicsInfo = $"Panel/GraphicsInfo"
onready var ResolutionDropdown = $"Panel/DisplayResolution/display_resolution"
onready var AudioDropdown = $"Panel/Mix target/target"

func _ready():
	$"Panel/GraphicsQuality/graphics_preset".select(default_preset)
	_on_graphics_preset_item_selected(default_preset)
	var screen_size = OS.get_screen_size()
	for resolution in display_resolutions:
		if resolution.x < screen_size.x and resolution.y < screen_size.y:
			ResolutionDropdown.add_item(str(resolution.x) + "×" + str(resolution.y))
	ResolutionDropdown.add_item("Fullscreen")
	ResolutionDropdown.select(ResolutionDropdown.get_item_count() - 1)
	for target in mix_target_presets:
		AudioDropdown.add_item(target)

func construct_bbcode(preset):
	return """[table=2]
[cell][b]Anti-aliasing[/b][/cell] [cell]""" + str(presets[preset]["rendering/quality/filters/msaa"][1]) + """[/cell]
[cell][b]Anisotropic filtering[/b][/cell] [cell]""" + str(presets[preset]["rendering/quality/anisotropic_filter_level"][1]) + """[/cell]
[cell][b]Global illumination[/b][/cell] [cell]""" + str(presets[preset]["rendering/quality/voxel_cone_tracing/high_quality"][1]) + """[/cell]
[cell][b]Ambient occlusion[/b][/cell] [cell]""" + str(presets[preset]["environment/ssao_enabled"][1]) + """[/cell]
[cell][b]Bloom[/b][/cell] [cell]""" + str(presets[preset]["environment/glow_enabled"][1]) + """[/cell]
[cell][b]Screen-space reflections[/b][/cell] [cell]""" + str(presets[preset]["environment/ss_reflections_enabled"][1]) + """[/cell]
[/table]"""

func _on_ConfirmButton_pressed():
	visible = false

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_HSlider_value_changed( value ):
	$"AudioStreamPlayer".volume_db = -50 + value/2

func _on_display_resolutionn_item_selected( ID ):
	if ID < ResolutionDropdown.get_item_count() - 1:
		OS.set_window_fullscreen(false)
		OS.set_window_size(display_resolutions[ID])
		OS.set_window_maximized(false)
	else:
		OS.set_window_fullscreen(true)

func _on_graphics_preset_item_selected( ID ):
	GraphicsBlurb.bbcode_text = preset_descriptions[ID]
	GraphicsInfo.bbcode_text = construct_bbcode(ID)
	for setting in presets[ID]:
		var value = presets[ID][setting][0]
		ProjectSettings.set_setting(setting, value)
		match setting:
			"environment/glow_enabled":
				environment.glow_enabled = value
			"environment/ss_reflections_enabled":
				environment.ss_reflections_enabled = value
			"environment/ssao_enabled":
				environment.ssao_enabled = value
			"environment/ssao_blur":
				environment.ssao_blur = value
			"environment/ssao_quality":
				environment.ssao_quality = value
			"rendering/quality/filters/msaa":
				get_viewport().msaa = value

func _on_target_item_selected( ID ):
	if ID==0:
		$"AudioStreamPlayer".MIX_TARGET_STEREO
	if ID==1:
		$"AudioStreamPlayer".MIX_TARGET_SURROUND
	if ID==2:
		$"AudioStreamPlayer".MIX_TARGET_CENTER
