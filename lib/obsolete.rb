module Magick
  AddCompositeOp = ModulusAddCompositeOp
  deprecate_constant 'AddCompositeOp'

  AlphaChannelType = AlphaChannelOption
  deprecate_constant 'AlphaChannelType'

  ColorSeparationMatteType = ColorSeparationAlphaType
  deprecate_constant 'ColorSeparationMatteType'

  CopyOpacityCompositeOp = CopyAlphaCompositeOp
  deprecate_constant 'CopyOpacityCompositeOp'

  DistortImageMethod = DistortMethod
  deprecate_constant 'DistortImageMethod'

  DivideCompositeOp = DivideDstCompositeOp
  deprecate_constant 'DivideDstCompositeOp'

  FilterTypes = FilterType
  deprecate_constant 'FilterTypes'

  GrayscaleMatteType = GrayscaleAlphaType
  deprecate_constant 'GrayscaleMatteType'

  ImageLayerMethod = LayerMethod
  deprecate_constant 'ImageLayerMethod'

  InterpolatePixelMethod = PixelInterpolateMethod
  deprecate_constant 'InterpolatePixelMethod'

  MeanErrorPerPixelMetric = MeanErrorPerPixelErrorMetric
  deprecate_constant 'MeanErrorPerPixelMetric'

  MinusCompositeOp = MinusDstCompositeOp
  deprecate_constant 'MinusCompositeOp'

  PaletteBilevelMatteType = PaletteBilevelAlphaType
  deprecate_constant 'PaletteBilevelMatteType'

  PaletteMatteType = PaletteAlphaType
  deprecate_constant 'PaletteMatteType'

  PeakSignalToNoiseRatioMetric = PeakSignalToNoiseRatioErrorMetric
  deprecate_constant 'PeakSignalToNoiseRatioMetric'

  SubtractCompositeOp = ModulusSubtractCompositeOp
  deprecate_constant 'SubtractCompositeOp'

  TrueColorMatteType = TrueColorAlphaType
  deprecate_constant 'TrueColorMatteType'

  UndefinedMetric = UndefinedErrorMetric
  deprecate_constant 'UndefinedMetric'

  deprecate_constant 'ConstantVirtualPixelMethod'
  deprecate_constant 'FlattenAlphaChannel'
  deprecate_constant 'IntegerPixel'
  deprecate_constant 'MatteChannel'
  deprecate_constant 'OpaqueOpacity'
  deprecate_constant 'Rec601LumaColorspace'
  deprecate_constant 'Rec709LumaColorspace'
  deprecate_constant 'ResetAlphaChannel'
  deprecate_constant 'StaticGravity'
  deprecate_constant 'TransparentOpacity'
end
