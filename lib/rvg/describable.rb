# frozen_string_literal: true

# Copyright (c) 2002 - 2009 Timothy P. Hunter
# Copyright (c) 2009 -      RMagick contributors

module Magick
  class RVG
    #--
    # Corresponds to SVG's Description.class
    #++
    # This module defines a number of metadata attributes.
    module Describable
      private

      def initialize(*args, &)
        super
        @title, @desc, @metadata = nil
      end

      public

      # Sets the object description
      attr_writer :desc
      # Sets the object title
      attr_writer :title
      # Sets the object metadata
      attr_writer :metadata

      # Returns the title of this object. The RVG object title is stored as
      # the 'title' property on the image
      def title
        @title.to_s
      end

      # Returns the description of this object. The RVG object description is
      # stored as the 'desc' property on the image
      def desc
        @desc.to_s
      end

      # Returns additional metadata of this object. The RVG object metadata
      # are stored as the 'metadata' property on the image
      def metadata
        @metadata.to_s
      end
    end # module Describable
  end # class RVG
end # module Magick
