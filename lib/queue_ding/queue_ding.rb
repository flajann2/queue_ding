=begin rdoc
= QueueDing -- a queue to handle passing of messages between threads in a thread safe manner

This is based on and extends the Array class, and wraps it with semaphores so that
messages -- any arbitrary objects -- can be added to and removed from the Array queue across
multiple threads.

Note that any object added to this QueueDing should probably be frozen, but if it is clear
that whomever removes the object from the QDing now owns that object, that requirement can
be relaxed.
=end

require 'aquarium'
require 'thread'
require 'set'

module QueueDing

  # QDing is basically an extension of the Array class for queuing purposes.
  # We add QDing#next as a blocking get the next element, as well as
  # QDing#dequeue which is an alias for Array#pop. Conversely, we add
  # QDing#enqueue, which is just an alias for Array#unshift.
  class QDing < Array
    include Aquarium::DSL

    # These accessors are ONLY used internally, and are
    # subject to change.
    attr_accessor :semaphore, :resource, :listener_threads

    def initialize
      super
      @listener_threads = Set.new
      @semaphore = Mutex.new
      @resource = ConditionVariable.new
    end

    alias_method :next, :shift
    alias_method :dequeue, :shift
    alias_method :enqueue, :push
    alias_method :enqueue, :push

    
    # enqueue, and others that need protection for multithreading
    around calls_to: [:<<,
                      :enqueue,
                      :unshift
    ] do |join_point, q, *args|
      result = nil
      q.semaphore.synchronize {
        result = join_point.proceed
        q.resource.signal
      }
      result
    end

    # dequeue
    around calls_to: [:pop,
                      :next,
                      :dequeue
    ] do |join_point, q, *args|
      result = nil
      q.semaphore.synchronize {
        q.listener_threads << (curth = Thread.current)
        curth[:localq] ||= []

        while q.empty? and curth[:localq].empty?
          q.resource.wait(q.semaphore)
        end
        # At this point, at least one of the queues have something.
        # What we do here is that if we have something in the main
        # queue? We distribute that to the other waiting threads.
        # Those threads will check their own localq to see if they have
        # an entry, etc.
        result = unless curth[:localq].empty?
                   curth[:localq].shift
                 else
                   r = join_point.proceed
                   q.listener_threads.reject{|t|
                     t == curth
                   }.each{ |t|
                     t[:localq] << r
                   }
                   r
                 end
      }
      result
    end
  end
end
