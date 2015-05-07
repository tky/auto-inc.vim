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
      VIM.evaluate("setline(#{col}, '#{message}')")
    end

    def append_line(col, message)
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
      return [].fill(1, 0, [d1.length, d2.length].max) if d1.length != d2.length

      diffs = d1.zip(d2).map{|v1, v2|
        if is_numeric?(v1) && is_numeric?(v2)
          v1.to_i - v2.to_i
        else
          1
        end
      }
      return diffs
    end

    def generate_increment
      pos = get_pos
      line = get_line(pos)
      divided = line.split(/([[:digit:]]+)/)
      diffs = diff_line(line, get_line(pos - 1))
      translated = divided.map.with_index do |v, i|
        diff = diffs[i]
        is_numeric?(v) ? increment(v, diff) : v
      end
      return translated.join
    end

    def execute_generate_increment
      pos = get_pos
      append_line(pos, generate_increment())
    end

    def execute_update
      pos = get_pos
      set_line(pos, generate_increment())
    end
  end
end
$autoinc = AutoInc::Main.new
RUBY

func! g:autoinc#generate_increment()
ruby << RUBY
  $autoinc.execute_generate_increment()
RUBY
endfunc

func! g:autoinc#update_to_increment()
ruby << RUBY
  $autoinc.execute_update()
RUBY
endfunc

command! GenerateIncrement :call g:autoinc#generate_increment()
command! UpdateToIncrement :call g:autoinc#update_to_increment()
