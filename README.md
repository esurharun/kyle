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

```bash
sh$ gem install kyle
```

### Usage

Just type ***kyle*** on command line to run.

```bash
Hostname:
abc.com
Account:
superuser
Port:
80
Key:

Key (again):

Calculating...
Ape	_,o_iMmO5L!ZRlQH
Bat	EZPBcTf6oo-jzWpM
Bear	.ZmYlZ4PQpdOfish
Whale	wb%EOphi7uqySwRZ
Crow	eTXvLc.4FgTdIEJ%
Dog	.Q,PBaMeFRO8nG-a
Cat	,lHFEMVXo%SjTlsm
Wasp	e0CyUAHvs9-ljGFr
Fox	2%yxWtBZz-cOVW@b
Gull	avuR86nGjG6DNkkX
Jackal	+zhRwHPWCHknxlZp
Lion	xMxPwb0E+5vQ_q4x
Panda	qj7GQqJP7EKjU*gG
Rat	kvniGIszq758@Sie
Shark	1aF3.iiV,e*OTGpT
Spider	*nrvUtila0wnmb22
Turtle	wYQerXRYffJJGvxZ
Wolf	MD!VTDkikYxZvzM!
Zebra	asVw!Q/5!QvqxiRf
```
Pick any password depending on your favourite animal.

#### Updates on 0.0.2 version

##### Added -b (BATCH) mode which help you generate bulk passwords;

```
kyle -b <kyle_record_file> <favourite_animal>

<kyle_record_file> a file contains host, account, port data with ; delimited. Ex: facebook.com;zuckerberg;80
<favourite_animal> your favourite animal name
```

##### Added -r option to add entered values to <USER_HOME>/.kyle file

```
kyle -r

If you generate your password with the -r parameter host, account and port data will be saved into <USER_HOME>/.kyle file
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

