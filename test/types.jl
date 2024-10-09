@testset "CircularLoop" begin

    loop = CircularLoop(current = 10u"mA", diameter = 100u"mm")
    @test loop.current == 10u"mA"
    @test loop.diameter == 100u"mm"

    @test_throws AssertionError CircularLoop(current = 10u"mA", diameter = -100u"mm")
    @test_throws AssertionError CircularLoop(current = 10u"m", diameter = 100u"mm")
    @test_throws AssertionError CircularLoop(current = 10u"A", diameter = 100u"V")

end

@testset "RectangularLoop" begin

    loop = RectangularLoop(current = 10u"mA", width = 20u"m", height = 30u"m")
    @test loop.current == 10u"mA"
    @test loop.width == 20u"m"
    @test loop.height == 30u"m"

    @test_throws AssertionError RectangularLoop(current = 10u"mA", width = -20u"m", height = 30u"m")
    @test_throws AssertionError RectangularLoop(current = 10u"mA", width = 20u"m", height = -30u"m")
    @test_throws AssertionError RectangularLoop(current = 10u"m", width = 20u"m", height = 30u"m")
    @test_throws AssertionError RectangularLoop(current = 10u"mA", width = 20u"V", height = 30u"m")
    @test_throws AssertionError RectangularLoop(current = 10u"mA", width = 20u"m", height = 30u"V")

end

@testset "Displace" begin

    loop = CircularLoop(current = 10u"mA", diameter = 100u"mm")
    disp = Displace(loop; x = 10u"m", y = 20u"m", z = 30u"m")

    @test disp.coil == loop
    @test disp.x == 10u"m"
    @test disp.y == 20u"m"
    @test disp.z == 30u"m"

    @test_throws AssertionError Displace(loop; x = 10u"A")
    @test_throws AssertionError Displace(loop; y = 10u"A")
    @test_throws AssertionError Displace(loop; z = 10u"A")

end

@testset "CircularCoil" begin

    @test CircularCoil(
        current = 10u"mA",
        inner_diameter = 100u"mm",
        outer_diameter = 160u"mm",
        thickness = 10u"mm",
        radial_turns = 3,
        axial_turns = 2,
    ).coils == [
        Displace(CircularLoop(current = 10u"mA", diameter = 100u"mm"), z = -5u"mm"),
        Displace(CircularLoop(current = 10u"mA", diameter = 100u"mm"), z = 5u"mm"),
        Displace(CircularLoop(current = 10u"mA", diameter = 130u"mm"), z = -5u"mm"),
        Displace(CircularLoop(current = 10u"mA", diameter = 130u"mm"), z = 5u"mm"),
        Displace(CircularLoop(current = 10u"mA", diameter = 160u"mm"), z = -5u"mm"),
        Displace(CircularLoop(current = 10u"mA", diameter = 160u"mm"), z = 5u"mm"),
    ]

end

@testset "RectangularCoil" begin

    @test RectangularCoil(
        current = 10u"mA",
        inner_width = 80u"mm",
        outer_width = 120u"mm",
        inner_height = 100u"mm",
        outer_height = 160u"mm",
        thickness = 10u"mm",
        radial_turns = 2,
        axial_turns = 2,
    ).coils == [
        Displace(
            RectangularLoop(current = 10u"mA", width = 80u"mm", height = 100u"mm"),
            z = -5u"mm",
        ),
        Displace(
            RectangularLoop(current = 10u"mA", width = 80u"mm", height = 100u"mm"),
            z = 5u"mm",
        ),
        Displace(
            RectangularLoop(current = 10u"mA", width = 120u"mm", height = 160u"mm"),
            z = -5u"mm",
        ),
        Displace(
            RectangularLoop(current = 10u"mA", width = 120u"mm", height = 160u"mm"),
            z = 5u"mm",
        ),
    ]

end
