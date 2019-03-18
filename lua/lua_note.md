# lua 5.0 Note

## 1. Begin

### 1.1 chunk

Chunk 是一系列语句，Lua 执行的每一**块**语句，比如**一个文件**或者**交互模式**下的*每一行*都是一个 Chunk。
每个语句结尾的分号（;）是可选的，但如果同一行有多个语句最好用；分开(but valid)
Chunk可以很大，在 Lua 中几个 MByte 的 Chunk 是很常见的

交互模式下 键入文件结束符可以退出交互模式（Ctrl-D in Unix, Ctrl-Z in DOS/Windows），或者调用 OS 库的 os.exit()函数也可以退出

> prompt> lua -la -lb

命令首先在一个 Chunk 内先运行 a 然后运行 b。（注意：-l 选项会调用 require，将会在指定的目录下搜索文件，如果环境变量没有设好，上面的命令可能不能正确运行。)

> lua -i -la -lb

将在一个 Chunk 内先运行 a 然后运行 b，最后直接进入交互模式

最好不要使用下划线加大写字母的标示符，因为 Lua 的保留字也是这样的。

### 1.4 lua ，命令

- -e：直接将命令传入 Lua

    > prompt> lua -e "print(math.sin(12))" --> -0.53657291800043

- -l：加载一个文件.
- -i：进入交互模式.
    _PROMPT 内置变量作为交互模式的提示符

    > prompt> lua -i -e "_PROMPT=' lua> '"
    > lua>

Lua 的运行过程，在运行参数之前，Lua 会查找环境变量 `LUA_INIT` 的值，

- 如果变量存在并且`值`为`@filename`，Lua 将**加载**指定文件。
- 如果变量存在但`不是以@开头`，Lua假定 filename 为 Lua 代码文件并且**运行**他。

全局变量 `arg` 存放 Lua 的命令行参数。在运行以前，Lua 使用所有参数构造 arg 表。

- 脚本名索引为 0，
- 脚本的参数从 1 开始增加。
- 脚本前面的参数从-1 开始减少

> prompt> lua -e "sin=math.sin" script a b
arg 表如下：

```lua
arg[-3] = "lua"
arg[-2] = "-e"
arg[-1] = "sin=math.sin"
arg[0] = "script"
arg[1] = "a"
arg[2] = "b"
```

## 2. 类型

Lua 是动态类型语言，变量不要类型定义。
Lua 中有8 个基本类型分别为：`nil、boolean、number、string、userdata、function、thread 和 table`。
函数 `type` 可以测试给定变量或者值的类型。

在控制结构的条件中除了 `false` 和 `nil` 为假，其他值都为真。
所以 Lua 认为 `0` 和`空串`都是真。

`number`表示实数，Lua 中没有整数。

note: ***一般有个错误的看法 CPU 运算浮点数比整数慢。事实不是如此，用实数代替整数不会有什么误差（除非数字大于 100,000,000,000,000）。***
Lua的 numbers 可以处理任何长整数不用担心误差。

note: 你也可以在编译 `Lua` 的时候使用长整型或者`单精度浮点型`代替 numbers，在一些平台硬件`不支持浮点数`的情况下这个特性是非常有用的，具体的情况请参考 Lua 发布版所附的详细说明。

### 2.4 string

字符的序列, lua 是 8 位字节，所以字符串可以包含任何数值字符，包括嵌入的 0。
这意味着你可以存储任意的二进制数据在一个字符串里。

```lua
a = "one string"
b = string.gsub(a, "one", "another") -- change string parts
print(a) --> one string
print(b) --> another string
```

Lua 可以高效的处理长字符串，`1M` 的 string 在 Lua 中是很常见的。可以使用`单引号`或者`双引号`表示字符串

还可以在字符串中使用\ddd（ddd 为三位十进制数字）方式表示字母。
> "alo\n123\""
> '\97lo\10\04923"'
> 是相同的

还可以使用`[[...]]`表示字符串。
这种形式的字符串可以包含`多行`也，可以嵌套且`不会解释转义序列`，如果`第一个字符`是`换行符`会被自动**忽略**掉。

种形式的字符串用来包含一段代码是非常方便的。

```lua
page = [[
<HTML>
<HEAD>
<TITLE>An HTML Page</TITLE>
</HEAD>
<BODY>
Lua
[[a text between double brackets]]
</BODY>
</HTML>
]]
io.write(page)
```

运行时，Lua 会自动在 string 和 numbers 之间自动进行类型转换，当一个字符串使
用算术操作符时，string 就会被转成数字。

```lua
print("10" + 1) --> 11
print("10 + 1") --> 10 + 1
print("-5.3e - 10" * "2") --> -1.06e-09 
print("hello" + 1) -- ERROR (cannot convert "hello")
```

`..`在 Lua 中是字符串连接符，当在一个`数字`后面写`..`时，必须`加上空格`以防止被解释错

显式将 string 转成数字可以使用函数 `tonumber()`，如果 string 不是正确的数字该函数将返回 `nil`。

可以调用`tostring()`将数字转成字符串，这种转换一直有效

### 2.5 Function

函数是`第一类值`（和其他变量相同），意味着

- 函数可以存储在变量中，
- 可以作为函数的参数，
- 也可以作为函数的返回值。

### 2.6 Userdata and Threads

- userdata 可以将 C 数据存放在 Lua 变量中，
- userdata 在 Lua 中预定义操作`赋值`和`相等比较`

## 3. 表达式

### 3.2 关系运算符

> < > <= >= == ~=

- Lua 通过`引用`比较`tables、userdata、functions`。也就是说当且仅当两者表示同一个对象时相等。
- Lua 比较数字按传统的数字大小进行，
- 比较字符串按字母的顺序进行，但是字母顺序依赖于本地环境

### 3.3 逻辑运算符

> and or not

一个很实用的技巧：如果 x 为 false 或者 nil 则给 x 赋初始值 v
> x = x or v

C 语言中的三元运算符
> (a and b) or c ==> a ? b : c

### 3.5 优先级

从高到低的顺序：

```lua
^
not - (unary)
* /
+ -
..
< > <= >= ~= ==
and
or
```

除了^和..外所有的二元运算符都是`左连接`的。

```lua
a+i < b/2+1 <--> (a+i) < ((b/2)+1)
5+x^2*8 <--> 5+((x^2)*8)
a < y and y <= z <--> (a < y) and (y <= z)
-x^2 <--> -(x^2)
x^y^z <--> x^(y^z)
```

### 3.6 表的构造

最简单的构造函数是`{}`，用来创建一个`空表`。

使用 table 构造一个 list：

```lua
list = nil
for line in io.lines() do
 list = {next=list, value=line}
end
```

嵌套构造函数

```lua
polyline = {color="blue", thickness=2, npoints=4,
 {x=0, y=0},
 {x=-10, y=0},
 {x=-10, y=1},
 {x=0, y=1}
}
```

- 不能使用负索引初始化一个表中元素，
- 字符串索引也不能被恰当的表示。

```lua
opnames = {
    ["+"] = "add",
    ["-"] = "sub",
    ["*"] = "mul",
    ["/"] = "div"
}

i = 20; s = "-"
a = {[i+0] = s, [i+1] = s..s, [i+2] = s..s..s,}

print(opnames[s]) --> sub
print(a[22]) --> ---
```

- 注意：不推荐数组下标`从 0 开始`，否则`很多标准库不能使用`。
- 在构造函数的`最后的`","是可选的，可以方便以后的扩展。
- 在构造函数中域分隔符逗号（","）可以用分号（";"）替代，通常我们使用分号用来分割不同类型的表元素。

如果真的想要数组下标从 0 开始：

> days = {[0]="Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
> {x=10, y=45; "one", "two", "three"}

### 4. 基本语法

> a, b = 10, 2*x <--> a=10; b=2*x

遇到赋值语句 Lua 会先计算右边所有的值然后再执行赋值操作，所以我们可以这样
进行交换变量的值：

```lua
x, y = y, x -- swap 'x' for 'y'
a[i], a[j] = a[j], a[i] -- swap 'a[i]' for 'a[i]'
```

当变量个数和值的个数不一致时，Lua 会一直以变量个数为基础采取以下策略：

- a. 变量个数>值的个数 按变量个数补足 nil
- b. 变量个数<值的个数 多余的值会被忽略

```lua
a, b, c = 0, 1
print(a,b,c) --> 0 1 nil
a, b = a+1, b+1, b+2 -- value of b+2 is ignored
print(a,b) --> 1 2
a, b, c = 0
print(a,b,c) --> 0 nil nil
```

### 4.2 局部变量 代码块 block

使用 `local` 创建一个局部变量，与全局变量不同，局部变量只在被声明的那个代码块内有效。代码块：指一个`控制结构`内，一个`函数体`，或者一个 `chunk`（变量被声明的那个文件或者文本串）

应该尽可能的使用局部变量，有两个好处：

  1. 避免命名冲突
  2. 访问局部变量的速度比全局变量更快.

> do ... end

```lua
if conditions then
    statements
elseif conditions then
    statements
else
    statements
end;

while condition do
    statements
end;

repeat
    statements;
until conditions;

-- 数值 for 循环:
for var=exp1,exp2,exp3 do
    loop-part
end

-- 范型 for 循环：
-- print all values of array 'a'
for i,v in ipairs(a) do print(v) end

for k in pairs(t) do print(k) end
```

### 4.3 break return

有时候为了调试或者其他目的需要在 block 的中间使用 return 或者 break，可以显式的使用 do..end 来实现：

```lua
function foo ()
    return --<< SYNTAX ERROR
    -- 'return' is the last statement in the next block
    do return end -- OK
    ... -- statements not reached
end
```

## 5. 函数

调用函数的时候，如果参数列表为空，必须使用()表明是函数调用。

当函数`只有一个参数`并且这个参数是`字符串`或者`表构造`的时候，()是可选的：

```lua
print "Hello World"     --> print("Hello World")
dofile 'a.lua'          --> dofile ('a.lua')
print [[a multi-line
    message]]

print([[a multi-line
    message]])

f{x=10, y=20}   --> f({x=10, y=20})
type{}          --> type({})

-- 面向对象方式调用函数的语法
o:foo(x) -- > o.foo(o, x)
```

string.find，其返回匹配串`“开始和结束的下标”`（如果不存在匹配串返回 `nil`）。

```lua
s, e = string.find("hello Lua users", "Lua") 
print(s, e) --> 7 9
```

### 5.1 返回多个结果值

- 作为表达式调用函数

  1. 当调用`作为表达式最后一个参数`或者`仅有一个参数`时，根据变量个数函数尽可能多地返回多个值，不足补 nil，超出舍去。
  2. 其他情况下，函数调用`仅返回第一个值`（如果没有返回值为 nil）

    ```lua
    function foo0 () end -- returns no results 
    function foo1 () return 'a' end -- returns 1 result 
    function foo2 () return 'a','b' end -- returns 2 results

    x,y = foo2(), 20 -- x='a', y=20
    x,y = foo0(), 20, 30 -- x='nil', y=20, 30 is discarded
    ```

- 作为函数参数调用

    ```lua
    print(foo2(), 1) --> a 1
    print(foo2() .. "x") --> ax
    ```

- 在表构造函数 调用

    ```lua
    a = {foo0(), foo2(), 4} -- a[1] = nil, a[2] = 'a', a[3] = 4
    ```

- return f()这种类型的返回 f()返回的`所有值`

- 可以使用圆括号强制使调用返回一个值。

    ```lua
    print((foo0())) --> nil
    print((foo1())) --> a
    print((foo2())) --> a
    ```

函数多值返回的特殊函数 unpack，接受一个数组作为输入参数，返回数组的所有元素。
unpack 被用来实现范型调用机制，在 C 语言中可以使用函数指针调用可变的函数，可以声明参数可变的函数，但不能两者同时可变。

在 Lua 中如果你想调用可变参数的可变函数只需要这样

> f(unpack(a))

预定义的 unpack 函数是用 C 语言实现的，我们也可以用 Lua 来完成：

```lua
function unpack(t, i)
    i = i or 1
    if t[i] then
        return t[i], unpack(t, i + 1)
    end
end
```

### 5.2 可变参数

Lua 函数可以接受可变数目的参数，和 C 语言类似在函数参数列表中使用三点`（...）`表示函数有可变的参数。
Lua 将函数的参数放在一个叫 `arg` 的表中，除了参数以外，`arg表`中还有一个`域 n` 表示参数的个数。

```lua
function g (a, b, ...) end
CALL PARAMETERS
g(3) a=3, b=nil, arg={n=0}
g(3, 4) a=3, b=4, arg={n=0}
g(3, 4, 5, 8) a=3, b=4, arg={5, 8; n=2}
```

如果我们只想要 string.find 返回的第二个值：一个典型的方法是使用虚变量（下划线）

> local _, x = string.find(s, p)

### 5.3 命名参数

```lua
function rename (arg)
    return os.rename(arg.old, arg.new)
end

rename{old="temp.lua", new="temp1.lua"}

```

## 6. 再论函数

note: ***Lua 中的函数是带有词法定界（lexical scoping）的第一类值（first-class values）。***