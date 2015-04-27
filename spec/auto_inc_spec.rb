require 'spec_helper'

def set_file_content(string)
  string = normalize_string_indent(string)
  File.open(filename, 'w'){ |f| f.write(string) }
  vim.edit filename
end

def get_file_content()
  vim.write
  IO.read(filename).strip
end

def before(string)
  options.each { |x| vim.command(x) }
  set_file_content(string)
end

def after(string)
  get_file_content().should eq normalize_string_indent(string)
end

def type(string)
  string.scan(/<.*?>|./).each do |key|
    if /<.*>/.match(key)
      vim.feedkeys "\\#{key}"
    else
      vim.feedkeys key
    end
  end
end

describe 'autoinc' do
  let(:filename) { 'test.txt' }
  let(:options) { [] }

  it 'simple number' do
    before <<-EOF
      work1
    EOF
    vim.command(':AutoIncrement')
    after <<-EOF
      work1
      work2
    EOF
  end

  it 'comma separeted value' do
    before <<-EOF
      work1,name1
    EOF
    vim.command(':AutoIncrement')
    after <<-EOF
      work1,name1
      work2,name2
    EOF
  end

  it 'comma separeted formatted value' do
    before <<-EOF
      work01,name001,type0099
    EOF
    vim.command(':AutoIncrement')
    after <<-EOF
      work01,name001,type0099
      work02,name002,type0100
    EOF
  end

  it 'increment based on previous data' do
    before <<-EOF
      work01
      work03
    EOF
    vim.normal('G')
    vim.command(':AutoIncrement')
    after <<-EOF
      work01
      work03
      work05
    EOF
  end
end
