#!/usr/bin/ruby
require 'openssl'
require 'highline/import'
require 'constants'

# Password generation from 4 inputs
class Kyle
  attr_accessor :hostname, :account, :port, :key

  def initialize(hostname, account, port, key)
    @hostname = hostname
    @account = account
    @port = port
    @key = key
  end

  def passwords
    @passwords ||= generate
  end

  def generate
    passwords  = {}

    salt = encrypted_inputs
    cipher = salt

    Constants::ANIMALS.each do |a|
      cipher = OpenSSL::PKCS5.pbkdf2_hmac_sha1(cipher, salt, 10_000, 32)

      passwords[a] = Kyle.hash_to_password(cipher)
    end

    passwords
  end

  def hashed_hostname
    Kyle.hash_twice(hostname)
  end

  def hashed_account
    Kyle.hash_twice(account)
  end

  def hashed_port
    Kyle.hash_twice(port)
  end

  def hashed_key
    Kyle.hash_twice(key)
  end

  def encrypted_inputs
    Kyle.iterative_encrypt(
      Kyle.iterative_encrypt(hashed_hostname, hashed_account),
      Kyle.iterative_encrypt(hashed_port, hashed_key))
  end

  #################
  # Class methods #
  #################
  def self.encrypt(alg, val, key)
    cipher = OpenSSL::Cipher::Cipher.new(alg)
    cipher.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(key, 'kyle', 10_000, 32)
    cipher.iv = sha512ize(key)
    cipher.encrypt
    return cipher.update(val) + cipher.final
  rescue OpenSSL::Cipher::CipherError => e
    puts "Error: #{e.message}"
  end

  def self.iterative_encrypt(val, key)
    ret = val

    val.each_byte do |c|
      alg = Constants::ENC_ALGS[c % Constants::ENC_ALGS.length]
      ret = encrypt(alg, ret, key)
    end

    ret
  end

  def self.hash(alg, val)
    OpenSSL::Digest.digest(alg, val)
  end

  def self.iterative_hash(val)
    ret = val

    val.each_byte do |c|
      alg = Constants::HASH_ALGS[c % Constants::HASH_ALGS.length]
      ret = hash(alg, ret)
    end

    ret
  end

  def self.sha512ize(val)
    hash('sha512', val)
  end

  def self.hash_twice(val)
    iterative_hash(iterative_hash(val))
  end

  def self.hash_to_password(val)
    ret = ''

    # to be sure it is long enough
    hashed = sha512ize(val)

    hashed.each_byte do |c|
      ret += Constants::PASSWORD_CHARS[c % Constants::PASSWORD_CHARS.length]
      break if ret.length >= 16
    end

    ret[0..15]
  end
end
