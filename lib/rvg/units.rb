# frozen_string_literal: true

# Copyright (c) 2002 - 2009 Timothy P. Hunter
# Copyright (c) 2009 -      RMagick contributors

module Magick
  class RVG
    # Define RVG.dpi and RVG.dpi=. Add conversions to Integer and Float classes
    class << self
      attr_reader :dpi

      def dpi=(n)
        unless defined?(@dpi)
          [Float, Integer].each do |c|
            c.class_eval <<-END_DEFS, __FILE__, __LINE__ + 1
              # the default measurement - 1px is 1 pixel
              def px
                self
              end
              # inches
              def in
                self * ::Magick::RVG.dpi
              end
              # millimeters
              def mm
                self * ::Magick::RVG.dpi / 25.4
              end
              # centimeters
              def cm
                self * ::Magick::RVG.dpi / 2.54
              end
              # points
              def pt
                self * ::Magick::RVG.dpi / 72.0
              end
              # picas
              def pc
                self * ::Magick::RVG.dpi / 6.0
              end
              # percentage of the argument
              def pct(of)
                self * Float(of) / 100.0
              end
              # the default is deg
              def deg
                self
              end
              # radians -> degrees
              def rad
                self * 180.0 / Math::PI
              end
              # grads -> degrees
              def grad
                self * 9.0 / 10.0
              end
            END_DEFS
          end
        end

        @dpi = Float(n)
        @dpi
      rescue ArgumentError
        raise TypeError, "Can't convert `#{n}' to Float"
      end
    end # class << self
  end # class RVG
end # module Magick
