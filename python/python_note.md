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

> list

    ```python
    list[]
    list[0] ... list[index] ... list[-1]
    len(list) list.append(str) list.insert(1,str)
    str=list.pop() list.pop(index) list[2]:str
    list=[str,123,true]
    # 二维list
    list[2][3]
    ```

> tuple

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

> dist

    ```python
    dist={'a':1,'b':2,'c':3}
    dist['d'] = 4
    'd' in dist #=> true
    dist.get('d') #=> 4,None
    dist.get('e,'-1) #=> -1
    dist.pop('a') # => 1
    ```

> set

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

## 函数

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

## 函数高级特性:切片 迭代 列表生成器 生成器 迭代器

> 切片

    ```python
    list[:3]
    list[1:3]
    list[-2:]
    list[-2:-1]
    list[:10:2] # 前10个数 每2个 取 1个
    list[::-1] # 倒序
    list[::5]  # 所有数 每5个 取1个
    list[:] # 复制一个list
    (0,1,2,3,4,5)[:3] # => (0,1,2)
    'ABCDEFG'[:3] # => 'ABC'
    for key in dict:
        pass
    for value in d.values():
        pass
    for k,v in dict.items():
        pass
    for ch in 'ABC':
        pass
    from collections import Iterable
    instance('abc',Iterable) # => true/false
    for i,value in enumerate(['A','B','C']):
        pass
    for x,y in [(1,1),(2,4),(3,9)]
        pass

    ```

> 列表生成器

    ```python
    [x*x for x in range(1,11)]
    [x*x for x in range(1,11) if x%2 == 0]
    [m+n for min'ABC' for n in 'XYZ']
    import os
    [d for d in os.listdir('.')]
    [k+'='+v for k,v in dict.items()]
    [s.lower() for s in List] # => List是一个字符串list
    ```

> 生成器 generator

    ```python
    g=(x*x for x in range(10))
    next(g)
    for n in g:
        pass
    def fib(max):
        n,a,b,=0,0,1
        while n < max:
            yield b
            a,b = b,a+b
            n=n+1
        return 'done'
    fpr n in fib(6):
        print(n)
    g=fib(6)
    while True:
        try:
            x=next(g)
            print('g:',x)
        except StopIteration as e:
            print('Generation return value:',e.value)
            break
    ```

> 迭代器

可迭代对象 Iterable对象
Iterator对象 list,dict,str 不是
iter(list) iter(str) iter(dict)

---

## 函数式编程

list
编程范式
纯函数式编程
函数式编程:

> 高阶函数:变量指向函数,函数名也是变量 传入函数=>高阶函数

    ```python
    def add(-5.6,abs)
        return abs(-5)+abs(6)
    ```
* map/reduce:
    ```python
    list(map)(str,[1,2,3])
    from functools import reduce
    DIGITS={'0':0,'1':1,...,'9':9}
    def str2Int(s):
        def fn(x,y):
            return x*10+y
        def char2num(s):
            return DIGITS[s]
        return reduce(fn,map(char2num,s))
    def str2Int(s):
        return reduce(lambda x,y:x*10+y, map(char2num,s))
    ```

* filter:
    ```python
    def not_empty(s):
        return s and s.strip()
    list(filter(not_empty,['A','','B',None,'C','_'])) #=> ['A','B','C']
    ```

> 返回函数:

闭包
匿名函数: lambda x: x*x
装饰器:
函数对象: __name__

    ```python
    # log是装饰器 decorator
    def log(func):
        def wrapper(*args,**kw):
            print('call %s():' % func.__name__)
            return func(*args, **kw)
        return wrapper
    import functools
    @functools.wraps(func)
    @log # => now => log(now)
    def now():
        print('...')
    # 带参decorator
    def log(text):
        def decorator(func):
            @functools.wraps(func)
            def wrapper(*args,**kw):
                print('%s %s c >= ' % (text,func.__name__))
                return func(*args, **kw)
            return wrapper
        return decorator
    ```

> 偏函数

```python
int('12345',base=8)
int('12345',16)
import functools
int2 = functools.partial(int,base=2)
```

## 模块

```python
__name__, __main__
import sys
sys.path
sys.path.append('...')
```

> OOP

```python
class Student(object):
    def _init_(self,name,score):
        self.name = name
        self.score = score
        # 私有
        self._name = '' # _Student_name
    def print_score(self):
        print('%s:%s' % (self.name, self.score))

# 新增变量
bart._name='new name'
type(fn)
types.FunctionType
types.BuiltFunctionType
types.LambdaType
types.GeneratorType
int
str
isinstance('a',str)
isinstance(123,int)
isinstance(b'a',bytes)
isinstance([1,2,3], (list,tuple))
isinstance((1,2,3), (list,tuple))
dir()
class MyDog(object):
    def __len__(self):
        return 100
dog=MyDog()
len(dog)
hasattr(obj,'x')
obj.x
setattr(obj,'y',19)
getattr(obj,'y')
# 类属性 类实例属性
```

## 高级 OOP

```python
class student(object):
    # 限制实例的属性及方法
    __slot__ = ('name', 'age')

    # birth  可读写
    @property
    def birth(self):
        return self._birth
    @birth.setter
    def birth(self,value):
        self._birth = value

    # age 不可写
    @property
    def age(self):
        return 2015-self.birth
```

> 多重继承

```python
class MyTCPServer(TCPServer,ForkingMixIn):
    pass
class MyUDPServer(UDPServer,ThreadingMixIn):
    pass
class MyTCPServer(TCPServer,CoroutineMixIn):
    pass
```

> 定制

```python
def __str__(self):
    return 'Student %s' % self.name
__repo__ = __str__
def __iter__(self):
    return self
def __next__(self):
    self.a, self.b = self.b, self.a + self.b
    if self.a > 100000:
        raise StopIteration()
    return self.a
def __init__(self):
    self.a,self.b = 0,1
def __getitem__(self,n):
    a,b = 1,1
    for x in range(n):
        a,b =b, a+b
    return a
def __setitem__(self, ...)
    pass
def __delitem__(self, ...)
    pass
def __getattr__(self,attr):
    if attr == 'score':
        return 99
    elif attr == 'age':
        return lambda:25
    raise AttributeError('...')
# callable(Student())
def __call__(self):
    pass

from enum import Enum
Month=Enum('Month',('Jan','Feb',...,'Dec'))
for name,member in Month._member_.items():
    print(name,'=>',member,',',member.value)
from enum import Enum,unique
@unique
class Weekday(Enum):
    Sun = 0
    Mon = 1
    .
    .
    .
    Sat = 6
Weekday(1) #=>Weekday.Mon
```

## 错误 调试测试
## IO编程
## 进程 线程
## 正则表达式
## 常用内建模块
## 常用第三方模块
## 网络编程
## email
## database
## web
## 异步IO