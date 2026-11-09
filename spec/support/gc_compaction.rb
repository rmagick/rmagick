# frozen_string_literal: true

module GCCompaction
  # Ruby 4.1 moves a String that only an argument slot refers to. Older
  # versions keep it in place, and their GC is not reliable when it compacts
  # under stress.
  def self.moves_arguments?
    Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('4.1') && GC.respond_to?(:auto_compact=)
  end

  def with_gc_compaction
    auto_compact = GC.auto_compact
    stress = GC.stress
    GC.auto_compact = true
    GC.stress = true
    yield
  ensure
    GC.stress = stress
    GC.auto_compact = auto_compact
  end
end
