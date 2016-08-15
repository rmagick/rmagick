# Change Log

All notable changes to this project are documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## RMagick 2.16.0

- Support ImageMagick 6.9+ - @ZipoKing

## RMagick 2.15.4

- Improved C extension building process - @u338steven

## RMagick 2.15.3

- Fixed ImageMagick version detection on Windows - @maisumakun

## RMagick 2.15.2

- GitHub repository moved back to github.com/rmagick/rmagick - @wurde, @vassilevsky

## RMagick 2.15.1

- Fix loop in linked list in `ImageList` methods => they no longer hang - @u338steven

## RMagick 2.15.0

- Ability to remove alpha channel - @ollie
- C local variables guarded against GC to avoid segfaults - @u338steven
- trace_proc protected with a mutex to avoid segfaults - @u338steven

## RMagick 2.14.0

- `RMagick.rb` moved to deprecated directory - @mockdeep
- Better ImageMagick feature detection - @bf4
- Prevent compilation failures if prefix is an empty string - @voxik
- `SplineInterpolatePixel` preprocessor check removed - @joshk
- Make error format a string literal - @mtasaka
- Automatically set `ARCHFLAGS` on OS X - @u338steven
- Fixed `rmagick/version` require failure - @u338steven
- Fixed escaping of `%` in `Draw#get_type_metrics` - @mkluczny
- Silence warnings on Ruby 2.2 when comparing Enums - @meanphil
- Multiple test suite improvements - @mockdeep, @bf4
- Ruby source code formatting with RuboCop - @vassilevsky

## RMagick 2.13.4

- Proof of concept for using `pkg-config` in place of `Magick-config` on debian based systems (#129) - @theschoolmaster
- Changed `Image#resample` to calling `ResampleImage` (#127, related #29, #45) - @u338steven
- Fixed #122: `lib/RMagick.rb` is overwritten by `lib/rmagick.rb` on case-insensitive systems (#124) - @u338steven
- New class `SolidFill` in order to fill image with monochromatic background (#123) - @prijutme4ty
- Quotes for correct path of font file (#121) - @markotom
- Allow `MagickCore6` from `Magick-config` (#120) - @chulkilee
- Fixed: build error with ImageMagick 6.8.9 (when deprecated functions are excluded) (#112) - @u338steven
- Fixed: related x_resolution, y_resolution (#102) - @u338steven
- Lots of test fixes - @u338steven
- Fix pixel hash test (#95) - @ioquatix
- Fixed: build error on Windows Ruby x64 (with ImageMagick 6.8.0-10 / ImageMagick 6.8.7-7) (#94) - @u338steven

## RMagick 2.13.3

- Fix installation error on systems with HRDI enabled RMagick (#90) - @bricef

## RMagick 2.13.2

- Fixed issues preventing RMagick from working with version 6.8 or higher
- Fixed issues preventing RMagick from working with ruby 1.9.3

## RMagick 2.13.1

- Fixed bug preventing RMagick from working with version 6.5.9 or higher

## RMagick 2.13.0

- Added Doxygen documentation, for automatic documentation
- Fixed bug #27467, get RMagick to compile witH ImageMagick 6.5.7
- Fixed bug #27607, switch `Pixel#from_hsla` and `Pixel#to_hsla` to use ranges
  0-255 instead of 0-100 for saturation and lightness (range used by
  ImageMagick 6.5.6-5 and higher). Also added ability to specify all
  arguments to these functions as percentages (bug report by Arthur Chan).


## RMagick 2.12.2

- Add feature tests for `SinusoidFunction` and `PolynomialFunction` enum
  values to allow compiling with ImageMagick 6.4.8-7 (bug report by Mark
  Richman)

## RMagick 2.12.1

- Fix bug #27239, allow 2.12.0 to compile with older releases of ImageMagick
  (bug report by Sam Lown)

## RMagick 2.12.0

- Added `Image#function_channel` (available in ImageMagick 6.4.8-8)
- Added `Image#auto_level_channel`, `Image#auto_gamma_channel` (available in
  ImageMagick 6.5.5-1)
- Added `Draw#interline_spacing`, `#interline_spacing=` (available in
  ImageMagick 6.5.5-8)

## RMagick 2.11.1

- Applied Alexey Borzenkov's mingw patches to `extconf.rb`.
- Fixed a bug in `Magick.trace_proc` that could cause a segv at program exit
  with Ruby 1.9.1 (bug report by Larry Young)
- Added new `CompressionType` enum values `ZipSCompression`, `PixCompression`,
  `Pxr24Compression`, `B44Compression`, `B44ACompression` (available in
  ImageMagick 6.5.5-4)

## RMagick 2.11.0

- Fix bug #26475, dissolve and watermark don't work with new versions of
  ImageMagick (reported by Jim Crate)
- Add `Image#composite_mathematics` (available in ImageMagick 6.5.4-3)
- Add new `LinearDodgeCompositeOp`, `LinearBurnCompositeOp`,
  `PegtopCompositeOp`, `PinLightCompositeOp`, `VividLightCompositeOp` enum values
  (available in ImageMagick 6.5.4-3)

## RMagick 2.10.0

- ImageMagick releases earlier than 6.3.5-10 and Ruby releases earlier
  than 1.8.5 no longer supported.
- (Experimental) Support the use of Ruby managed memory for all memory
  allocations (available in ImageMagick 6.5.3-10)
- Add `Image#selective_blur_channel` (available in ImageMagick 6.5.0-3)
- Add new `AlphaBackgroundChannel` enum value (available in ImageMagick
  6.5.2-5)
- Add new `DistortCompositeOp` enum value (available in ImageMagick 6.5.3-7)

## RMagick 2.9.2

- Add new `HorizontalTileEdgeVirtualPixelMethod`,
  `VerticalTileEdgeVirtualPixelMethod`, `CheckerTileVirtualPixelMethod`
  `VirtualPixelMethod` enum values (available in ImageMagick 6.5.0-1)
- Added `BilinearForwardDistortion`, `BilinearReverseDistortion` enums
  (available in ImageMagick 6.5.1-2)
- Add missing composite operators to `Magick::Draw#composite` method
- Add warning about dropping support for ImageMagick < 6.3.5 and
  Ruby < 1.8.5
- Fix bug #25892, stack buffer overflow in `Magick::TypeMetric.to_s`
  (reported by Roman Simecek)

## RMagick 2.9.1

- Fix a bug that prevents the use of transparent background colors when
  built with ImageMagick 6.4.9-0

## RMagick 2.9.0

- Fix #23209, improve RVG's letter spacing (patch from Jonah Fox)
- Add `Draw#kerning=` attribute (available in ImageMagick 6.4.7-8)
- Add `Draw#interword_spacing=` attribute (available in ImageMagick
  6.4.8-0)
- Add `Draw#kerning`, `Draw#interword_spacing` primitive methods (available in
  ImageMagick 6.4.8-3)
- Feature #23171, support `ImageList`, `Draw`, `Pixel` marshaling.
- Support all the new `EvaluateOperator` constants

## RMagick 2.8.0

- Add the `endian`, `scene`, and `transparent_color` attributes to `Image::Info`
- Deprecate `Image#endian=` attribute setter
- Add the `transparent_chroma` method to the `Image` class (available in
  ImageMagick 6.4.5-6)
- Add the `sparse_color` method to the `Image` class (available in ImageMagick
  6.4.3)
- Update `Image#change_geometry` to work with the new `ParseSizeGeometry` API
  in ImageMagick 6.4.6-9.

## RMagick 2.7.2

- Fix bug #22740, some `Image::Info` attribute values are not propogated to
  the image object (bug report by Thomas Watson)

## RMagick 2.7.1

- Fix bug #22471, `Magick::fonts` can abend on 64-bit systems (bug report and
  patch by James Le Cuirot)
- `ImageList.new` accepts a block which is passed on to `Image::read` when
  reading the input  images. The block is executed in the context of an
  `Image::Info` object.
- Add support for the "user" image property.
- Define the `Magick::FatalImageMagickError` exception class, raised if
  ImageMagick raises a fatal (unrecoverable) exception.
- Added feature #22618, `Image#total_ink_density` (request by F. Behrens)

## RMagick 2.7.0

- Fix bug #22152, `extconf.rb` does not respect the `LDFLAGS` environment
  variable (bug report by Joseph Sokol-Margolis)
- Fix bug #22190, the `NoDitherMethod` enum value is not defined in
  ImageMagick 6.4.2
- Add the `TrimBoundsLayer` `ImageLayerMethod` enum value (available in
  ImageMagick 6.4.3-8)
- Add the `CopyAlphaChannel`, `ExtractAlphaChannel`, `OpaqueAlphaChannel`,
  `ShapeAlphaChannel`, and `TransparentAlphaChannel` `AlphaChannelType` enum
  values (available in ImageMagick 6.4.3-7)
- Rename `Image#affinity` and `ImageList#affinity` to `Image#remap` and
  `ImageList#remap`. Retain the old names as aliases. (Changed in ImageMagick
  6.4.4-0)

## RMagick 2.6.0

- Fix bug #21237, `Image::write` ignores format attribute when called with a
  `Tempfile` pathname (bug report by Jack Shedd)
- Fix bug #21897, `ImageList#from_blob` abends when certain corrupt JPEG
  images are used (bug report by Peter Szabo)
- Add `Image#composite_tiled`, `Image#composite_tiled!` (ref:
  http://rubyforge.org/forum/forum.php?thread_id=27347&forum_id=33)
- Add `Image#deskew` (available with ImageMagick 6.4.2-5)
- Add `Image#define`, `Image#undefine` (available in ImageMagick 6.3.6)
- Add `Image#level_colors` (available in ImageMagick 6.4.2-1)
- Add `Image#levelize_channel` (available in ImageMagick 6.4.2-1)
- Add `Image#affinity`, `ImageList#affinity` (available in ImageMagick 6.4.3-6).
  These methods replace `Image#map` and `ImageList#map`.
- Accept `DitherMethod` values for the `dither` argument to `Image#quantize`,
  `ImageList#quantize`
- Add the `BarrelDistortion`, `PolynomialDistortion`, `ShepardsDistortion`,
  `PolarDistortion`, and `DePolarDistortion` `MagickDistortion` Method enum values
  (available in ImageMagick 6.4.2-6)
- Add the `HorizontalTileVirtualPixelMethod` and
  `VerticalTileVirtualPixelMethod` `VirtualPixelMethod` enum values
  (available in ImageMagick 6.4.2-6)
- Add `DitherMethod` enum class
- Added general-purpose `OptionalMethodArguments` class to handle ad-hoc
  optional arguments.
- Support optional "distort:viewport" and "distort:scale" arguments to
  `Image#distort`
- Support optional `highlight_color` and `lowlight_color` arguments
  to `Image#compare_channel`

## RMagick 2.5.2

- Add support for `MergeLayer` to `Magick::ImageList#optimize_layers` (patch
  #21189, submitted by Andrew Watson)
- Add `PowQuantumOperator` argument for `Image#quantum_operator` (available
  in ImageMagick 6.4.1-9)

## RMagick 2.5.1

- Update `Pixel#to_color` to work with the new `QueryMagickColorname` API in
  ImageMagick 6.4.1-9.

## RMagick 2.5.0

- Added `Image#add_compose_mask`, `#delete_compose_mask` (feature #20531)

## RMagick 2.4.0

- Added `Image#image_type=` (feature #20490)

## RMagick 2.3.0

- Added `Image#encipher`, `Image#decipher` (available with ImageMagick 6.3.8-6)
- Added `DXT1Compression`, `DXT3Compression`, and `DXT5Compression`
  `CompressionType` enums (available in ImageMagick 6.3.9-4)
- Added optional "use hex format" argument to `Pixel#to_color`
- Support `:area` resource type in `Magick.limit_resource`
- `Pixel.from_HSL` and `Pixel#to_HSL` are deprecated. Use `Pixel.from_hsla`
  and `Pixel#to_hsla` instead. The new methods rely on the ImageMagick 6.3.5
  and later API.
- The `Image#alpha` and `alpha=` attributes are deprecated. Use `alpha()` and
  `alpha?` instead.
- The `Image#mask=` attribute is deprecated. Use `mask()` instead.
- The use of Ruby older than version 1.8.4 with RMagick is deprecated and
  will not be supported in a future release.
- Fix bug #18271, rvg width and height attributes wrong after a call to
  viewbox (reported by Greg Jarman)

## RMagick 2.2.2

- Fix bug #18016, add test for `InitializeMagick` in `libMagickCore` to
  `extconf.rb`

## RMagick 2.2.0

- Added `Image#opaque_channel`, `Image#paint_transparent` (available with
  ImageMagick 6.3.7-10)
- Added `Image#liquid_rescale` (available with ImageMagick 6.3.8-2)
- Added `CMYColorspace` `ColorspaceType` value
- Fixed bug #17148, compiler error message on Solaris (bug report by Trever
  Wennblom)
- Fixed bug #17470, `get_exif_by_number`, `get_exif_by_entry` may fail when
  called with one or more arguments

## RMagick 2.1.0

- Added `Image::Info#caption=` attribute
- Rename `Image#crop_resized`, `#crop_resized!` to `#resize_to_fill`,
  `#resize_to_fill!`. Add aliases for the old names.
- Fix bug #16776, in the `axes.rb` example the last 2 arguments to
  `border.rectangle` are swapped (bug report by Alain Feler)
- Fix bug #16931, apostrophe in #error directive causes error in some
  versions of GCC (bug report by Justin Dossey)

## RMagick 2.0.0

- Replaced `configure`/`make`/`make install` with standard Ruby `setup.rb`,
  `extconf.rb`
- Removed support for Ruby earlier than 1.8.2
- Removed support for GraphicsMagick. As a result these methods are no
  longer available: `Image#grayscale_pseudo_class`, `Image#statistics`.
- Removed support for all releases of ImageMagick earlier than 6.3.0.
- Removed deprecated `Image#random_channel_threshold`. Use
  `Image#random_threshold_channel` instead
- Removed deprecated `Image#channel_threshold`. Use
  `Image#random_threshold_channel` instead
- Removed unecessary `Image#montage=`
- Removed unecessary and undocumented `Image#image_type=`
- Removed deprecated `Image::Info#tile_info`, `tile_info=` attributes.
- Removed deprecated `Image::Info#tile`, `tile=` attributes. Use `#extract`,
  `#extract=` instead
- Removed deprecated `Image::Info#subimage`, `subimage=` attributes. Use
  `scene`, `scene=` instead
- Removed deprecated `Image::Info#subrange`, `subrange=` attributes. Use
  `number_scenes`, `number_scenes=` instead
- Removed deprecated `Magick.set_monitor`. Use `Image#set_monitor`,
  `Image::Info#set_monitor` instead
- Removed deprecated `RunlengthEncodedCompression` `CompressionType`. Use
  `RLECompression` instead
- Deprecated `Image#matte`, `matte=` with ImageMagick 6.3.5 and later
- Added `Image::Info#stroke=`, `stroke_width=` and `undercolor=` attributes
- Added `Image::Info#tile_offset=` attribute
- Added `Draw#fill_pattern=` and `#stroke_pattern=` annotate attributes
- Changed `Image::Info[]` and `Image::Info[]=` to allow an omitted "format"
  argument
- Added `Image#destroy!`, `destroyed?`, `check_destroyed` methods
- Support `Image` object creation/destruction tracing with the
  `Magick.trace_proc` attribute
- Added `Magick::QuantumRange`. `Magick::MaxRGB` is deprecated.
- Added `OptimizeTransLayer`, `RemoveDupsLayer`, `RemoveZeroLayer`,
  `OptimizeImageLayer` `ImageLayerMethods` enum values (available with
  ImageMagick 6.3.3),
  `MosaicLayer`, `FlattenLayer` (available with ImageMagick 6.3.6)
- RMagick works with Q32 version of ImageMagick
- Added `ChangeMaskCompositeOp`, `DivideCompositeOp`, `LinearLightCompositeOp`
  `CompositeOperator` enum values
- Added `SplineInterpolatePixel` `InterpolatePixelMethod` enum value
- Added `DitherVirtualPixelMethod`, `RandomVirtualPixelMethod`,
  `BlackVirtualPixelMethod`, `GrayVirtualPixelMethod`, `WhiteVirtualPixelMethod`
  (available with ImageMagick 6.3.5), and `MaskVirtualPixelMethod` (available
  with ImageMagick 6.3.3) `VirtualPixelMethod` enum values
- Added `GIFInterlace`, `JPEGInterlace`, `PNGInterlace` `Interlace` type enum
  values (available with ImageMagick 6.3.4)
- Added `SentinelFilter` `FilterTypes` enum value (available in ImageMagick
  6.3.6)
- Added `Image.combine`
- Added `Image#separate` (available with ImageMagick 6.3.2)
- Added `Image#distort` (available with ImageMagick 6.3.5)
- Added `Image#each_pixel` (thanks to Russell Norris for the suggestion and
  code)
- Added `Image#histogram?` (available with ImageMagick 6.3.5)
- Added `Image#sync_profiles`  (available with ImageMagick 6.3.2)
- Added `Image#extent` (available with ImageMagick 6.3.1)
- Added `Image#excerpt`, `Image#excerpt!` (available with ImageMagick 6.3.5)
- Added `Image::Info#attenuate`
- Added `Image#clut_channel` (available with ImageMagick 6.3.5)
- Feature Request #16264, added `ImageList#composite_layers` (available with
  ImageMagick 6.3.3, request from Steve Martocci)
- Added `Image#alpha=` (available with ImageMagick 6.3.5)
- Added `Image#gravity=`
- Added `Image#equalize_channel` (available with ImageMagick 6.3.6)
- Added new `FilterTypes` values `KaiserFilter`, `WelshFilter`, `ParzenFilter`,
  `LagrangeFilter`, `BohmanFilter`, `BartlettFilter` (available with ImageMagick
  6.3.6)
- Fix bug #10339, `Image#trim` does not support "reset page information
  option" (bug report from Nobody)
- Renamed `RMagick.so` to `RMagick2.so` to prevent confusion between `RMagick.rb`
  and `RMagick.so`
- Feature Request #16276, re-organize doc to not split `Image` method pages
  in the middle of an initial letter (request from Roy Leban)
- Updated for ImageMagick 6.3.7-5
- Made changes as necessary to work with current Ruby 1.9.0

## RMagick 1.15.12

- Fix bug #16221, starting with ImageMagick 6.3.2, get_exif_by_entry/number
  returns empty array/hash when no arguments are specified, even though the
  image has EXIF data (bug report from Paul Clegg)

## RMagick 1.15.11

- Fix bug #15887, the x_ and y_resolution attributes don't respect the units
  attribute (bug report from Ben Greenburg)
- Fix bug #15889, memory leak in Draw#composite method (bug report from Till
  Vollmer)

## RMagick 1.15.10

- Update Magick::Pixel.from_HSL, #to_HSL to work with new APIs in
  ImageMagick 6.3.5-9.

## RMagick 1.15.9

- Fixed bug #12089 (bug report from Hans de Graaff)

## RMagick 1.15.8

- Fixed bug #12671, incorrect link in HTML doc (bug report from Thomas R.
  Koll
- Fixed bug #11890, incorrect usage description for Draw#text_undercolor in
  HTML doc (bug report from Ezra Freedman)
- Fixed bug #12706, specifying both a gravity and offsets to Image#composite
  positions the composite image incorrectly (bug report from Benoit Larroque)

## RMagick 1.15.7

- Fix bug #11033, make distclean misses some files (bug report from Lucas
  Nussbaum)
- Work around SetMagickRegistry problem in ImageMagick 6.3.4-7

## RMagick 1.15.6

- Fix bug #10070, memory leak in Draw#get_type_metrics,
  Draw#get_multiline_type_metrics, Draw#annotate (bug report from Sinclair
  Bain)
- Fix bug #10080, scripts in examples directory should not be marked
  executable (bug report from Lucas Nussbaum)

## RMagick 1.15.5

- Fix bug #9637, export_pixels always exports all 0's for 1-bit images (bug
  report from Doug Patterson)

## RMagick 1.15.4

- Fix bug #8927, RMagick and rbgsl both export the name ID_call (bug report
  from Shin Enomoto)

## RMagick 1.15.3

- Fix bug #8697, Image::Info.fill= doesn't work when creating "caption:"
  format images (bug report from choonkeat)

## RMagick 1.15.2

- Fix bug #8408, a compatibility problem with some versions of ImageMagick
  before 6.2.5 (bug report from Geir Gluckstad)

## RMagick 1.15.1

- Fix bug #8307, compatibility problems with older (6.0.x) versions of
  ImageMagick (bug report from Chris Taggart)

## RMagick 1.15.0

- Added fx method to ImageList class
- Added wet_floor method to the Image class
- Added linear_stretch method to the Image class (available with
  ImageMagick 6.3.1-1)
- Added recolor method to the Image class (available with ImageMagick 6.3.1-3)
- Added polaroid method to the Image class (available with ImageMagick 6.3.1-6)
- Added origin attribute to the Image::Info class (supported by
  ImageMagick 6.3.1-4 and later)
- Added PaletteBilevelMatteType to the ImageType enum
- Fix bug #6260, some RVG examples produce all-black GIF images
- Fix bug #7034, fix the matte method in the Draw class
- Fix bug #7373, default channels should be RGB instead of RGBA
- Fix bug #7716, Pixel#intensity wrong for gray images (bug report from
  Morio Miki)
- Fix bug #7949, Magick::Draw.new abends when an exception occurs before
  the draw object is fully initialized (bug report from Andrew Kaspick)
- Fix bug #8015, Magick::Draw.new doesn't call the optional arguments block
  in the right scope (bug report from Andrew Kaspick)
- Tested with ImageMagick 6.3.2-0

## RMagick 1.14.1

- Handle change to the type of the ColorInfo.color field introduced by
  ImageMagick 6.3.0

## RMagick 1.14.0

- Feature request #5015, support CMYK->RGB conversions. Added the
  add_profile and delete_profiles to the Image class. Fixed the profile!,
  iptc_profile, and color_profile methods. Added the
  black_point_compensation attribute. (requested by Niklas Ekman)
- Added adaptive_blur, adaptive_blur_channel, find_similar_region, sketch
  methods to the Image class (available with ImageMagick 6.2.8-6)
- Added adaptive_resize to the Image class (available with
  ImageMagick 6.2.9)
- Added resample method to the Image class (thanks to Ant Peacocke for the
  idea)
- Added four new compositing methods to the Image class: blend, displace,
  dissolve, and watermark
- Feature request #5418, add get_iptc_dataset and each_iptc_dataset to the
  Image class (requested by Oliver Andrich)
- Added the bias and mask attributes to the Image class
- Added optional qualifier argument to Image#rotate
- Patch #5742 from Douglas Sellers, adds channel method to the Image::Info
  class.
- Added new ChannelType enum values
- Added texture= attribute writer to the Image::Info class
- Added tile= attribute writer to the Draw class
- Added  pixel_interpolation_method attribute, InterpolatePixelMethod enum
  class to the Image class (available with ImageMagick 6.2.9)
- Added "Magick Command Options and Their Equivalent Methods" page to the
  documentation
- Fix bug #5079, Image#quantum_operator method doesn't work (bug report
  from Pedro Martins)
- Fix bug #5080, incorrect RVG images when non-0 values used for the min_x
  or min_y arguments to RVG#viewbox (bug report from Daniel Harple)
- Fix bug #5370, the clip_mask= attribute doesn't work
- Fix bug #5506, wrong argument used to intialize AffineMatrix (bug
  report from Michael Shantzis)

## RMagick 1.13.0

- Added transform, transform!, transpose, transpose! methods to Image class
  (available with ImageMagick 6.2.8)
- Feature #4844, add auto_orient, auto_orient! methods to Image class
  (suggestion from John Oordopjes, available with ImageMagick 6.2.8)
- Added adaptive_sharpen, adaptive_sharpen_channel methods to Image class
  (available with ImageMagick 6.2.7)
- Added composite_image_channel, composite_image_channel! methods to Image
  class (added in ImageMagick 6.2.6)
- Added radial_blur_channel method to Image class (available in
  ImageMagick 6.2.4)
- Fix bug #4806, add hash, eql? methods to Pixel class (bug report from
  Tim Pease)
- Change extension filename to match RubyGems 0.9.0 expectations.
- Fix bug #4821, correct doc for Image#rotate (bug report from Tim Pease)
- Update the Draw#annotate documentation

## RMagick 1.12.0

- Fix bug #4630, the new signature for #level is incompatible with
  releases prior to 1.10.1 (bug report from Al Evans)

## RMagick 1.11.1

- Fix bug #4511, add Makefile, rmagick_config.h as dependencies
  in the Makefile (bug report from Eric Hodel)
- Ensure ExceptionInfo structures are freed

## RMagick 1.11.0

- Feature #3705, add resize_to_fit (thanks to Robert Manni for the code)
- Added optimize_layers method to the ImageList class (available with
  ImageMagick 6.2.6)
- Added limit_resource method to the Magick module
- Replaced install.rb with setup.rb, improved gem install
  (bug report from Ryan Davis)
- Added --disable-htmldoc option to setup.rb
- Fix bug #4104, incorrect label on example (reported by Jason Lee)
- Added contrast_stretch_channel to the Image class (available with
  ImageMagick 6.2.6)
- Improved Magick exception handling to eliminate memory leaks when an exception
  is rescued and execution continues.
- Tested with ImageMagick 6.2.7

## RMagick 1.10.1

- Fix bug #3437, memory leak in ImageList#to_blob
- Fix bug #3363, Image#composite doesn't work when the source image
  is bigger than the destination
- Fix bug #3635, Image#import_pixels doesn't accept FloatPixel or DoublePixel
  storage types
- Feature #3597, add border_color attribute to the Draw class

## RMagick 1.10.0

- Added add_noise_channel method to Image class (available with ImageMagick 6.2.5)
- Added vignette method to the Image class (available with ImageMagick 6.2.6)
- Added crop_resize method to the Image class (thanks to Jerret Taylor for
  the suggestion and original code)
- Added export_pixels_to_str method to the Image class
- Provided default arguments to Image#export_pixels
- Added "order" option to Image#ordered_dither
- Added cyan, magenta, yellow, and black attribute accessors to the Pixel class
- Added CineonLogRGBColorspace, LABColorspace, Rec601LumaColorspace,
  Rec601YCbCrColorspace, Rec709LumaColorspace, Rec709YCbCrColorspace,
  LogColorspace enumerators to the ColorspaceType enumeration class.
- Fixed bug #2844, Image#to_blob exits if the image is a 0x0 JPEG
- Fixed bug #2688, Image#annotate, Draw#get_multiline_type_metrics handle
  newline characters properly
- Tested with ImageMagick 6.2.6
- Removed support for all versions of ImageMagick prior to 6.0.0

## RMagick 1.9.3

- Feature #2521, add Image#distortion_channel method
- Fixed bug #2546, ImageList#to_blob builds multi-image blobs again. (ImageMagick 6.2.0
  silently broke the ImageToBlob method.) Thanks to Tom Werner for reporting this bug.
- Test with GraphicsMagick 1.1.7

## RMagick 1.9.2

- Feature #2412, add the virtual_pixel_method attribute and the VirtualPixelMethod
  enumeration
- Feature #2462, add the ticks_per_second attribute

## RMagick 1.9.1

- Fixed bug #2157, Image#total_colors is now an alias of Image#number_colors
- Fixed bug #2155, Image#dispose= now accepts a DisposeType enum, #dispose
  now returns a DisposeType enum.
- Fixed bug #2156, Image#properties no longer returns garbage for the property
  name and value.
- Fixed bug #2190, Image#compose now returns a CompositeOperator
- Fixed bug #2191, Image#composite no longer abends when called with 0 arguments
- Fixed bug #2213, ImageList#montage method no longer leaves the imagelist corrupt
  after raising an ImageMagickError
- Feature #2159, added GrayChannel ChannelType enum value, BlendCompositeOp and
  ColorBurnCompositeOp CompositeOperator enum values, RLECompression CompressionType
  enum value, deprecate RunlengthCompression
- Feature #2172, added optional argument to crop and crop! to reset the saved
  page offsets after cropping
- Deprecated Image#channel_threshold. This method is deprecated in ImageMagick.
- Feature #2373, change Image#import_pixels to accept a pixel data buffer as well
  as a pixel data array. (Thanks to Ara T. Howard for this suggestion!)
- Fixed to compile without errors with ImageMagick 6.2.4-4.

## RMagick 1.9.0

- Added Image#monitor=, Image::Info#monitor=. Deprecated Magick.set_monitor.
- Fixed bug #2070, support color names with embedded spaces
- Fixed bug #2109, properly scope Magick constants in RVG

## RMagick 1.8.3

- Tested with ImageMagick 6.2.3-2
- Added comment, delay, dispose, fill, gravity, and label attributes to
  Image::Info

## RMagick 1.8.2

- Fix bug #1983, potential buffer overflow in version_constants
- Added feature #2015, support the pointsize, authenticate,
  and sampling_factor attributes in Image::Info

## RMagick 1.8.1

- Fix bugs #1876, #1888, #1919
- Added feature #1941, RVG's polyline, polygon accept array arguments
- Numerous fixes to the RVG documentation

## RMagick 1.8.0

- Added Image#shadow (ImageMagick 6.1.7)
- Added Image::Info#undefine, #[], #[]=
- Added sigmoidal_contrast_channel, sepiatone to Image class (ImageMagick 6.2.1)
- Added JPEG2000Compression constant (ImageMagick 6.2.2)
- Incorporated RVG classes
- Added RVG documentation, examples, updated installer
- Tested with ImageMagick 6.2.2-0, latest GraphicsMagick 1.2

## RMagick 1.7.4

- Fix bug #1727
- Fix affine_transform.rb
- Tested with ImageMagick 6.2.1

## RMagick 1.7.3

- Fix bug #1553, a build issue with ImageMagick 6.0.x

## RMagick 1.7.2

- Fix bugs #1308, #1310, #1314, #1533

## RMagick 1.7.1

- Fix bugs #1250, #1253
- Tested with ImageMagick 6.1.7, Ruby 1.8.2

## RMagick 1.7.0

- Added splice, set_channel_depth to Image class (ImageMagick 6.0.0)
- Added sharpen_channel, blur_channel to Image class (ImageMagick 6.0.1)
- Added get_multiline_type_metrics to Draw class (ImageMagick 6.1.5),
  added new example scripts and images
- Added normalize_channel, unsharp_mask_channel to Image class
  (ImageMagick 6.1.0)
- Added read_inline to Image class
- Renamed channel_compare to compare_channel, retained old name as an alias
  for backward compatibility.
- Added default values for unsharp_mask arguments
- Fixed bug #1193
- Fixed segfault in destroy_Draw when Ruby gc'd the temp file name
  array before calling destroy_Draw
- Tested with ImageMagick 6.1.6, GraphicsMagick 1.1.4, Ruby 1.8.2preview3.

## RMagick 1.6.2

- Fixed ImageList#deconstruct to return an imagelist
- Fixed installation procedure to propagate user's CFLAGS, CPPFLAGS,
  and LDFLAGS through to the low-level Makefile
- Fixed bugs #1048, #1127

## RMagick 1.6.1

- Changed to match changes in ImageMagick 6.1.4 API
- Fixed bug #950

## RMagick 1.6.0

- Added posterize, gaussian_blur_channel, convolve_channel methods to Image class
  (ImageMagick 6.0.0)
- Added new CompositeOperator constants (ImageMagick 6.0.0)
- Added trim and trim! methods to Image class
- Added each method to Enum subclasses
- Added stroke_width= attribute to the Draw class
- Fixed bugs #624, #642, #716, applied patch #819 (thanks to Daniel Quimper)
- Tested with ImageMagick 6.0.5-2, GraphicsMagick 1.1.3, Ruby 1.8.2

## RMagick 1.5.0

- Added meaningful implementations of dup and clone to the Image and Draw
  classes. Clarified the documentation.
- Do not allow changes to frozen Image, ImageList, and Draw objects.
- Raise TypeError if freeze method sent to Image::Info or ImageList::Montage
  object.
- Added view method to Image, Image::View class (thanks to Ara T. Howard and
  Charles Comstock on c.l.r for the discussion which prompted me to add this class)
- Added grayscale_pseudo_class method to Image class (GraphicsMagick 1.1)
- Added radial_blur, random_threshold_channel methods to Image class
  (ImageMagick 6.0.0)
- Added quantum_operator method to Image class (GraphicsMagick 1.1, ImageMagick 6.0.0)
- Added statistics method to Image class (GraphicsMagick 1.1)
- Support channel_extrema, channel_mean with GraphicsMagick 1.1
- Added endian attribute to Image class
- Added composite! method to Image class
- Deprecated random_channel_threshold method when linked with ImageMagick 6.0.0.

## RMagick 1.4.0

- Revised and updated documentation
- Implemented enumeration values as instances of an Enum
  class. Based on a description by Paul Brannon in ruby-talk 79041.
- Added HSLColorspace, HWBColorspace constants (ImageMagick 5.5.7,
  GraphicsMagick 1.0.2)
- Added CopyCyanCompositeOp, CopyMagentaCompositeOp,
  CopyYellowCompositeOp, CopyBlackCompositeOp constants (ImageMagick 5.5.7,
  GraphicsMagick 1.1)
- Added ReplaceCompositeOp. CopyCompositeOp constants (ImageMagick 6.0.0)
- Added color_histogram to Image class. (ImageMagick 6.0.0, GraphicsMagick 1.1)
- Added define method to Image::Info class (ImageMagick 6.0.0, GraphicsMagick 1.1)
- Added tint, each_profile, channel_extrema, channel_compare,
  channel_depth, channel_mean, quantum_depth, preview, gamma_channel,
  negate_channel, bilevel_channel methods to Image class (ImageMagick 6.0.0)
- Added get_exif_by_entry, get_exif_by_tag to Image class
- Added border! method to Image class
- Added fcmp, intensity methods to Pixel class
- Added Version_long constant
- The 'fuzz' attribute in the Image and ImageInfo classes now
  accepts a percentage value as well as a numeric value.
- Added Geometry class and changed all methods that accept a geometry
  string to accept a Geometry object as well
- Added dup and clone methods to the ImageList, Image, and Draw
  classes (Fix for bug #254.)
- Tested with latest ImageMagick 6.0.0 beta and GraphicsMagick 1.1 snapshot

## RMagick 1.3.2

- Fix profile! to require only 2 arguments, as documented.
- Correct spelling of 'transparent' in text_antialias.rb example.
- Add output of `Magick-config --libs` to LIBS variable in configure
- Minor fixes in documentation
- Test with GraphicsMagick 1.0.4
- Test with latest ImageMagick 5.5.8 beta

## RMagick 1.3.1

- Fixed default base URI in the links to the installed xMagick doc
- Applied the patch for bug #76 that caused the rubyname.rb example
  to hang when installing on FreeBSD.
- Fixed the <=> method in Image to return nil when the class of the
  other object is not Image
- Added code to ensure that the `text' argument to Draw#text is not
  nil or empty
- Fixed the handle_error function to re-initialize the exception
  structure after destroying its contents.

## RMagick 1.3.0

- Added strip!, import_pixels, export_pixels, random_channel_threshold
  to the Image class. (Available only with ImageMagick 5.5.8, which
  is still in beta.)
- Added black_threshold and white_threshold to the Image class.
- Added format= attribute writer to the Image class
- Added monochrome= attribute writer to the Image::Info class
- Added annotate to the Image class.
- Made the image argument to get_type_metrics optional. (Thanks to
  Hal Fulton for suggesting this change and the annotate change!)
- Enhance the read, write, and ping methods in both the Image
  class and the ImageList class to accept an open File object as
  well as a filename argument.
- Added change_geometry to the Image class
- Changed configure to generate top-level Makefile with install
  and uninstall targets. (Thanks to Bob Friesenhahn for the
  suggestion and the the Makefile!)
- Incorporated 1.2.2.1 patch to correct problems when building
  with Ruby 1.6.7.
- Added "magick_location" attribute to the ImageMagickError
  class. (Available only with GraphicsMagick 1.1, not yet released.)
- Tested with ImageMagick 5.5.8 beta
- Tested with GraphicsMagick 1.0.2 and 1.1 snapshot
- Tested with Ruby 1.8.0
- Changed to MIT license

## RMagick 1.2.2

- Fixed many bugs in configuration script
- Added support for GraphicsMagick 1.0 (with assistance from Bob Friesenhahn)
- Changed default documentation directory (--doc-dir option default) to
  $prefix/share/RMagick
- Added "examples" directory to contain example programs that aren't
  referenced by the documentation

## RMagick 1.2.1

- Yet another fix to the Cygwin installation procedure

## RMagick 1.2.0

- Changed install to work correctly on Cygwin
  (Cygwin testing by Yuki Hirakawa and David Martinez Garcia.)
- Changed install to support Gentoo ebuild
  (Gentoo support provided by Tom Payne.)
- Changed configure script to find IM doc in IM 5.5.7
- Added Image#capture
- Added optional matte_pct argument to Image#colorize
- Add default argument values to Image#gaussian_blur
- Fix bug in Image#store_pixels that prevented it from working with
  GIF and other PseudoClass image formats
- Changed Image#crop and Image#crop! to accept a GravityType constant
  as the first argument, instead of the x- and y-offset arguments.
  (Suggested by Robert Wagner.)
- Added Image::Info#filename=, image_type=
- Added ImageList#__map__ as an alias for Enumerable#map
- Added fetch, insert, select, reject methods to ImageList class for
  Ruby 1.8.0
- Undefined zip and transpose methods in ImageList class for Ruby 1.8.0
- ImageMagick 5.5.7 supported

## RMagick 1.1.0

- Fixed bug in handle_error that caused an abend when linked with IM 5.5.6
- Added RMAGICK image "format". When read, returns 252x108 RMagick logo
  in PNG format.
- Changed examples to give all floating point constants a leading digit.
- Added Image#rotate!
- Tested with Ruby 1.8.0preview2
- Added Image#extract_info, Image::Info#extract=, Image::Info#scene=,
  Image::Info#number_scenes=, Image::Info#tile=
- Added Draw#text_align, Draw#text_anchor, Draw#text_undercolor
- ImageMagick 5.5.6 supported

## RMagick 1.0.0

- Fixed warnings when compiling with Ruby 1.8.0
- Added Draw#rotation=, rotated_text.rb
- Fixed temp image files in Montage_texture and Draw_composite
- ImageMagick 5.5.5 supported

## RMagick 0.9.5

- Added channel.rb example
- Fixed install problems with IM 5.5.1

## RMagick 0.9.4

- Cleaned up documentation.
- Added logging methods Magick.set_log_event_mask and Magick.set_log_format
- Added Magick.set_monitor
- Added custom serialization methods _dump and _load to Image class.
  Added marshaling section to usage doc.
- Added Image#mime_type
- Changed install to use autoconf-generated configure script
- Replaced makedoc.rb with post-install.rb hook
- Added rmconst.rb utility script
- ImageMagick 5.5.4 supported

## RMagick 0.9.3

- Changed ImageList#<=> to use same algorithm as Array#<=>
- Changed Draw class variables to class constants
- Fixed bug in Magick::colors method that caused some colors
  to be repeated or missed when the optional block is used
- Changed fill classes to not inherit from common Fill class.
  Removed Fill class.
- Improved usage documentation
- Added Image#level_channel, introduced with IM 5.5.3
- ImageMagick 5.5.3 supported
- Ruby 1.6.8, 1.8.0preview1 supported

## RMagick 0.9.2

- Added crop!, flip!, flop!, magnify!, minify!, resize!, sample!,
  scale!, shave!, channel_threshold methods to Image class
- Documented DisposeType, ColorSeparationMatteType and OptimizeType
  constants
- Changed Image#<=>, ImageList#<=> to raise TypeError if the other
  argument is not in the same class
- Deleted Image#==, ImageList#==, include Comparable in both classes
- Added Image#thumbnail, thumbnail!, adaptive_threshold for 5.5.2 & later
- Used image list functions in 5.5.2 & later
- ImageMagick 5.5.2 supported
- Removed last vestiges of 5.4.9 support

## RMagick 0.9.1

- Added -Wl,rpath option to $LDFLAGS in extconf.rb
- #include <sys/types.h> in rmagick.h
- Changed set_cache_threshold to call SetMagickResourceLimit instead of SetCacheThreshold
- Changed Image_texture_flood_fill to clone texture image instead of adding a reference
- Many fixes to the Array methods in ImageList
- Defined Image#<=>, defined Image#== in terms of Image#<=>
- Defined ImageList#<=> in terms of Image#<=>

## RMagick 0.9.0

1st beta
