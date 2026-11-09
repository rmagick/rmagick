# frozen_string_literal: true

module GCCompaction
  # Ruby 4.1 moves a String that only an argument slot refers to. Older
  # versions keep it in place, and their GC is not reliable when it compacts
  # under stress.
  def self.moves_arguments?
    RUBY_VERSION >= '4.1' && GC.respond_to?(:auto_compact=)
  end

  # Runs the block with the GC collecting and compacting on every allocation,
  # so that a pointer taken from an object that nothing pins goes stale.
  def with_gc_compaction
    GC.auto_compact = true
    GC.stress = true
    yield
  ensure
    GC.stress = false
    GC.auto_compact = false
  end
end
