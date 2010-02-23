module PocRoulette
  class IBet
    def initialize(*args); end
    def accept?(line); false; end
    def match?(number); false; end
    def factor; 0; end
  end

  module Bet
    class BlackBet < IBet
      def accept?(line); line == "black" || line =~ /^B(:?\d+)?$/; end
      def match?(n); n.roulette.color == :black; end
      def factor; 2; end
      def to_s; "B"; end
    end

    class RedBet < IBet
      def accept?(line); line == "red" || line =~ /^R(:?\d+)?$/; end
      def match?(n); n.roulette.color == :red; end
      def factor; 2; end
      def to_s; "R"; end
    end

    class EvenBet < IBet
      def accept?(line); line == "even" || line =~ /^E(:?\d+)?$/; end
      def match?(n); n.even? && !n.zero?; end
      def factor; 2; end
      def to_s; "E"; end
    end

    class OddBet < IBet
      def accept?(line); line == "odd" || line =~ /^O(:?\d+)?$/; end
      def match?(n); n.odd?; end
      def factor; 2; end
      def to_s; "O"; end
    end

    class RangeBet < IBet
      def initialize(range, factor)
        @range, @factor = range, factor
        @re = Regexp.new("^#{range}(:\\d+)?$")
      end
      def accept?(line); line =~ @re; end
      def match?(n); @range.include?(n); end
      def factor; @factor; end
      def to_s; @range.to_s; end
      def self.matchers
        matchers = [[1..18, 2],[19..36, 2]]
        matchers += (1..34).select{ |n| n%3==1 }.collect{ |n| [Range.new(n, n+2), 12] }
        matchers += (1..31).select{ |n| n%3==1 }.collect{ |n| [Range.new(n, n+5), 6] }
        matchers += (1..25).select{ |n| (n-1)%12==0 }.collect{ |n| [Range.new(n, n+11), 3] }
        matchers.collect{|e| new(*e) }
      end
    end

    class ColumnBet < IBet
      def initialize(n); @re = Regexp.new("^c#{n+1}(:\\d+)?$"); @rest = (n+1) % 3; end
      def accept?(line); line =~ @re; end
      def match?(n); n % 3 == @rest; end
      def factor; 3; end
      def to_s; "c#{@rest==0 ? 3 : @rest}"; end
      def self.matchers; 3.times.collect{ |n| new(n) }; end
    end

    class NumberBet < IBet
      def initialize(n); @n = n; @re = Regexp.new("^#{n}(:\\d+)?$"); end
      def accept?(line); line =~ @re; end
      def match?(n); n == @n; end
      def factor; 36; end
      def to_s; @n.to_s; end
      def number; @n; end
      def self.matchers; (0..36).to_a.collect{ |n| new(n) }; end
    end
  end

  Matchers = []
  Bet.constants.each do |bet|
    bet_class = Bet.const_get(bet)
    if bet_class.respond_to? :matchers
      bet_class.matchers.each do |m|
        Matchers << m
      end
    else
      Matchers << bet_class.new
    end
  end
end
