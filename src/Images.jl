module Images

export HomogeneousPoint

using StaticArrays

using Reexport
@reexport using ImageCore
@reexport using ImageBase

@reexport using FileIO: load, save
import Graphics # TODO: eliminate this direct dependency
using StatsBase  # TODO: eliminate this dependency
using IndirectArrays, ImageCore.MappedArrays

const is_little_endian = ENDIAN_BOM == 0x04030201 # CHECKME: is this still used?

@reexport using ImageTransformations
using ImageTransformations.Interpolations
@reexport using ImageAxes
@reexport using ImageMetadata
@reexport using ImageFiltering
@reexport using ImageMorphology
@reexport using ImageDistances
@reexport using ImageContrastAdjustment
@reexport using ImageQualityIndexes

# Non-exported symbol bindings to ImageShow so that we can use, e.g., `Images.gif`
import ImageShow: play, explore, gif

# While we are bridging the old API and the new API in ImageContrastAdjustment
# we need to import these functions because we make new definitions for them
# in deprecations.jl
import ImageContrastAdjustment: build_histogram, adjust_histogram, adjust_histogram!

import ImageMorphology: dilate, erode
using TiledIteration: EdgeIterator

# TODO(v1.0.0): remove these entry points
# Entry points that isn't used by JuliaImages at all
# They used to be accessible by, e.g., `Images.metadata`
import .Colors: Fractional
import FileIO: metadata
import Graphics: Point

include("compat.jl")
include("misc.jl")
include("labeledarrays.jl")
include("algorithms.jl")
include("deprecations.jl")
include("corner.jl")
include("edge.jl")

export
    # types
    BlobLoG,
    ColorizedArray,
    Percentile,

    # macros
    @test_approx_eq_sigma_eps,

    # core functions
    maxabsfinite,
    maxfinite,
    minfinite,

    # algorithms
    imcorner,
    imcorner_subpixel,
    corner2subpixel,
    harris,
    shi_tomasi,
    kitchen_rosenfeld,
    fastcorners,
    meancovs,
    gammacovs,
    imedge,  # TODO: deprecate?
    blob_LoG,
    findlocalmaxima,
    findlocalminima,
    imgaussiannoise,
    imlineardiffusion,
    imROF,
    otsu_threshold,
    yen_threshold,

    #Exposure
    imhist,
    histeq,
    adjust_gamma,
    histmatch,
    clahe,
    imadjustintensity,
    imstretch,
    cliphist,

    magnitude,
    magnitude_phase,
    meanfinite,
    entropy,
    orientation,
    phase,
    thin_edges,
    thin_edges_subpix,
    thin_edges_nonmaxsup,
    thin_edges_nonmaxsup_subpix,
    canny,
    integral_image,
    boxdiff,
    gaussian_pyramid,

    # phantoms
    shepp_logan

"""
Constructors, conversions, and traits:

    - Construction: use constructors of specialized packages, e.g., `AxisArray`, `ImageMeta`, etc.
    - "Conversion": `colorview`, `channelview`, `rawview`, `normedview`, `permuteddimsview`
    - Traits: `pixelspacing`, `sdims`, `timeaxis`, `timedim`, `spacedirections`

Contrast/coloration:

    - `clamp01`, `clamp01nan`, `scaleminmax`, `colorsigned`, `scalesigned`

Algorithms:

    - Reductions: `maxfinite`, `maxabsfinite`, `minfinite`, `meanfinite`, `integral_image`, `boxdiff`, `gaussian_pyramid`
    - Resizing: `restrict`, `imresize` (not yet exported)
    - Filtering: `imfilter`, `imfilter!`, `mapwindow`, `imROF`, `padarray`
    - Filtering kernels: `Kernel.` or `KernelFactors.`, followed by `ando[345]`, `guassian2d`, `imaverage`, `imdog`, `imlaplacian`, `prewitt`, `sobel`
    - Exposure : `imhist`, `histeq`, `adjust_gamma`, `histmatch`, `imadjustintensity`, `imstretch`, `imcomplement`, `clahe`, `cliphist`
    - Gradients: `backdiffx`, `backdiffy`, `forwarddiffx`, `forwarddiffy`, `imgradients`
    - Edge detection: `imedge`, `imgradients`, `thin_edges`, `magnitude`, `phase`, `magnitudephase`, `orientation`, `canny`
    - Corner detection: `imcorner`,`imcorner_subpixel`, `harris`, `shi_tomasi`, `kitchen_rosenfeld`, `meancovs`, `gammacovs`, `fastcorners`
    - Blob detection: `blob_LoG`, `findlocalmaxima`, `findlocalminima`
    - Morphological operations: `dilate`, `erode`, `closing`, `opening`, `tophat`, `bothat`, `morphogradient`, `morpholaplace`, `feature_transform`, `distance_transform`, `convexhull`
    - Connected components: `label_components`, `component_boxes`, `component_lengths`, `component_indices`, `component_subscripts`, `component_centroids`

Test images and phantoms (see also TestImages.jl):

    - `shepp_logan`
"""
Images

end
