scriptencoding utf-8
ruby << RUBY
require 'ripper'

module AutoInc
  class Main
    @@weeks = ['monday' , 'tuesday' , 'wednesday' , 'thursday' , 'friday' , 'saturday' , 'sunday']
    @@abbr_weeks = ['mon', 'tue', 'wed', 'thurs', 'fri', 'sat', 'sun']

    def week?(value)
      @@weeks.include?(value.to_s.downcase) || @@abbr_weeks.include?(value.to_s.downcase)
    end

    def week_pos(value)
      @@weeks.index(value.downcase) || @@abbr_weeks.index(value.downcase)
    end

    def echom(message)
      VIM.command("echom '#{message}'")
    end

    def get_pos
      VIM.evaluate('getpos(".")[1]')
    end

    def get_line(col)
      VIM.evaluate("getline('#{col}')")
    end

    def set_line(col, message)
      VIM.evaluate("setline(#{col}, '#{message}')")
    end

    def append_line(col, message)
      VIM.evaluate("append(#{col}, '#{message}')")
    end

    def numeric?(str)
      !str.nil? && !str.match(/^[[:digit:]]+$/).nil?
    end

    def increment_week(str, diff)
      index = @@weeks.index(str.downcase)
      return @@weeks[(index + diff) % @@weeks.length] if !index.nil?

      index = @@abbr_weeks.index(str.downcase)
      return @@abbr_weeks[(index + diff) % @@abbr_weeks.length] if !index.nil?
      return nil
    end

    def increment_number(src, diff)
      inc = (src.to_i + diff).to_s
      if src.start_with?("0")
        inc.rjust(src.length, "0")
      else
        inc
      end
    end

    def diff_element(c, p)
      if numeric?(c) && numeric?(p)
        c.to_i - p.to_i
      else
        1
      end
    end

    def increment_string(current, prev)
      if week?(current)
        diff = week?(prev) ? week_pos(current) - week_pos(prev) : 1
        week = increment_week(current, diff)
        return adjust_case(week, current) if !week.nil?
      else
        return current
      end
    end

    def adjust_case(value, origin)
      adjusted = value.split("").zip(origin.split("")).map do |vs|
        v = vs[0]
        o = vs[1]
        if !o.nil? && o == o.upcase then
          v.upcase
        else
          v
        end
      end
      adjusted.join
    end

    def generate_increment(pos)
      line = get_line(pos)
      prev = get_line(pos - 1)
      current_divided = line.split(/([[:digit:]]+|[., ])/)
      prev_divided = prev.split(/([[:digit:]]+|[., ])/)

      if current_divided.length != prev_divided.length then
        translated = current_divided.map do |v|
          numeric?(v) ? increment_number(v, 1) : increment_string(v, 1)
        end
        translated.join
      else
        translated = current_divided.zip(prev_divided).map do |vs|
          current = vs[0]
          prev = vs[1]
          d = diff_element(current, prev)
          numeric?(current) ? increment_number(current, d) : increment_string(current, prev)
        end
        translated.join
      end
    end

    def execute_generate_increment
      pos = get_pos
      append_line(pos, generate_increment(pos))
    end

    def execute_update
      pos = get_pos
      set_line(pos, generate_increment(pos))
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
