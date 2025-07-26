# frozen_string_literal: true

# $Id: rmagick_internal.rb,v 1.84 2009/09/15 22:08:41 rmagick Exp $
#==============================================================================
#                  Copyright (C) 2009 by Timothy P. Hunter
#   Name:       rmagick_internal.rb
#   Author:     Tim Hunter
#   Purpose:    Extend Ruby to interface with ImageMagick.
#   Notes:      RMagick2.so defines the classes. The code below adds methods
#               to the classes.
#==============================================================================

if RUBY_PLATFORM.match?(/mingw/i)
  require 'ruby_installer'
  ENV['PATH'].split(File::PATH_SEPARATOR).grep(/ImageMagick/i).each do |path|
    RubyInstaller::Runtime.add_dll_directory(path) if File.exist?(File.join(path, 'CORE_RL_magick_.dll')) || File.exist?(File.join(path, 'CORE_RL_MagickCore_.dll'))
  end
end

require 'English'
require 'observer'
require 'RMagick2.so'

module Magick
  IMAGEMAGICK_VERSION = Magick::Magick_version.split[1].split('-').first

  class << self
    # Describes the image formats supported by ImageMagick.
    # If the optional block is present, calls the block once for each image format.
    # The first argument, +k+, is the format name. The second argument, +v+, is the
    # properties string described below.
    #
    # - +B+ is "*" if the format has native blob support, or " " otherwise.
    # - +R+ is "r" if ImageMagick can read that format, or "-" otherwise.
    # - +W+ is "w" if ImageMagick can write that format, or "-" otherwise.
    # - +A+ is "+" if the format supports multi-image files, or "-" otherwise.
    #
    # @overload formats
    #   @return [Hash] the formats hash
    #
    # @overload formats
    #   @yield [k, v]
    #   @yieldparam k [String] the format name
    #   @yieldparam v [String] the properties string
    #   @return [Magick]
    #
    # @example
    #   p Magick.formats
    #   => {"3FR"=>" r-+", "3G2"=>" r-+", "3GP"=>" r-+", "A"=>"*rw+",
    #   ...
    def formats(&block)
      formats = init_formats

      if block
        formats.each(&block)
        self
      else
        formats
      end
    end
  end

  # Geometry class and related enum constants
  class GeometryValue < Enum
    # no methods
  end

  PercentGeometry  = GeometryValue.new(:PercentGeometry, 1).freeze
  AspectGeometry   = GeometryValue.new(:AspectGeometry, 2).freeze
  LessGeometry     = GeometryValue.new(:LessGeometry, 3).freeze
  GreaterGeometry  = GeometryValue.new(:GreaterGeometry, 4).freeze
  AreaGeometry     = GeometryValue.new(:AreaGeometry, 5).freeze
  MinimumGeometry  = GeometryValue.new(:MinimumGeometry, 6).freeze

  class Geometry
    FLAGS = ['', '%', '!', '<', '>', '@', '^'].freeze
    RFLAGS = {
      '%' => PercentGeometry,
      '!' => AspectGeometry,
      '<' => LessGeometry,
      '>' => GreaterGeometry,
      '@' => AreaGeometry,
      '^' => MinimumGeometry
    }.freeze

    attr_accessor :width, :height, :x, :y, :flag

    def initialize(width = nil, height = nil, x = nil, y = nil, flag = nil)
      raise(ArgumentError, "width set to #{width}") if width.is_a? GeometryValue
      raise(ArgumentError, "height set to #{height}") if height.is_a? GeometryValue
      raise(ArgumentError, "x set to #{x}") if x.is_a? GeometryValue
      raise(ArgumentError, "y set to #{y}") if y.is_a? GeometryValue

      # Support floating-point width and height arguments so Geometry
      # objects can be used to specify Image#density= arguments.
      if width.nil?
        @width = 0
      elsif width.to_f >= 0.0
        @width = width.to_f
      else
        Kernel.raise ArgumentError, "width must be >= 0: #{width}"
      end
      if height.nil?
        @height = 0
      elsif height.to_f >= 0.0
        @height = height.to_f
      else
        Kernel.raise ArgumentError, "height must be >= 0: #{height}"
      end

      @x    = x.to_i
      @y    = y.to_i
      @flag = flag
    end

    # Construct an object from a geometry string
    W = /(\d+\.\d+%?)|(\d*%?)/
    H = W
    X = /(?:([-+]\d+))?/
    Y = X
    RE = /\A#{W}x?#{H}#{X}#{Y}([!<>@\^]?)\Z/

    def self.from_s(str)
      m = RE.match(str)
      if m
        width  = (m[1] || m[2]).to_f
        height = (m[3] || m[4]).to_f
        x      = m[5].to_i
        y      = m[6].to_i
        flag   = RFLAGS[m[7]]
      else
        Kernel.raise ArgumentError, 'invalid geometry format'
      end
      flag = PercentGeometry if str['%']
      Geometry.new(width, height, x, y, flag)
    end

    # Convert object to a geometry string
    def to_s
      str = +''
      if @width > 0
        fmt = @width.truncate == @width ? '%d' : '%.2f'
        str << sprintf(fmt, @width)
        str << '%' if @flag == PercentGeometry
      end

      str << 'x' if (@width > 0 && @flag != PercentGeometry) || (@height > 0)

      if @height > 0
        fmt = @height.truncate == @height ? '%d' : '%.2f'
        str << sprintf(fmt, @height)
        str << '%' if @flag == PercentGeometry
      end
      str << sprintf('%+d%+d', @x, @y) if @x != 0 || @y != 0
      str << FLAGS[@flag.to_i] if @flag != PercentGeometry
      str
    end
  end

  class Draw
    # Thse hashes are used to map Magick constant
    # values to the strings used in the primitives.
    ALIGN_TYPE_NAMES = {
      LeftAlign.to_i => 'left',
      RightAlign.to_i => 'right',
      CenterAlign.to_i => 'center'
    }.freeze
    ANCHOR_TYPE_NAMES = {
      StartAnchor.to_i => 'start',
      MiddleAnchor.to_i => 'middle',
      EndAnchor.to_i => 'end'
    }.freeze
    DECORATION_TYPE_NAMES = {
      NoDecoration.to_i => 'none',
      UnderlineDecoration.to_i => 'underline',
      OverlineDecoration.to_i => 'overline',
      LineThroughDecoration.to_i => 'line-through'
    }.freeze
    FONT_WEIGHT_NAMES = {
      AnyWeight.to_i => 'all',
      NormalWeight.to_i => 'normal',
      BoldWeight.to_i => 'bold',
      BolderWeight.to_i => 'bolder',
      LighterWeight.to_i => 'lighter'
    }.freeze
    GRAVITY_NAMES = {
      NorthWestGravity.to_i => 'northwest',
      NorthGravity.to_i => 'north',
      NorthEastGravity.to_i => 'northeast',
      WestGravity.to_i => 'west',
      CenterGravity.to_i => 'center',
      EastGravity.to_i => 'east',
      SouthWestGravity.to_i => 'southwest',
      SouthGravity.to_i => 'south',
      SouthEastGravity.to_i => 'southeast'
    }.freeze
    PAINT_METHOD_NAMES = {
      PointMethod.to_i => 'point',
      ReplaceMethod.to_i => 'replace',
      FloodfillMethod.to_i => 'floodfill',
      FillToBorderMethod.to_i => 'filltoborder',
      ResetMethod.to_i => 'reset'
    }.freeze
    STRETCH_TYPE_NAMES = {
      NormalStretch.to_i => 'normal',
      UltraCondensedStretch.to_i => 'ultra-condensed',
      ExtraCondensedStretch.to_i => 'extra-condensed',
      CondensedStretch.to_i => 'condensed',
      SemiCondensedStretch.to_i => 'semi-condensed',
      SemiExpandedStretch.to_i => 'semi-expanded',
      ExpandedStretch.to_i => 'expanded',
      ExtraExpandedStretch.to_i => 'extra-expanded',
      UltraExpandedStretch.to_i => 'ultra-expanded',
      AnyStretch.to_i => 'all'
    }.freeze
    STYLE_TYPE_NAMES = {
      NormalStyle.to_i => 'normal',
      ItalicStyle.to_i => 'italic',
      ObliqueStyle.to_i => 'oblique',
      AnyStyle.to_i => 'all'
    }.freeze

    private

    def enquote(str)
      str = to_string(str)
      if str.length > 2 && /\A(?:"[^\"]+"|'[^\']+'|\{[^\}]+\})\z/.match(str)
        str
      else
        '"' + str + '"'
      end
    end

    def to_opacity(opacity)
      return opacity if opacity.is_a?(String) && opacity.end_with?('%')

      value = Float(opacity)
      Kernel.raise ArgumentError, 'opacity must be >= 0 and <= 1.0' if value < 0 || value > 1.0

      value
    end

    def to_string(obj)
      return obj if obj.is_a?(String)
      return obj.to_s if obj.is_a?(Symbol)
      return obj.to_str if obj.respond_to?(:to_str)

      Kernel.raise TypeError, "no implicit conversion of #{obj.class} into String"
    end

    public

    # Apply coordinate transformations to support scaling (s), rotation (r),
    # and translation (t). Angles are specified in radians.
    def affine(sx, rx, ry, sy, tx, ty)
      primitive 'affine ' + sprintf('%g,%g,%g,%g,%g,%g', sx, rx, ry, sy, tx, ty)
    end

    # Set alpha (make transparent) in image according to the specified
    # colorization rule
    def alpha(x, y, method)
      Kernel.raise ArgumentError, 'Unknown paint method' unless PAINT_METHOD_NAMES.key?(method.to_i)
      name = Gem::Version.new(Magick::IMAGEMAGICK_VERSION) > Gem::Version.new('7.0.0') ? 'alpha ' : 'matte '
      primitive name + sprintf('%g,%g, %s', x, y, PAINT_METHOD_NAMES[method.to_i])
    end

    # Draw an arc.
    def arc(start_x, start_y, end_x, end_y, start_degrees, end_degrees)
      primitive 'arc ' + sprintf(
        '%g,%g %g,%g %g,%g',
        start_x, start_y, end_x, end_y, start_degrees, end_degrees
      )
    end

    # Draw a bezier curve.
    def bezier(*points)
      if points.empty?
        Kernel.raise ArgumentError, 'no points specified'
      elsif points.length.odd?
        Kernel.raise ArgumentError, 'odd number of arguments specified'
      end
      primitive 'bezier ' + points.map! { |x| sprintf('%g', x) }.join(',')
    end

    # Draw a circle
    def circle(origin_x, origin_y, perim_x, perim_y)
      primitive 'circle ' + sprintf('%g,%g %g,%g', origin_x, origin_y, perim_x, perim_y)
    end

    # Invoke a clip-path defined by def_clip_path.
    def clip_path(name)
      primitive "clip-path #{to_string(name)}"
    end

    # Define the clipping rule.
    def clip_rule(rule)
      rule = to_string(rule)
      Kernel.raise ArgumentError, "Unknown clipping rule #{rule}" unless %w[evenodd nonzero].include?(rule.downcase)
      primitive "clip-rule #{rule}"
    end

    # Define the clip units
    def clip_units(unit)
      unit = to_string(unit)
      Kernel.raise ArgumentError, "Unknown clip unit #{unit}" unless %w[userspace userspaceonuse objectboundingbox].include?(unit.downcase)
      primitive "clip-units #{unit}"
    end

    # Set color in image according to specified colorization rule. Rule is one of
    # point, replace, floodfill, filltoborder,reset
    def color(x, y, method)
      Kernel.raise ArgumentError, "Unknown PaintMethod: #{method}" unless PAINT_METHOD_NAMES.key?(method.to_i)
      primitive 'color ' + sprintf('%g,%g,%s', x, y, PAINT_METHOD_NAMES[method.to_i])
    end

    # Specify EITHER the text decoration (none, underline, overline,
    # line-through) OR the text solid background color (any color name or spec)
    def decorate(decoration)
      if DECORATION_TYPE_NAMES.key?(decoration.to_i)
        primitive "decorate #{DECORATION_TYPE_NAMES[decoration.to_i]}"
      else
        primitive "decorate #{enquote(decoration)}"
      end
    end

    # Define a clip-path. A clip-path is a sequence of primitives
    # bracketed by the "push clip-path <name>" and "pop clip-path"
    # primitives. Upon advice from the IM guys, we also bracket
    # the clip-path primitives with "push(pop) defs" and "push
    # (pop) graphic-context".
    def define_clip_path(name)
      push('defs')
      push("clip-path #{enquote(name)}")
      push('graphic-context')
      yield
    ensure
      pop('graphic-context')
      pop('clip-path')
      pop('defs')
    end

    # Draw an ellipse
    def ellipse(origin_x, origin_y, width, height, arc_start, arc_end)
      primitive 'ellipse ' + sprintf(
        '%g,%g %g,%g %g,%g',
        origin_x, origin_y, width, height, arc_start, arc_end
      )
    end

    # Let anything through, but the only defined argument
    # is "UTF-8". All others are apparently ignored.
    def encoding(encoding)
      primitive "encoding #{to_string(encoding)}"
    end

    # Specify object fill, a color name or pattern name
    def fill(colorspec)
      primitive "fill #{enquote(colorspec)}"
    end
    alias fill_color fill
    alias fill_pattern fill

    # Specify fill opacity (use "xx%" to indicate percentage)
    def fill_opacity(opacity)
      opacity = to_opacity(opacity)
      primitive "fill-opacity #{opacity}"
    end

    def fill_rule(rule)
      rule = to_string(rule)
      Kernel.raise ArgumentError, "Unknown fill rule #{rule}" unless %w[evenodd nonzero].include?(rule.downcase)
      primitive "fill-rule #{rule}"
    end

    # Specify text drawing font
    def font(name)
      primitive "font #{enquote(name)}"
    end

    def font_family(name)
      primitive "font-family #{enquote(name)}"
    end

    def font_stretch(stretch)
      Kernel.raise ArgumentError, 'Unknown stretch type' unless STRETCH_TYPE_NAMES.key?(stretch.to_i)
      primitive "font-stretch #{STRETCH_TYPE_NAMES[stretch.to_i]}"
    end

    def font_style(style)
      Kernel.raise ArgumentError, 'Unknown style type' unless STYLE_TYPE_NAMES.key?(style.to_i)
      primitive "font-style #{STYLE_TYPE_NAMES[style.to_i]}"
    end

    # The font weight argument can be either a font weight
    # constant or [100,200,...,900]
    def font_weight(weight)
      if weight.is_a?(WeightType)
        primitive "font-weight #{FONT_WEIGHT_NAMES[weight.to_i]}"
      else
        primitive "font-weight #{Integer(weight)}"
      end
    end

    # Specify the text positioning gravity, one of:
    # NorthWest, North, NorthEast, West, Center, East, SouthWest, South, SouthEast
    def gravity(grav)
      Kernel.raise ArgumentError, 'Unknown text positioning gravity' unless GRAVITY_NAMES.key?(grav.to_i)
      primitive "gravity #{GRAVITY_NAMES[grav.to_i]}"
    end

    def image(composite, x, y, width, height, image_file_path)
      Kernel.raise ArgumentError, 'Unknown composite' unless composite.is_a?(CompositeOperator)
      composite_name = composite.to_s.sub!('CompositeOp', '')
      primitive 'image ' + sprintf('%s %g,%g %g,%g %s', composite_name, x, y, width, height, enquote(image_file_path))
    end

    # IM 6.5.5-8 and later
    def interline_spacing(space)
      primitive "interline-spacing #{Float(space)}"
    end

    # IM 6.4.8-3 and later
    def interword_spacing(space)
      primitive "interword-spacing #{Float(space)}"
    end

    # IM 6.4.8-3 and later
    def kerning(space)
      primitive "kerning #{Float(space)}"
    end

    # Draw a line
    def line(start_x, start_y, end_x, end_y)
      primitive 'line ' + sprintf('%g,%g %g,%g', start_x, start_y, end_x, end_y)
    end

    # Specify drawing fill and stroke opacities. If the value is a string
    # ending with a %, the number will be multiplied by 0.01.
    def opacity(opacity)
      opacity = to_opacity(opacity)
      primitive "opacity #{opacity}"
    end

    # Draw using SVG-compatible path drawing commands. Note that the
    # primitive requires that the commands be surrounded by quotes or
    # apostrophes. Here we simply use apostrophes.
    def path(cmds)
      primitive "path #{enquote(cmds)}"
    end

    # Define a pattern. In the block, call primitive methods to
    # draw the pattern. Reference the pattern by using its name
    # as the argument to the 'fill' or 'stroke' methods
    def pattern(name, x, y, width, height)
      push('defs')
      push("pattern #{to_string(name)} " + sprintf('%g %g %g %g', x, y, width, height))
      push('graphic-context')
      yield
    ensure
      pop('graphic-context')
      pop('pattern')
      pop('defs')
    end

    # Set point to fill color.
    def point(x, y)
      primitive 'point ' + sprintf('%g,%g', x, y)
    end

    # Specify the font size in points. Yes, the primitive is "font-size" but
    # in other places this value is called the "pointsize". Give it both names.
    def pointsize(points)
      primitive 'font-size ' + sprintf('%g', points)
    end
    alias font_size pointsize

    # Draw a polygon
    def polygon(*points)
      if points.empty?
        Kernel.raise ArgumentError, 'no points specified'
      elsif points.length.odd?
        Kernel.raise ArgumentError, 'odd number of points specified'
      end
      primitive 'polygon ' + points.map! { |x| sprintf('%g', x) }.join(',')
    end

    # Draw a polyline
    def polyline(*points)
      if points.empty?
        Kernel.raise ArgumentError, 'no points specified'
      elsif points.length.odd?
        Kernel.raise ArgumentError, 'odd number of points specified'
      end
      primitive 'polyline ' + points.map! { |x| sprintf('%g', x) }.join(',')
    end

    # Return to the previously-saved set of whatever
    # pop('graphic-context') (the default if no arguments)
    # pop('defs')
    # pop('gradient')
    # pop('pattern')

    def pop(*what)
      if what.empty?
        primitive 'pop graphic-context'
      else
        primitive 'pop ' + what.map { |x| to_string(x) }.join(' ')
      end
    end

    # Push the current set of drawing options. Also you can use
    # push('graphic-context') (the default if no arguments)
    # push('defs')
    # push('gradient')
    # push('pattern')
    def push(*what)
      if what.empty?
        primitive 'push graphic-context'
      else
        primitive 'push ' + what.map { |x| to_string(x) }.join(' ')
      end
    end

    # Draw a rectangle
    def rectangle(upper_left_x, upper_left_y, lower_right_x, lower_right_y)
      primitive 'rectangle ' + sprintf(
        '%g,%g %g,%g',
        upper_left_x, upper_left_y, lower_right_x, lower_right_y
      )
    end

    # Specify coordinate space rotation. "angle" is measured in degrees
    def rotate(angle)
      primitive 'rotate ' + sprintf('%g', angle)
    end

    # Draw a rectangle with rounded corners
    def roundrectangle(center_x, center_y, width, height, corner_width, corner_height)
      primitive 'roundrectangle ' + sprintf(
        '%g,%g,%g,%g,%g,%g',
        center_x, center_y, width, height, corner_width, corner_height
      )
    end

    # Specify scaling to be applied to coordinate space on subsequent drawing commands.
    def scale(x, y)
      primitive 'scale ' + sprintf('%g,%g', x, y)
    end

    def skewx(angle)
      primitive 'skewX ' + sprintf('%g', angle)
    end

    def skewy(angle)
      primitive 'skewY ' + sprintf('%g', angle)
    end

    # Specify the object stroke, a color name or pattern name.
    def stroke(colorspec)
      primitive "stroke #{enquote(colorspec)}"
    end
    alias stroke_color stroke
    alias stroke_pattern stroke

    # Specify if stroke should be antialiased or not
    def stroke_antialias(bool)
      bool = bool ? '1' : '0'
      primitive "stroke-antialias #{bool}"
    end

    # Specify a stroke dash pattern
    def stroke_dasharray(*list)
      if list.empty?
        primitive 'stroke-dasharray none'
      else
        list.map! { |x| Float(x) }.each do |x|
          Kernel.raise ArgumentError, "dash array elements must be > 0 (#{x} given)" if x <= 0
        end
        primitive "stroke-dasharray #{list.join(',')}"
      end
    end

    # Specify the initial offset in the dash pattern
    def stroke_dashoffset(value = 0)
      primitive 'stroke-dashoffset ' + sprintf('%g', value)
    end

    def stroke_linecap(value)
      value = to_string(value)
      Kernel.raise ArgumentError, "Unknown linecap type: #{value}" unless %w[butt round square].include?(value.downcase)
      primitive "stroke-linecap #{value}"
    end

    def stroke_linejoin(value)
      value = to_string(value)
      Kernel.raise ArgumentError, "Unknown linejoin type: #{value}" unless %w[round miter bevel].include?(value.downcase)
      primitive "stroke-linejoin #{value}"
    end

    def stroke_miterlimit(value)
      value = Float(value)
      Kernel.raise ArgumentError, 'miterlimit must be >= 1' if value < 1
      primitive "stroke-miterlimit #{value}"
    end

    # Specify opacity of stroke drawing color
    #  (use "xx%" to indicate percentage)
    def stroke_opacity(opacity)
      opacity = to_opacity(opacity)
      primitive "stroke-opacity #{opacity}"
    end

    # Specify stroke (outline) width in pixels.
    def stroke_width(pixels)
      primitive 'stroke-width ' + sprintf('%g', pixels)
    end

    # Draw text at position x,y. Add quotes to text that is not already quoted.
    def text(x, y, text)
      text = to_string(text)
      Kernel.raise ArgumentError, 'missing text argument' if text.empty?
      if text.length > 2 && /\A(?:"[^\"]+"|'[^\']+'|\{[^\}]+\})\z/.match(text)
      # text already quoted
      elsif !text['\'']
        text = '\'' + text + '\''
      elsif !text['"']
        text = '"' + text + '"'
      elsif !(text['{'] || text['}'])
        text = '{' + text + '}'
      else
        # escape existing braces, surround with braces
        text = '{' + text.gsub(/[}]/) { |b| '\\' + b } + '}'
      end
      primitive 'text ' + sprintf('%g,%g %s', x, y, text)
    end

    # Specify text alignment relative to a given point
    def text_align(alignment)
      Kernel.raise ArgumentError, "Unknown alignment constant: #{alignment}" unless ALIGN_TYPE_NAMES.key?(alignment.to_i)
      primitive "text-align #{ALIGN_TYPE_NAMES[alignment.to_i]}"
    end

    # SVG-compatible version of text_align
    def text_anchor(anchor)
      Kernel.raise ArgumentError, "Unknown anchor constant: #{anchor}" unless ANCHOR_TYPE_NAMES.key?(anchor.to_i)
      primitive "text-anchor #{ANCHOR_TYPE_NAMES[anchor.to_i]}"
    end

    # Specify if rendered text is to be antialiased.
    def text_antialias(boolean)
      boolean = boolean ? '1' : '0'
      primitive "text-antialias #{boolean}"
    end

    # Specify color underneath text
    def text_undercolor(color)
      primitive "text-undercolor #{enquote(color)}"
    end

    # Specify center of coordinate space to use for subsequent drawing
    # commands.
    def translate(x, y)
      primitive 'translate ' + sprintf('%g,%g', x, y)
    end
  end # class Magick::Draw

  # Define IPTC record number:dataset tags for use with Image#get_iptc_dataset
  module IPTC
    # rubocop:disable Naming/ConstantName
    module Envelope
      Model_Version                          = '1:00'
      Destination                            = '1:05'
      File_Format                            = '1:20'
      File_Format_Version                    = '1:22'
      Service_Identifier                     = '1:30'
      Envelope_Number                        = '1:40'
      Product_ID                             = '1:50'
      Envelope_Priority                      = '1:60'
      Date_Sent                              = '1:70'
      Time_Sent                              = '1:80'
      Coded_Character_Set                    = '1:90'
      UNO                                    = '1:100'
      Unique_Name_of_Object                  = '1:100'
      ARM_Identifier                         = '1:120'
      ARM_Version                            = '1:122'
    end

    module Application
      Record_Version                         = '2:00'
      Object_Type_Reference                  = '2:03'
      Object_Name                            = '2:05'
      Title                                  = '2:05'
      Edit_Status                            = '2:07'
      Editorial_Update                       = '2:08'
      Urgency                                = '2:10'
      Subject_Reference                      = '2:12'
      Category                               = '2:15'
      Supplemental_Category                  = '2:20'
      Fixture_Identifier                     = '2:22'
      Keywords                               = '2:25'
      Content_Location_Code                  = '2:26'
      Content_Location_Name                  = '2:27'
      Release_Date                           = '2:30'
      Release_Time                           = '2:35'
      Expiration_Date                        = '2:37'
      Expiration_Time                        = '2:35'
      Special_Instructions                   = '2:40'
      Action_Advised                         = '2:42'
      Reference_Service                      = '2:45'
      Reference_Date                         = '2:47'
      Reference_Number                       = '2:50'
      Date_Created                           = '2:55'
      Time_Created                           = '2:60'
      Digital_Creation_Date                  = '2:62'
      Digital_Creation_Time                  = '2:63'
      Originating_Program                    = '2:65'
      Program_Version                        = '2:70'
      Object_Cycle                           = '2:75'
      By_Line                                = '2:80'
      Author                                 = '2:80'
      By_Line_Title                          = '2:85'
      Author_Position                        = '2:85'
      City                                   = '2:90'
      Sub_Location                           = '2:92'
      Province                               = '2:95'
      State                                  = '2:95'
      Country_Primary_Location_Code          = '2:100'
      Country_Primary_Location_Name          = '2:101'
      Original_Transmission_Reference        = '2:103'
      Headline                               = '2:105'
      Credit                                 = '2:110'
      Source                                 = '2:115'
      Copyright_Notice                       = '2:116'
      Contact                                = '2:118'
      Abstract                               = '2:120'
      Caption                                = '2:120'
      Editor                                 = '2:122'
      Caption_Writer                         = '2:122'
      Rasterized_Caption                     = '2:125'
      Image_Type                             = '2:130'
      Image_Orientation                      = '2:131'
      Language_Identifier                    = '2:135'
      Audio_Type                             = '2:150'
      Audio_Sampling_Rate                    = '2:151'
      Audio_Sampling_Resolution              = '2:152'
      Audio_Duration                         = '2:153'
      Audio_Outcue                           = '2:154'
      ObjectData_Preview_File_Format         = '2:200'
      ObjectData_Preview_File_Format_Version = '2:201'
      ObjectData_Preview_Data                = '2:202'
    end

    module Pre_ObjectData_Descriptor
      Size_Mode                              = '7:10'
      Max_Subfile_Size                       = '7:20'
      ObjectData_Size_Announced              = '7:90'
      Maximum_ObjectData_Size                = '7:95'
    end

    module ObjectData
      Subfile                                = '8:10'
    end

    module Post_ObjectData_Descriptor
      Confirmed_ObjectData_Size              = '9:10'
    end
    # rubocop:enable Naming/ConstantName
  end # module Magick::IPTC

  # Ruby-level Magick::Image methods
  class Image
    include Comparable

    alias affinity remap

    # Provide an alternate version of Draw#annotate, for folks who
    # want to find it in this class.
    def annotate(draw, width, height, x, y, text, &block)
      check_destroyed
      draw.annotate(self, width, height, x, y, text, &block)
      self
    end

    # Set the color at x,y
    def color_point(x, y, fill)
      f = copy
      f.pixel_color(x, y, fill)
      f
    end

    # Set all pixels that have the same color as the pixel at x,y and
    # are neighbors to the fill color
    def color_floodfill(x, y, fill)
      target = pixel_color(x, y)
      color_flood_fill(target, fill, x, y, Magick::FloodfillMethod)
    end

    # Set all pixels that are neighbors of x,y and are not the border color
    # to the fill color
    def color_fill_to_border(x, y, fill)
      color_flood_fill(border_color, fill, x, y, Magick::FillToBorderMethod)
    end

    # Set all pixels to the fill color. Very similar to Image#erase!
    # Accepts either String or Pixel arguments
    def color_reset!(fill)
      save = background_color
      # Change the background color _outside_ the begin block
      # so that if this object is frozen the exeception will be
      # raised before we have to handle it explicitly.
      self.background_color = fill
      begin
        erase!
      ensure
        self.background_color = save
      end
      self
    end

    # Used by ImageList methods - see ImageList#cur_image
    def cur_image
      self
    end

    # Thanks to Russell Norris!
    def each_pixel
      get_pixels(0, 0, columns, rows).each_with_index do |p, n|
        yield(p, n % columns, n / columns)
      end
      self
    end

    # Retrieve EXIF data by entry or all. If one or more entry names specified,
    # return the values associated with the entries. If no entries specified,
    # return all entries and values. The return value is an array of [name,value]
    # arrays.
    def get_exif_by_entry(*entry)
      ary = []
      if entry.empty?
        exif_data = self['EXIF:*']
        exif_data&.split("\n")&.each { |exif| ary.push(exif.split('=')) }
      else
        get_exif_by_entry # ensure properties is populated with exif data
        entry.each do |name|
          rval = self["EXIF:#{name}"]
          ary.push([name, rval])
        end
      end
      ary
    end

    # Retrieve EXIF data by tag number or all tag/value pairs. The return value is a hash.
    def get_exif_by_number(*tag)
      hash = {}
      if tag.empty?
        exif_data = self['EXIF:!']
        exif_data&.split("\n")&.each do |exif|
          tag, value = exif.split('=')
          tag = tag[1, 4].hex
          hash[tag] = value
        end
      else
        get_exif_by_number # ensure properties is populated with exif data
        tag.each do |num|
          rval = self[sprintf('#%04X', num.to_i)]
          hash[num] = rval == 'unknown' ? nil : rval
        end
      end
      hash
    end

    # Retrieve IPTC information by record number:dataset tag constant defined in
    # Magick::IPTC, above.
    def get_iptc_dataset(ds)
      self['IPTC:' + ds]
    end

    # Iterate over IPTC record number:dataset tags, yield for each non-nil dataset
    def each_iptc_dataset
      Magick::IPTC.constants.each do |record|
        rec = Magick::IPTC.const_get(record)
        rec.constants.each do |dataset|
          data_field = get_iptc_dataset(rec.const_get(dataset))
          yield(dataset, data_field) unless data_field.nil?
        end
      end
      nil
    end

    # Patches problematic change to the order of arguments in 1.11.0.
    # Before this release, the order was
    #       black_point, gamma, white_point
    # RMagick 1.11.0 changed this to
    #       black_point, white_point, gamma
    # This fix tries to determine if the arguments are in the old order and
    # if so, swaps the gamma and white_point arguments.  Then it calls
    # level2, which simply accepts the arguments as given.

    # Inspect the gamma and white point values and swap them if they
    # look like they're in the old order.

    # (Thanks to Al Evans for the suggestion.)
    def level(black_point = 0.0, white_point = nil, gamma = nil)
      black_point = Float(black_point)

      white_point ||= Magick::QuantumRange - black_point
      white_point = Float(white_point)

      gamma_arg = gamma
      gamma ||= 1.0
      gamma = Float(gamma)

      if gamma.abs > 10.0 || white_point.abs <= 10.0 || white_point.abs < gamma.abs
        gamma, white_point = white_point, gamma
        white_point = Magick::QuantumRange - black_point unless gamma_arg
      end

      level2(black_point, white_point, gamma)
    end

    # These four methods are equivalent to the Draw#matte method
    # with the "Point", "Replace", "Floodfill", "FilltoBorder", and
    # "Replace" arguments, respectively.

    # Make the pixel at (x,y) transparent.
    def matte_point(x, y)
      f = copy
      f.alpha(OpaqueAlphaChannel) unless f.alpha?
      pixel = f.pixel_color(x, y)
      pixel.alpha = TransparentAlpha
      f.pixel_color(x, y, pixel)
      f
    end

    # Make transparent all pixels that are the same color as the
    # pixel at (x, y).
    def matte_replace(x, y)
      f = copy
      f.alpha(OpaqueAlphaChannel) unless f.alpha?
      target = f.pixel_color(x, y)
      f.transparent(target)
    end

    # Make transparent any pixel that matches the color of the pixel
    # at (x,y) and is a neighbor.
    def matte_floodfill(x, y)
      f = copy
      f.alpha(OpaqueAlphaChannel) unless f.alpha?
      target = f.pixel_color(x, y)
      f.matte_flood_fill(target, x, y, FloodfillMethod, alpha: TransparentAlpha)
    end

    # Make transparent any neighbor pixel that is not the border color.
    def matte_fill_to_border(x, y)
      f = copy
      f.alpha(OpaqueAlphaChannel) unless f.alpha?
      f.matte_flood_fill(border_color, x, y, FillToBorderMethod, alpha: TransparentAlpha)
    end

    # Make all pixels transparent.
    def matte_reset!
      alpha(TransparentAlphaChannel)
      self
    end

    # Force an image to exact dimensions without changing the aspect ratio.
    # Resize and crop if necessary. (Thanks to Jerett Taylor!)
    def resize_to_fill(ncols, nrows = nil, gravity = CenterGravity)
      copy.resize_to_fill!(ncols, nrows, gravity)
    end

    def resize_to_fill!(ncols, nrows = nil, gravity = CenterGravity)
      nrows ||= ncols
      if ncols != columns || nrows != rows
        scale = [ncols / columns.to_f, nrows / rows.to_f].max
        resize!(scale * columns + 0.5, scale * rows + 0.5)
      end
      crop!(gravity, ncols, nrows, true) if ncols != columns || nrows != rows
      self
    end

    # Preserve aliases used < RMagick 2.0.1
    alias crop_resized resize_to_fill
    alias crop_resized! resize_to_fill!

    # Convenience method to resize retaining the aspect ratio.
    # (Thanks to Robert Manni!)
    def resize_to_fit(cols, rows = nil)
      rows ||= cols
      change_geometry(Geometry.new(cols, rows)) do |ncols, nrows|
        resize(ncols, nrows)
      end
    end

    def resize_to_fit!(cols, rows = nil)
      rows ||= cols
      change_geometry(Geometry.new(cols, rows)) do |ncols, nrows|
        resize!(ncols, nrows)
      end
    end

    # Replace matching neighboring pixels with texture pixels
    def texture_floodfill(x, y, texture)
      target = pixel_color(x, y)
      texture_flood_fill(target, texture, x, y, FloodfillMethod)
    end

    # Replace neighboring pixels to border color with texture pixels
    def texture_fill_to_border(x, y, texture)
      texture_flood_fill(border_color, texture, x, y, FillToBorderMethod)
    end

    # Construct a view. If a block is present, yield and pass the view
    # object, otherwise return the view object.
    def view(x, y, width, height)
      view = View.new(self, x, y, width, height)

      return view unless block_given?

      begin
        yield(view)
      ensure
        view.sync
      end
      nil
    end

    # Magick::Image::View class
    class View
      attr_reader :x, :y, :width, :height
      attr_accessor :dirty

      def initialize(img, x, y, width, height)
        img.check_destroyed
        Kernel.raise ArgumentError, "invalid geometry (#{width}x#{height}+#{x}+#{y})" if width <= 0 || height <= 0
        Kernel.raise RangeError, "geometry (#{width}x#{height}+#{x}+#{y}) exceeds image boundary" if x < 0 || y < 0 || (x + width) > img.columns || (y + height) > img.rows
        @view = img.get_pixels(x, y, width, height)
        @img = img
        @x = x
        @y = y
        @width = width
        @height = height
        @dirty = false
      end

      def [](*args)
        rows = Rows.new(@view, @width, @height, args)
        rows.add_observer(self)
        rows
      end

      # Store changed pixels back to image
      def sync(force = false)
        @img.store_pixels(x, y, width, height, @view) if @dirty || force
        @dirty || force
      end

      # Get update from Rows - if @dirty ever becomes
      # true, don't change it back to false!
      def update(rows)
        @dirty = true
        rows.delete_observer(self) # No need to tell us again.
        nil
      end

      # Magick::Image::View::Pixels
      # Defines channel attribute getters/setters
      class Pixels < Array
        include Observable

        # Define a getter and a setter for each channel.
        %i[red green blue opacity].each do |c|
          module_eval <<-END_EVAL, __FILE__, __LINE__ + 1
            def #{c}
              return collect { |p| p.#{c} }
            end
            def #{c}=(v)
              each { |p| p.#{c} = v }
              changed
              notify_observers(self)
              v
            end
          END_EVAL
        end
      end # class Magick::Image::View::Pixels

      # Magick::Image::View::Rows
      class Rows
        include Observable

        def initialize(view, width, height, rows)
          @view = view
          @width = width
          @height = height
          @rows = rows
        end

        def [](*args)
          cols(args)

          # Both View::Pixels and Magick::Pixel implement Observable
          if @unique
            pixels = @view[@rows[0] * @width + @cols[0]]
            pixels.add_observer(self)
          else
            pixels = View::Pixels.new
            each do |x|
              p = @view[x]
              p.add_observer(self)
              pixels << p
            end
          end
          pixels
        end

        def []=(*args)
          rv = args.delete_at(-1) # get rvalue
          unless rv.is_a?(Pixel) # must be a Pixel or a color name
            begin
              rv = Pixel.from_color(rv)
            rescue TypeError
              Kernel.raise TypeError, "cannot convert #{rv.class} into Pixel"
            end
          end
          cols(args)
          each { |x| @view[x] = rv.dup }
          changed
          notify_observers(self)
        end

        # A pixel has been modified. Tell the view.
        def update(pixel)
          changed
          notify_observers(self)
          pixel.delete_observer(self) # Don't need to hear again.
          nil
        end

        private

        def cols(*args)
          @cols = args[0] # remove the outermost array
          @unique = false

          # Convert @rows to an Enumerable object
          case @rows.length
          when 0                      # Create a Range for all the rows
            @rows = Range.new(0, @height, true)
          when 1                      # Range, Array, or a single integer
            # if the single element is already an Enumerable
            # object, get it.
            if @rows.first.respond_to? :each
              @rows = @rows.first
            else
              @rows = Integer(@rows.first)
              @rows += @height if @rows < 0
              Kernel.raise IndexError, "index [#{@rows}] out of range" if @rows < 0 || @rows > @height - 1
              # Convert back to an array
              @rows = Array.new(1, @rows)
              @unique = true
            end
          when 2
            # A pair of integers representing the starting column and the number of columns
            start = Integer(@rows[0])
            length = Integer(@rows[1])

            # Negative start -> start from last row
            start += @height if start < 0

            if start > @height || start < 0 || length < 0
              Kernel.raise IndexError, "index [#{@rows.first}] out of range"
            elsif start + length > @height
              length = @height - length
              length = [length, 0].max
            end
            # Create a Range for the specified set of rows
            @rows = Range.new(start, start + length, true)
          end

          case @cols.length
          when 0 # all rows
            @cols = Range.new(0, @width, true) # convert to range
            @unique = false
          when 1 # Range, Array, or a single integer
            # if the single element is already an Enumerable
            # object, get it.
            if @cols.first.respond_to? :each
              @cols = @cols.first
              @unique = false
            else
              @cols = Integer(@cols.first)
              @cols += @width if @cols < 0
              Kernel.raise IndexError, "index [#{@cols}] out of range" if @cols < 0 || @cols > @width - 1
              # Convert back to array
              @cols = Array.new(1, @cols)
              @unique &&= true
            end
          when 2
            # A pair of integers representing the starting column and the number of columns
            start = Integer(@cols[0])
            length = Integer(@cols[1])

            # Negative start -> start from last row
            start += @width if start < 0

            if start > @width || start < 0 || length < 0
            # nop
            elsif start + length > @width
              length = @width - length
              length = [length, 0].max
            end
            # Create a Range for the specified set of columns
            @cols = Range.new(start, start + length, true)
            @unique = false
          end
        end

        # iterator called from subscript methods
        def each
          maxrows = @height - 1
          maxcols = @width - 1

          @rows.each do |j|
            Kernel.raise IndexError, "index [#{j}] out of range" if j > maxrows
            @cols.each do |i|
              Kernel.raise IndexError, "index [#{i}] out of range" if i > maxcols
              yield j * @width + i
            end
          end
          nil # useless return value
        end
      end # class Magick::Image::View::Rows
    end # class Magick::Image::View
  end # class Magick::Image

  class ImageList
    include Comparable
    include Enumerable

    attr_reader :scene

    private

    def get_current
      @images[@scene].__id__
    rescue StandardError
      nil
    end

    protected

    def assert_image(obj)
      Kernel.raise ArgumentError, "Magick::Image required (#{obj.class} given)" unless obj.is_a? Magick::Image
    end

    # Ensure array is always an array of Magick::Image objects
    def assert_image_array(ary)
      Kernel.raise ArgumentError, "Magick::ImageList or array of Magick::Images required (#{ary.class} given)" unless ary.respond_to? :each
      ary.each { |obj| assert_image obj }
    end

    # Find old current image, update scene number
    # current is the id of the old current image.
    def set_current(current)
      if length.zero?
        self.scene = nil
        return
      # Don't bother looking for current image
      elsif scene.nil? || scene >= length
        self.scene = length - 1
        return
      elsif !current.nil?
        # Find last instance of "current" in the list.
        # If "current" isn't in the list, set current to last image.
        self.scene = length - 1
        each_with_index do |f, i|
          self.scene = i if f.__id__ == current
        end
        return
      end
      self.scene = length - 1
    end

    public

    # Allow scene to be set to nil
    def scene=(n)
      if n.nil?
        Kernel.raise IndexError, 'scene number out of bounds' unless @images.empty?
        @scene = nil
        return
      elsif @images.empty?
        Kernel.raise IndexError, 'scene number out of bounds'
      end

      n = Integer(n)
      Kernel.raise IndexError, 'scene number out of bounds' if n < 0 || n > length - 1
      @scene = n
    end

    # All the binary operators work the same way.
    # 'other' should be either an ImageList or an Array
    %w[& + - |].each do |op|
      module_eval <<-END_BINOPS, __FILE__, __LINE__ + 1
        def #{op}(other)
          assert_image_array(other)
          ilist = self.class.new
          a = other #{op} @images
          current = get_current()
          a.each { |image| ilist << image }
          ilist.set_current current
          return ilist
        end
      END_BINOPS
    end

    def *(other)
      Kernel.raise ArgumentError, "Integer required (#{other.class} given)" unless other.is_a? Integer
      current = get_current
      ilist = self.class.new
      (@images * other).each { |image| ilist << image }
      ilist.set_current current
      ilist
    end

    def <<(obj)
      assert_image obj
      @images << obj
      @scene = @images.length - 1
      self
    end

    # Compare ImageLists
    # Compare each image in turn until the result of a comparison
    # is not 0. If all comparisons return 0, then
    #   return if A.scene != B.scene
    #   return A.length <=> B.length
    def <=>(other)
      return unless other.is_a? self.class

      size = [length, other.length].min
      size.times do |x|
        r = self[x] <=> other[x]
        return r unless r.zero?
      end

      return 0 if @scene.nil? && other.scene.nil?
      return if @scene.nil? && !other.scene.nil?
      return if !@scene.nil? && other.scene.nil?

      r = scene <=> other.scene
      return r unless r.zero?

      length <=> other.length
    end

    def [](*args)
      a = @images[*args]
      if a.respond_to?(:each)
        ilist = self.class.new
        a.each { |image| ilist << image }
        a = ilist
      end
      a
    end

    def []=(*args)
      obj = @images.[]=(*args)
      if obj.respond_to?(:each)
        assert_image_array(obj)
        set_current obj.last.__id__
      elsif obj
        assert_image(obj)
        set_current obj.__id__
      else
        set_current nil
      end
    end

    %i[
      at each each_index empty? fetch
      first hash include? index length rindex
    ].each do |mth|
      module_eval <<-END_SIMPLE_DELEGATES, __FILE__, __LINE__ + 1
        def #{mth}(*args, &block)
          @images.#{mth}(*args, &block)
        end
      END_SIMPLE_DELEGATES
    end
    alias size length

    def sort!(*args, &block)
      @images.sort!(*args, &block)
      self
    end

    def clear
      @scene = nil
      @images.clear
    end

    def clone
      ditto = dup
      ditto.freeze if frozen?
      ditto
    end

    # override Enumerable#collect
    def collect(&block)
      current = get_current
      a = @images.map(&block)
      ilist = self.class.new
      a.each { |image| ilist << image }
      ilist.set_current current
      ilist
    end

    def collect!(&block)
      @images.map!(&block)
      assert_image_array @images
      self
    end

    # Make a deep copy
    def copy
      ditto = self.class.new
      @images.each { |f| ditto << f.copy }
      ditto.scene = @scene
      ditto
    end

    # Return the current image
    def cur_image
      Kernel.raise IndexError, 'no images in this list' unless @scene
      @images[@scene]
    end

    # ImageList#map took over the "map" name. Use alternatives.
    alias map collect
    alias __map__ collect
    alias map! collect!
    alias __map__! collect!

    # ImageMagick used affinity in 6.4.3, switch to remap in 6.4.4.
    alias affinity remap

    def compact
      current = get_current
      ilist = self.class.new
      a = @images.compact
      a.each { |image| ilist << image }
      ilist.set_current current
      ilist
    end

    def compact!
      current = get_current
      a = @images.compact! # returns nil if no changes were made
      set_current current
      a.nil? ? nil : self
    end

    def concat(other)
      assert_image_array other
      other.each { |image| @images << image }
      @scene = length - 1
      self
    end

    # Set same delay for all images
    def delay=(d)
      raise ArgumentError, 'delay must be greater than or equal to 0' if Integer(d) < 0

      @images.each { |f| f.delay = Integer(d) }
    end

    def delete(obj, &block)
      assert_image obj
      current = get_current
      a = @images.delete(obj, &block)
      set_current current
      a
    end

    def delete_at(ndx)
      current = get_current
      a = @images.delete_at(ndx)
      set_current current
      a
    end

    def delete_if(&block)
      current = get_current
      @images.delete_if(&block)
      set_current current
      self
    end

    def dup
      ditto = self.class.new
      @images.each { |img| ditto << img }
      ditto.scene = @scene
      ditto
    end

    def eql?(other)
      begin
        assert_image_array other
      rescue ArgumentError
        return false
      end

      eql = other.eql?(@images)
      begin # "other" is another ImageList
        eql &&= @scene == other.scene
      rescue NoMethodError
        # "other" is a plain Array
      end
      eql
    end

    def fill(*args, &block)
      assert_image args[0] unless block
      current = get_current
      @images.fill(*args, &block)
      assert_image_array self
      set_current current
      self
    end

    # Override Enumerable's find_all
    def find_all(&block)
      current = get_current
      a = @images.select(&block)
      ilist = self.class.new
      a.each { |image| ilist << image }
      ilist.set_current current
      ilist
    end
    alias select find_all

    def from_blob(*blobs, &block)
      Kernel.raise ArgumentError, 'no blobs given' if blobs.empty?
      blobs.each do |b|
        Magick::Image.from_blob(b, &block).each { |n| @images << n }
      end
      @scene = length - 1
      self
    end

    # Initialize new instances
    def initialize(*filenames, &block)
      @images = []
      @scene = nil
      filenames.each do |f|
        Magick::Image.read(f, &block).each { |n| @images << n }
      end

      @scene = length - 1 if length > 0 # last image in array
    end

    def insert(index, *args)
      args.each { |image| assert_image image }
      current = get_current
      @images.insert(index, *args)
      set_current current
      self
    end

    # Call inspect for all the images
    def inspect
      img = @images.map(&:inspect)
      '[' + img.join(",\n") + "]\nscene=#{@scene}"
    end

    # Set the number of iterations of an animated GIF
    def iterations=(n)
      n = Integer(n)
      Kernel.raise ArgumentError, 'iterations must be between 0 and 65535' if n < 0 || n > 65_535
      @images.each { |f| f.iterations = n }
    end

    def last(*args)
      if args.empty?
        a = @images.last
      else
        a = @images.last(*args)
        ilist = self.class.new
        a.each { |img| ilist << img }
        @scene = a.length - 1
        a = ilist
      end
      a
    end

    # Custom marshal/unmarshal for Ruby 1.8.
    def marshal_dump
      ary = [@scene]
      @images.each { |i| ary << Marshal.dump(i) }
      ary
    end

    def marshal_load(ary)
      @scene = ary.shift
      @images = []
      ary.each { |a| @images << Marshal.load(a) }
    end

    # The ImageList class supports the Magick::Image class methods by simply sending
    # the method to the current image. If the method isn't explicitly supported,
    # send it to the current image in the array. If there are no images, send
    # it up the line. Catch a NameError and emit a useful message.
    def method_missing(meth_id, *args, &block)
      if @scene
        img = @images[@scene]
        new_img = img.public_send(meth_id, *args, &block)
        img.equal?(new_img) ? self : new_img
      else
        super
      end
    rescue NoMethodError
      Kernel.raise NoMethodError, "undefined method `#{meth_id.id2name}' for #{self.class}"
    rescue Exception
      $ERROR_POSITION.delete_if { |s| /:in `send'$/.match(s) || /:in `method_missing'$/.match(s) }
      Kernel.raise
    end

    # Create a new image and add it to the end
    def new_image(cols, rows, *fill, &info_blk)
      self << Magick::Image.new(cols, rows, *fill, &info_blk)
    end

    def partition(&block)
      a = @images.partition(&block)
      t = self.class.new
      a[0].each { |img| t << img }
      t.set_current nil
      f = self.class.new
      a[1].each { |img| f << img }
      f.set_current nil
      [t, f]
    end

    # Ping files and concatenate the new images
    def ping(*files, &block)
      Kernel.raise ArgumentError, 'no files given' if files.empty?
      files.each do |f|
        Magick::Image.ping(f, &block).each { |n| @images << n }
      end
      @scene = length - 1
      self
    end

    def pop
      current = get_current
      a = @images.pop # can return nil
      set_current current
      a
    end

    def push(*objs)
      objs.each do |image|
        assert_image image
        @images << image
      end
      @scene = length - 1
      self
    end

    # Read files and concatenate the new images
    def read(*files, &block)
      Kernel.raise ArgumentError, 'no files given' if files.empty?
      files.each do |f|
        Magick::Image.read(f, &block).each { |n| @images << n }
      end
      @scene = length - 1
      self
    end

    # override Enumerable's reject
    def reject(&block)
      current = get_current
      ilist = self.class.new
      a = @images.reject(&block)
      a.each { |image| ilist << image }
      ilist.set_current current
      ilist
    end

    def reject!(&block)
      current = get_current
      a = @images.reject!(&block)
      @images = a unless a.nil?
      set_current current
      a.nil? ? nil : self
    end

    def replace(other)
      assert_image_array other
      current = get_current
      @images.clear
      other.each { |image| @images << image }
      @scene = length.zero? ? nil : 0
      set_current current
      self
    end

    # Ensure respond_to? answers correctly when we are delegating to Image
    alias __respond_to__? respond_to?
    def respond_to?(meth_id, priv = false)
      return true if __respond_to__?(meth_id, priv)

      if @scene
        @images[@scene].respond_to?(meth_id, priv)
      else
        super
      end
    end

    def reverse
      current = get_current
      a = self.class.new
      @images.reverse_each { |image| a << image }
      a.set_current current
      a
    end

    def reverse!
      current = get_current
      @images.reverse!
      set_current current
      self
    end

    def reverse_each(&block)
      @images.reverse_each(&block)
      self
    end

    def shift
      current = get_current
      a = @images.shift
      set_current current
      a
    end

    def slice(*args)
      slice = @images.slice(*args)
      if slice
        ilist = self.class.new
        if slice.respond_to?(:each)
          slice.each { |image| ilist << image }
        else
          ilist << slice
        end
      else
        ilist = nil
      end
      ilist
    end

    def slice!(*args)
      current = get_current
      a = @images.slice!(*args)
      set_current current
      a
    end

    def ticks_per_second=(t)
      Kernel.raise ArgumentError, 'ticks_per_second must be greater than or equal to 0' if Integer(t) < 0
      @images.each { |f| f.ticks_per_second = Integer(t) }
    end

    def to_a
      @images.map { |image| image }
    end

    def uniq
      current = get_current
      a = self.class.new
      @images.uniq.each { |image| a << image }
      a.set_current current
      a
    end

    def uniq!(*_args)
      current = get_current
      a = @images.uniq!
      set_current current
      a.nil? ? nil : self
    end

    # @scene -> new object
    def unshift(obj)
      assert_image obj
      @images.unshift(obj)
      @scene = 0
      self
    end

    def values_at(*args)
      a = self.class.new
      @images.values_at(*args).each { |image| a << image }
      a.scene = a.length - 1
      a
    end
    alias indexes values_at
    alias indices values_at

    def destroy!
      @images.each(&:destroy!)
      self
    end

    def destroyed?
      @images.all?(&:destroyed?)
    end
  end # Magick::ImageList

  class Pixel
    # include Observable for Image::View class
    include Observable
  end

  #  Collects non-specific optional method arguments
  class OptionalMethodArguments
    def initialize(img)
      @img = img
    end

    # miscellaneous options like -verbose
    def method_missing(mth, val)
      @img.define(mth.to_s.tr('_', '-'), val)
    end

    # set(key, val) corresponds to -set option:key val
    def define(key, val = nil)
      @img.define(key, val)
    end

    # accepts Pixel object or color name
    def highlight_color=(color)
      color = @img.to_color(color) if color.respond_to?(:to_color)
      @img.define('highlight-color', color)
    end

    # accepts Pixel object or color name
    def lowlight_color=(color)
      color = @img.to_color(color) if color.respond_to?(:to_color)
      @img.define('lowlight-color', color)
    end
  end

  # Example fill class. Fills the image with the specified background
  # color, then crosshatches with the specified crosshatch color.
  # @dist is the number of pixels between hatch lines.
  # See Magick::Draw examples.
  class HatchFill
    def initialize(bgcolor, hatchcolor = 'white', dist = 10)
      @bgcolor = bgcolor
      @hatchpixel = hatchcolor.is_a?(Pixel) ? hatchcolor : Pixel.from_color(hatchcolor)
      @dist = dist
    end

    def fill(img) # required
      img.background_color = @bgcolor
      img.erase! # sets image to background color
      pixels = Array.new([img.rows, img.columns].max, @hatchpixel)
      @dist.step((img.columns - 1) / @dist * @dist, @dist) do |x|
        img.store_pixels(x, 0, 1, img.rows, pixels)
      end
      @dist.step((img.rows - 1) / @dist * @dist, @dist) do |y|
        img.store_pixels(0, y, img.columns, 1, pixels)
      end
    end
  end

  # Fill class with solid monochromatic color
  class SolidFill
    def initialize(bgcolor)
      @bgcolor = bgcolor
    end

    def fill(img)
      img.background_color = @bgcolor
      img.erase!
    end
  end
end # Magick
