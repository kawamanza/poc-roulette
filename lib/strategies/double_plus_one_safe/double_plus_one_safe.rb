module PocRoulette
  class DoublePlusOneSafeStrategy < Strategy
    def first_bet
      new_bet.add_bet :black, 1
      new_bet.add_bet :red, 1
    end
    def other_bets
      last_bet.spots.each do |spot|
        chips = 1
        if spot.earned_value == 0
          chips = spot.value * 2 + 1 if spot.value > 1 || bet_history.size > 1 && bet_history[-2].spots.any?{ |s| s.bet_location == spot.bet_location && s.earned_value == 0 }
        end
        new_bet.add_bet spot.bet_location, chips
      end
    end
  end
end
