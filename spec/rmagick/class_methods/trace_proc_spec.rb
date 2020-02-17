describe Magick, '.trace_proc' do
  after do
    described_class.trace_proc = nil
  end

  it 'works' do
    described_class.trace_proc = proc do |which, description, id, method|
      expect(which).to eq(:c)
      expect(description).to be_instance_of(String)
      expect(id).to be_instance_of(String)
      expect(method).to eq(:initialize)
    end
    image = Magick::Image.new(20, 20)

    described_class.trace_proc = proc do |which, description, id, method|
      expect(which).to eq(:d)
      expect(description).to be_instance_of(String)
      expect(id).to be_instance_of(String)
      expect(method).to eq(:"destroy!")
    end
    image.destroy!
  end
end
