# Bitcoin Addrgen - Deterministic Bitcoin Address Generator

## Installation

```sh
~$ gem install bitcoin-addrgen
```

## Usage

```ruby
require 'bitcoin-addrgen'

master_public_key = "675b7041a347223984750fe3ab229df0c9f960e7ec98226b7182a2cb1990e39901feecf5a670f1d788ab29f626e20de424f049d216fc6f4c6ec42506763fa28e"
first_ten_addresses = 10.times.collect do |address_index|
  BitcoinAddrgen.generate_public_address(master_public_key, address_index)
end

puts first_ten_addresses
# 13EfJ1hQBGMBbEwvPa3MLeH6buBhiMSfCC
# 1AZW6GGmsUizkHhrtg853Qnxk68vCx2gFq
# 1M7ReiRrcYygYYLdyPS2cKQi7p9s9ViFS1
# 1NcawzHFoECpDhz8hUCZp43hGjvdEB8DBA
# 1PjcUN9kEBn3kvUmT2BXezwTG4RRvrqjRw
# 16QNfbdLoKkMKtQR3MK8uisss7YAF88Yv4
# 1jmA5ySdFz7cDwWb15rWQe63ZUo8spiBa
# 1BsHKTsi3umme8xv4GbrPxGCfQ2feJYZAV
# 16uCFEcanBtRPAwn6GhkFtmVeurrkbgt1U
# 1J7yTE8Cm9fMV9nqCjnM6kTTzTkksVic98

```

# Credits

* Pure PHP Elliptic Curve Cryptography Library by Matej Danter, https://github.com/mdanter/phpecc
* mpkgen by Chris Savery, https://github.com/bkkcoins/misc/tree/master/mpkgen/php

Donations welcome at 1PuRV7zVXrajGxHJ6LJLccgDYz4hNcVPfS

# Copyright

See LICENSE.txt for further details.
