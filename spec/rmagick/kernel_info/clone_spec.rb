RSpec.describe Magick::KernelInfo, '#clone' do
  it 'works' do
    kernel = described_class.new('Octagon')

    expect(kernel.clone).to be_instance_of(described_class)
    expect(kernel.clone).not_to be(kernel)
  end
end
