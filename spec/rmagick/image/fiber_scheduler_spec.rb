# frozen_string_literal: true

require_relative '../../support/offloading_scheduler'

# RMagick offloads only on Ruby 4.0, which has the C API a scheduler needs to
# cancel and drain a blocking operation (rb_fiber_scheduler_blocking_operation_extract).
offloading = Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("4.0")

RSpec.describe Magick::Image, if: offloading do
  context "with a Fiber scheduler that offloads blocking operations" do
    let(:scheduler) { OffloadingScheduler.new }
    let(:cancelled) { Class.new(StandardError) }
    let(:in_use) { an_instance_of(RuntimeError).and(having_attributes(message: "object is in use by another fiber")) }

    def red_image
      described_class.new(10, 10) { |options| options.background_color = "red" }
    end

    def blue_image
      described_class.new(10, 10) { |options| options.background_color = "blue" }
    end

    # Bytes of the pixel caches that ImageMagick holds in memory, in maps and
    # on disk. Unlike the RSS, it leaves out what malloc keeps for reuse after
    # ImageMagick frees it, which grows with the number of threads.
    def pixel_cache_size
      %i[memory map disk].sum { |resource| Magick.resource_usage(resource) }
    end

    def attempt
      yield
    rescue StandardError => e
      e
    end

    it "runs heavy calls through #blocking_operation_wait" do
      image = described_class.new(20, 20)

      result = scheduler.run { image.blur_image }

      expect(scheduler.offloaded.size).to eq(1)
      expect(scheduler.completed).to eq(scheduler.offloaded)
      expect(result).to be_instance_of(described_class)
      expect(result.columns).to eq(20)
    end

    it "keeps cheap calls on the calling thread" do
      image = described_class.new(20, 20)

      pixel = scheduler.run { image.pixel_color(0, 0) }

      expect(pixel).to be_instance_of(Magick::Pixel)
      expect(scheduler.offloaded).to be_empty
    end

    it "reads and writes images on the worker thread" do
      blob = scheduler.run do
        image = described_class.read(FLOWER_HAT).first
        image.to_blob { |info| info.format = "PNG" }
      end

      expect(scheduler.offloaded.size).to eq(2)
      expect(scheduler.completed).to eq(scheduler.offloaded)
      expect(described_class.from_blob(blob).first.format).to eq("PNG")
    end

    it "delivers an exception raised into the waiting fiber after the call has completed" do
      image = described_class.new(200, 200)
      scheduler.cancel_next_operation(cancelled.new)

      expect { scheduler.run { image.gaussian_blur(0, 10) } }.to raise_error(cancelled)

      expect(scheduler.completed).to eq(scheduler.offloaded)
      expect(image.columns).to eq(200)
      expect(image.blur_image).to be_instance_of(described_class)
    end

    it "releases the result of a cancelled call", if: offloading && !Gem.win_platform? do
      GC.start
      empty = pixel_cache_size
      image = described_class.new(1000, 1000)
      before = pixel_cache_size

      3.times do
        scheduler = OffloadingScheduler.new
        scheduler.cancel_next_operation(cancelled.new)
        expect { scheduler.run { image.gaussian_blur(0, 0.5) } }.to raise_error(cancelled)
      end

      expect(before - empty).to be >= image.columns * image.rows
      expect(pixel_cache_size).to be <= before
    end

    it "restores the channel mask of a cancelled call" do
      image = red_image
      scheduler.cancel_next_operation(cancelled.new)

      expect { scheduler.run { image.blur_channel(0, 1, Magick::GreenChannel) } }.to raise_error(cancelled)

      expect(image.negate.pixel_color(0, 0).to_color).to eq(red_image.negate.pixel_color(0, 0).to_color)
    end

    it "lets another fiber read an image that a call reads" do
      image = described_class.new(200, 200)
      reads = nil
      scheduler.before_next_operation do
        Fiber.schedule do
          reads = [image.pixel_color(0, 0).class, image.blur_image.columns, Fiber.blocking { image.columns }]
        end
      end

      result = scheduler.run { image.gaussian_blur(0, 5) }

      expect(reads).to eq([Magick::Pixel, 200, 200])
      expect(result.columns).to eq(200)
    end

    it "does not let another fiber change or destroy an image that a call reads" do
      image = described_class.new(200, 200)
      other = red_image
      errors = nil
      scheduler.before_next_operation do
        Fiber.schedule do
          errors = [
            attempt { image.destroy! },
            attempt { image.resize!(50, 50) },
            attempt { image.compare_channel(other, Magick::MeanAbsoluteErrorMetric) }
          ]
        end
      end

      result = scheduler.run { image.gaussian_blur(0, 5) }

      expect(errors).to all(in_use)
      expect(image).not_to be_destroyed
      expect(image.columns).to eq(200)
      expect(result.columns).to eq(200)
    end

    it "does not let another fiber use an image that a call changes" do
      image = described_class.new(200, 200)
      errors = nil
      scheduler.before_next_operation do
        Fiber.schedule do
          errors = [
            attempt { image.pixel_color(0, 0) },
            attempt { image.blur_image },
            attempt { Fiber.blocking { image.columns } },
            attempt { image.destroy! }
          ]
        end
      end

      scheduler.run { image.resize!(100, 100) }

      expect(errors).to all(in_use)
      expect(image.columns).to eq(100)
    end

    it "lets a fiber use an image while a call is in flight on another image" do
      first = described_class.new(20, 20)
      second = described_class.new(200, 200)
      scheduler.before_next_operation do
        Fiber.schedule { first.destroy! }
      end

      scheduler.run { second.gaussian_blur(0, 5) }

      expect(first).to be_destroyed
    end

    it "composites with an image that another fiber's call reads" do
      src = described_class.new(200, 200)
      dst = described_class.new(50, 50)
      composited = nil
      scheduler.before_next_operation do
        Fiber.schedule { composited = dst.composite_affine(src, Magick::AffineMatrix.new(1, 0, 0, 1, 0, 0)) }
      end

      scheduler.run do
        src.gaussian_blur(0, 5)
        dst.destroy!
      end

      expect(composited.columns).to eq(50)
      expect(dst).to be_destroyed
    end

    it "does not let another fiber read an image as an argument while a call changes it" do
      src = red_image
      dst = described_class.new(10, 10)
      error = nil
      scheduler.before_next_operation do
        Fiber.schedule { error = attempt { dst.composite(src, 0, 0, Magick::CopyCompositeOp) } }
      end

      scheduler.run { src.colorspace = Magick::CMYKColorspace }

      expect(error).to in_use
    end

    it "does not let another fiber read an image while a call changes its channel mask", if: offloading && Gem::Version.new(Magick::IMAGEMAGICK_VERSION) >= Gem::Version.new("7.0.0") do
      image = red_image
      other = blue_image
      error = nil
      scheduler.before_next_operation { Fiber.schedule { error = attempt { other.difference(image) } } }

      scheduler.run { image.blur_channel(0, 1, Magick::GreenChannel) }

      expect(error).to in_use
      expect(other.difference(image)).not_to eq([0.0, 0.0, 0.0])
    end

    it "lets another fiber run a channel method on an image that a call reads on IM6", if: offloading && Gem::Version.new(Magick::IMAGEMAGICK_VERSION) < Gem::Version.new("7.0.0") do
      image = red_image
      mean = nil
      scheduler.before_next_operation { Fiber.schedule { mean = attempt { image.channel_mean(Magick::RedChannel) } } }

      scheduler.run { image.blur_image }

      expect(mean).to eq([Float(Magick::QuantumRange), 0.0])
    end

    it "does not let another fiber read an image while compare_channel sets its distortion" do
      image = red_image
      other = blue_image
      error = nil
      scheduler.before_next_operation { Fiber.schedule { error = attempt { image.blur_image } } }

      scheduler.run { image.compare_channel(other, Magick::MeanAbsoluteErrorMetric) }

      expect(error).to in_use
    end

    it "does not let another fiber draw on an image that a call reads" do
      image = red_image
      draw = Magick::Draw.new
      draw.fill("blue").rectangle(0, 0, 9, 9)
      error = nil
      scheduler.before_next_operation { Fiber.schedule { error = attempt { draw.draw(image) } } }

      scheduler.run { image.blur_image }

      expect(error).to in_use
      expect(image.pixel_color(5, 5).to_color).to eq(red_image.pixel_color(5, 5).to_color)
    end

    it "does not let another fiber remap an image that a call reads" do
      image = red_image
      palette = blue_image
      images = Magick::ImageList.new << image
      error = nil
      scheduler.before_next_operation { Fiber.schedule { error = attempt { images.remap(palette) } } }

      scheduler.run { image.blur_image }

      expect(error).to in_use
      expect(image.pixel_color(0, 0).red).to eq(Magick::QuantumRange)
    end

    it "remaps with a palette that another fiber's call reads" do
      image = red_image
      palette = blue_image
      images = Magick::ImageList.new << image
      error = :not_run
      scheduler.before_next_operation { Fiber.schedule { error = attempt { images.remap(palette) } } }

      scheduler.run { palette.blur_image }

      expect(error).to be_kind_of(Magick::ImageList)
      expect(image.pixel_color(0, 0).blue).to eq(Magick::QuantumRange)
    end

    it "appends a list with a member that another fiber's call reads" do
      images = Magick::ImageList.new << red_image << red_image
      appended = nil
      scheduler.before_next_operation { Fiber.schedule { appended = images.append(false) } }

      scheduler.run { images[1].blur_image }

      expect(appended.columns).to eq(20)
    end

    it "does not let another fiber change an overlay that a call reads" do
      image = described_class.new(50, 50)
      overlay = described_class.new(200, 200)
      error = nil
      scheduler.before_next_operation { Fiber.schedule { error = attempt { image.blend(overlay, 0.5) } } }

      scheduler.run { overlay.blur_image(0, 3) }

      expect(error).to in_use
    end

    it "does not let another fiber change a Draw that an annotation uses" do
      image = described_class.new(100, 40)
      expected = described_class.new(100, 40)
      other = red_image
      draw = Magick::Draw.new
      draw.pointsize = 30
      draw.dup.annotate(expected, 0, 0, 5, 30, "HELLO")
      errors = nil
      scheduler.before_next_operation do
        Fiber.schedule do
          errors = [
            attempt { draw.pointsize = 2 },
            attempt { draw.annotate(other, 0, 0, 0, 0, "x") },
            attempt { draw.get_type_metrics(other, "x") }
          ]
        end
      end

      scheduler.run { draw.annotate(image, 0, 0, 5, 30, "HELLO") }

      expect(errors).to all(in_use)
      expect(image.signature).to eq(expected.signature)
    end

    it "keeps the annotation of another fiber that takes the Draw over during the block" do
      first = described_class.new(100, 40)
      second = described_class.new(100, 40)
      expected = described_class.new(100, 40)
      draw = Magick::Draw.new
      draw.pointsize = 30
      draw.dup.annotate(expected, 0, 0, 5, 30, "HELLO")
      error = nil

      scheduler.run do
        error = attempt do
          draw.annotate(first, 0, 0, 5, 30, "HELLO") do
            Fiber.schedule { draw.annotate(second, 0, 0, 5, 30, "HELLO") }
          end
        end
      end

      expect(error).to in_use
      expect(second.signature).to eq(expected.signature)
      expect(first.signature).to eq(described_class.new(100, 40).signature)
    end

    it "does not let another fiber change the options of a montage in progress" do
      images = Magick::ImageList.new << red_image << blue_image
      options = nil
      error = nil
      scheduler.before_next_operation { Fiber.schedule { error = attempt { options.title = "x" } } }

      scheduler.run { images.montage { |montage| options = montage } }

      expect(error).to in_use
    end

    it "appends two lists that share an image" do
      shared = red_image
      first = Magick::ImageList.new << shared << blue_image
      second = Magick::ImageList.new << shared << blue_image
      appended = nil
      scheduler.before_next_operation { Fiber.schedule { appended = second.append(false) } }

      result = scheduler.run { first.append(false) }

      expect(result.columns).to eq(20)
      expect(appended.columns).to eq(20)
      expect((Magick::ImageList.new << shared).append(false).columns).to eq(10)
    end

    it "does not let another fiber set an artifact on an image that a call reads" do
      image = described_class.new(50, 50)
      overlay = described_class.new(200, 200)
      errors = nil
      scheduler.before_next_operation do
        Fiber.schedule do
          errors = [
            attempt { image.composite_mathematics(overlay, 1, 0, 0, 0, Magick::CenterGravity) },
            attempt { image.composite_tiled(overlay) },
            attempt { overlay.deskew(0.4, 10) }
          ]
        end
      end

      scheduler.run { overlay.blur_image(0, 3) }

      expect(errors).to all(in_use)
      expect(%w[compose:args modify-outside-overlay deskew:auto-crop].map { |key| overlay.artifact(key) }).to all(be(nil))
    end

    it "does not let another fiber change the offset of an image that stegano reads" do
      image = described_class.read(FLOWER_HAT).first.resize(80, 60)
      watermark = image.resize(10, 10).quantize(2, Magick::GRAYColorspace)
      expected = image.stegano(watermark, 0)
      error = nil
      scheduler.before_next_operation { Fiber.schedule { error = attempt { image.stegano(watermark, 7) } } }

      result = scheduler.run { image.stegano(watermark, 0) }

      expect(error).to in_use
      expect(result.signature).to eq(expected.signature)
    end

    it "does not let another fiber destroy an image that it removes from a list being written" do
      first = red_image
      second = blue_image
      images = Magick::ImageList.new << first << second
      error = nil

      Dir.mktmpdir do |dir|
        scheduler.before_next_operation do
          Fiber.schedule do
            images.delete_at(1)
            scheduler.before_next_operation { error = attempt { second.destroy! } }
          end
        end

        scheduler.run { images.write("#{dir}/out.jpg") }

        expect(error).to in_use
        expect(Dir.children(dir).sort).to eq(%w[out-0.jpg out-1.jpg])
      end
    end

    it "does not let another fiber destroy an image while add_compose_mask negates the mask" do
      image = red_image
      mask = blue_image
      error = nil
      scheduler.before_next_operation { Fiber.schedule { error = attempt { image.destroy! } } }

      scheduler.run { image.add_compose_mask(mask) }

      expect(error).to in_use
      expect(image).not_to be_destroyed
    end

    it "does not let another fiber destroy an image while mask resizes the mask" do
      image = red_image
      mask = described_class.new(5, 5)
      error = nil
      scheduler.before_next_operation { Fiber.schedule { error = attempt { image.destroy! } } }

      scheduler.run { image.mask(mask) }

      expect(error).to in_use
      expect(image).not_to be_destroyed
    end

    it "does not let another fiber destroy an image while profile! decodes the profile" do
      image = red_image
      error = nil
      scheduler.before_next_operation { Fiber.schedule { error = attempt { image.destroy! } } }

      scheduler.run { image.profile!("iptc", "xxx") }

      expect(error).to in_use
      expect(image).not_to be_destroyed
    end

    it "does not let another fiber destroy the other image while <=> computes a signature" do
      first = red_image
      second = blue_image
      error = nil
      scheduler.before_next_operation { Fiber.schedule { error = attempt { second.destroy! } } }

      result = scheduler.run { first <=> second }

      expect(error).to in_use
      expect(result).to eq(first <=> blue_image)
    end

    it "does not let another fiber destroy an image while wet_floor crops its reflection" do
      image = red_image
      error = nil
      scheduler.before_next_operation do
        scheduler.before_next_operation { Fiber.schedule { error = attempt { image.destroy! } } }
      end

      result = scheduler.run { image.wet_floor }

      expect(error).to in_use
      expect(result.columns).to eq(10)
    end

    it "keeps the images of a list that another fiber clears while append reads them" do
      images = Magick::ImageList.new
      3.times { images << red_image }
      scheduler.before_next_operation do
        Fiber.schedule do
          images.clear
          GC.start
        end
      end

      result = scheduler.run { images.append(false) }

      expect(result.columns).to eq(30)
    end

    it "keeps the image of a list that another fiber clears while clut_channel reads it" do
      image = described_class.new(200, 200)
      clut = Magick::ImageList.new << described_class.new(16, 1)
      scheduler.before_next_operation do
        Fiber.schedule do
          clut.clear
          GC.start
        end
      end

      result = scheduler.run { image.clut_channel(clut) }

      expect(result).to be(image)
    end

    it "does not let another fiber change read options until the worker finishes" do
      options = nil
      error = nil
      scheduler.before_next_operation { Fiber.schedule { error = attempt { options.size = "30x30" } } }

      images = scheduler.run do
        described_class.read("xc:red") do |info|
          options = info
          info.size = "5x5"
        end
      end

      expect(error).to in_use
      expect(images.first.columns).to eq(5)
      expect(options.size).to eq("5x5")
    end

    it "does not let another fiber change options while decoding a blob" do
      blob = red_image.to_blob { |info| info.format = "PNG" }
      options = nil
      error = nil
      scheduler.before_next_operation { Fiber.schedule { error = attempt { options.quality = 1 } } }

      images = scheduler.run { described_class.from_blob(blob) { |info| options = info } }

      expect(error).to in_use
      expect(images.first.columns).to eq(10)
    end

    it "does not let another fiber change options while encoding a blob" do
      image = red_image
      options = nil
      error = nil
      scheduler.before_next_operation { Fiber.schedule { error = attempt { options.format = "JPEG" } } }

      blob = scheduler.run do
        image.to_blob do |info|
          options = info
          info.format = "PNG"
        end
      end

      expect(error).to in_use
      expect(described_class.from_blob(blob).first.format).to eq("PNG")
    end

    it "does not let another fiber change options while writing an image" do
      image = red_image
      options = nil
      error = nil
      scheduler.before_next_operation { Fiber.schedule { error = attempt { options.quality = 1 } } }

      Dir.mktmpdir do |dir|
        scheduler.run { image.write(File.join(dir, "image.png")) { |info| options = info } }
      end

      expect(error).to in_use
    end

    it "does not let another fiber change a morphology kernel until the worker finishes" do
      image = red_image
      kernel = Magick::KernelInfo.new("1:1")
      error = nil
      scheduler.before_next_operation { Fiber.schedule { error = attempt { kernel.scale(0, Magick::NoValue) } } }

      result = scheduler.run do
        image.morphology_channel(Magick::RedChannel, Magick::ConvolveMorphology, 1, kernel)
      end

      expect(error).to in_use
      expect(result.pixel_color(0, 0).red).to eq(Magick::QuantumRange)
    end

    it "releases the options when a read is cancelled" do
      options = nil
      scheduler.cancel_next_operation(cancelled.new)

      expect do
        scheduler.run { described_class.read(FLOWER_HAT) { |info| options = info } }
      end.to raise_error(cancelled)

      expect { options.size = "5x5" }.not_to raise_error
    end

    it "releases the kernel when morphology is cancelled" do
      image = red_image
      kernel = Magick::KernelInfo.new("1:1")
      scheduler.cancel_next_operation(cancelled.new)

      expect do
        scheduler.run { image.morphology(Magick::ConvolveMorphology, 1, kernel) }
      end.to raise_error(cancelled)

      expect { kernel.scale(0, Magick::NoValue) }.not_to raise_error
    end

    it "restores the SIGCHLD handler when a cancelled read is unwound", if: offloading && RUBY_PLATFORM.match?(/darwin|freebsd/) do
      calls = 0
      previous = Signal.trap("CHLD") { calls += 1 }
      begin
        scheduler.cancel_next_operation(cancelled.new)
        expect { scheduler.run { described_class.read(FLOWER_HAT) } }.to raise_error(cancelled)

        Process.kill("CHLD", Process.pid)
        sleep(0.05)
        expect(calls).to eq(1)
      ensure
        Signal.trap("CHLD", previous)
      end
    end

    it "restores the SIGCHLD handler after overlapping reads", if: offloading && RUBY_PLATFORM.match?(/darwin|freebsd/) do
      calls = 0
      previous = Signal.trap("CHLD") { calls += 1 }
      begin
        scheduler.run do
          Fiber.schedule { described_class.read(FLOWER_HAT) }
          described_class.read(FLOWER_HAT)
        end
        expect(scheduler.offloaded.size).to eq(2)

        Process.kill("CHLD", Process.pid)
        sleep(0.05)
        expect(calls).to eq(1)
      ensure
        Signal.trap("CHLD", previous)
      end
    end

    it "keeps the bookkeeping per Ractor", if: offloading && defined?(Ractor) do
      experimental = Warning[:experimental]
      Warning[:experimental] = false
      ractors = Array.new(4) do
        Ractor.new(described_class) do |image_class|
          image = image_class.new(5, 5)
          OffloadingScheduler.new.run { 200.times { image.blur_image.destroy! } }
          :ok
        end
      end

      expect(ractors.map(&:value)).to all(eq(:ok))
    ensure
      Warning[:experimental] = experimental
    end

    it "fetches the image after the write options block" do
      image = described_class.new(600, 600)
      other = described_class.new(1200, 1200)

      Dir.mktmpdir do |dir|
        path = File.join(dir, "written.png")
        scheduler.run do
          Fiber.schedule do
            sleep(0.01)
            image.resize!(50, 50)
          end
          image.write(path) { |_info| other.blur_image(0, 3) }
        end

        expect(described_class.read(path).first.columns).to eq(50)
      end
    end

    it "reads a blob that another fiber modifies meanwhile" do
      blob = described_class.new(500, 500).to_blob { |info| info.format = "PPM" }

      images = scheduler.run do
        Fiber.schedule do
          sleep(0.001)
          blob.replace("x")
        end
        described_class.from_blob(blob)
      end

      expect(images.first.columns).to eq(500)
      expect(blob).to eq("x")
    end
  end
end
