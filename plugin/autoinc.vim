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

    def increment(src, diff)
      inc = (src.to_i + diff).to_s
      if src.start_with?("0")
        return inc.rjust(src.length, "0")
      else
        return inc
      end
    end

    def diff_line(l1, l2)
      d1 = l1.split(/([[:digit:]]+)/)
      d2 = l2.split(/([[:digit:]]+)/)
      return 1 if d1.length != d2.length

      diffs = d1.zip(d2) do |v1, v2|
        if is_numeric?(v1) && is_numeric?(v2)
          return v1.to_i - v2.to_i
        end
      end
      return diffs(0)
    end

    def execute
      pos = get_pos
      line = get_line(pos)
      divided = line.split(/([[:digit:]]+)/)
      diff = diff_line(line, get_line(pos - 1))
      translated = divided.map do |v|
        is_numeric?(v) ? increment(v, diff) : v
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
