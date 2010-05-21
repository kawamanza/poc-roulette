module PocRoulette
  class FibonacciPlusZeroStrategy < Strategy
    FibonacciSequence = [0, 1, 2, 3]
    def first_bet
      new_bet.add_bet 0, 1
      #new_bet.add_bet 16..21, 1
      new_bet.add_bet 1..12, FibonacciSequence[3]
      new_bet.add_bet 25..36, FibonacciSequence[2]
    end
    def other_bets
      bet = []
      earned_zero = 0
      last_bet.spots.each do |spot|
        case spot.bet_location
        when '1..12', '25..36'
          bet << spot
        else
          earned_zero = spot.earned_value
          new_bet.add_bet spot.bet_location, spot.value
        end
      end
      v = 0
      bet = bet.sort{ |spot1, spot2| spot2.value <=> spot1.value }
      bet_values = bet.collect(&:value)
      if earned_zero > 0
        if bet_values[0] == 5
          bet_values[0] = 0
        else
          bet_values = bet_values.collect do |value|
            [8, 3].include?(value) ? 0 : value
          end
        end
      end
      if bet[0].earned_value > 0 || bet_values[0] == 0
        if bet[1].value == 2
          new_bet.add_bet bet[0].bet_location, 2
          new_bet.add_bet bet[1].bet_location, 3
        else
          pos = FibonacciSequence.index(bet[1].value)
          new_bet.add_bet bet[0].bet_location, FibonacciSequence[pos-1]
          new_bet.add_bet bet[1].bet_location, bet[1].value
        end
      elsif bet[1].earned_value > 0 || bet_values[1] == 0
        bet.each{ |spot| new_bet.add_bet spot.bet_location, spot.value }
      else
        bet.each do |spot|
          pos = FibonacciSequence.index(spot.value)
          FibonacciSequence << FibonacciSequence[-1] + FibonacciSequence[-2] if FibonacciSequence.size == pos + 1
          new_bet.add_bet spot.bet_location, FibonacciSequence[pos+1]
        end
      end
    end
  end
end
