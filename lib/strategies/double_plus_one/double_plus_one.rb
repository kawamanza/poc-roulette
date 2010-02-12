module PocRoulette
  class DoublePlusOneStrategy < Strategy
    def strategy
      if last_bet.nil?
        new_bet.add_bet :black, 2
        new_bet.add_bet :red, 1
      else
        last_bet.spots.each do |spot|
          if spot.earned_value == 0
            new_bet.add_bet spot.bet_location, spot.value*2
          else
            new_bet.add_bet spot.bet_location, 1
          end
        end
      end
    end
  end
end
