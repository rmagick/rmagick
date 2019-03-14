RSpec.describe Magick::Image, '#composite' do
  let(:img1) { Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first }
  let(:img2) { Magick::Image.read(IMAGES_DIR + '/Button_1.gif').first }
  let(:composite_ops) do
    [
      Magick::UndefinedCompositeOp,
      Magick::AlphaCompositeOp,
      Magick::AtopCompositeOp,
      Magick::BlendCompositeOp,
      Magick::BlurCompositeOp,
      Magick::BumpmapCompositeOp,
      Magick::ChangeMaskCompositeOp,
      Magick::ClearCompositeOp,
      Magick::ColorBurnCompositeOp,
      Magick::ColorDodgeCompositeOp,
      Magick::ColorizeCompositeOp,
      Magick::CopyBlackCompositeOp,
      Magick::CopyBlueCompositeOp,
      Magick::CopyCompositeOp,
      Magick::CopyCyanCompositeOp,
      Magick::CopyGreenCompositeOp,
      Magick::CopyMagentaCompositeOp,
      Magick::CopyAlphaCompositeOp,
      Magick::CopyRedCompositeOp,
      Magick::CopyYellowCompositeOp,
      Magick::DarkenCompositeOp,
      Magick::DarkenIntensityCompositeOp,
      Magick::DifferenceCompositeOp,
      Magick::DisplaceCompositeOp,
      Magick::DissolveCompositeOp,
      Magick::DistortCompositeOp,
      Magick::DivideDstCompositeOp,
      Magick::DivideSrcCompositeOp,
      Magick::DstAtopCompositeOp,
      Magick::DstCompositeOp,
      Magick::DstInCompositeOp,
      Magick::DstOutCompositeOp,
      Magick::DstOverCompositeOp,
      Magick::ExclusionCompositeOp,
      Magick::HardLightCompositeOp,
      Magick::HardMixCompositeOp,
      Magick::HueCompositeOp,
      Magick::InCompositeOp,
      Magick::IntensityCompositeOp,
      Magick::LightenCompositeOp,
      Magick::LightenIntensityCompositeOp,
      Magick::LinearBurnCompositeOp,
      Magick::LinearDodgeCompositeOp,
      Magick::LinearLightCompositeOp,
      Magick::LuminizeCompositeOp,
      Magick::MathematicsCompositeOp,
      Magick::MinusDstCompositeOp,
      Magick::MinusSrcCompositeOp,
      Magick::ModulateCompositeOp,
      Magick::ModulusAddCompositeOp,
      Magick::ModulusSubtractCompositeOp,
      Magick::MultiplyCompositeOp,
      Magick::NoCompositeOp,
      Magick::OutCompositeOp,
      Magick::OverCompositeOp,
      Magick::OverlayCompositeOp,
      Magick::PegtopLightCompositeOp,
      Magick::PinLightCompositeOp,
      Magick::PlusCompositeOp,
      Magick::ReplaceCompositeOp,
      Magick::SaturateCompositeOp,
      Magick::ScreenCompositeOp,
      Magick::SoftLightCompositeOp,
      Magick::SrcAtopCompositeOp,
      Magick::SrcCompositeOp,
      Magick::SrcInCompositeOp,
      Magick::SrcOutCompositeOp,
      Magick::SrcOverCompositeOp,
      Magick::ThresholdCompositeOp,
      Magick::VividLightCompositeOp,
      Magick::XorCompositeOp,
      Magick::StereoCompositeOp
    ]
  end
  let(:gravity) do
    [
      Magick::NorthEastGravity,
      Magick::EastGravity,
      Magick::SouthWestGravity,
      Magick::SouthGravity,
      Magick::SouthEastGravity
    ]
  end

  it 'raises an error given invalid arguments' do
    expect { img1.composite }.to raise_error(ArgumentError)
    expect { img1.composite(img2) }.to raise_error(ArgumentError)
    expect do
      img1.composite(img2, Magick::NorthWestGravity)
    end.to raise_error(ArgumentError)
    expect { img1.composite(2) }.to raise_error(ArgumentError)
    expect { img1.composite(img2, 2) }.to raise_error(ArgumentError)
  end

  context 'when given 3 arguments' do
    it 'works when 2nd argument is a gravity' do
      composite_ops.each do |op|
        gravity.each do |grav|
          expect { img1.composite(img2, grav, op) }.not_to raise_error
        end
      end
    end

    it 'raises an error when 2nd argument is not a gravity' do
      expect do
        img1.composite(img2, 2, Magick::OverCompositeOp)
      end.to raise_error(TypeError)
    end
  end

  context 'when given 4 arguments' do
    it 'works when 4th argument is a composite operator' do
      # there are way too many CompositeOperators to test them all, so just try
      # few representative ops
      composite_ops.each do |op|
        expect { img1.composite(img2, 0, 0, op) }.not_to raise_error
      end
    end

    it 'returns a new Magick::Image object' do
      res = img1.composite(img2, 0, 0, Magick::OverCompositeOp)
      expect(res).to be_instance_of(Magick::Image)
    end

    it 'raises an error when 4th argument is not a composite operator' do
      expect { img1.composite(img2, 0, 0, 2) }.to raise_error(TypeError)
    end
  end

  context 'when given 5 arguments' do
    it 'works when 2nd argument is gravity and 5th is a composite operator' do
      composite_ops.each do |op|
        gravity.each do |grav|
          expect { img1.composite(img2, grav, 0, 0, op) }.not_to raise_error
        end
      end
    end

    it 'raises an error when 2nd argument is not a gravity' do
      expect do
        img1.composite(img2, 0, 0, 2, Magick::OverCompositeOp)
      end.to raise_error(TypeError)
    end
  end

  it 'raises an error when the image has been destroyed' do
    img2.destroy!
    expect do
      img1.composite(img2, Magick::CenterGravity, Magick::OverCompositeOp)
    end.to raise_error(Magick::DestroyedImageError)
  end
end
