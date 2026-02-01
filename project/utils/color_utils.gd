class_name ColorUtils
## Color science utilities for DCC pipelines
## Supports linear workflow, color space conversions, and tonemapping

# === Color Space Conversions ===

static func linear_to_srgb(linear: Color) -> Color:
	return Color(
		_linear_to_srgb_channel(linear.r),
		_linear_to_srgb_channel(linear.g),
		_linear_to_srgb_channel(linear.b),
		linear.a
	)


static func srgb_to_linear(srgb: Color) -> Color:
	return Color(
		_srgb_to_linear_channel(srgb.r),
		_srgb_to_linear_channel(srgb.g),
		_srgb_to_linear_channel(srgb.b),
		srgb.a
	)


static func _linear_to_srgb_channel(c: float) -> float:
	if c <= 0.0031308:
		return c * 12.92
	return 1.055 * pow(c, 1.0 / 2.4) - 0.055


static func _srgb_to_linear_channel(c: float) -> float:
	if c <= 0.04045:
		return c / 12.92
	return pow((c + 0.055) / 1.055, 2.4)


# === Wider Gamut Conversions ===

static func srgb_to_rec2020(c: Color) -> Color:
	## sRGB to Rec.2020 (wider gamut for HDR)
	var r := c.r * 0.6274 + c.g * 0.3293 + c.b * 0.0433
	var g := c.r * 0.0691 + c.g * 0.9195 + c.b * 0.0114
	var b := c.r * 0.0164 + c.g * 0.0880 + c.b * 0.8956
	return Color(r, g, b, c.a)


static func srgb_to_dci_p3(c: Color) -> Color:
	## sRGB to DCI-P3 (cinema/Apple displays)
	var r := c.r * 0.8225 + c.g * 0.1774 + c.b * 0.0001
	var g := c.r * 0.0332 + c.g * 0.9669 + c.b * -0.0001
	var b := c.r * 0.0171 + c.g * 0.0724 + c.b * 0.9105
	return Color(r, g, b, c.a)


# === Tonemapping ===

static func tonemap_aces(c: Color) -> Color:
	## ACES Filmic tonemapping (industry standard)
	return Color(
		_aces_channel(c.r),
		_aces_channel(c.g),
		_aces_channel(c.b),
		c.a
	)


static func _aces_channel(x: float) -> float:
	const a := 2.51
	const b := 0.03
	const c := 2.43
	const d := 0.59
	const e := 0.14
	x *= 0.6  # Pre-exposure
	return clampf((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0)


static func tonemap_reinhard(c: Color) -> Color:
	## Simple Reinhard tonemapping
	return Color(
		c.r / (1.0 + c.r),
		c.g / (1.0 + c.g),
		c.b / (1.0 + c.b),
		c.a
	)


# === Color Temperature ===

static func kelvin_to_rgb(kelvin: float) -> Color:
	## Convert color temperature (Kelvin) to RGB
	var temp := kelvin / 100.0
	var r: float
	var g: float
	var b: float

	if temp <= 66.0:
		r = 255.0
		g = 99.4708025861 * log(temp) - 161.1195681661
	else:
		r = 329.698727446 * pow(temp - 60.0, -0.1332047592)
		g = 288.1221695283 * pow(temp - 60.0, -0.0755148492)

	if temp >= 66.0:
		b = 255.0
	elif temp <= 19.0:
		b = 0.0
	else:
		b = 138.5177312231 * log(temp - 10.0) - 305.0447927307

	return Color(
		clampf(r / 255.0, 0.0, 1.0),
		clampf(g / 255.0, 0.0, 1.0),
		clampf(b / 255.0, 0.0, 1.0)
	)


# === Luminance & Exposure ===

static func luminance(c: Color) -> float:
	## Rec.709 luminance (perceived brightness)
	return c.r * 0.2126 + c.g * 0.7152 + c.b * 0.0722


static func apply_exposure(c: Color, ev: float) -> Color:
	## Apply exposure value (EV) adjustment
	var multiplier := pow(2.0, ev)
	return Color(c.r * multiplier, c.g * multiplier, c.b * multiplier, c.a)


static func contrast(c: Color, amount: float, midpoint: float = 0.18) -> Color:
	## Adjust contrast around midpoint (default 18% gray)
	return Color(
		lerpf(midpoint, c.r, amount),
		lerpf(midpoint, c.g, amount),
		lerpf(midpoint, c.b, amount),
		c.a
	)


static func saturation(c: Color, amount: float) -> Color:
	## Adjust saturation
	var lum := luminance(c)
	return Color(
		lerpf(lum, c.r, amount),
		lerpf(lum, c.g, amount),
		lerpf(lum, c.b, amount),
		c.a
	)
