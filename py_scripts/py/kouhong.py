#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2017/8/16 16:31
# @Author  : 奶权
# @File    : ysl.py
import requests,re
from lxml import etree
from multiprocessing import Pool
def out2File(name,userId,addr,addr_zip,phone):
    f = open('opt.csv','a')
    f.write('\n{},{},{},{},{}'.format(name.encode('gbk'),userId.encode('gbk'),addr.encode('gbk'),addr_zip.encode('gbk'),phone.encode('gbk')))
def main(url):
    try:
        r = requests.get(url,timeout=3)
        userId = re.search(r'olapicCheckout\.setAttribute\("olapicIdentifier", encodeURIComponent\("(.*?)"\)',r.text).group(1)
        htmlOBJ = etree.HTML(r.text)
        name = htmlOBJ.xpath('//div[@class="shipping_address"]/div[1]/span/text()')[0]
        addr = htmlOBJ.xpath('//div[@class="shipping_address"]/div[2]/span[1]/text()')[0] + htmlOBJ.xpath('//div[@class="shipping_address"]/div[2]/span[2]/text()')[0] + htmlOBJ.xpath('//div[@class="shipping_address"]/div[2]/span[3]/text()')[0] + htmlOBJ.xpath('//div[@class="shipping_address"]/div[3]/span/text()')[0]
        addr_zip = htmlOBJ.xpath('//div[@class="shipping_address"]/div[4]/span/span/span/text()')[0]
        phone = htmlOBJ.xpath('//div[@class="shipping_address"]/div[5]/span/span/span/text()')[0]
        print name,userId,addr,addr_zip,phone
        out2File(name,userId,addr,addr_zip,phone)
    except:
        return
if __name__ == '__main__':
    orderNum = 280000
    orderUrls = ['https://www.yslbeautycn.com/.../zh_CN/Wechat-ShowConfirmation?orderNo=YSL00' + str(orderNum) for orderNum in range(280000,380000)]
    pool = Pool(100)
    pool.map(main,orderUrls)
    pool.close()
    pool.join()
