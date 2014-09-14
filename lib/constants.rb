# Algorithms, password characters, animals
module Constants
  ENC_ALGS = %w(des3 desx des cast bf aes128 aes192 aes256 rc4).freeze
  HASH_ALGS = %w(sha512 sha384 sha256 sha224 sha1 sha md5 md4 ripemd160).freeze

  LETTERS = %w(q w e r t y u i o p a s d f g h j k l z x c v b n m).freeze
  BIG_LETTERS = %w(Q W E R T Y U I O P A S D F G H J K L Z X C V B N M).freeze
  NUMBERS = %w(0 1 2 3 4 5 6 7 8 9).freeze
  SPECIAL_CHARS = %w(. @ + - * / % _ ! ,).freeze

  PASSWORD_CHARS = (LETTERS + BIG_LETTERS + NUMBERS + SPECIAL_CHARS).freeze

  ANIMALS = %w(Ape Bat Bear Whale Crow Dog Cat Wasp Fox Gull Jackal Lion Panda
               Rat Shark Spider Turtle Wolf Zebra).freeze
end
