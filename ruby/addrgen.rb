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
require 'gmp'

class Curve

	attr_reader :prime, :a, :b

	def initialize(prime, a, b)
		@prime = prime
		@a = a
		@b = b
	end

	def contains(x, y)
		GMP::Z.new(0) == (y**2 - (x ** 3 + @a * x + @b)).fmod(@prime)
	end

	def self.cmp(cp1, cp2)
		if cp1.a == cp2.a and cp1.b == cp2.b and cp1.prime == cp2.prime
			return 0
		else
			return 1
		end
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
			raise Exception, 'Curve does not contain point' if !@curve.contains(@x, @y)
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
		if p1.x == p2.x and p1.y == p2.y and Curve.cmp(p1.curve, p2.curve)
			return 0
		else
			return 1
		end
	end

	def self.add(p1, p2)

		return p1 if Point.cmp(p2, :infinity) == 0 and p1.instance_of?(Point)
		return p2 if Point.cmp(p1, :infinity) == 0 and p2.instance_of?(Point)
		return :infinity if Point.cmp(p1, :infinity) == 0 and Point.cmp(p2, :infinity) == 0

		if Curve.cmp(p1.curve, p2.curve) == 0
			if p1.x == p2.x
				if (p1.y + p2.y).fmod(p1.curve.prime) == 0
					return :infinity
				else
					return Point.double(p1)
				end
			end
			p = p1.curve.prime
			l = (p2.y - p1.y) * (p2.x - p1.x).invert(p)
			x3 = (l ** 2 - p1.x - p2.x).fmod(p)
			y3 = (l * (p1.x - x3) - p1.y).fmod(p)
			p3 = Point.new(p1.curve, x3, y3)
			return p3
		else
			raise Exception, 'Elliptic curves do not match'
		end
	end

	def self.mul(x2, p1)
		e = x2
		return :infinity if Point.cmp(p1, :infinity) == 0
		e = e.fmod(p1.order) if p1.order != nil
		return :infinity if e == GMP::Z.new(0)
		if e > GMP::Z.new(0)
			e3 = 3 * e
			negative_self = Point.new(p1.curve, p1.x, -p1.y, p1.order)
			i = Point.leftmost_bit(e3).tdiv(2)
			result = p1
			while i > GMP::Z.new(1)
				result = Point.double(result)
				result = Point.add(result, p1) if (e3 & i) != GMP::Z.new(0) and (e & i) == GMP::Z.new(0)
				result = Point.add(result, negative_self) if (e3 & i) == GMP::Z.new(0) and (e & i) != GMP::Z.new(0)
				i = i.tdiv(2)
			end
			return result
		end
	end

	def self.leftmost_bit(x)
		if x > GMP::Z.new(0)
			result = GMP::Z.new(1)
			while result <= x
				result *= 2
			end
			return result.tdiv(2)
		end
	end

	def self.double(p1)
		p = p1.curve.prime
		a = p1.curve.a
		inverse = (2 * p1.y).invert(p)
		three_x2 = 3 * (p1.x ** 2)
		l = ((three_x2 + a) * inverse).fmod(p)
		x3 = (l ** 2 - 2 * p1.x).fmod(p)
		y3 = (l * (p1.x - x3) - p1.y).fmod(p)
		y3 = p + y3 if 0 > y3
		p3 = Point.new(p1.curve, x3, y3)
		p3
	end

end

def hex_to_bin(s)
	[s].pack('H*')
end

def sha256_raw(data)
	Digest::SHA256.digest(data)
end

def sha256(data)
	Digest::SHA256.hexdigest(data)
end

def ripemd160(data)
	Digest::RMD160.hexdigest(data)
end

def addr_from_mpk(mpk, idx)

	_p  = GMP::Z.new('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F', 16)
	_r  = GMP::Z.new('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141', 16)
	_b  = GMP::Z.new('0000000000000000000000000000000000000000000000000000000000000007', 16)
	_Gx = GMP::Z.new('79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798', 16)
	_Gy = GMP::Z.new('483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8', 16)
	curve = Curve.new(_p, 0, _b)
	gen = Point.new(curve, _Gx, _Gy, _r)

	# prepare the input values
	x = GMP::Z.new(mpk[0, 64], 16)
	y = GMP::Z.new(mpk[64, 64], 16)
	z = GMP::Z.new(sha256(sha256_raw(idx.to_s + ':0:' + hex_to_bin(mpk))), 16)

	# generate the new public key based off master and sequence points
	pt = Point.add(Point.new(curve, x, y), Point.mul(z, gen))
	keystr = hex_to_bin('04' + pt.x.to_s(16).rjust(64, '0') + pt.y.to_s(16).rjust(64, '0'))
	vh160 =  '00' + ripemd160(sha256_raw(keystr))
	addr = vh160 + sha256(sha256_raw(hex_to_bin(vh160)))[0, 8]

	num = GMP::Z.new(addr, 16).to_s(58)
	num = num.tr('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuv', '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz')

	pad = ''
	n = 0
	while addr[n] == '0' and addr[n+1] == '0'
		pad += '1'
		n += 2
	end

	pad + num
end
