# python note

---

`不转义`

```python
print(r'\\\n\\')
print(''' ''')
```

`动态语言, 静态语言:定义变量时指定类型`

>* 10//3
>* 9/3
>* 10%3

'ABC', b'ABC' 每个字符只占一个字节
> 'ABC'.encode('ascii')
> '中文'.encode('utf-8')

中文编码范围超过了ASCII 编码范围
> '中文'.encode('ascii')

bytes 无法显示的ascii 字符的字节 用\x## 表示
b'ABC'.decode('ascii')
b'\xe4\xb8\xad\xe6\x96\x87'.decode('utf-8')
bytes中包含无法解码的字节会报错 只有一小部分的无效字节 可以传入errors = 'ignore'

> len(str/bytes)

%s 打印会把其他类型转换为str

Hello, 小明, 17.1%
> 'Hello, {0}, {1:.1f}%'.format('小明', 17.125)

---

list

```python
list[]
list[0] ... list[index] ... list[-1]
len(list) list.append(str) list.insert(1,str)
str=list.pop() list.pop(index) list[2]:str
list=[str,123,true]
# 二维list
list[2][3]
```

tuple

```python
# 初始化后不可变
tuple=(str1,str2,str3)
tuple=(1) => tuple = 1
tuple=(1,) => tuple=(1,)
#str与数字比较会报错 int(str)
list(range(5)) => [0,1,2,3,4]
for iter in llist:
    ...
```

dist

```python
dist={'a':1,'b':2,'c':3}
dist['d'] = 4
'd' in dist #=> true
dist.get('d') #=> 4,None
dist.get('e,'-1) #=> -1
dist.pop('a') # => 1
```

set

```python
s=set([1,1,2,2,2,3,]) #=> {1,2,3}
s.add(4)
s.remove(4)
s1=set([1,2,3])
s2=set([2,3,4])
s1&s2 #=> {2,3}
s1|s2 #=> {1,2,3,4}
```

```python
a=['c','b','a']
a.sort()
a=['a','b','c']
a='abc'
a.replace('a','A') #=>'Abc'
a=>'abc'
```

函数

> abs() max() int() float() str() bool()

```python
def nop():
    pass # 占位符

def enroll(name, gender, age=6, city='BeiJing'):
    pass

enroll('Adam', 'M', city='TianJin')

def addnode(list=None):
    pass

def addnode(list=[]):
    pass

# 可变参数
def calc(*numbers):
    pass
calc(1,2)
calc(1)
nums=[1,2,3]
calc(*nums)

# 关键字参数
def person(name, age, **kw):
    pass
person('Adam', 45, gender='M', job='Engineer')
extra={'city':'BeiJing', 'Job':'Engineer'}
person('Adam', 45, **extra)

# 命名关键字参数
def person(name, age, *, city='BeiJing', job):
    pass
def person(name, age, *args, city, job):
    pass

def f1(a, b, c=0, *args, **kw):
    pass
f1(1,2)
f1(1,2,c=3)
f1(1,2,3,'a','b')
f1(1,2,3,'a','b',x=99)
args=(1,2,3,4)
kw={'d':99,'x':'#'}
f1(*args, **kw)

def f2(a, b, c=0, *, d, **kw):
    pass
args=(1,2,3)
kw={'d':88,'x':'#'}
f2(*args, **kw)

# 递归 栈溢出
# 尾递归 尾递归优化
# 栈大小 限制
```

函数高级特性:切片 迭代 列表生成器 生成器 迭代器

```python
list[:3]
list[1:3]
list[-2:]
list[-2:-1]
list[:10:2] # 前10个数 每2个 取 1个
list[::-1] # 倒序
list[::5]  # 所有数 每5个 取1个
list[:] # 复制一个list
```