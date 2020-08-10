RSpec.describe Magick::Image, "#change_geometry" do
  it "passes the original image to the block" do
    image = build_image
    block_image = nil
    image.change_geometry('400x400') do |_cols, _rows, inner_image|
      block_image = inner_image
    end

    expect(block_image).to be(image)
  end

  it "returns the result from the block" do
    image = build_image

    result = image.change_geometry('400x400') { "some_result" }

    expect(result).to eq("some_result")
  end

  it "does not directly modify the original image" do
    image = build_image

    image.change_geometry('400x400') {}

    expect([image.rows, image.columns]).to eq([2, 2])
  end

  it "passes dimensions to enable enlarging the image" do
    image = build_image

    resized_image = image.change_geometry('400x400') do |cols, rows, block_image|
      block_image.resize(cols, rows)
    end

    expect([resized_image.rows, resized_image.columns]).to eq([400, 400])
  end

  it "passes dimensions that will maintain the aspect ratio" do
    image = build_image

    image.change_geometry('300x4000') do |cols, rows|
      image.resize!(cols, rows)
    end

    expect([image.rows, image.columns]).to eq([300, 300])
  end

  it "accepts a Geometry object that maintains the aspect ratio" do
    image = build_image

    image.change_geometry(Magick::Geometry.new(300, 4000)) do |cols, rows|
      image.resize!(cols, rows)
    end

    expect([image.rows, image.columns]).to eq([300, 300])
  end

  it "raises an error when extra arguments are passed" do
    image = build_image

    expect { image.change_geometry('400x400', "boo") {} }
      .to raise_error(ArgumentError)
  end

  it "raises an error when no block is passed" do
    image = build_image

    expect { image.change_geometry('400x400') }
      .to raise_error(LocalJumpError)
  end
end
