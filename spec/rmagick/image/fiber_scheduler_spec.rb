# frozen_string_literal: true

RSpec.describe Magick::Image, if: Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.4") do
  context "with a Fiber scheduler that offloads blocking operations" do
    let(:scheduler) { OffloadingScheduler.new }
    let(:cancelled) { Class.new(StandardError) }

    it "runs an ImageMagick call through #blocking_operation_wait" do
      image = described_class.new(20, 20)

      result = scheduler.run { image.blur_image }

      expect(scheduler.offloaded.size).to eq(1)
      expect(scheduler.completed).to eq(scheduler.offloaded)
      expect(result).to be_instance_of(described_class)
      expect(result.columns).to eq(20)
    end

    it "reads and writes images on the worker thread" do
      blob = scheduler.run do
        image = described_class.read(FLOWER_HAT).first
        image.to_blob { |info| info.format = "PNG" }
      end

      expect(scheduler.offloaded.size).to be >= 2
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

    it "survives repeated cancellation and garbage collection" do
      20.times do
        scheduler = OffloadingScheduler.new
        scheduler.cancel_next_operation(cancelled.new)

        expect { scheduler.run { described_class.new(100, 100).gaussian_blur(0, 5) } }.to raise_error(cancelled)
        GC.start

        expect(scheduler.completed).to eq(scheduler.offloaded)
      end
    end
  end
end
