require 'openssl'
require 'highline/import'


$ENC_ALGS = [ 
  "des3",            "desx",         "des",          "cast",         "bf",
  "aes128",       "aes192",       "aes256",       "rc4",             "rc5"
 
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
  "coW//.1@TI3Y6P1I", "-Szvi.iY4g1kdjXy", "7r6mg-7deXock6PZ", "xa-Nr-oNcp*VIM*p",
  "OXwzEPWyDjs7T!DO", "hRTlwhn/hNdhYsbF", "qwnfRTA0k.Oh1cRA", "jk%w68nPmnA8ZORr",
  "Zo5evvyrSAqysC-I", "EFg7Fdb.%u-F4sCB", "uC*F2phIvh2muK/A", "DyDhQr6zEiIvIlTo",
  "4@QfNyaRGPl4.aCY", "Nf4GqhnTxxy1fbCS", "owqa/Z50INdeSL*n", "difCKZ%8R1yJiw9n",
  "00SQaINu/00ZTIIb", "SAuQMhQoy6%3Ij,+", "10q**M/9eA-9hUp9"
  ],
  [
    $passctable.join,$passctable.join,$passctable.join,$passctable.join,
    "hglvFa7+JQLRd5tR", "DWCu*417y/s2h0lY", "Y7bGjG%cQNo70RXA", "A%P/biGk@Y6C8!@-",
    "lkkkC.uFN-vaaawR", "0HZvPhjpPTXlPeb!", "UoI%jFeN3_@ypgXI", "q*Dhoul/9!5Iwj5g",
    "-!NzBxb5lPdsf7ZX", "%vYYS/mTq%eAk2I!", "fjXHnk0qvUl0MsT.", "sPjcoCsvMo2dF%ZD",
    "iuOEJFwDpEa1retY", "s000FfYEEjlfa7kC", "mTgoP+lwtpZT+gvR", "GgEli28jWlseYe@c",
    "cP/e!FlnOxq.q+2X", "wrzP9DvaL9_BS9pi", "I_0!jpVgOXSDtnc!"
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

  puts "Calculating..."
  vals = generate(hostname,account,port,key)
  
  $animalnames.each.with_index(0) do |animal,i|
  
    puts "#{animal}\t#{vals[i]}"
  
  end
end
