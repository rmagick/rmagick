# frozen_string_literal: true

# A small Fiber scheduler, independent of the async gem, that runs blocking
# operations on a worker thread the way Async's worker pool does.
#
# Ruby 3.4 added Fiber::Scheduler#blocking_operation_wait. When a scheduler
# implements it, rb_nogvl hands every call made with RB_NOGVL_OFFLOAD_SAFE to
# that hook instead of running it on the scheduler's thread. This scheduler
# records those calls so the specs can check that RMagick's GVL-free calls opt
# in, and it never returns control to the waiting fiber before the worker has
# finished, since the arguments of the call live on that fiber's stack.
class OffloadingScheduler
  attr_reader :offloaded, :completed

  def initialize
    @offloaded = []
    @completed = []
    @blocked = {}
    @ready = Thread::Queue.new
    @cancel_next = nil
  end

  # Runs the block in a non-blocking fiber on a fresh thread and drives the
  # scheduler until every fiber has finished. Returns the block's value and
  # re-raises whatever the fiber raised.
  def run(&block)
    Thread.new do
      Thread.current.report_on_exception = false
      run_on_current_thread(&block)
    end.value
  end

  # Raises +exception+ in the fiber that waits for the next offloaded call, as
  # a scheduler does when a task is stopped or a timeout expires.
  def cancel_next_operation(exception)
    @cancel_next = exception
  end

  def blocking_operation_wait(work)
    @offloaded << work
    thread = Thread.new do
      work.call
      @completed << work
    end
    if (exception = @cancel_next)
      @cancel_next = nil
      fiber_interrupt(Fiber.current, exception)
    end
    thread.join
  ensure
    thread.join while thread&.alive?
  end

  def fiber_interrupt(fiber, exception)
    @ready << [fiber, exception]
  end

  def block(_blocker, _timeout = nil)
    @blocked[Fiber.current] = true
    Fiber.yield
  end

  def unblock(_blocker, fiber)
    @ready << [fiber, nil]
  end

  def kernel_sleep(duration = nil)
    Fiber.blocking { sleep(duration) }
  end

  def io_wait(_io, events, _timeout = nil)
    events
  end

  private

  def run_on_current_thread
    Fiber.set_scheduler(self)
    result = nil
    Fiber.new(blocking: false) { result = yield }.resume
    until @blocked.empty?
      fiber, exception = @ready.pop
      @blocked.delete(fiber)
      exception ? fiber.raise(exception) : fiber.resume
    end
    result
  ensure
    Fiber.set_scheduler(nil)
  end
end
