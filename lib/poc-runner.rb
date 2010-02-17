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
        counter.times do |n|
          bet = bet_handle.strategy.new_bet
          raise "You lost!" if bet.chips > balance
          balance = balance - bet.chips
          bet.number = bet_handle.dealer.next_number
          balance += bet.earned_value
          ccputs "Placed bet: #{bet}", "Chips: {yellow}#{bet.chips}", "Number: #{bet.number.roulette}", "Earned: {green}#{bet.earned_value}", "Balance: #{balance}"
          bet_handle.bet_history << bet
        end
        ccputs "Initial balance: {green}#{initial_balance} {default}chips"
        ccputs "Total bets count: #{counter}"
        ccputs "Final balance: {green}#{balance} {default}chips"
      end
    end
  end
end

PocRoulette::BetHandle.run
