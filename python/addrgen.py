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

from hashlib import sha256
import hashlib
import gmpy
from binascii import unhexlify

class Curve:

	def __init__(self, prime, a, b):
		self.prime = prime
		self.a = a
		self.b = b

	def contains(self, x, y):
		return 0 == (y**2 - (x ** 3 + self.a * x + self.b)) % self.prime

	@staticmethod
	def cmp(cp1, cp2):
		if cp1.a == cp2.a and cp1.b == cp2.b and cp1.prime == cp2.prime:
			return 0
		else:
			return 1

class Point:

	infinity = 'infinity'

	def __init__(self, curve, x, y, order = None):
		self.curve = curve
		self.x = x
		self.y = y
		self.order = order

		if self.curve and isinstance(self.curve, Curve):
			if not self.curve.contains(self.x, self.y):
				raise Exception('Curve does not contain point')

			if self.order != None:
				if Point.cmp(Point.mul(order, self), Point.infinity) != 0:
					raise Exception('Self*Order must equal infinity')

	@staticmethod
	def cmp(p1, p2):
		if not isinstance(p1, Point):
			if isinstance(p2, Point):
				return 1
			if not isinstance(p2, Point):
				return 0
		if not isinstance(p2, Point):
			if isinstance(p1, Point):
				return 1
			if not isinstance(p1, Point):
				return 0
		if p1.x == p2.x and p1.y == p2.y and Curve.cmp(p1.curve, p2.curve):
			return 0
		else:
			return 1

	@staticmethod
	def add(p1, p2):
		if Point.cmp(p2, Point.infinity) == 0 and instanceof(p1, Point):
			return p1
		if Point.cmp(p1, Point.infinity) == 0 and instanceof(p2, Point):
			return p2
		if Point.cmp(p1, Point.infinity) == 0 and Point.cmp(p2, Point.infinity) == 0:
			return Point.infinity

		if Curve.cmp(p1.curve, p2.curve) == 0:
			if p1.x == p2.x:
				if (p1.y + p2.y) % p1.curve.prime == 0:
					return Point.infinity
				else:
					return Point.double(p1)

			p = p1.curve.prime
			l = (p2.y - p1.y) * gmpy.invert((p2.x - p1.x), p)
			x3 = (l ** 2 - p1.x - p2.x) % p
			y3 = (l * (p1.x - x3) - p1.y) % p
			return Point(p1.curve, x3, y3)
		else:
			raise Exception('Elliptic curves do not match')

	@staticmethod
	def mul(x2, p1):
		e = x2
		if Point.cmp(p1, Point.infinity) == 0:
			return Point.infinity
		if p1.order != None:
			e = e % p1.order
		if e == 0:
			return Point.infinity
		if e > 0:
			e3 = 3 * e
			negative_self = Point(p1.curve, p1.x, -p1.y, p1.order)
			i = Point.leftmost_bit(e3) / 2
			result = p1
			while i > 1:
				result = Point.double(result)
				if (e3 & i) != 0 and (e & i) == 0:
					result = Point.add(result, p1)
				if (e3 & i) == 0 and (e & i) != 0:
					result = Point.add(result, negative_self)
				i = i / 2
			return result

	@staticmethod
	def leftmost_bit(x):
		if x > 0:
			result = gmpy.mpz(1)
			while result <= x:
				result = 2 * result
			return result / 2

	@staticmethod
	def double(p1):
		p = p1.curve.prime
		a = p1.curve.a
		inverse = gmpy.invert((2 * p1.y), p)
		three_x2 = 3 * (p1.x ** 2)
		l = ((three_x2 + a) * inverse) % p
		x3 = (l ** 2 - 2 * p1.x) % p
		y3 = (l * (p1.x - x3) - p1.y) % p
		if 0 > y3:
			y3 = p + y3
		return Point(p1.curve, x3, y3)

def ripemd160(s):
	h = hashlib.new('ripemd160')
	h.update(s)
	return h.hexdigest()

def addr_from_mpk(mpk, idx, change = False):
	# create the ecc curve
	_p  = gmpy.mpz('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F', 16)
	_r  = gmpy.mpz('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141', 16)
	_b  = gmpy.mpz('0000000000000000000000000000000000000000000000000000000000000007', 16)
	_Gx = gmpy.mpz('79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798', 16)
	_Gy = gmpy.mpz('483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8', 16)
	curve = Curve(_p, 0, _b)
	gen = Point(curve, _Gx, _Gy, _r)

	# prepare the input values
	x = gmpy.mpz(mpk[ 0: 64], 16)
	y = gmpy.mpz(mpk[64:128], 16)
	branch = change and 1 or 0
	z = gmpy.mpz(sha256(sha256(str(idx) + ':' + str(branch) + ':' + unhexlify(mpk)).digest()).hexdigest(), 16)

	# generate the new public key based off master and sequence points
	pt = Point.add(Point(curve, x, y), Point.mul(z, gen))

	keystr = unhexlify('04' + hex(pt.x)[2:].zfill(64) + hex(pt.y)[2:].zfill(64))

	vh160 = '00' + ripemd160(sha256(keystr).digest())
	addr = vh160 + sha256(sha256(unhexlify(vh160)).digest()).hexdigest()[0:8]

	__b58chars = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
	__b58base = len(__b58chars)

	num = gmpy.mpz(addr, 16)
	enc = ''
	while num >= __b58base:
		num, mod = gmpy.fdivmod(num, __b58base)
		enc = __b58chars[int(mod)] + enc
	if num > 0:
		enc = __b58chars[num] + enc

	pad = ''
	n = 0
	while addr[n] == '0' and addr[n+1] == '0':
		pad += '1'
		n += 2

	return pad + enc
