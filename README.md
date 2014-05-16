Kyle
====
A password manager for paranoids.

### Overview

For a password manager kyle differs with the others in two points;

  * It doesn't store any password so there is no file to steal and crack for attackers 
  * So you can't store any given password from 3rd parties but demand your own

And kyle differs with password generators with;

  * Generated passwords are not random but a brute-force method can take trillions of years to crack just one

  	For example on the test vectors Bill Gates' password tooks 12.11 secs on a MacBook Pro Early 2013 with 2,4 GHZ Intel Core i7. So even for a lazy master-key with 8 chars includes small-case-letters and numbers 36^8+36^7+36^5+36^4+36^3+36^2+36 equals 2901713047668 combination with 12.11 secs per combination try leads to ***1,114,274 years*** to try all combinations.

  * It doesn't use any specific hash or encryption algorithm although it uses mixture of them by an algorithm to choose which generated from info and master-key.

### Installation

```
gem install kyle
```


### Algorithm

#### Overall

```

     +--------+   +-------+  +----+  +----------+
     |HOSTNAME|   |ACCOUNT|  |PORT|  |MASTER-KEY|
     +---+----+   +---+---+  +--+-+  +-----+----+
         |            |         |          |
         v            v         v          v
      +------+    +------+   +------+   +------+
      |I.HASH|    |I.HASH|   |I.HASH|   |I.HASH|
      +------+    +------+   +------+   +------+
         |            |         |          |
         v            v         v          v
      +------+    +------+   +------+   +------+
      |I.HASH|    |I.HASH|   |I.HASH|   |I.HASH|
      +------+    +------+   +------+   +------+
         +            +         +            +
         |            |         |            |
         +-----+++----+         +-----+++----+
                |                      |
                v                      v
             +------+              +------+
             |I.ENC.|              |I.ENC.|
             +------+              +------+
                +                      +
                |                      |
                +------------+++-------+
                              |
                              v
                            +------+
                            |I.ENC.|
                            +------+             +------------+
                               +                 |ANIMAL NAMES|
                               |                 +------------+
                              ENC                |   A1..AN   |
                               |                 +------------+
                               v
         +--(A1..AN)------------------------------+
         |RES = PBKDF2_HMAC_SHA1(ENC,RES,10000,32)|
         +----------------------------------------+
                                       +
                                       v
                             +----------------------+
                             |HASH2PASS(SHA512(RES))|
                             +----------------------+
                                      + + +
                                      | | |
                                    (A1..AN)
                                      | | |
                                      v v v

                                 MULTIPLE PASSES

```

#### Iterative Hash

```
                                                              +-------------+
                     Iterative Hash                           |ALGORITHMS   |
                                                              +-------------+
                     +-------------+                    +-->  |SHA512       |
                     |Text=(t1..tn)|                    |     +-------------+
                     +------+------+                    +-->  |SHA384       |
                            |                           |     +-------------+
                            |                           +-->  |SHA256       |
                            v                           |     +-------------+
 +--(i=1..n)-----------------------------------------+  +-->  |SHA224       |
 |HASH=ALGORITHM[(ti % ALGORITHMS.SIZE)](Text | HASH)|+-+     +-------------+
 +---------------------------------------------------+  +-->  |SHA1         |
                            +                           |     +-------------+
                            |                           +-->  |SHA2         |
                            |                           |     +-------------+
                            v                           +-->  |MD5          |
                                                        |     +-------------+
                          HASH                          +-->  |MD4          |
                                                        |     +-------------+
                                                        +-->  |RIPEMD160    |
                                                              +-------------+
```                                                              

#### Iterative Encryption

```
                                                                           +-------------+
                    Iterative Encryption                                   |ALGORITHMS   |
                                                                           +-------------+
                     +-------------+                                 +-->  |DES3         |
                     |TEXT=(t1..tn)|                                 |     +-------------+
                     |KEY=(k1..kn) |                                 +-->  |DESX         |
                     +-------------+                                 |     +-------------+
                            |                                        +-->  |DES          |
                            v                                        |     +-------------+
 +--(i=1..n)----------------------------------------------+          +-->  |CAST         |
 |ENC.=ALGORITHM[(ti % ALGORITHMS.SIZE)]((Text | ENC.),KEY|--------->|     +-------------+
 +-------------------------------------------+------------+          +-->  |BLOWFISH     |
                            +                |     ^                 |     +-------------+
                            |                |     |                 +-->  |AES128       |
                            |                |     |                 |     +-------------+
                            |                v     |                 +-->  |AES192       |
                            |       +--------------+------------+    |     +-------------+
                            |       |KEY=PBKDF2("kyle",10000,32)|    +-->  |AES256       |
                            |       | IV=SHA512(KEY)            |    |     +-------------+
                            |       +---------------------------+    +-->  |RC4          |
                            |                                              +-------------+
                            v

                        ENCRYPTED
```               

