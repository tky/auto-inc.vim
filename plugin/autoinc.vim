scriptencoding utf-8
ruby << RUBY
require 'ripper'

module AutoInc
  class Main
    def echom(message)
      VIM.command("echom '#{message}'")
    end

    def get_pos
      return VIM.evaluate('getpos(".")[1]')
    end

    def get_line(col)
      return VIM.evaluate("getline('#{col}')")
    end

    def set_line(col, message)
      VIM.evaluate("append(#{col}, '#{message}')")
    end

    def is_numeric?(str)
      !str.match(/^[[:digit:]]+$/).nil?
    end

    def increment(src)
      return src.to_i + 1
    end

    def execute
      pos = get_pos
      line = get_line(pos)
      divided = line.split(/([[:digit:]]+)/)
      translated = divided.map do |v|
        is_numeric?(v) ? increment(v) : v
      end
      set_line(pos, translated.join)
    end
  end
end
$autoinc = AutoInc::Main.new
RUBY

func! AutoIncrement()
ruby << RUBY
  $autoinc.execute()
RUBY
endfunc

command! AutoIncrement :call AutoIncrement()
