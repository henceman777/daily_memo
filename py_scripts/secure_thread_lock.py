#!/usr/bin/env python

import time
import threading

def t1():
	lock.acquire()
	for x in range(5):
		print("t1:"+str(x))
		time.sleep(0.1)
	lock.release()

def t2():
	lock.acquire()
	for x in range(5):
		print("t2:"+str(x))
		time.sleep(0.1)
	lock.release()
		
lock = threading.Lock()

t1 = threading.Thread(target=t1)
t2 = threading.Thread(target=t2)

t1.start()
t2.start()


