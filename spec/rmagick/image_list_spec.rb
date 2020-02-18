# rubocop:disable Style/CollectionMethods
RSpec.describe Magick::ImageList do
  it 'does not have certain array methods' do
    image_list = described_class.new(*FILES[0..9])

    expect { image_list.assoc }.to raise_error(NoMethodError)
    expect { image_list.flatten }.to raise_error(NoMethodError)
    expect { image_list.flatten! }.to raise_error(NoMethodError)
    expect { image_list.join }.to raise_error(NoMethodError)
    expect { image_list.pack }.to raise_error(NoMethodError)
    expect { image_list.rassoc }.to raise_error(NoMethodError)
  end

  it 'has certain enumerable methods' do
    image_list = described_class.new(*FILES[0..9])

    expect { image_list.detect { true } }.not_to raise_error

    image_list.each_with_index { |image, _n| expect(image).to be_instance_of(Magick::Image) }

    expect { image_list.entries }.not_to raise_error
    expect { image_list.include?(image_list[0]) }.not_to raise_error
    expect { image_list.inject(0) { 0 } }.not_to raise_error
    expect { image_list.max }.not_to raise_error
    expect { image_list.min }.not_to raise_error
    expect { image_list.sort }.not_to raise_error
    expect { image_list.sort_by(&:signature) }.not_to raise_error
    expect { image_list.zip }.not_to raise_error
  end
end
# rubocop:enable Style/CollectionMethods
