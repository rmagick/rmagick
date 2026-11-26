# frozen_string_literal: true

module ResourceLimits
  def without_resources
    limits = %i[area memory map disk].to_h { |resource| [resource, Magick.limit_resource(resource, 0)] }
    yield
  ensure
    limits&.each { |resource, limit| Magick.limit_resource(resource, limit) }
  end
end
