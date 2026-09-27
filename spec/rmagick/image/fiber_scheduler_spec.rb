# frozen_string_literal: true

require_relative '../../support/offloading_scheduler'

# RMagick offloads only on Ruby 4.0, which has the C API a scheduler needs to
# cancel and drain a blocking operation (rb_fiber_scheduler_blocking_operation_extract).
offloading = Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("4.0")

RSpec.describe Magick::Image, if: offloading do
  context "with a Fiber scheduler that offloads blocking operations" do
    let(:scheduler) { OffloadingScheduler.new }
    let(:cancelled) { Class.new(StandardError) }

    def red_image
      described_class.new(10, 10) { |options| options.background_color = "red" }
    end

    def resident_set_size
      Integer(`ps -o rss= -p #{Process.pid}`)
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

      depth = scheduler.run { image.depth }

      expect(depth).to be_kind_of(Integer)
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
      image = described_class.new(1000, 1000)
      cancel_blur = lambda do
        scheduler = OffloadingScheduler.new
        scheduler.cancel_next_operation(cancelled.new)
        expect { scheduler.run { image.gaussian_blur(0, 0.5) } }.to raise_error(cancelled)
      end
      cancel_blur.call
      before = resident_set_size

      20.times { cancel_blur.call }
      GC.start

      expect(resident_set_size - before).to be < 100 * 1024
    end

    it "restores the channel mask of a cancelled call" do
      image = red_image
      scheduler.cancel_next_operation(cancelled.new)

      expect { scheduler.run { image.blur_channel(0, 1, Magick::GreenChannel) } }.to raise_error(cancelled)

      expect(image.negate.pixel_color(0, 0).to_color).to eq(red_image.negate.pixel_color(0, 0).to_color)
    end

    it "makes another fiber wait for a call in flight before it destroys the image" do
      image = described_class.new(2000, 2000)
      order = []

      result = scheduler.run do
        Fiber.schedule do
          sleep(0.01)
          image.destroy!
          order << :destroyed
        end
        blurred = image.gaussian_blur(0, 5)
        order << :blurred
        blurred
      end

      expect(order).to eq(%i[blurred destroyed])
      expect(image).to be_destroyed
      expect(result.columns).to eq(2000)
    end

    it "keeps a waiting fiber from using an image that another fiber replaced" do
      image = described_class.new(2000, 2000)
      results = []

      scheduler.run do
        Fiber.schedule { results << image.gaussian_blur(0, 3) }
        Fiber.schedule { image.resize!(500, 500) }
        Fiber.schedule { results << image.gaussian_blur(0, 3) }
      end

      expect(results.map(&:columns)).to eq([2000, 500])
      expect(image.columns).to eq(500)
    end

    it "lets a fiber use an image while a call is in flight on another image" do
      first = described_class.new(20, 20)
      second = described_class.new(2000, 2000)

      result = scheduler.run do
        Fiber.schedule { second.gaussian_blur(0, 5) }
        Fiber.schedule do
          sleep(0.01)
          first.destroy!
        end
        first.composite(second, 0, 0, Magick::OverCompositeOp)
      end

      expect(result.columns).to eq(20)
      expect(first).to be_destroyed
    end

    it "waits before drawing on an image used by a worker" do
      image = red_image
      draw = Magick::Draw.new
      draw.fill("blue").rectangle(0, 0, 9, 9)
      scheduler.before_next_operation { Fiber.schedule { draw.draw(image) } }

      result = scheduler.run { image.blur_image }

      expect(result.pixel_color(5, 5).to_color).to eq(red_image.pixel_color(5, 5).to_color)
      expect(image.pixel_color(5, 5).blue).to eq(Magick::QuantumRange)
    end

    it "waits before remapping an image used by a worker" do
      image = red_image
      images = Magick::ImageList.new << image
      palette = described_class.new(1, 1) { |info| info.background_color = "blue" }
      scheduler.before_next_operation { Fiber.schedule { images.remap(palette) } }

      result = scheduler.run { image.blur_image }

      expect(result.pixel_color(0, 0).red).to eq(Magick::QuantumRange)
      expect(image.pixel_color(0, 0).blue).to eq(Magick::QuantumRange)
    end

    it "waits for a remap palette before fetching the target images" do
      image = red_image
      palette = red_image
      images = Magick::ImageList.new << image
      errors = []
      scheduler.before_next_operation do
        Fiber.schedule do
          images.remap(palette)
        rescue Magick::DestroyedImageError => e
          errors << e
        end
        image.destroy!
      end

      scheduler.run { palette.blur_image }

      expect(errors.size).to eq(1)
    end

    it "waits for every list member before linking native images" do
      first = red_image
      second = red_image
      images = Magick::ImageList.new << first << second
      errors = []
      scheduler.before_next_operation do
        Fiber.schedule do
          images.append(false)
        rescue Magick::DestroyedImageError => e
          errors << e
        end
        first.destroy!
      end

      scheduler.run { second.blur_image }

      expect(errors.size).to eq(1)
    end

    it "keeps read options stable until the worker finishes" do
      options = nil
      scheduler.before_next_operation { Fiber.schedule { options.size = "30x30" } }

      images = scheduler.run do
        described_class.read("xc:red") do |info|
          options = info
          info.size = "5x5"
        end
      end

      expect(images.first.columns).to eq(5)
      expect(options.size).to eq("30x30")
    end

    it "locks options while decoding a blob" do
      blob = red_image.to_blob { |info| info.format = "PNG" }
      options = nil
      order = []
      scheduler.before_next_operation do
        Fiber.schedule do
          options.quality = 1
          order << :changed
        end
      end

      scheduler.run do
        described_class.from_blob(blob) { |info| options = info }
        order << :decoded
      end

      expect(order).to eq(%i[decoded changed])
    end

    it "locks options while encoding a blob" do
      image = red_image
      options = nil
      order = []
      scheduler.before_next_operation do
        Fiber.schedule do
          options.format = "JPEG"
          order << :changed
        end
      end

      blob = scheduler.run do
        result = image.to_blob do |info|
          options = info
          info.format = "PNG"
        end
        order << :encoded
        result
      end

      expect(order).to eq(%i[encoded changed])
      expect(described_class.from_blob(blob).first.format).to eq("PNG")
    end

    it "locks options while writing an image" do
      image = red_image
      options = nil
      order = []
      scheduler.before_next_operation do
        Fiber.schedule do
          options.quality = 1
          order << :changed
        end
      end

      Dir.mktmpdir do |dir|
        scheduler.run do
          image.write(File.join(dir, "image.png")) { |info| options = info }
          order << :written
        end
      end

      expect(order).to eq(%i[written changed])
    end

    it "keeps morphology kernels stable until the worker finishes" do
      image = red_image
      kernel = Magick::KernelInfo.new("1:1")
      scheduler.before_next_operation { Fiber.schedule { kernel.scale(0, Magick::NoValue) } }

      result = scheduler.run do
        image.morphology_channel(Magick::RedChannel, Magick::ConvolveMorphology, 1, kernel)
      end

      expect(result.pixel_color(0, 0).red).to eq(Magick::QuantumRange)
      expect(image.morphology(Magick::ConvolveMorphology, 1, kernel).pixel_color(0, 0).red).to eq(0)
    end

    it "releases the options lock when a read is cancelled" do
      options = nil
      scheduler.cancel_next_operation(cancelled.new)

      expect do
        scheduler.run { described_class.read(FLOWER_HAT) { |info| options = info } }
      end.to raise_error(cancelled)

      expect { options.size = "5x5" }.not_to raise_error
    end

    it "releases the kernel lock when morphology is cancelled" do
      image = red_image
      kernel = Magick::KernelInfo.new("1:1")
      scheduler.cancel_next_operation(cancelled.new)

      expect do
        scheduler.run { image.morphology(Magick::ConvolveMorphology, 1, kernel) }
      end.to raise_error(cancelled)

      expect { kernel.scale(0, Magick::NoValue) }.not_to raise_error
    end

    it "lets a blocking fiber wait for a replaced image" do
      image = red_image
      widths = []
      scheduler.before_next_operation do
        Fiber.schedule { Fiber.blocking { widths << image.columns } }
      end

      scheduler.run { image.resize!(5, 5) }

      expect(widths).to eq([5])
    end

    it "removes a cancelled blocking waiter before waking other fibers" do
      image = red_image
      errors = []
      widths = []
      scheduler.before_next_operation do
        waiter = Fiber.schedule do
          Fiber.blocking { image.columns }
        rescue StandardError => e
          errors << e
        end
        scheduler.fiber_interrupt(waiter, cancelled.new)
        Fiber.schedule { Fiber.blocking { widths << image.columns } }
      end

      scheduler.run { image.resize!(5, 5) }

      expect(errors).to contain_exactly(an_instance_of(cancelled))
      expect(widths).to eq([5])
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

    it "waits for an overlay in flight before changing it" do
      image = described_class.new(50, 50)
      overlay = described_class.new(1500, 1500)
      order = []

      scheduler.run do
        Fiber.schedule do
          overlay.blur_image(0, 3)
          order << :blurred
        end
        image.blend(overlay, 0.5)
        order << :blended
      end

      expect(order).to eq(%i[blurred blended])
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
