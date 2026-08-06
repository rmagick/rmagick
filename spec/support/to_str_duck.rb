# frozen_string_literal: true

# Not a String, but converts to one. Arguments of this type make the extension
# take the #to_str coercion path, where the String the conversion produces is
# referenced by nothing the caller can see.
class ToStrDuck
  def initialize(str)
    @str = str
  end

  def to_str
    @str.dup
  end
end
