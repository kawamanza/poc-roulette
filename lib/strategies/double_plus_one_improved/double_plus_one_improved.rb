module PocRoulette
  class DoublePlusOneImprovedStrategy < Strategy
    def first_bet
      new_bet.add_bet :black, 2
      new_bet.add_bet :red, 1
    end
    def other_bets
      last_bet.chips > 16 ? optimized_bet : default_bet
    end
  private
    def default_bet
      last_bet.spots.each do |spot|
        if spot.earned_value == 0
          new_bet.add_bet spot.bet_location, spot.value*2
        else
          new_bet.add_bet spot.bet_location, 1
        end
      end
    end
    def optimized_bet
      base = last_bet.chips - (last_bet.earned_value / 2)
      max = last_bet.spots.inject(0){ |sum, spot| spot.value > sum ? spot.value : sum }
      base = base * 2 + 1
      factor = 0.9
      last_bet.spots.each do |spot|
        if last_bet.earned_value == 0
          chips = spot.value * 2 + 1
        else
          chips = (base * factor).round
          if spot.earned_value == 0
            chips = base - 1 if chips == base
          else
            chips = chips == base ? 1 : base - chips
          end
        end
        new_bet.add_bet spot.bet_location, chips
      end
    end
  end
end
