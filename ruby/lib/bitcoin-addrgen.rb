module BitcoinAddrgen; end

require 'bitcoin_addrgen/addrgen'

module BitcoinAddrgen
  def self.generate_public_address(master_public_key, address_index, change = false, version = :bitcoin)
    BitcoinAddrgen::Addrgen.addr_from_mpk(master_public_key, address_index, change, version)
  end
end
