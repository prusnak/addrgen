#
# Copyright (c) 2012 Matyas Danter
# Copyright (c) 2012 Chris Savery
# Copyright (c) 2013 Pavol Rusnak
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
# OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

require 'digest'
require 'ffi'

module GMP
  extend FFI::Library
  ffi_lib ['gmp', 'libgmp.so.3', 'libgmp.so.10']
  attach_function :__gmpz_init_set_str, [:pointer, :string, :int], :int
  attach_function :__gmpz_get_str, [:string, :int, :pointer], :string
  attach_function :__gmpz_add, [:pointer, :pointer, :pointer], :void
  attach_function :__gmpz_add_ui, [:pointer, :pointer, :ulong], :void
  attach_function :__gmpz_and, [:pointer, :pointer, :pointer], :void
  attach_function :__gmpz_clear, [:pointer], :void
  attach_function :__gmpz_cmp, [:pointer, :pointer], :int
  attach_function :__gmpz_cmp_si, [:pointer, :long], :int
  attach_function :__gmpz_fdiv_q_ui, [:pointer, :pointer, :ulong], :ulong
  attach_function :__gmpz_fdiv_r, [:pointer, :pointer, :pointer], :void
  attach_function :__gmpz_invert, [:pointer, :pointer, :pointer], :int
  attach_function :__gmpz_mul, [:pointer, :pointer, :pointer], :void
  attach_function :__gmpz_mul_si, [:pointer, :pointer, :long], :void
  attach_function :__gmpz_neg, [:pointer, :pointer], :void
  attach_function :__gmpz_pow_ui, [:pointer, :pointer, :ulong], :void
  attach_function :__gmpz_sub, [:pointer, :pointer, :pointer], :void

  @ptrlist = []

  def self.collect(ptr)
    @ptrlist << ptr
  end

  def self.collect_clear
    @ptrlist.each { |p|
      GMP::__gmpz_clear(p)
    }
    @ptrlist = []
  end

end

def gmp_init(str, base)
  ptr = FFI::MemoryPointer.new :char, 16
  GMP::collect(ptr)
  GMP::__gmpz_init_set_str(ptr, str, base)
  ptr
end

def gmp_strval(op, base)
  GMP::__gmpz_get_str(nil, base, op)
end

def gmp_add(a, b)
  ptr = FFI::MemoryPointer.new :char, 16
  GMP::collect(ptr)
  if a.instance_of? Fixnum
    GMP::__gmpz_add_ui(ptr, b, a)
  elsif b.instance_of? Fixnum
    GMP::__gmpz_add_ui(ptr, a, b)
  else
    GMP::__gmpz_add(ptr, a, b)
  end
  ptr
end

def gmp_and(a, b)
  ptr = FFI::MemoryPointer.new :char, 16
  GMP::collect(ptr)
  GMP::__gmpz_and(ptr, a, b)
  ptr
end

def gmp_cmp(a, b)
  if a.instance_of? Fixnum and b.instance_of? Fixnum
    a <=> b
  elsif a.instance_of? Fixnum
    -GMP::__gmpz_cmp_si(b, a)
  elsif b.instance_of? Fixnum
    GMP::__gmpz_cmp_si(a, b)
  else
    GMP::__gmpz_cmp(a, b)
  end
end

def gmp_div(a, b)
  ptr = FFI::MemoryPointer.new :char, 16
  GMP::collect(ptr)
  GMP::__gmpz_fdiv_q_ui(ptr, a, b)
  ptr
end

def gmp_invert(a, b)
  ptr = FFI::MemoryPointer.new :char, 16
  GMP::collect(ptr)
  GMP::__gmpz_invert(ptr, a, b)
  ptr
end

def gmp_mod(a, b)
  ptr = FFI::MemoryPointer.new :char, 16
  GMP::collect(ptr)
  GMP::__gmpz_fdiv_r(ptr, a, b)
  ptr
end

def gmp_mul(a, b)
  ptr = FFI::MemoryPointer.new :char, 16
  GMP::collect(ptr)
  if a.instance_of? Fixnum
    GMP::__gmpz_mul_si(ptr, b, a)
  elsif b.instance_of? Fixnum
    GMP::__gmpz_mul_si(ptr, a, b)
  else
    GMP::__gmpz_mul(ptr, a, b)
  end
  ptr
end

def gmp_neg(a)
  ptr = FFI::MemoryPointer.new :char, 16
  GMP::collect(ptr)
  GMP::__gmpz_neg(ptr, a)
  ptr
end

def gmp_pow(a, b)
  ptr = FFI::MemoryPointer.new :char, 16
  GMP::collect(ptr)
  GMP::__gmpz_pow_ui(ptr, a, b)
  ptr
end

def gmp_sub(a, b)
  ptr = FFI::MemoryPointer.new :char, 16
  GMP::collect(ptr)
  GMP::__gmpz_sub(ptr, a, b)
  ptr
end

module BitcoinAddrgen
  class Curve

    attr_reader :prime, :a, :b

    def initialize(prime, a, b)
      @prime = prime
      @a = a
      @b = b
    end

    def contains(x, y)
      gmp_cmp(gmp_mod(gmp_sub(gmp_pow(y, 2), gmp_add(gmp_add(gmp_pow(x, 3), gmp_mul(@a, x)), @b)), @prime), 0) == 0
    end

    def self.cmp(cp1, cp2)
      gmp_cmp(cp1.a, cp2.a) or gmp_cmp(cp1.b, cp.b) or gmp_cmp(cp.prime, cp.prime)
    end

  end

  class Point

    attr_reader :curve, :x, :y, :order

    def initialize(curve, x, y, order = nil)
      @curve = curve
      @x = x
      @y = y
      @order = order
      if @curve and @curve.instance_of?(Curve)
        raise Exception, 'Curve does not contain point' if not @curve.contains(@x, @y)
        if @order != nil
          raise Exception, 'Self*Order must equal infinity' if (Point.cmp(Point.mul(order, self), :infinity) != 0)
        end
      end
    end

    def self.cmp(p1, p2)
      if !p1.instance_of?(Point)
        return 1 if p2.instance_of?(Point)
        return 0 if !p2.instance_of?(Point)
      end
      if !p2.instance_of?(Point)
        return 1 if p1.instance_of?(Point)
        return 0 if !p1.instance_of?(Point)
      end
      gmp_cmp(p1.x, p2.x) or gmp_cmp(p1.y, p2.y) or Curve.cmp(p1.curve, p2.curve)
    end

    def self.add(p1, p2)

      return p1 if Point.cmp(p2, :infinity) == 0 and p1.instance_of?(Point)
      return p2 if Point.cmp(p1, :infinity) == 0 and p2.instance_of?(Point)
      return :infinity if Point.cmp(p1, :infinity) == 0 and Point.cmp(p2, :infinity) == 0

      if Curve.cmp(p1.curve, p2.curve) == 0
        if gmp_cmp(p1.x, p2.x) == 0
          if gmp_mod(gmp_add(p1.y, p2.y), p1.curve.prime) == 0
            return :infinity
          else
            return Point.double(p1)
          end
        end
        p = p1.curve.prime
        l = gmp_mul(gmp_sub(p2.y, p1.y), gmp_invert(gmp_sub(p2.x, p1.x), p))
        x3 = gmp_mod(gmp_sub(gmp_sub(gmp_pow(l, 2), p1.x), p2.x), p)
        y3 = gmp_mod(gmp_sub(gmp_mul(l, gmp_sub(p1.x, x3)), p1.y), p)
        p3 = Point.new(p1.curve, x3, y3)
        return p3
      else
        raise Exception, 'Elliptic curves do not match'
      end
    end

    def self.mul(x2, p1)
      e = x2
      return :infinity if Point.cmp(p1, :infinity) == 0
      e = gmp_mod(e, p1.order) if p1.order != nil
      return :infinity if gmp_cmp(e, 0) == 0
      if gmp_cmp(e, 0) > 0
        e3 = gmp_mul(3, e)
        negative_self = Point.new(p1.curve, p1.x, gmp_neg(p1.y), p1.order)
        i = gmp_div(Point.leftmost_bit(e3), 2)
        result = p1
        while gmp_cmp(i, 1) > 0
          result = Point.double(result)
          result = Point.add(result, p1) if gmp_cmp(gmp_and(e3, i), 0) != 0 and gmp_cmp(gmp_and(e, i), 0) == 0
          result = Point.add(result, negative_self) if gmp_cmp(gmp_and(e3, i), 0) == 0 and gmp_cmp(gmp_and(e, i), 0) != 0
          i = gmp_div(i, 2)
        end
        return result
      end
    end

    def self.leftmost_bit(x)
      if gmp_cmp(x, 0) > 0
        result = gmp_init('1', 10)
        while gmp_cmp(result, x) <= 0
          result = gmp_mul(2, result)
        end
        return gmp_div(result, 2)
      end
    end

    def self.double(p1)
      p = p1.curve.prime
      a = p1.curve.a
      inverse = gmp_invert(gmp_mul(2, p1.y), p)
      three_x2 = gmp_mul(3, gmp_pow(p1.x, 2))
      l = gmp_mod(gmp_mul(gmp_add(three_x2, a), inverse), p)
      x3 = gmp_mod(gmp_sub(gmp_pow(l, 2), gmp_mul(2, p1.x)), p)
      y3 = gmp_mod(gmp_sub(gmp_mul(l, gmp_sub(p1.x, x3)), p1.y), p)
      y3 = gmp_add(p, y3) if (gmp_cmp(0, y3) > 0)
      return Point.new(p1.curve, x3, y3)
    end

  end

  class Addrgen
    def self.hex_to_bin(s)
      [s].pack('H*')
    end

    def self.sha256_raw(data)
      Digest::SHA256.digest(data)
    end

    def self.sha256(data)
      Digest::SHA256.hexdigest(data)
    end

    def self.ripemd160(data)
      Digest::RMD160.hexdigest(data)
    end

    def self.addr_from_mpk(mpk, idx)
      _p  = gmp_init('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F', 16)
      _r  = gmp_init('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141', 16)
      _b  = gmp_init('0000000000000000000000000000000000000000000000000000000000000007', 16)
      _Gx = gmp_init('79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798', 16)
      _Gy = gmp_init('483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8', 16)
      curve = Curve.new(_p, 0, _b)
      gen = Point.new(curve, _Gx, _Gy, _r)

      # prepare the input values
      x = gmp_init(mpk[0, 64], 16)
      y = gmp_init(mpk[64, 64], 16)
      z = gmp_init(sha256(sha256_raw(idx.to_s + ':0:' + hex_to_bin(mpk))), 16)

      # generate the new public key based off master and sequence points
      pt = Point.add(Point.new(curve, x, y), Point.mul(z, gen))
      keystr = hex_to_bin('04' + gmp_strval(pt.x, 16).rjust(64, '0') + gmp_strval(pt.y, 16).rjust(64, '0'))
      vh160 =  '00' + ripemd160(sha256_raw(keystr))
      addr = vh160 + sha256(sha256_raw(hex_to_bin(vh160)))[0, 8]

      num = gmp_strval(gmp_init(addr, 16), 58)
      num = num.tr('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuv', '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz')

      pad = ''
      n = 0
      while addr[n] == '0' and addr[n+1] == '0'
        pad += '1'
        n += 2
      end

      GMP::collect_clear
      pad + num
    end
  end
end
