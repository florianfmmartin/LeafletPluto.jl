### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# ╔═╡ 7c52b98c-3617-4ad4-bf12-930468793f89
using HypertextLiteral

# ╔═╡ baef2610-79dc-11ef-12f2-ad52aa82fd14
md"""
# LeafletPluto.jl
### Displaying Leaflet maps in Pluto
"""

# ╔═╡ e51f2cf3-7e90-4489-a5eb-59aefbdfc3db
md"""
Highly inspired by [PlutoMapPicker.jl](https://github.com/lukavdplas/PlutoMapPicker.jl/blob/main/src/map-picker.jl)

Used [this LeafletJS page](https://leafletjs.com/reference.html) as a reference
"""

# ╔═╡ 8db92502-e6cf-493b-9ade-a9f7bcf4ba70
md"""
## Tile layers

!!! warning "Thanks to PlutoMapPicker.jl"
	This content was copied over from [PlutoMapPicker.jl](https://github.com/lukavdplas/PlutoMapPicker.jl/blob/main/src/map-picker.jl)
"""

# ╔═╡ 2ed6631f-d845-48fb-be56-e4cffab14295
begin
	"""
A tile layer that can be used in a Leaflet map.

The configuration includes:
- `url`: a url template to request tiles
- `options`: a `Dict` with extra configurations, such as a minimum and maximum zoom level of the tiles. This is interpolated to a Javascript object using HypertextLiteral.

The configuration is used to create a TileLayer in leaflet; see [leaflet's TileLayer documentation](https://leafletjs.com/reference.html#tilelayer) to read more about URL templates and the available options.
"""
struct TileLayer
	url::String
	options::Dict{String,Any}
end

attribution_stadia = "&copy; <a href='https://stadiamaps.com/'>Stadia Maps</a>"

attribution_stamen = "&copy; <a href='https://stamen.com/'>Stamen Design</a>"

attribution_openmaptiles = "&copy; <a href='https://openmaptiles.org/'>OpenMapTiles</a>"

attribution_osm = "&copy; <a href='https://www.openstreetmap.org/copyright'>OpenStreetMap</a>"

"""
TileLayer for open street map. Please read OSM's [tile usage policy](https://operations.osmfoundation.org/policies/tiles/) to decide if your usage complies with it.
"""
osm_tile_layer = TileLayer(
	"https://tile.openstreetmap.org/{z}/{x}/{y}.png",
	Dict(
		"maxZoom" => 19,
		"attribution" => attribution_osm
	)
)

osm_humanitarian_tile_layer = TileLayer(
	"https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png",
	Dict(
		"maxZoom" => 19,
		"subdomains" => "ab",
		"attribution" => attribution_osm
	)
)

"""
TileLayers for Open Street Map. Please read OSM's [tile usage policy](https://operations.osmfoundation.org/policies/tiles/) to decide if your usage complies with it.
"""
osm_tile_layers = (
	standard = osm_tile_layer,
	humanitarian = osm_humanitarian_tile_layer,
)

stadia_osm_bright_tile_layer = TileLayer(
	"https://tiles.stadiamaps.com/tiles/osm_bright/{z}/{x}/{y}{r}.png",
	Dict(
		"maxZoom" => 20,
		"attribution" =>  "$attribution_stadia $attribution_openmaptiles $attribution_osm",
		"referrerPolicy" => "origin",
	)
)

stadia_outdoors_tile_layer = TileLayer(
	"https://tiles.stadiamaps.com/tiles/outdoors/{z}/{x}/{y}{r}.png",
	Dict(
		"maxZoom" => 20,
		"attribution" =>  "$attribution_stadia $attribution_openmaptiles $attribution_osm",
		"referrerPolicy" => "origin",
	)
)

stadia_stamen_toner_tile_layer = TileLayer(
	"https://tiles.stadiamaps.com/tiles/stamen_toner/{z}/{x}/{y}{r}.png",
	Dict(
		"maxZoom" => 20,
		"attribution" =>  "$attribution_stadia $attribution_stamen $attribution_openmaptiles $attribution_osm",
		"referrerPolicy" => "origin",
	)
)

stadia_stamen_watercolor_tile_layer = TileLayer(
	"https://tiles.stadiamaps.com/tiles/stamen_watercolor/{z}/{x}/{y}.jpg",
	Dict(
		"maxZoom" => 16,
		"attribution" =>  "$attribution_stadia $attribution_stamen $attribution_openmaptiles $attribution_osm",
		"referrerPolicy" => "origin",
	)
)

"""
Tile layers that retrieve tiles from Stadia Maps.

See [the documentation of Stadia Maps](https://docs.stadiamaps.com/) for more information about their terms of service.

## Styles

- `osm_bright`: similar to the OpenStreetMap layout.
- `outdoors`: similar to `osm_bright`, but puts more focus on things like parks, hiking trails, mountains, etc.
- `stamen_toner`: a high-contrast, black and white style.
- `stamen_watercolor`: looks like a watercolour painting.

## Authentication

Requests to Stadia Maps are not authenticated and do not contain an API key.

At the time of writing, Stadia Maps allows unauthenticated requests from `localhost`, such as those from a local Pluto notebook. If you want to host your notebook online, you should request an API key from Stadia Maps and create a `TileLayer` that uses your API key. 
"""
stadia_tile_layers = (
	osm_bright = stadia_osm_bright_tile_layer,
	outdoors = stadia_outdoors_tile_layer,
	stamen_toner = stadia_stamen_toner_tile_layer,
	stamen_watercolor = stadia_stamen_watercolor_tile_layer,
)

md"""
Click the eye icon to see this content.
"""
end

# ╔═╡ e377c1ff-e618-4192-b351-9aad766d3e69
md"""
## Map
"""

# ╔═╡ 87b5ce4e-756e-44b2-a725-451788c234bd
md"### Some useful types"

# ╔═╡ 0f7abed3-56e3-4492-8592-5df441652314
"""
`LatLng` is a type alias for `Tuple{Number, Number}`.

Example:
	`(0, 0)`
"""
LatLng = Tuple{Number, Number}

# ╔═╡ 9c8ec369-8e24-4a9e-af45-0bd73946302d
"""
A `Path` contains some of the available options to render elements.
In JS, it is a class that other types inherit from.
Here in Julia, we use composition of this types inside the elements.

It contains:
- `stroke`: `true` to see the outline
- `color`: any `String` that is a valid CSS color will color the stroke
- `weight`: a `Number` for the width of the stroke
- `fill`: `true` to fill in the shape
- `fillColor`: any `String` that is a valid CSS color will color the fill
"""
@kwdef struct Path
	stroke::Bool = true
	color::String = "#3388ff"
	weight::Number = 3
	fill::Bool = true
	fillColor::String = "#3388ff"
end

# ╔═╡ a9e6e3d6-c607-4c3c-851d-8c1acf06322a
md"""
### Elements
These are things that can be put on to the map.
"""

# ╔═╡ 50926132-f8e5-446c-ba18-ad0c275b1b94
"""
A `Marker` is a location to put a pin on the `Map`
"""
struct Marker
	center::LatLng
end

# ╔═╡ 8b3724ce-a96f-4aec-ab8b-4ac811ff0ce6
"""
A `Polyline` is a line to display on the `Map`
"""
@kwdef struct Polyline
	latlngs::Vector{LatLng}
	path::Path = Path()
end

# ╔═╡ 708af5fa-86b9-4f48-ab3b-bd58ee9f8c0f
"""
A `Polygon` is a polygon or shape to display on the `Map`
"""
@kwdef struct Polygon
	latlngs::Vector{LatLng}
	path::Path = Path()
end

# ╔═╡ e4583488-4266-4ecd-87c0-6cb07b7908d2
"""
A `Circle` is a circle to display on the `Map`
"""
@kwdef struct Circle
	center::LatLng
	radius::Number
	path::Path = Path()
end

# ╔═╡ a258ecde-61ee-4e21-8afa-e55c45bcad77
"""
A `MapOption` contains some of the available options to customize the `Map`.

It contains:
- `zoomControl`: `true` displays the zoom control buttons
- `doubleClickZoom`: `true` allows to double-click to zoom
- `scrollWheelZoom`: `true` allows the scroll-wheel to zoom
- `dragging`: `true` allows the mouse to drag the map around
"""
@kwdef struct MapOption
	zoomControl::Bool = true
	doubleClickZoom::Bool = true
	scrollWheelZoom::Bool = true
	dragging::Bool = true
end

# ╔═╡ 28e0f702-2791-49f1-9620-caa126ffded6
"""
The `staticMapOption` is a function that returns a `MapOption` which creates a completly static `Map` rendering.
"""
function staticMapOption()::MapOption
	MapOption(false, false, false, false)
end

# ╔═╡ eb8bcc8a-1125-40e9-be98-8a4a4a3cf847
"""
A `Map` is a representation of map to be rendered.

It contains:
- `center`: a `LatLng` to center the map
- `zoom`: a `Number` for the zoom amount `1` is wide and `10+` is zoomed in
- `tile`: a `TileLayer` to change the look
- `height`: an `Integer` to set the height
- `lines`: a `Vector{Polyline}` for lines to display
- `polygons`: a `Vector{Polygon}` for polygons to display
- `circles`: a `Vector{Circle}` for circles to display
- `markers`: a `Vector{Marker}` for markers to display
- `option`: a `MapOption` to configure
"""
@kwdef mutable struct Map
	center::LatLng
	zoom::Number = 4
	tile::TileLayer= osm_tile_layers.standard
	height::Integer = 500
	lines::Vector{Polyline} = []
	polygons::Vector{Polygon} = []
	circles::Vector{Circle} = []
	markers::Vector{Marker} = []
	option::MapOption = MapOption()
end

# ╔═╡ 7b64daba-0701-4981-b0d0-015b4126d16a
md"""
### Custom @htl rendering
The following cells define custom rendering methods for the map rendering to work.

We extend `Base.show` and `HypertextLiteral.print_script`
"""

# ╔═╡ 704362e3-be7f-43b4-8d45-80177668b86b
"""
The function `to_dict` is a little helper that is used for rendering struct correctly in JS.
"""
function to_dict(mo)::Dict{String, Any}
	Dict(String(key) => getfield(mo, key) for key in propertynames(mo))
end

# ╔═╡ af83beb6-1f07-4ef6-9fca-d6fa2ff2d2e1
function Base.show(io::IO, m::MIME"text/javascript", p::Polyline)
	tio1, tio2 = (IOBuffer(), IOBuffer())
	HypertextLiteral.print_script(tio1, p.latlngs)
	HypertextLiteral.print_script(tio2, to_dict(p.path))
	print(io, "L.polyline($(String(take!(tio1))), $(String(take!(tio2)))).addTo(zeMap);")
end

# ╔═╡ 62bfb5e4-5a87-4391-90bd-137ff2d8d1ad
function HypertextLiteral.print_script(io::IO, value::Vector{Marker})
	foreach(p -> Base.show(io, MIME("text/javascript"), p), value)
end

# ╔═╡ 29defb6b-1f55-4e94-a481-d735e2a882e3
function Base.show(io::IO, m::MIME"text/javascript", p::Marker)
	tio1 = IOBuffer()
	HypertextLiteral.print_script(tio1, p.center)
	print(io, "L.marker($(String(take!(tio1)))).addTo(zeMap);")
end

# ╔═╡ 8d278e04-ffec-4730-b0f6-c01c91bd06dd
function HypertextLiteral.print_script(io::IO, value::Vector{Polyline})
	foreach(p -> Base.show(io, MIME("text/javascript"), p), value)
end

# ╔═╡ 8e7197d6-1432-4302-ac47-75d04652a5b2
function Base.show(io::IO, m::MIME"text/javascript", p::Circle)
	tio1, tio2 = (IOBuffer(), IOBuffer())
	HypertextLiteral.print_script(tio1, p.center)
	HypertextLiteral.print_script(tio2, to_dict(p.path))
	print(io, "L.circle($(String(take!(tio1))), { radius: $(p.radius), ...$(String(take!(tio2))) }).addTo(zeMap);")
end

# ╔═╡ 4bf06d7d-3705-4c7d-bae6-aa3cb92c6b99
function HypertextLiteral.print_script(io::IO, value::Vector{Circle})
	foreach(p -> Base.show(io, MIME("text/javascript"), p), value)
end

# ╔═╡ 91802110-663e-4fb4-9167-c68af3561dbf
"""
"""
function Base.show(io::IO, m::MIME"text/javascript", p::Polygon)
	tio1, tio2 = (IOBuffer(), IOBuffer())
	HypertextLiteral.print_script(tio1, p.latlngs)
	HypertextLiteral.print_script(tio2, to_dict(p.path))
	print(io, "L.polygon($(String(take!(tio1))), $(String(take!(tio2)))).addTo(zeMap);")
end

# ╔═╡ 7a563f43-4a2e-4e27-b153-ca33e126dc90
"""
"""
function HypertextLiteral.print_script(io::IO, value::Vector{Polygon})
	foreach(p -> Base.show(io, MIME("text/javascript"), p), value)
end

# ╔═╡ 54ab5a53-b023-427f-8918-cbd2abccc2da
md"## Map building"

# ╔═╡ b10f75b0-b3be-4950-9644-127190284512
begin
	"""
	The `build` function takes a `Map` and a element and adds the element to its list of elements of the corresponding type.
	"""
	function build end

	"""
	Use this `build` to add a `Polyline` to your `Map`'s lines.
	"""
	function build(m::Map, l::Polyline)
		m.lines = [m.lines ; l]
	end

	"""
	Use this `build` to add a `Polygon` to your `Map`'s polygons.
	"""
	function build(m::Map, p::Polygon)
		m.polygons = [m.polygons ; p]
	end

	"""
	Use this `build` to add a `Circle` to your `Map`'s circles.
	"""
	function build(m::Map, c::Circle)
		m.circles = [m.circles ; c]
	end

	"""
	Use this `build` to add a `Marker` to your `Map`'s markers.
	"""
	function build(m::Map, k::Marker)
		m.markers = [m.markers ; k]
	end
end

# ╔═╡ 2cc5f89f-042d-436c-bbbc-6be1a1d61e6c
md"## Render a map"

# ╔═╡ 095c821d-60ee-401c-a51d-705a9ddd8e68
"""
The `leaflet` function takes a `Map` and renders it to the cell in Pluto.
It returns the `HypertextLiteral.Result` types.
"""
function leaflet(m::Map)
	@htl("""
	<div>
		<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
			integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
			crossorigin=""/>
		<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
	    	integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo="
	    	crossorigin=""></script>
	
		<div id="map"></div>
	
		<style>
			#map { height: $(m.height)px; }
		</style>
	
		<script>
			var parent = currentScript.parentElement;
			var mapElement = parent.querySelector("#map");
			var zeMap = L.map(mapElement, $(to_dict(m.option)))
					   .setView([$(m.center[1]), $(m.center[2])], $(m.zoom));
	
			L.tileLayer($(m.tile.url), $(m.tile.options)).addTo(zeMap);
			$(m.lines)
			$(m.polygons)
			$(m.circles)
			$(m.markers)
		</script>
	</div>
	""")
end

# ╔═╡ 96fbe075-8dfd-44cf-88a0-489bc361e62c
md"## Demo"

# ╔═╡ 0edd50fd-e72f-4b36-869c-31d5465ac29a
begin
	m = Map(center = (0, 0), option = staticMapOption())
	build(m, Polyline(latlngs = [(0, 5), (0, 10), (0, 15)]))
	build(m, Polyline(latlngs = [(5, 0), (10, 0), (15, 0)], path = Path(color = "#88ff33")))
	build(m, Polygon(latlngs = [(2, 6), (6, 6), (6, 10), (2, 10)]))
	build(m, Circle(center = (-4, -4), radius = 500_000, path = Path(color = "red")))
	build(m, Marker((-4, -4)))
	leaflet(m)
end

# ╔═╡ 7a84c7e1-8d2d-4742-81bf-a35be540b517
begin
	m2 = Map(center = (46.81411097653479, -71.20089272116749), option = staticMapOption(), zoom = 12)
	build(m2, Marker((46.81411097653479, -71.20089272116749)))
	leaflet(m2)
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"

[compat]
HypertextLiteral = "~0.9.5"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.5"
manifest_format = "2.0"
project_hash = "5b37abdf7398dc5da4cd347d0609990238d895bb"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"
"""

# ╔═╡ Cell order:
# ╟─baef2610-79dc-11ef-12f2-ad52aa82fd14
# ╟─e51f2cf3-7e90-4489-a5eb-59aefbdfc3db
# ╠═7c52b98c-3617-4ad4-bf12-930468793f89
# ╟─8db92502-e6cf-493b-9ade-a9f7bcf4ba70
# ╟─2ed6631f-d845-48fb-be56-e4cffab14295
# ╟─e377c1ff-e618-4192-b351-9aad766d3e69
# ╟─87b5ce4e-756e-44b2-a725-451788c234bd
# ╠═0f7abed3-56e3-4492-8592-5df441652314
# ╠═9c8ec369-8e24-4a9e-af45-0bd73946302d
# ╟─a9e6e3d6-c607-4c3c-851d-8c1acf06322a
# ╠═50926132-f8e5-446c-ba18-ad0c275b1b94
# ╠═8b3724ce-a96f-4aec-ab8b-4ac811ff0ce6
# ╠═708af5fa-86b9-4f48-ab3b-bd58ee9f8c0f
# ╠═e4583488-4266-4ecd-87c0-6cb07b7908d2
# ╠═a258ecde-61ee-4e21-8afa-e55c45bcad77
# ╠═28e0f702-2791-49f1-9620-caa126ffded6
# ╠═eb8bcc8a-1125-40e9-be98-8a4a4a3cf847
# ╟─7b64daba-0701-4981-b0d0-015b4126d16a
# ╠═91802110-663e-4fb4-9167-c68af3561dbf
# ╠═7a563f43-4a2e-4e27-b153-ca33e126dc90
# ╠═8e7197d6-1432-4302-ac47-75d04652a5b2
# ╠═4bf06d7d-3705-4c7d-bae6-aa3cb92c6b99
# ╠═af83beb6-1f07-4ef6-9fca-d6fa2ff2d2e1
# ╠═8d278e04-ffec-4730-b0f6-c01c91bd06dd
# ╠═29defb6b-1f55-4e94-a481-d735e2a882e3
# ╠═62bfb5e4-5a87-4391-90bd-137ff2d8d1ad
# ╠═704362e3-be7f-43b4-8d45-80177668b86b
# ╟─54ab5a53-b023-427f-8918-cbd2abccc2da
# ╠═b10f75b0-b3be-4950-9644-127190284512
# ╟─2cc5f89f-042d-436c-bbbc-6be1a1d61e6c
# ╠═095c821d-60ee-401c-a51d-705a9ddd8e68
# ╟─96fbe075-8dfd-44cf-88a0-489bc361e62c
# ╠═0edd50fd-e72f-4b36-869c-31d5465ac29a
# ╠═7a84c7e1-8d2d-4742-81bf-a35be540b517
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
