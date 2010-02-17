module PocRoulette
  class BetHandle
    attr_reader :bet_history, :dealer, :poc_strategy_class
    def initialize
      @bet_history = []
      @dealer = PocRoulette::Dealer.new
      @poc_strategy_class = PocRoulette::Strategy[PocConfig['roulette']['strategy']]
    end
    def strategy
      strategy = poc_strategy_class.new(bet_history)
      strategy.strategy if strategy.respond_to?(:strategy)
      strategy.suggest if strategy.respond_to?(:suggest)
      strategy
    end
    class << self
      def run
        bet_handle = self.new
        initial_balance = balance = PocConfig['roulette']['initial_chips'] || 1000
        counter = PocConfig['roulette']['total_bets'] || 100
        balance_stats = [initial_balance, initial_balance]
        counter.times do |n|
          bet = bet_handle.strategy.new_bet
          raise "You lost!" if bet.chips > balance
          balance = balance - bet.chips
          bet.number = bet_handle.dealer.next_number
          balance += bet.earned_value
          if balance < balance_stats[0]
            balance_color = "{red}"
            balance_stats[0] = balance
          elsif balance > balance_stats[1]
            balance_color = "{light_green}"
            balance_stats[1] = balance
          elsif balance >= initial_balance
            balance_color = "{blue}"
          else
            balance_color = "{brown}"
          end
          ccputs "Placed bet #{"%#{counter.to_s.size}d" % [n+1]}: #{bet}", "Chips: {yellow}#{bet.chips}", "Number: #{bet.number.roulette}", "Earned: {green}#{bet.earned_value}", "Balance: #{balance_color}#{balance}"
          bet_handle.bet_history << bet
          sleep PocConfig['roulette']['sleep'] unless PocConfig['roulette']['sleep'].nil?
        end
        puts '='*50
        ccputs "Total bets count: {yellow}#{counter}"
        ccputs "Initial balance: {green}#{initial_balance} {default}chips"
        ccputs "Minimal balance: {brown}#{balance_stats[0]}"
        ccputs "Maximal balance: {light_green}#{balance_stats[1]}"
        ccputs "Final balance: {green}#{balance} {default}chips"
      end
    end
  end
end

PocRoulette::BetHandle.run
