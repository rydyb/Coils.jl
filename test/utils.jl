@testset "qconvert" begin

    qconvert(1u"m", u"m") == 1u"m"

    qconvert(1, u"m") == 1u"m"

    qconvert(1Unitful.u"m", u"m") == 1u"m"

end
