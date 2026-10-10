# frozen_string_literal: true

RSpec.describe Magick do
  describe '::Magick_features' do
    it 'works' do
      expect(Magick::Magick_features).to be_instance_of(String)
    end
  end

  describe '::OpaqueAlpha' do
    it 'works' do
      expect(Magick::OpaqueAlpha).to eq(Magick::QuantumRange)
    end
  end

  describe '::TransparentAlpha' do
    it 'works' do
      expect(Magick::TransparentAlpha).to eq(0)
    end
  end

  describe '::PercentGeometry' do
    it 'works' do
      expect(Magick::PercentGeometry).to be_kind_of(Magick::GeometryValue)
      expect(Magick::PercentGeometry.to_s).to eq('PercentGeometry')
      expect(Magick::PercentGeometry.to_i).to eq(1)
    end
  end

  describe '::AspectGeometry' do
    it 'works' do
      expect(Magick::AspectGeometry).to be_kind_of(Magick::GeometryValue)
      expect(Magick::AspectGeometry.to_s).to eq('AspectGeometry')
      expect(Magick::AspectGeometry.to_i).to eq(2)
    end
  end

  describe '::LessGeometry' do
    it 'works' do
      expect(Magick::LessGeometry).to be_kind_of(Magick::GeometryValue)
      expect(Magick::LessGeometry.to_s).to eq('LessGeometry')
      expect(Magick::LessGeometry.to_i).to eq(3)
    end
  end

  describe '::GreaterGeometry' do
    it 'works' do
      expect(Magick::GreaterGeometry).to be_kind_of(Magick::GeometryValue)
      expect(Magick::GreaterGeometry.to_s).to eq('GreaterGeometry')
      expect(Magick::GreaterGeometry.to_i).to eq(4)
    end
  end

  describe '::AreaGeometry' do
    it 'works' do
      expect(Magick::AreaGeometry).to be_kind_of(Magick::GeometryValue)
      expect(Magick::AreaGeometry.to_s).to eq('AreaGeometry')
      expect(Magick::AreaGeometry.to_i).to eq(5)
    end
  end

  describe '::MinimumGeometry' do
    it 'works' do
      expect(Magick::MinimumGeometry).to be_kind_of(Magick::GeometryValue)
      expect(Magick::MinimumGeometry.to_s).to eq('MinimumGeometry')
      expect(Magick::MinimumGeometry.to_i).to eq(6)
    end
  end

  describe 'Ractor', :slow do
    it 'is supported' do
      expect do
        r = Ractor.new do
          img = Magick::ImageList.new
          img.new_image(200, 200, Magick::GradientFill.new(100, 50, 100, 50, 'khaki1', 'turquoise'))
          img.resize(20, 20)
        end

        if r.respond_to?(:take)
          r.take
        else
          # Ractor#take was replaced at Ruby 4.0.
          # https://bugs.ruby-lang.org/issues/21262
          r.join
        end
      end.not_to raise_error

      expect do
        r = Ractor.new do
          img = Magick::ImageList.new
          img.new_image(40, 40, Magick::HatchFill.new('white', 'lightcyan2'))
          gc = Magick::Draw.new

          gc.font_weight(Magick::NormalWeight)
          gc.font_style(Magick::NormalStyle)
          gc.text(5, 20, "'20,20'")
          gc.draw(img)
        end

        if r.respond_to?(:take)
          r.take
        else
          # Ractor#take was replaced at Ruby 4.0.
          # https://bugs.ruby-lang.org/issues/21262
          r.join
        end
      end.not_to raise_error

      unless RUBY_PLATFORM.include?('mingw')
        # Skip because it causes "`init_formats': unable to register image format 'DMR'" error on Windows
        expect do
          r = Ractor.new do
            Magick.formats # rubocop:disable RSpec/DescribedClass
          end

          if r.respond_to?(:take)
            r.take
          else
            # Ractor#take was replaced at Ruby 4.0.
            # https://bugs.ruby-lang.org/issues/21262
            r.join
          end
        end.not_to raise_error
      end
    end
  end

  describe '::MANAGED_MEMORY' do
    it 'frees objects that the GC collects while it runs' do
      image = Magick::Image.new(20, 20)

      expect do
        with_gc_stress do
          3.times do
            info = Magick::Image::Info.new
            info.texture = image

            draw = Magick::Draw.new
            draw.composite(0, 0, 5, 5, image)

            list = Magick::ImageList.new
            list << image.copy << image.copy
            list.montage { |options| options.texture = image }

            Magick::KernelInfo.new('Gaussian:1x1')
            Magick::Pixel.new(1, 2, 3)
            Magick::GradientFill.new(0, 0, 1, 1, 'red', 'blue')
            Magick::TextureFill.new(image)
            image.resize(10, 10)
          end
        end
        GC.start
      end.not_to raise_error
    end

    it 'does not run the GC while GC.disable is in effect' do
      image = Magick::Image.new(2000, 1500)

      GC.disable
      count = GC.count
      10.times { image.resize(1000, 750) }
      expect(GC.count).to eq(count)
    ensure
      GC.enable
    end

    it 'finishes a GC in progress when ImageMagick allocates a lot' do
      image = Magick::Image.new(2000, 1500)
      objects = Array.new(200_000) { Object.new }

      GC.start(full_mark: true, immediate_mark: false, immediate_sweep: false)
      expect(GC.latest_gc_info(:state)).not_to eq(:none)

      10.times { image.resize(1000, 750) }
      expect(GC.latest_gc_info(:state)).to eq(:none)
      expect(objects.size).to eq(200_000)
    end
  end
end
