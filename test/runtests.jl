using LeafletPluto
using Test
using HypertextLiteral

@testset "LeafletPluto.jl" begin
    @testset "rendering works" begin
        m = Map(center = (0, 0), option = staticMapOption())
        build(m, Polyline(latlngs = [(0, 5), (0, 10), (0, 15)]))
        build(m, Polyline(latlngs = [(5, 0), (10, 0), (15, 0)], path = Path(color = "#88ff33")))
        build(m, Polygon(latlngs = [(2, 6), (6, 6), (6, 10), (2, 10)]))
        build(m, Circle(center = (-4, -4), radius = 500_000, path = Path(color = "red")))
        build(m, Marker((-4, -4)))

        @test typeof(leaflet(m)) == HypertextLiteral.Result
    end
end
