module ColoredConsole
  class << self
    def puts(*args)
      STDOUT.puts colored(*args)
    end

    def print(*args)
      STDOUT.print colored(*args)
    end

    def colored(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      color = options[:with]
      args.collect do |text|
        if color.nil?
          "#{text}{default}".gsub(/\{\w+\}/) {|m| Colors[m[1..-2].to_sym] }
        else
          "#{Colors[color]}#{text}#{Colors[:default]}"
        end
      end.join " "
    end

    Colors = {
      :default      => "\033[0m",
      :black        => "\033[0;30m",
      :red          => "\033[0;31m",
      :green        => "\033[0;32m",
      :brown        => "\033[0;33m",
      :blue         => "\033[0;34m",
      :purple       => "\033[0;35m",
      :cyan         => "\033[0;36m",
      :light_gray   => "\033[0;37m",
      :dark_gray    => "\033[1;30m",
      :light_red    => "\033[1;31m",
      :light_green  => "\033[1;32m",
      :yellow       => "\033[1;33m",
      :light_blue   => "\033[1;34m",
      :light_purple => "\033[1;35m",
      :light_cyan   => "\033[1;36m",
      :white        => "\033[1;37m",
    }
  end
end

def ccputs(*args)
  ColoredConsole.puts *args
end
