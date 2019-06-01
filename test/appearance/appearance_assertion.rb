require 'test/unit'

module AppearanceAssertion
  include Test::Unit::Assertions

  def assert_same_image(expected_image_path, image_object, delta: 0.01)
    path = File.expand_path(File.join(__dir__, expected_image_path))

    expected = Magick::Image.read(path).first
    _, error = expected.compare_channel(image_object, Magick::MeanSquaredErrorMetric)
    assert_in_delta(0.0, error, delta)
  end
end
