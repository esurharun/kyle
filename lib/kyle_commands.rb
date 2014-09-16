require 'kyle'

# Command line access to Kyle
class KyleCommands
  attr_accessor :args

  def initialize(args = [])
    @args = args
  end

  def run
    puts 'Kyle - A password manager for paranoids. ( 0.0.5 )'
    puts ''

    batch_generate if batch?
    single_generate_choose if single_by_choose?
    single_generate if !batch? && !single_by_choose?
  end

  def ask_for_key
    return ask('Key:') { |q| q.echo = false } unless check?

    key = 'a'
    key_check = 'b'

    while key != key_check
      key  = ask('Key:') { |q| q.echo = false }
      key_check  = ask('Key (again):') { |q| q.echo = false }

      puts 'Keys do not match!' unless key == key_check
    end

    key
  end

  def batch_generate
    text = File.open(file).read

    text.gsub!(/\r\n?/, "\n")

    text.each_line do |line|
      hostname, account, port = line.split(';')

      port.gsub!(/\n/, '')

      passwords = make_passwords(hostname, account, port, key)

      passwords.select { |a, _| animals.include? a }.each do |a, p|
        puts "#{hostname}:#{account}:#{port} (#{a}) = #{p}"
      end
    end
  end

  def kyle_r_path
    File.join(Dir.home, '.kyle')
  end

  def record
    line_to_add = "#{hostname};#{account};#{port}"

    File.open(kyle_r_path, 'a') do |file|
      file.puts line_to_add
    end
  end

  def saved_records
    recs = []
    i_a = 0
    File.open(kyle_r_path).each do |line|
      recs << line.rstrip!
      puts "#{i_a} - #{line}"
      i_a += 1
    end

    recs
  end

  def single_generate_choose
    recs = saved_records

    puts('')
    idx = ask('Selection:')

    r = recs[idx.to_i].split(';')

    @hostname = r[0]
    @account = r[1]
    @port = r[2]

    single_generate
  end

  def single_generate
    record if record?

    passwords = make_passwords(hostname, account, port, key)

    if animals.length > 1
      Constants::ANIMALS.each { |a| puts "#{a}\t#{passwords[a]}" }
    else
      puts passwords[animals[0]]
    end
  end

  def record?
    args.include? '-r'
  end

  def check?
    (args.include? '-c') || (record?)
  end

  def batch?
    args.include? '-b'
  end

  def single_by_choose?
    args.include? '-a'
  end

  def main_args
    args.reject { |arg| arg[0] == '-' }
  end

  def hostname
    @hostname ||= main_args[0] || ask('Hostname:')
  end

  def account
    @account ||= main_args[1] || ask('Account:')
  end

  def port
    @port ||= main_args[2] || ask('Port:')
  end

  def animals
    animal = batch? ? main_args[1] : main_args[3]

    return Constants::ANIMALS if animal.nil?
    Constants::ANIMALS.select { |a| a.downcase == animal.downcase }
  end

  def make_passwords(hostname, account, port, key)
    puts 'Generating...'
    puts ''

    Kyle.new(hostname, account, port, key).passwords
  end

  def file
    fail 'File only for batch operations' unless batch?
    main_args[0]
  end

  def key
    @key ||= ask_for_key
  end
end
