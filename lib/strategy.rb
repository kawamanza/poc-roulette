module PocRoulette
  class SpotBet
    attr_reader :value, :matcher
    attr_reader :owner
    def initialize(matcher, value, owner)
      @matcher, @value = matcher, value
      @owner = owner
    end
    def bet_location; matcher.to_s; end
    def number; owner.number; end
    def earned_value
      if number.nil?
        0
      else
        matcher.match?(number) ? matcher.factor * value : 0
      end
    end
    def to_s
      "#{earned_value == 0 ? "{blue}" : "{light_blue}"}#{matcher}:#{value}"
    end
  end

  class PlacedBet
    attr_reader :spots
    attr_accessor :number
    def initialize
      @spots = []
    end
    def add_bet(location, value)
      spot = location.to_s
      matcher = Matchers.select{ |m| m.accept?(spot) }.first
      raise "Invalid spot: #{spot}" if matcher.nil?
      spots << SpotBet.new(matcher, value, self)
    end
    def chips
      spots.collect(&:value).inject(0){ |b, n| b + n }
    end
    def earned_value
      spots.collect(&:earned_value).inject(0){ |b, n| b + n }
    end
    def to_s
      spots.collect(&:to_s).join(' ')
    end
  end

  class Strategy
    @@strategies = {}
    attr_reader :bet_history
    def initialize(history)
      @bet_history = history
    end
    def new_bet
      @new_bet ||= PlacedBet.new
    end
    def last_bet
      bet_history.last
    end
    class << self
      def inherited(base)
        base_name = base.to_s.underscore.split('/').last.sub(/_strategy$/, '')
        @@strategies[base_name] = base
      end
      def [](strategy); @@strategies[strategy]; end
    end
  end
end

ccputs "{light_blue}Strategies:"
Dir.glob(File.join File.dirname(__FILE__), 'strategies', '*/') do |strategy|
  strategy_name = strategy.scan(/[^\/]+/).last
  ccputs "\t- {brown}#{strategy_name}"
  strategy_file = strategy + strategy_name
  require strategy_file
end
