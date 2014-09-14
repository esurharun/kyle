require 'kyle'

# Command line access to Kyle
class KyleCommands
  attr_accessor :args

  def initialize(args = [])
    @args = args
  end

  def run
    batch? ? batch_generate : single_generate
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

  def record
    # Record given parameters to .kyle file at home
    kyle_r_path = File.join(Dir.home, '.kyle')

    line_to_add = "#{hostname};#{account};#{port}"

    File.open(kyle_r_path, 'a') do |file|
      file.puts line_to_add
    end
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
    args.include? '-c'
  end

  def batch?
    args.include? '-b'
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
