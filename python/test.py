#!/usr/bin/python

from addrgen import addr_from_mpk

mpk = '675b7041a347223984750fe3ab229df0c9f960e7ec98226b7182a2cb1990e39901feecf5a670f1d788ab29f626e20de424f049d216fc6f4c6ec42506763fa28e'

for i in range(10):
	print addr_from_mpk(mpk, i)
for i in [100, 65537, 4294967296]:
	print addr_from_mpk(mpk, i)
for i in range(3):
	print addr_from_mpk(mpk, i, True)

# should print:
#
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
# 1LNUmaHWMybREGszq8wiDTULJR3tvsjx7
# 1JnjQQ5LcMDYDLNd31bEU2L5wZ9fipvEQ6
# 1KJwuVF7hm7EoT1AYJas2WM3yodCzsEhAQ
# 14LQiAFjVBePtffagNtsDW9TFY21Mpngka
# 15GTr4N3vUDGmSrFX2XXGvwhnWqG1LzCTi
# 1Q4hqqSSTTpbcr4MoigFDFhDLMMP13NorG
