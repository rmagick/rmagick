module Magick
  class Image
    def blur
      warn "Image#blur is deprecated. It is no effect now."
    end

    def blur=(value)
      warn "Image#blur= is deprecated. It is no effect now."
    end

    def sync_profiles
      warn "Image#sync_profiles is deprecated. It is no effect now."
    end

    class Info
      def group
        warn "Info#group is deprecated. It is no effect now."
      end

      def group=(value)
        warn "Info#group= is deprecated. It is no effect now."
      end
    end
  end
end
