# -*- coding: utf-8 -*-

s1 = '中文'
s2 = u'你好'
#print s1 + unicode(s2, 'utf-8')   # 中文你好
#print s1 + s2.decode('utf-8')     # 中文你好
#print s1.encode('utf-8') + s2     # 中文你好
 
print type(s1)                    # <type 'str'>
print type(s2)                    # <type 'unicode'>
print type(s1.decode('utf-8'))    # <type 'unicode'>
print type(s2.encode('utf-8'))    # <type 'str'>
print s1 + s2.encode('utf-8')
print s1.decode('utf-8') + s2
