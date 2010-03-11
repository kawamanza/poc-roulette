module PocRoulette
  class BetHandle
    attr_reader :bet_history, :dealer, :poc_strategy_class
    attr_reader :initial_chips, :total_bets, :balance_range
    attr_accessor :balance, :counter
    attr_accessor :max_chips
    attr_accessor :max_chips_per_spot
    attr_accessor :spot_over_chips_counter, :bet_over_chips_counter
    def initialize
      @bet_history = []
      @dealer = PocRoulette::Dealer.new
      @poc_strategy_class = PocRoulette::Strategy[PocConfig['roulette']['strategy']]
      self.balance = @initial_chips = PocConfig['roulette']['initial_chips'] || 1000
      @balance_range = [balance, balance]
      @max_chips = 0
      @max_chips_per_spot = 0
      @spot_over_chips_counter, @bet_over_chips_counter = 0, 0
      @total_bets = PocConfig['roulette']['total_bets'] || 100
      @counter = 0
    end
    def strategy
      strategy = poc_strategy_class.new(bet_history)
      strategy.update_statistics unless bet_history.empty?
      if strategy.respond_to?(:first_bet) && strategy.respond_to?(:other_bets)
        bet_history.empty? ? strategy.first_bet : strategy.other_bets
      else
        strategy.suggest
      end
      strategy
    end
    def next_bet
      self.counter += 1
      bet = strategy.new_bet
      raise "You lost!" if bet.chips > balance
      bet.spots.each do |spot|
        self.spot_over_chips_counter += 1 if spot.value > PocConfig['roulette']['max_chips_per_spot']
        self.max_chips_per_spot = spot.value if max_chips_per_spot < spot.value
      end
      self.bet_over_chips_counter += 1 if bet.chips > PocConfig['roulette']['max_chips_per_bet']
      self.balance -= bet.chips
      bet.number = dealer.next_number
      self.balance += bet.earned_value
      ccputs "Placed bet #{"%#{total_bets.to_s.size}d" % [counter]}: #{bet}",
        "Chips: #{ max_chips < bet.chips ? '{yellow}' : '{brown}' }#{bet.chips}",
        "Number: #{bet.number.roulette}",
        "Earned: {green}#{bet.earned_value}",
        "Balance: #{balance_color}#{balance}"
      self.max_chips = bet.chips if max_chips < bet.chips
      bet_history << bet
    end
    def balance_color
      if balance < balance_range[0]
        balance_range[0] = balance
        "{red}"
      elsif balance > balance_range[1]
        balance_range[1] = balance
        "{light_green}"
      elsif balance >= initial_chips
        "{blue}"
      else
        "{brown}"
      end
    end
    def show_statistics
      puts '='*50
      ccputs "Total bets count: {yellow}#{total_bets}"
      ccputs "Initial balance: {green}#{initial_chips} {default}chips"
      ccputs "Minimal balance: {brown}#{balance_range[0]}"
      ccputs "Maximal balance: {light_green}#{balance_range[1]}"
      ccputs "Final balance: {green}#{balance} {default}chips"
      puts '='*50
      ccputs "Earned less than bet: {brown}#{poc_strategy_class.earning[:less_than_bet]}"
      ccputs "Earned more than bet: {light_green}#{poc_strategy_class.earning[:more_than_bet]}"
      ccputs "Earned nothing: {yellow}#{poc_strategy_class.earning[:nothing]}"
      puts '='*50
      ccputs "Max chips count in one bet: {yellow}#{ max_chips }"
      ccputs "Over #{ PocConfig['roulette']['max_chips_per_bet'] } chips count in one bet: {yellow}#{ bet_over_chips_counter }", "times"
      ccputs "Max chips count in one spot: {yellow}#{ max_chips_per_spot }"
      ccputs "Over #{ PocConfig['roulette']['max_chips_per_spot'] } chips count in one spot: {yellow}#{ spot_over_chips_counter }", "times"
      puts '='*50
      spot_statistics = poc_strategy_class.statistics.sort do |spot1, spot2|
        f = spot1.matcher.factor <=> spot2.matcher.factor
        c = spot1.matcher.class.to_s <=> spot2.matcher.class.to_s
        if f.zero?
          (c.zero? ? (spot1.frequency <=> spot2.frequency) * -1 : c)
        else
          f
        end
      end
      #spot_statistics.select{ |spot| spot.frequency > 0 }.each do |spot|
      spot_statistics = spot_statistics.select{ |spot| spot.matcher.factor < 4 || spot.matcher.is_a?(Bet::NumberBet) && spot.matcher.number == 0 }
      spot_statistics.each do |spot|
        ccputs "Spot: {blue}#{spot}", "Frequency: {yellow}#{spot.frequency}"
      end
    end
    class << self
      def run!
        bet_handle = self.new
        bet_handle.total_bets.times do |n|
          bet_handle.next_bet
          sleep PocConfig['roulette']['sleep'] unless PocConfig['roulette']['sleep'].nil?
        end
      rescue => e
        ccputs "{light_red}#{e.message}"
      ensure
        bet_handle.show_statistics
      end
    end
  end
end
