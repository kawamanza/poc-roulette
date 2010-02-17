module PocRoulette
  class Dealer
    attr_reader :ball_pos
    @@sequence = %w[0 32 15 19 4 21 2 25 17 34 6 27 13 36 11 30 8 23 10 5 24 16 33 1 20 14 31 9 22 18 29 7 28 12 35 3 26].collect{ |n| n.to_i }
    def initialize
      @ball_pos = 0
    end
    def next_number
      pos = ball_pos + (@@sequence.size / 3) + ((rand+1) * @@sequence.size)
      @ball_pos = pos.round(0).to_i % @@sequence.size
      @@sequence[ball_pos]
    end
  end
end
