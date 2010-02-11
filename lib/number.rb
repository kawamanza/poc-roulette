module PocRoulette
  class Number
    attr_reader :number, :color
    def initialize(*args)
      @number = args.shift
      @color  = args.shift
    end
    class << self
      def numbers
        @@numbers ||= []
      end
      def add(*args)
        numbers << Number.new(*args) if numbers.select{ |n| n.number == args.first }.empty?
      end
    end

    pos = 0
    37.times do |n|
      pos = (pos + 1) % 2
      pos = (pos + 1) % 2 if [11, 19, 29].include?(n)
      add n, n.zero? ? :green : [:red, :black][pos]
    end
  end
end
