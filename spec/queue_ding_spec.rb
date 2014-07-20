require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'thread'

CNT = 100000
CNTI = CNT
CNTO = CNT

describe QueueDing::QDing do
  before(:each) do
    @queue = QueueDing::QDing.new

    class Foobar
      def initialize
        @stuff = [1, 2, 3]
      end

    end
    @foo = Foobar.new
  end

  it "QDing can be created" do
    expect(@queue).to_not be_nil
  end

  it "pushes an object into the queue" do
    @queue << @foo
    expect(@queue.first).to eq @foo
  end

  it "extracts an object from the queue" do
    @queue << @foo
    bar = @queue.pop
    expect(bar).to eq @foo
  end

  it "handles concurrency" do
    tout = Thread.new do
      (0..CNTO).each{ |j|
        (i, num) = @queue.next
        expect(j).to eq i
        expect(num).to eq j * 7 + 3
      }
    end
    tin = Thread.new do
      (0..CNTI).map{|i| [i, i * 7 + 3]}.each{|pair| @queue << pair }
    end
    tin.join
    tout.join
    expect(@queue.empty?).to be_truthy
  end
end
