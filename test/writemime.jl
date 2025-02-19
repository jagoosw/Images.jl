using Images, ImageShow
using Test

@testset "show (MIME)" begin
    # Test that we remembered to turn off Colors.jl's colorswatch display
    @test !showable(MIME("image/svg+xml"), rand(Gray{N0f8}, 5, 5))
    @test !showable(MIME("image/svg+xml"), rand(RGB{N0f8},  5, 5))
    @test showable(MIME("image/png"), rand(Gray{N0f8}, 5, 5))
    @test showable(MIME("image/png"), rand(RGB{N0f8},  5, 5))
    workdir = joinpath(tempdir(), "Images")
    if !isdir(workdir)
        mkdir(workdir)
    end
    @testset "no compression or expansion" begin
        A = N0f8[0.01 0.99; 0.25 0.75]
        fn = joinpath(workdir, "writemime.png")
        open(fn, "w") do file
            show(file, MIME("image/png"), Gray.(A), minpixels=0, maxpixels=typemax(Int))
        end
        b = load(fn)
        @test b == A
        @test Images.metadata(fn) == (reverse(size(A)), Gray{N0f8})

        img = fill(RGB{N0f16}(1,0,0), 1, 1)
        open(fn, "w") do file
            show(IOContext(file, :full_fidelity=>true), MIME("image/png"), img, minpixels=0, maxpixels=typemax(Int))
        end
        b = load(fn)
        @test b == img
        if VERSION >= v"1.3"
            # ImageMagick backend is broken here.
            # For Julia >=v1.3 FileIO will use ImageIO backend
            @test Images.metadata(fn) == (reverse(size(img)), RGB{N0f16})
        end

        A = N0f8[0.01 0.99; 0.25 0.75]
        fn = joinpath(workdir, "writemime.png")
        open(fn, "w") do file
            show(IOContext(file, :full_fidelity=>true), MIME("image/png"), Gray.(A), minpixels=5, maxpixels=typemax(Int))
        end
        @test load(fn) == A
        @test Images.metadata(fn) == (reverse(size(A)), Gray{N0f8})

        A = N0f8[0.01 0.4 0.99; 0.25 0.8 0.75; 0.6 0.2 0.0]
        fn = joinpath(workdir, "writemime.png")
        open(fn, "w") do file
            show(IOContext(file, :full_fidelity=>true), MIME("image/png"), Gray.(A), minpixels=0, maxpixels=5)
        end
        @test load(fn) == A
        @test Images.metadata(fn) == (reverse(size(A)), Gray{N0f8})

        # a genuinely big image (tests the defaults)
        abig = colorview(Gray, normedview(rand(UInt8, 1024, 1023)))
        fn = joinpath(workdir, "big.png")
        open(fn, "w") do file
            show(IOContext(file, :full_fidelity=>true), MIME("image/png"), abig, maxpixels=10^6)
        end
        b = load(fn)
        @test b == abig
        @test Images.metadata(fn) == (reverse(size(abig)), Gray{N0f8})
    end
    @testset "colorspace normalization" begin
        img = fill(HSV{Float64}(0.5, 0.5, 0.5), 1, 1)
        fn = joinpath(workdir, "writemime.png")
        open(fn, "w") do file
            show(file, MIME("image/png"), img, minpixels=0, maxpixels=typemax(Int))
        end
        b = load(fn)
        @test b == convert(Array{RGB{N0f8}}, img)
        @test Images.metadata(fn) == (reverse(size(img)), RGB{N0f8})
        img = fill(RGB{N0f16}(1,0,0), 1, 1)
        open(fn, "w") do file
            show(file, MIME("image/png"), img, minpixels=0, maxpixels=typemax(Int))
        end
        b = load(fn)
        @test eltype(b) <: AbstractRGB && eltype(eltype(b)) == N0f8 && b[1] == RGB(1,0,0)
        @test Images.metadata(fn) == (reverse(size(img)), RGB{N0f8})
        img = fill(RGBA{Float32}(1,0,0,0.5), 1, 1)
        open(fn, "w") do file
            show(file, MIME("image/png"), img, minpixels=0, maxpixels=typemax(Int))
        end
        b = load(fn)
        @test isa(b, Matrix{RGBA{N0f8}}) && b[1] == RGBA{N0f8}(1,0,0,0.5)
        @test Images.metadata(fn) == (reverse(size(img)), RGBA{N0f8})
        img = Gray.([0.1 0.2; -0.5 0.8])
        open(fn, "w") do file
            show(file, MIME("image/png"), img, minpixels=0, maxpixels=typemax(Int))
        end
        b = load(fn)
        @test isa(b, Matrix{Gray{N0f8}}) && b == Gray{N0f8}[0.1 0.2; 0 0.8]
        @test Images.metadata(fn) == (reverse(size(img)), Gray{N0f8})
    end
    @testset "small images (expansion)" begin
        A = N0f8[0.01 0.99; 0.25 0.75]
        fn = joinpath(workdir, "writemime.png")
        open(fn, "w") do file
            show(file, MIME("image/png"), Gray.(A), minpixels=5, maxpixels=typemax(Int))
        end
        @test load(fn) == A[[1,1,2,2],[1,1,2,2]]
        @test Images.metadata(fn) == ((4,4), Gray{N0f8})
    end
    @testset "big images (use of restrict)" begin
        A = N0f8[0.01 0.4 0.99; 0.25 0.8 0.75; 0.6 0.2 0.0]
        Ar = restrict(A)
        fn = joinpath(workdir, "writemime.png")
        open(fn, "w") do file
            show(file, MIME("image/png"), Gray.(A), minpixels=0, maxpixels=5)
        end
        @test load(fn) == N0f8.(Ar)
        @test Images.metadata(fn) == (reverse(size(Ar)), Gray{N0f8})
        # a genuinely big image (tests the defaults)
        abig = colorview(Gray, normedview(rand(UInt8, 1024, 1023)))
        fn = joinpath(workdir, "big.png")
        open(fn, "w") do file
            show(file, MIME("image/png"), abig, maxpixels=10^6)
        end
        b = load(fn)
        @test b == N0f8.(restrict(abig, (1,2)))
        @test Images.metadata(fn) == (reverse(size(restrict(abig,(1,2)))), Gray{N0f8})
    end
    @testset "display matrix of images" begin
        img() = colorview(Gray, rand([0.250 0.5; 0.75 1.0], rand(2:10), rand(2:10)))
        io = IOBuffer()
        # test that these methods don't fail
        show(io, MIME"text/html"(), [img() for i=1:2])
        show(io, MIME"text/html"(), [img() for i=1:2, j=1:2])
        show(io, MIME"text/html"(), [img() for i=1:2, j=1:2, k=1:2])
    end
    @testset "display matrix of 1-D images" begin
        flat_imgs = [zeros(Gray{Float32}, 1)]
        io = IOBuffer()
        # These methods should not invoke the Images.jl display code, but they
        # used to throw errors: https://github.com/JuliaImages/Images.jl/issues/623
        @test !applicable(ImageShow._show_odd, io, MIME"text/html"(), flat_imgs)
        @test !applicable(ImageShow._show_even, io, MIME"text/html"(), flat_imgs)
    end
    rm(workdir, recursive=true)
end

nothing
