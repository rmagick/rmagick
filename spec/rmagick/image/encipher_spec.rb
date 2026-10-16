# frozen_string_literal: true

RSpec.describe Magick::Image, "#encipher" do
  it "releases what it holds when one of its calls is interrupted" do
    image = described_class.new(4, 4)

    expect(interrupt_each_call(Class.new(StandardError)) { image.encipher("passphrase") }).to be_positive
  end
end
