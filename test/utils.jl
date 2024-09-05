@testset "qconvert" begin

    @test qconvert(1u"m", u"m") == 1u"m"
    @test_throws IncompatibleUnitsError qconvert(1u"m", u"s")

    @test qconvert(1, u"m") == 1u"m"

    @test qconvert(1Unitful.u"m", u"m") == 1u"m"
    @test_throws IncompatibleUnitsError qconvert(1Unitful.u"m", u"s")

end
