@testset "CircularLoop" begin

    loop = CircularLoop(current = 10u"mA", radius = 100u"mm")
    @test loop.current == 10u"mA"
    @test loop.radius == 100u"mm"

    @test_throws AssertionError CircularLoop(current = 10u"mA", radius = -100u"mm")
    @test_throws AssertionError CircularLoop(current = 10u"m", radius = 100u"mm")
    @test_throws AssertionError CircularLoop(current = 10u"A", radius = 100u"V")

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

    loop = CircularLoop(current = 10u"mA", radius = 100u"mm")
    disp = Displace(loop; x = 10u"m", y = 20u"m", z = 30u"m")

    @test disp.coil == loop
    @test disp.x == 10u"m"
    @test disp.y == 20u"m"
    @test disp.z == 30u"m"

    @test_throws AssertionError Displace(loop; x = 10u"A")
    @test_throws AssertionError Displace(loop; y = 10u"A")
    @test_throws AssertionError Displace(loop; z = 10u"A")

end
