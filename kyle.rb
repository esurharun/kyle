#!/usr/bin/ruby
require 'openssl'
require 'highline/import'


$ENC_ALGS = [ 
  "des3",            "desx",         "des",          "cast",         "bf",
  "aes128",       "aes192",       "aes256",       "rc4"
 
]

$HSH_ALGS = [
  "sha512",       "sha384",       "sha256",       "sha224",       "sha1",         "sha",
  "md5",          "md4",          "ripemd160"
]

$letters = [
  "q","w","e","r","t","y","u","i","o","p",
  "a","s","d","f","g","h","j","k","l","z",
  "x","c","v","b","n","m"
]

$bletters = [
  "Q","W","E","R","T","Y","U","I","O","P",
  "A","S","D","F","G","H","J","K","L","Z",
  "X","C","V","B","N","M"
]

$nums = [
  "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
]

$schars = [
  ".", "@", "+", "-", "*", "/", "%", "_", "!", ","
]

$passctable = []

$letters.each { |c| $passctable << c }
$bletters.each { |c| $passctable << c }
$nums.each { |c| $passctable << c }
$schars.each { |c| $passctable << c }

$animalnames = [
  "Ape", "Bat", "Bear", "Whale", "Crow", "Dog", "Cat", "Wasp",
  "Fox", "Gull", "Jackal", "Lion", "Panda", "Rat", "Shark", "Spider",
  "Turtle", "Wolf", "Zebra"
]


def to_hex(s)
  s.each_byte.map { |b| b.to_s(16) }.join
end


def enc_it(alg,val,key) 
  #puts "enc_it #{alg} #{to_hex(val)} #{to_hex(key)}"
  begin
    cipher = OpenSSL::Cipher::Cipher.new(alg)
    cipher.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(key, "kyle", 10000, 32)
    cipher.iv = sha512ize(key)
    cipher.encrypt
    return cipher.update(val) + cipher.final
  rescue OpenSSL::Cipher::CipherError => e
    puts "Error: #{e.message}"
  end
end

def iterative_enc(val, key)
  ret = val
  val.each_byte do |c|
    ret = enc_it($ENC_ALGS[c % ($ENC_ALGS.size)], ret, key)
  end
  
  return ret
end

def hash_it(alg,val)
  #puts "hash_it #{alg} - #{to_hex(val)}"
  OpenSSL::Digest.digest(alg,val)
end

def iterative_hash(val)
  ret = val
  val.each_byte do |c|
    ret = hash_it($HSH_ALGS[c % ($HSH_ALGS.size)], ret)
  end
  return ret
end

def sha512ize(val)
  hash_it("sha512",val)
end

def di_hash(val)
  iterative_hash(iterative_hash(val))
end

def hash2pass(val) 
  ret = ""
  
  # to be sure it is long enough
  h = sha512ize(val)
  
  h.each_byte do |c|
    ret += $passctable[c % ($passctable.size)]
  end
  
  return ret[0..15]
end



def generate(hostname,account,port,key)
  
  ret  = Array.new
  
  harr = [ di_hash(hostname), di_hash(account), di_hash(port), di_hash(key) ]

  v1 = iterative_enc(harr[0],harr[1])
  v2 = iterative_enc(harr[2],harr[3])

  v = iterative_enc(v1,v2)

  c = v
  $animalnames.each do |animal|
    c = OpenSSL::PKCS5.pbkdf2_hmac_sha1(c, v, 10000, 32)
  
    ret << hash2pass(c)
  
  end
  
  return ret
end

$testarr = [
  [
  "microsoft.com","bill.gates","666","iKnowWhatYouDidToIBMLastSummer",
  "WW0nQIY.0Rn6D8d2", "nXzU19faM7*gv7,I", "cgu0q7*DuT65r3rY", "ILZ,5vZLl/wRxf9y",
  "Od..eF2k6_l3XHxe", "sedWPnJsSb4DEJw-", "JEr_SzZBoofgI7Tb", "xbbg@ebdz3FA.n6S",
  "5EMS!XZP7WfPLKpO", "LcwDHUu0/ynzdSWE", "5+fDOoY.yrE+ESbj", "VWKqetfVKZtT,FI9",
  "EDe7XvMZ%8tt2vsT", "vks.HPeDVkklS_qb", "hcVznOxvT5YvxIlU", "iBTr-I42uz7h7XnA",
  "fLV,g6%@1G7xpQil", "toMFvN@Zd,b*KBC%", "FYbi/6Udx_4mO3D0"
  ],
  [
    $passctable.join,$passctable.join,$passctable.join,$passctable.join,
    "cuoTJm!UuIYCcQxs", "3HrQ3s/j53A+Rssm", "KK+IV7QE9Imd65hi", "M@FH%uduAIvn/0Fg",
    "C@ffelLPbsh!ps68", "mF%j06cgTaD63v5C", "5pRiaZDk%SY6quet", "d56XIGF8PhHu!TfI",
    "71UES8Six9G48hsc", "kmtu%gr1.k%T!tPy", "zE8*qE+uU.PsOkYY", "77Rbxcaiwp4Fwm.M",
    "qWT0K%tFP8w7_H0S", "2uGyZI.SzAOujmkw", ".QhaGPzV_jnnRj@F", "4FsOh0GfaM4MVUUH",
    "_3r0DzAdYvEp@dlA", "qcWgE@nt9SgUEsjP", "8F1BJ.OlV5Kj!wmM"
   ]
]

def test_it()
  puts "Testing..."
  
  failed = false
  (0..1).each do |idx|
    vals = generate($testarr[idx][0],$testarr[idx][1],$testarr[idx][2],$testarr[idx][3])
    vals.each.with_index(0) do |v,i|
      if ($testarr[idx][i+4] != v)
        puts "Test failed: #{$testarr[idx][i+4]} <> #{v}"
        failed = true
      end
    end
  end
  puts "Finished #{failed ? "and Failed" : "successfully"}"
end

if (ARGV.size > 0 && ARGV[0] == "test")
  test_it()
else
  hostname = ask("Hostname:")
  account  = ask("Account:")
  port  = ask("Port:")
  key  = ask("Key:") { |q| q.echo = false }
  key2  = ask("Key (again):") { |q| q.echo = false }
  
  if (key != key2)
    puts "Passes do not match!!"
    exit
  end
  
  puts "Calculating..."
  vals = generate(hostname,account,port,key)
  
  $animalnames.each.with_index(0) do |animal,i|
  
    puts "#{animal}\t#{vals[i]}"
  
  end
end
