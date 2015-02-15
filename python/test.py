#!/usr/bin/python

import unittest
from addrgen import addr_from_mpk

class AddrgenTest(unittest.TestCase):

	def setUp(self):
		self.mpk = '675b7041a347223984750fe3ab229df0c9f960e7ec98226b7182a2cb1990e39901feecf5a670f1d788ab29f626e20de424f049d216fc6f4c6ec42506763fa28e'


	# regular addresses

	def test_address_0(self):
		addr = addr_from_mpk(self.mpk, 0)
		self.assertEqual(addr, '13EfJ1hQBGMBbEwvPa3MLeH6buBhiMSfCC')

	def test_address_6(self):
		addr = addr_from_mpk(self.mpk, 6)
		self.assertEqual(addr, '1jmA5ySdFz7cDwWb15rWQe63ZUo8spiBa')

	def test_address_9(self):
		addr = addr_from_mpk(self.mpk, 9)
		self.assertEqual(addr, '1J7yTE8Cm9fMV9nqCjnM6kTTzTkksVic98')

	def test_address_100(self):
		addr = addr_from_mpk(self.mpk, 100)
		self.assertEqual(addr, '1LNUmaHWMybREGszq8wiDTULJR3tvsjx7')

	def test_address_65537(self):
		addr = addr_from_mpk(self.mpk, 65537)
		self.assertEqual(addr, '1JnjQQ5LcMDYDLNd31bEU2L5wZ9fipvEQ6')

	def test_address_4294967296(self):
		addr = addr_from_mpk(self.mpk, 4294967296)
		self.assertEqual(addr, '1KJwuVF7hm7EoT1AYJas2WM3yodCzsEhAQ')


	# change addresses

	def test_change_address_0(self):
		addr = addr_from_mpk(self.mpk, 0, True)
		self.assertEqual(addr, '14LQiAFjVBePtffagNtsDW9TFY21Mpngka')

	def test_change_address_1(self):
		addr = addr_from_mpk(self.mpk, 1, True)
		self.assertEqual(addr, '15GTr4N3vUDGmSrFX2XXGvwhnWqG1LzCTi')

	def test_change_address_2(self):
		addr = addr_from_mpk(self.mpk, 2, True)
		self.assertEqual(addr, '1Q4hqqSSTTpbcr4MoigFDFhDLMMP13NorG')


	# testnet addresses

	def test_testnet_address_0(self):
		addr = addr_from_mpk(self.mpk, 0, False, 'testnet')
		self.assertEqual(addr, 'mhkcb4nNzHnSNMRY791jAZVRTtnQa3QKT3')

	def test_testnet_address_1(self):
		addr = addr_from_mpk(self.mpk, 1, False, 'testnet')
		self.assertEqual(addr, 'mq5TPKMkgWAFXQBUcF6SsL1Hc5jdBFy2q7')

	def test_testnet_address_2(self):
		addr = addr_from_mpk(self.mpk, 2, False, 'testnet')
		self.assertEqual(addr, 'n1dNwmWqRaQwKepFgxQQSEd2yoka4B85oo')


if __name__ == '__main__':
	unittest.main()
