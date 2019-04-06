# lua 5.0 Note

---

> 语言

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

**第一类值(first-class values)**指：***在 Lua 中函数和其他值（数值、字符串）一样，函数可以被存放在变量中，也可以存放在表中，可以作为函数的参数，还可以作为函数的返回值。***

**词法定界(lexical scoping)**指：***被嵌套的函数可以访问他外部函数中的变量。这一特性给 Lua 提供了强大的编程能力。***

Lua 中我们经常这样写：

```lua
function foo (x) return 2*x end
```

这实际上是利用 Lua 提供的“语法上的甜头”（***syntactic sugar***）的结果，下面是原本的函数：

```lua
-- why you try like that? because i dont't like sugar
foo = function (x) return 2*x end
```

```lua
-- 根据学生的成绩从高到低对学生进行排序， 这里的 names, grades 作用域是这个chunk的全局
names = {"Peter", "Paul", "Mary"}
grades = {Mary = 10, Paul = 7, Peter = 8}
table.sort(names, function (n1, n2)
return grades[n1] > grades[n2] -- compare the grades
end)
```

以其他函数作为参数的函数在 Lua 中被称作`高级函数`，高级函数在 Lua 中并没有特权，只是 Lua 把函数当作`第一类函数`处理的一个简单的结果。

```lua
function sortbygrade (names, grades)
    table.sort(names, function (n1, n2)
        return grades[n1] > grades[n2] -- compare the grades
    end)
end
```

包含在 sortbygrade 函数内部的 sort 中的匿名函数可以访问 sortbygrade 的参数grades，
在`匿名函数内部` grades 不是全局变量也不是局部变量，我们称作`外部的局部变量`（external local variable）或者 `upvalue`。

技术上来讲，`闭包`指值而不是指函数，函数仅仅是闭包的一个`原型声明`；
> 闭包的声明周期?

简单的说`闭包` 是 ***一个函数加上它可以正确访问的 upvalues。***

```lua
Lib = {}
Lib.foo = function (x,y) return x + y end
Lib.goo = function (x,y) return x - y end
--------------
Lib = {
    foo = function (x,y) return x + y end,
    goo = function (x,y) return x - y end,
}
--------------
Lib = {}
function Lib.foo (x,y)
    return x + y
end
function Lib.goo (x,y)
    return x - y
end
```

Lua 把 `chunk` 当作`函数`处理，在 chunk 内可以声明`局部函数`（***仅仅在 chunk 内可见***），词法定界保证了包内的`其他函数`**可以调用**此函数。

```lua
-- error usage
local fact = function (n)
    if n == 0 then
        return 1
    else
        return n*fact(n-1) -- buggy
    end
end
```

上面这种方式导致 Lua 编译时遇到 fact(n-1)并*不知道他是局部函数* `fact`，Lua 会去查找是否有这样的*全局函数* `fact`。
为了解决这个问题我们必须在*定义函数以前* 先**声明**:

```lua
local fact
fact = function (n)
    if n == 0 then
        return 1
    else
        return n*fact(n-1)
    end
end
```

note:*但是 Lua 扩展了他的语法使得可以在直接递归函数定义时使用两种方式都可以。*
note:*在定义`非`直接递归局部函数时要**先声明**然后定义才可以*

### 6.3 尾调用(proper tail calls)

```lua
function f(x)
    return g(x)
end
```

*这种情况下当被调用函数 g 结束时程序**不需要返回**到`调用者 f`；*
*所以**尾调用之后**程序不需要在栈中保留关于**调用者的任何信息**。*
*一些编译器比如 **Lua 解释器**利用这种特性在处理尾调用时**不使用额外的栈**，我们称这种语言**支持**`正确的尾调用`。*

note:*由于尾调用不需要使用栈空间，那么尾调用**递归的层次**可以无限制的。例如下面调用不论 n 为何值**不会导致栈溢出**。*

```lua
function foo (n)
    if n > 0 then return foo(n - 1) end
end

-- 非尾调用
return g(x) + 1 -- must do the addition
return x or g(x) -- must adjust to 1 result
return (g(x)) -- must adjust to 1 result
```

可以将尾调用理解成一种 goto，在**状态机的编程**领域尾调用是非常有用的。
状态机的应用要求函数记住每一个状态，改变状态只需要 goto(or call)一个特定的函数。

传统模式的编译器对于尾调用的处理方式就像处理其他普通函数调用一样，总会在调用时创建一个新的栈帧（stack frame）并将其推入调用栈顶部，用于表示该次函数调用。

当一个函数调用发生时，计算机必须 “记住” 调用函数的位置 —— 返回位置，才可以在调用结束时带着返回值回到该位置，返回位置一般存在调用栈上。在尾调用这种特殊情形中，计算机理论上可以*不需要记住尾调用的位置*而*从被调用的函数直接**带着返回值**返回调用函数的返回位置*（相当于直接连续返回两次）。
尾调用消除即是在不改变当前调用栈（也不添加新的返回位置）的情况下跳到新函数的一种优化（完全不改变调用栈是不可能的，还是需要校正调用栈上形式参数与局部变量的信息。）

由于当前函数帧上包含局部变量等等大部分的东西都不需要了，当前的*函数帧经过适当的更动*以后可以*直接当作被尾调用的函数的帧使用*，然后程序即可以跳到被尾调用的函数。产生这种函数帧更动代码与 “jump”（而不是一般常规函数调用的代码）的过程称作**尾调用消除(Tail Call Elimination)**或**尾调用优化(Tail Call Optimization, TCO)**。尾调用优化让位于尾位置的函数调用跟 goto 语句性能一样高，也因此使得高效的结构编程成为现实。

然而，对于 **C++** 等语言来说，在函数最后 return g(x); 并不一定是尾递归——在返回之前很可能涉及到**对象的析构函数**，使得 g(x) 不是最后执行的那个。这可以通过返回值优化来解决。

```lua
function foo(data1, data2)
   a(data1)
   return b(data2)


汇编代码:
```asm
foo:
  mov  reg,[sp+data1] ; 透过栈指针（sp）取得 data1 并放到暂用暂存器。
  push reg            ; 将 data1 放到栈上以便 a 使用。
  call a              ; a 使用 data1。
  pop                 ; 把 data1 從栈上拿掉。
  mov  reg,[sp+data2] ; 透过栈指針（sp）取得 data2 並放到暂用暂存器。
  push reg            ; 将 data2 放到栈上以便 b 使用。
  call b              ; b 使用 data2。
  pop                 ; 把 data2 從栈上拿掉。
  ret
```

优化后汇编代码:

```asm
foo:
  mov  reg,[sp+data1] ; 透过栈指针（sp）取得 data1 并放到暂用暂存器。
  push reg            ; 将 data1 放到栈上以便 a 使用。
  call a              ; a 使用 data1。
  pop                 ; 把 data1 從栈上拿掉。
  mov  reg,[sp+data2] ; 透过栈指針（sp）取得 data2 並放到暂用暂存器。  
  mov  [sp+data1],reg ; 把 data2 放到 b 预期的位置。
  jmp  b              ; b 使用 data2 並返回到调用 foo 的函数。
```

## 7. 迭代器 泛型for

创建一个`闭包`必须要创建其外部局部变量。
所以一个典型的闭包的结构包含两个函数：一个是`闭包`自己；另一个是工厂（`创建闭包的函数`）。

```lua
function list_iter (t)
    local i = 0
    local n = table.getn(t)
    return function ()
        i = i + 1
        if i <= n then return t[i] end
    end
end

-- usage:
t = {10, 20, 30}
iter = list_iter(t) -- creates the iterator
while true do
    local element = iter() -- calls the iterator
    if element == nil then break end
    print(element)
end

-- 泛型 for
t = {10, 20, 30}
for element in list_iter(t) do
    print(element)
end
```

note:*这个例子中 list_iter 是一个工厂，每次调用他都会创建一个新的闭包（迭代器本身）*

```lua
-- 迭代器
function allwords()
    local line = io.read() -- current line
    local pos = 1 -- current position in the line
    return function () -- iterator function
        while line do -- repeat while there are lines
            local s, e = string.find(line, "%w+", pos)
            if s then -- found a word
                pos = e + 1 -- next position is after this word
                return string.sub(line, s, e) -- return the word
            else
                line = io.read() -- word not found; try next line
                pos = 1 -- restart from first position
            end
        end
        return nil -- no more lines: end of traversal
    end
end

-- usage:
for word in allwords() do
    print(word)
end
```

### 7.2 泛型 for 的语义

一般式:

```lua
for var_1, ..., var_n in explist do block end
-- ==>

do
    local _f, _s, _var = explist
    while true do
        local var_1, ... , var_n = _f(_s, _var)
        _var = var_1
        if _var == nil then break end
        block
    end
end
```

### 7.3 无状态的迭代器

note:*迭代的状态包括被遍历的表（循环过程中不会改变的`状态常量`）和当前的索引下标（`控制变量`），*

```lua
function iter (a, i)
    i = i + 1
    local v = a[i]
    if v then
        return i, v
    end
end

function ipairs (a)
    return iter, a, 0
end
```

note:*当 Lua 调用 ipairs(a)开始循环时，他获取三个值:迭代函数 iter，状态常量 a 和控制变量初始值 0；然后 Lua 调用 iter(a,0)返回 1,a[1]（除非 a[1]=nil）；直到**第一个**非 nil 元素*

```lua
local n
-- n = nil 全部
-- n = 1 打印从2 开始
-- n = 0 出错
dd={1,3,3,3,}
for k, v in next, dd, n do
    print(k,v)
end
```

### 7.3 多状态的迭代器

## 8. 编译 运行 调试

note: *解释型语言的特征不在于他们是否被编译，而是`编译器`是`语言运行时`的一部分*

loadfile:*编译代码成中间码并且返回编译后的 chunk 作为一个函数，而不执行代码；*

note:*在发生错误的情况下，loadfile 返回 nil 和错误信息，这样我们就可以自定义错误处理*

```lua
f = loadstring("i = i + 1")
```

note:*f 将是一个函数，调用时执行 i=i+1*

Lua 把每一个 chunk 都作为一个`匿名函数`处理。
例如：chunk "a = 1"，
`loadstring` 返回与其等价的 `function () a = 1 end`与其他函数一样，
chunks 可以定义局部变量也可以返回值：`f = loadstring("local a = 10; return a + 20")`

note:*loadfile 和 loadstring 都不会抛出错误，如果发生错误他们将返回 nil 加上错误信息：*
note:*Lua 中的`函数定义`是发生在`运行时的赋值`而不是发生在编译时。*

如果你想快捷的调用 dostring（比如加载并运行），可以这样
`loadstring(s)()`

如果加载的内容存在`语法错误`的话，loadstring 返回 nil 和错误信息（attempt to call a nil value）；为了返回更清楚的错误信息可以使用 assert：
`assert(loadstring(s))()`

note:*每次调用 loadstring 都会重新编译,loadstring 编译的时候不关心词法范围*

```lua
local i = 0
f = loadstring("i = i + 1")
g = function () i = i + 1 end
```

note:*这个例子中，和想象的一样 `g` 使用**局部变量** i，然而 `f` 使用**全局变量** i；`loadstring` 总是在**全局环境**中**编译**他的串。*

note:*loadstring 期望一个 chunk，即语句。如果想要加载`表达式`，需要在表达式前加 `return`，那样将返回表达式的值。*

## 8.1 require

- *会搜索目录加载文件*
- *会判断是否文件已经加载避免重复加载同一文件*
- *?;?.lua;c:\windows\?;/usr/local/lua/?/?.lua*
- *require 和 dofile 完成同样的功能*

```lua
require lili
--[[
lili
lili.lua
c:\windows\lili
/usr/local/lua/lili/lili.lua
]]
```

note:*表中保留加载的文件的虚名，而不是实文件名。所以如果你使用不同的虚文件名 require同一个文件两次，将会加载两次该文件。比如 require "foo"和 require "foo.lua"，将会加载 foo.lua 两次,全局变量`_LOADED` 访问文件名列表, `_REQUIREDNAME`*

### 8.2 C Packages

note:*动态连接库不是 ANSI C 的一部分，也就是说在标准 C 中实现动态连接是很困难的。*

```lua
local path = "/usr/local/lua/lib/libluasocket.so"
-- or path = "C:\\windows\\luasocket.dll"
local f = assert(loadlib(path, "luaopen_socket"))
f() -- actually open the library
```

### 8.3 错误

```lua
print "enter a number:"
n = io.read("*number")
if not n then error("invalid input") end
```

### 8.4 异常 和 错误处理 pcall

### 8.5错误信息 和 回跟踪 xpcall

```lua
error("string expected", 2)
print(debug.traceback())
```

## 9.0 协同程序

协同程序（coroutine）*与多线程情况下的线程比较类似：有自己的堆栈，自己的局部变量，有自己的指令指针，但是和其他协同程序共享全局变量等很多信息。*

线程和协同程序的主要不同在于：在多处理器情况下，从概念上来讲多线程程序同时运行多个线程；而协同程序是通过协作来完成，在**任一指定时刻只有一个协同程序在运行**，并且这个正在运行的协同程序只有在明确的被要求挂起的时候才会被挂起。

```lua
co = coroutine.create(function () print("hi") end)
print(co) --> thread: 0x8071d98
```

note:*协同有三个状态：挂起态、运行态、停止态.当我们创建一个协同程序时他开始的状态为挂起态，也就是说我们创建协同程序的时候不会自动运行，*

```lua
print(coroutine.status(co)) --> suspended
coroutine.resume(co)
print(coroutine.status(co)) --> dead

co = coroutine.create(function ()
    for i=1,10 do
        print("co", i)
        coroutine.yield()
    end
end)

-- 协同程序处于终止状态 激活他，resume 将返回 false 和错误信息。
print(coroutine.resume(co)) --> false cannot resume dead coroutine
```

note:*resume 运行在保护模式下，因此如果协同内部存在错误 Lua 并不会抛出错误而是将错误返回给 resume 函数。*

```lua
-- yield 返回的额外的参数也将会传递给 resume。
co = coroutine.create (function ()
    print("co", coroutine.yield())
end)
coroutine.resume(co)
coroutine.resume(co, 4, 5) --> co 4 5
```

- resume 把额外的参数传递给协同的主程序。
- resume 返回除了 true 以外的其他部分将作为参数传递给相应的 yield, yield 返回的额外的参数也将会传递给 resume。
- 当协同代码结束时主函数返回的值都会传给相应的 resume

对称协同:*由执行到挂起之间状态转换的函数是相同的。*
不对称协同(半协同):*挂起一个正在执行的协同的函数与使一 个被挂起的协同再次执行的函数是不同的*

### 9.2 过滤器

过滤器:*指在生产者与消费者之间，可以对数据 进行某些转换处理。过滤器在同一时间既是生产者又是消费者，他请求生产者生产值并 且转换格式后传给消费者*

example:

```lua
function receive (prod)
local status, value = coroutine.resume(prod)
   return value
end

function send (x)
   coroutine.yield(x)
end

function producer ()
   return coroutine.create(function ()
        while true do
            local x = io.read() -- produce new value
            send(x)
        end
    end)
end

function filter (prod)
   return coroutine.create(function ()
       local line = 1
        while true do
            local x = receive(prod) -- get new value
            x = string.format("%5d %s", line, x)
            send(x) -- send it to consumer
            line = line + 1
        end
    end)
end

function consumer (prod)
    while true do
        local x = receive(prod) -- get new value
        io.write(x, "\n") -- consume new value
    end
end

consumer(filter(producer()))
```

### 9.3 迭代器

origin:

```lua
function permgen (a, n)
    if n == 0 then
        printResult(a)
    else
        for i=1,n do
            -- put i-th element as the last one
            a[n], a[i] = a[i], a[n]
            -- generate all permutations of the other elements
            permgen(a, n - 1)
            -- restore i-th element
            a[n], a[i] = a[i], a[n]
        end
    end
end

function printResult (a)
   for i,v in ipairs(a) do
       io.write(v, " ")
   end
   io.write("\n")
end

permgen ({1,2,3,4}, 4)
```

example:

```lua
function permgen (a, n)
    if n == 0 then
       coroutine.yield(a)
    else
        for i=1,n do
            -- put i-th element as the last one
            a[n], a[i] = a[i], a[n]
            -- generate all permutations of the other elements
            permgen(a, n - 1)
            -- restore i-th element
            a[n], a[i] = a[i], a[n]
        end
    end
end

function perm (a)
    local n = table.getn(a)
    local co = coroutine.create(function () permgen(a, n) end)
    return function () -- iterator
        local code, res = coroutine.resume(co)
        return res
    end
end

function printResult (a)
    for i,v in ipairs(a) do
        io.write(v, " ")
    end
    io.write("\n")
end

for p in perm{"a", "b", "c"} do
   printResult(p)
end
```

coroutine.wrap:*wrap 创建一个协同程序;不同的是 wrap 不返回协 同本身，而是返回一个函数，当这个函数被调用时将 resume 协同*

```lua
function perm (a)
   local n = table.getn(a)
   return coroutine.wrap(function () permgen(a, n) end)
end
```

### 9.4 非抢占式多线程

note:*协同是非抢占式的。 当一个协同正在运行时，不能在外部终止他。只能通过显示的调用 yield 挂起他的执行。*

```lua
协同是非抢占式的。 当一个协同正在运行时，不能在外部终止他。只能通过显示的调用 yield 挂起他的执行。
```

---
> table & object

## 11. 数据结构

### 11.1 数组

### 11.2 阵 多维数组

稀疏矩阵:*指矩阵的大部分元素都为空或者 0 的矩阵。*

### 11.3 链表

### 11.4 队列 双端队列

note:*Lua 的 table 库提供的 insert 和 remove 操作来实现队列，但这种方式 实现的队列针对**大数据量**时效率太低*

note:*有效的方式是使用两个索引下标，一个表示第一个元素，另一个表示最后一个元素。*

### 11.5 集合 包

### 11.6 字符串缓冲

```lua
-- WARNING: bad code ahead!!
local buff = ""
for line in io.lines() do
   buff = buff .. line .. "\n"
end
```

假定在 loop 中间，buff 已经是一个 50KB 的字符串， 每一行的大小为 20bytes，
当 Lua 执行 `buff..line.."\n"`时，她创建了一个新的字符串大小为 50,020 bytes，并且从 buff 中将 50KB 的字符串拷贝到新串中。
老的字符串变成了垃圾数据，两轮循环之后，将有两个老串包含超过 100KB 的垃圾 数据。这个时候 Lua 会做出正确的决定，进行他的垃圾收集并释放 100KB 的内存。问题 在于每两次循环 Lua 就要进行一次垃圾收集，读取整个文件需要进行 200 次垃圾收集。 并且它的内存使用是整个文件大小的三倍。

note:*其它的采用垃圾收集算法的并且字符串不可变的语言 也都存在这个问题。Java 专门提供 StringBuffer 来改善这种情况。*

```lua
function newStack ()
   return {""}   -- starts with an empty string
end

function addString (stack, s)
    table.insert(stack,s) --push's'intothethestack for i=table.getn(stack)-1, 1, -1 do
    if string.len(stack[i]) > string.len(stack[i+1]) then
        break
    end

    stack[i] = stack[i] .. stack[i+1]
    stack[i+1] = nil
    end
end

local s = newStack()
for line in io.lines() do
   addString(s, line .. "\n")
end
s = toString(s)

-- 或者
local t = {}
for line in io.lines() do
   table.insert(t, line)
end
s = table.concat(t, "\n") .. "\n"
```

## 12. 数据文件与持久化

> string.format("%q", o)

## 13. metatables metamethods

```lua
t1 = {}
setmetatable(t, t1)
assert(getmetatable(t) == t1)
```

note:*一组相关的表可以共享一个 metatable (描述他们共同的行为)。一个表也可以是**自身**的 metatable(描述其私有行为)。*

### 13.1  算术运算的 metamethods

```lua
Set = {}
Set.mt = {} -- metatable for sets

function Set.new (t)
   local set = {}
    setmetatable(set, Set.mt)
   for _, l in ipairs(t) do set[l] = true end
   return set
end
function Set.union (a,b)
    if getmetatable(a) ~= Set.mt or getmetatable(b) ~= Set.mt then
        error("attempt to `add' a set with a non-set value", 2)
    end
   local res = Set.new{}
   for k in pairs(a) do res[k] = true end
   for k in pairs(b) do res[k] = true end
   return res
end
function Set.intersection (a,b)
   local res = Set.new{}
   for k in pairs(a) do
res[k] = b[k]
end
   return res
end

function Set.tostring (set)
   local s = "{"
   local sep = ""
   for e in pairs(set) do
s = s .. sep .. e
sep = ", " end
   return s .. "}"
end
function Set.print (s)
   print(Set.tostring(s))
end

s1 = Set.new{10, 20, 30, 50}
s2 = Set.new{30, 1}
print(getmetatable(s1))     --> table: 00672B60
print(getmetatable(s2))     --> table: 00672B60

Set.mt.__add = Set.union

s3 = s1 + s2
Set.print(s3) --> {1, 10, 20, 30, 50}

Set.mt.__mul = Set.intersection
Set.print((s1 + s2)*s1)     --> {10, 20, 30, 50}

```

note:*除了__add,__mul, 还有__sub(减),__div(除),__unm(负),__pow(幂)，我们也可以定义__concat 定义连接行为。*

如果两个操作数有不同的 metatable, Lua 选择 metamethod 的原则:

- 如果第一个参数存在带有__add 域的 metatable，Lua 使用它作为 metamethod，和第二个参数无关;
- 否则第二个参数存在带有__add 域的 metatable，Lua 使用它作为 metamethod 否则报错。

### 13.2 关系运算的 metamethods

note:*__eq（等于），__lt（小于） ，和__le（小于等于)*

note:*`当我们遇到偏序（partial order）情况，也就是说，并不是所有的元素都可以正确的被排序情况。例如，在大多数机器上浮点数不能被排序，因为他的值不是一个数字（Not a Number 即 NaN）`*

note:*根据 IEEE 754 的标准，NaN 表示一个未定义的值，比如 0/0 的结果。该标准指出任何涉及到 NaN 比较的结果都应为 false。也就是说，NaN <= x 总是 false，x < NaN 也总是 false。这样一来，在这种情况下 a <= b 转换为 not (b < a)就不再正确了。*

note:*<=代表集合的包含：a <= b 表示集合 a 是集合 b 的子集。这种意义下，可能 a <= b 和 b < a 都是 false；*

note:*关系元算的 metamethods 不支持混合类型运算*

note:*试图比较一个字符串和一个数字，Lua 将抛出错误.相似的，如果你试图比较两个带有不同 metamethods 的对象，Lua 也将抛出错误。*

note:*但相等比较从来不会抛出错误，如果两个对象有不同的 metamethod，比较的结果为false，甚至可能不会调用 metamethod.*

note:*仅当两个有共同的 metamethod 的对象进行相等比较的时候，Lua 才会调用对应的 metamethod。*

### 13.3 库定义的 metamethods

note:*`print` 函数总是调用 tostring 来格式化它的输出, tostring 会首先检查对象是否存在一个带有`__tostring`域的 metatable。*

假定你想保护你的集合使其使用者既看不到也不能修改 metatables。
如果你对 metatable 设置了__metatable 的值， getmetatable 将返回这个域的值，而调用 setmetatable将会出错：

> Set.mt.__metatable = "not your business"

### 13.4 表相关 metamethods

#### 13.4.1 The __index Metamethod

note:*当我们访问一个表的不存在的域，这种访问触发 lua 解释器去查找__index metamethod*
note:*__index metamethod 不需要非是一个函数，他也可以是一个表。*

- 它是一个函数的时候，Lua 将 table 和缺少的域作为参数调用这个函数；
- 他是一个表的时候，Lua 将在这个表中看是否有缺少的域。

#### 13.4.2 The __newindex Metamethod

note:*当你给表的一个缺少的域赋值，解释器就会查找__newindex metamethod,如果存在则调用这个函数而不进行赋值操作。*

调用rawset(t,k,v)不掉用任何 metamethod 对表 t 的 k 域赋值为 v。

#### 13.4.3 有默认值的表

#### 13.4.4 监控表

单表监控

```lua
t = {} -- original table (created somewhere)
-- keep a private access to original table
local _t = t
-- create proxy
t = {}
-- create metatable
local mt = {
__index = function (t,k)
    print("*access to element " .. tostring(k))
    return _t[k] -- access the original table
end,
__newindex = function (t,k,v)
    print("*update of element " .. tostring(k) ..
    " to " .. tostring(v))
    _t[k] = v -- update original table
end
}
setmetatable(t, mt)
```

note:*注意：不幸的是，这个设计不允许我们遍历表。*

多表监控

```lua
-- create private index
local index = {}
-- create metatable
local mt = {
    __index = function (t,k)
        print("*access to element " .. tostring(k))
        return t[index][k] -- access the original table
    end
    __newindex = function (t,k,v)
        print("*update of element " .. tostring(k) .. " to ".. tostring(v))
        t[index][k] = v -- update original table
    end
}
function track (t)
    local proxy = {}
    proxy[index] = t
    setmetatable(proxy, mt)
    return proxy
end
```

#### 13.4.5 只读表

```lua
function readOnly (t)
    local proxy = {}
    local mt = { -- create metatable
        __index = t,
        __newindex = function (t,k,v)
            error("attempt to update a read-only table", 2)
        end
    }
    setmetatable(proxy, mt)
    return proxy
end

days = readOnly{"Sunday", "Monday", "Tuesday", "Wednesday","Thursday", "Friday", "Saturday"}
```

## 14.环境

### 14.1 使用动态名字访问全局变量

```lua
function getfield (f)
    local v = _G -- start with the table of globals
    for w in string.gfind(f, "[%w_]+") do
        v = v[w]
    end
    return v
end

function setfield (f, v)
    local t = _G -- start with the table of globals
    for w, d in string.gfind(f, "([%w_]+)(.?)") do
        if d == "." then -- not last field?
            t[w] = t[w] or {} -- create table if absent
            t = t[w] -- get the table
        else -- last field
            t[w] = v -- do the assignment
        end
    end
end
```

### 14.2 声明全局变量

```lua
local declaredNames = {}

function declare (name, initval)
    rawset(_G, name, initval)
    declaredNames[name] = true
end

setmetatable(_G, {
    __newindex = function (t, n, v)
        if not declaredNames[n] then
            print("attempt to write to undeclared var. "..n, 2)
        else
            rawset(t, n, v) -- do the actual set
        end
    end,
    __index = function (_, n)
        if not declaredNames[n] then
            print("attempt to read undeclared var. "..n, 2)
        else
            return nil
        end
    end,
})
```

### 14.3 非全局的环境

note:*当你安装一个 metatable 去控制全局访问时，你的整个程序都必须遵循同一个指导方针。如果你想使用标准库，标准库中可能使用到没有声明的全局变量，你将碰到坏运。*

Setfenv:*接受函数和新的环境作为参数。除了使用函数本身，还可以指定一个数字表示栈顶的活动函数。数字 1 代表当前函数，数字 2 代表调用当前函数的函数*

```lua
a = 1 -- create a global variable
-- change current environment to a new empty table
setfenv(1, {})
print(a)
```

必须在单独的 chunk 内运行这段代码，如果你在交互模式逐行运行他，每一行都是一个不同的函数，调用 setfenv 只会影响他自己的那一行

封装: populate

```lua
a = 1 -- create a global variable
-- change current environment
setfenv(1, {_G = _G})
_G.print(a) --> nil
_G.print(_G.a) --> 1
```

继承封装

```lua
a = 1 -- create a global variable
-- change current environment
setfenv(1, {_G = _G})
_G.print(a) --> nil
_G.print(_G.a) --> 1
```

note:*当你创建一个新的函数时，他从创建他的函数继承了环境变量*
note:*如果一个chunk 改变了他自己的环境，这个 chunk 所有在改变之后定义的函数都共享相同的环境，都会受到影响。这对创建**命名空间**是非常有用的机制*

## 15 package

note:*大多数语言中，packages 不是**第一类值(first-class values)**（也就是说，他们不能存储在变量里，不能作为函数参数。。。 ）*

- 对每一个函数定义都必须显示的在前面加上包的名称。
- 同一包内的函数`相互调用`必须在被调用函数前**指定包名**。

缺点:

- *修改函数的状态(公有变成私有或者私有变成公有)我们必须修改函数得**调用方式**。*
- *访问同一个package 内的其他公有的实体写法冗余，必须加上前缀 P.。*

```lua
local function checkComplex (c)
    if not ((type(c) == "table") and tonumber(c.r) and tonumber(c.i)) then
        error("bad complex number", 3)
    end
end

local function new (r, i) return {r=r, i=i} end
local function add (c1, c2)
    checkComplex(c1);
    checkComplex(c2);
    return new(c1.r + c2.r, c1.i + c2.i)
end

...

-- 列表放在后面 因为必须首先定义局部函数
complex = {
    new = new,
    add = add,
    sub = sub,
    mul = mul,
    div = div,
}
```

### 15.3 包 与 文件

    note:*当 require 加载一个文件的时候，它定义了一个变量来表示虚拟的文件名*

    ```lua
    -- 不需要 require 就可以使用 package
    local P = {} -- package
    if _REQUIREDNAME == nil then
        complex = P
    else
    _G[_REQUIREDNAME] = P
    end
    ```

    note:*我们可以在同一个文件之内定义多个 packages，我们需要做的只是将每一个 package 放在一个 **do 代码块***内，这样 local 变量才能被限制在那个代码块中*

    自动加载

    ```lua
    local location = {
    foo = "/usr/local/lua/lib/pack1_1.lua",
    goo = "/usr/local/lua/lib/pack1_1.lua",
    foo1 = "/usr/local/lua/lib/pack1_2.lua",
    goo1 = "/usr/local/lua/lib/pack1_3.lua",
    }

    pack1 = {}

    setmetatable(pack1, {__index = function (t, funcname)
        local file = location[funcname]
        if not file then
            error("package pack1 does not define " .. funcname)
        end
        assert(loadfile(file))()    -- load and run definition
        return t[funcname]          -- return the function
    end})

    return pack1
    ```

## 16 面向对象程序设计

    ```lua
    Account = {
        balance=0,
        withdraw = function (self, v)
            self.balance = self.balance - v
        end
    }
    function Account:deposit (v)
        self.balance = self.balance + v
    end
    Account.deposit(Account, 200.00)
    Account:withdraw(100.00)

    function Account:new (o)
        o = o or {} -- create object if user does not provide one
        setmetatable(o, self)
        self.__index = self
        return o
    end

    a = Account:new{balance = 0}
    a:deposit(100.00)

    getmetatable(a).__index.deposit(a, 100.00)
    Account.deposit(a, 100.00)

    ```

    ### 16.3 多重继承

        多重继承意味着一个类拥有多个父类

    ### 16.4 私有性

        通过闭包实现私有性

        ```lua
        function newAccount (initialBalance)
            local self = {
                balance = initialBalance,
                LIM = 10000.00,
            }

            local withdraw = function (v)
            self.balance = self.balance - v
            end

            local deposit = function (v)
            self.balance = self.balance + v
            end

            local extra = function ()
                if self.balance > self.LIM then
                    return self.balance*0.10
                else
                return 0 end
            end

            local getBalance = function ()
                return self.balance + self.extra()
            end

            --local getBalance = function () return self.balance end
            return {
                withdraw = withdraw,
                deposit = deposit,
                getBalance = getBalance
            }
        end

        acc1 = newAccount(100.00)
        acc1.withdraw(40.00)
        print(acc1.getBalance())    --> 60
        ```

    ### 16.5 Single-Method 的对象实现方法

        ```lua
        function newObject (value)
            return function (action, v)
                if action == "get" then return value
                elseif action == "set" then value = v
                else error("invalid action")
                end
            end
        end

        d = newObject(0)
        print(d("get")) --> 0
        d("set", 10)
        print(d("get")) --> 10
        ```

## 17 weak 表

    一个 weak 引用是指*一个不被 Lua 认为是垃圾的对象的引用。*
    如果一个对象所有的引用指向都是weak，对象将被收集，而那些 weak 引用将会被删除。
    如果一个对象只存在于 weak tables 中，Lua 将会最终将它收集。

    三种类型的 weak tables：

    - weak keys 组成的 tables；
    - weak values 组成的 tables；
    - 以及纯 weak tables 类型，他们的 keys 和 values 都是 weak 的。

    表的 weak 性由他的 metatable 的__mode 域来指定的。

    ```lua
    a = {}
    b = {}
    setmetatable(a, b)
    b.__mode = "k" -- now 'a' has weak keys
    key = {} -- creates first key
    a[{key}] = 1
    key = {} -- creates second key
    a[key] = 2
    collectgarbage() -- forces a garbage collection cycle
    for k, v in pairs(a) do print(v) end
    ```

    第二个赋值语句 key={}覆盖了第一个 key 的值。当垃圾收集器工作时，在其他地方没有指向第一个 key 的引用，所以它被收集了

    note:*只有对象才可以从一个 weak table 中被收集。比如数字和布尔值类型的值，都是不会被收集的。*

    example:*如果我们在 table 中插入了一个数值型的 key（在前面那个例子中），它将永远不会被收集器从 table 中移除。当然，如果对应于这个数值型 key 的 **vaule**被收集，那么它的整个入口将会从 weak table 中被移除。*

    note:*一个字符串不会从 weak tables 中被移除（除非它所关联的 vaule 被收集）*

    ### 17.1 记忆函数

        如果这个结果表中有 weak 值，每次的垃圾收集循环都会移除当前时间内所有未被使用的结果

        ```lua
        local results = {}
        setmetatable(results, {__mode = "v"}) -- make values weak
        function createRGB (r, g, b)
            local key = r .. "-" .. g .. "-" .. b
            if results[key] then return results[key]
            else
                local newcolor = {red = r, green = g, blue = b}
                results[key] = newcolor
                return newcolor
            end
        end
        ```

> 标准库

## 18. 数学库

    三角函数库（sin, cos, tan, asin, acos, etc.）
    幂指函数（exp, log, log10），
    舍入函数（floor, ceil）、
    max、min，加上一个变量 pi。

    所有的三角函数都在弧度单位下工作。**（Lua4.0 以前在度数下工作。）**
    你可以使用 `deg`和 `rad` 函数在度和弧度之间转换。

    math.random 用来产生伪随机数，有三种调用方式：

    - 第一：不带参数，将产生 [0,1)范围内的随机数.
    - 第二：带一个参数 n，将产生 1 <= x <= n 范围内的随机数 x.
    - 第三：带两个参数 a 和 b,将产生 a <= x <= b 范围内的随机数 x.

    ```lua
    math.randomseed(os.time())
    ```

## 19. table 库

    table.getn table.setn 已经弃用

    ```lua
    a = {nil, 1, 2, key = '1234321', nil, 15, 'sagewqgag', nil}

    for k,v in pairs(a) do
        print(k,v)
    end

    for k,v in ipairs(a) do
        print('ddd',k,v)
    end

    print('len:',#a)
    ```

    ipairs iterate number index until first `nil`
    pairs iterate all except `nil`
    when `{nil, 1, 2, key = '1234321', nil, 15, 'sagewqgag', nil}`, #a = 6
    when `{1, 2, key = '1234321', nil, 15, 'sagewqgag', nil}`, #a = 2
    when `{1, 2, key = '1234321', 15, 'sagewqgag', nil}`, #a = 4
    when `{1, 2, key = '1234321', 15, 'sagewqgag'}`, #a = 4

    table.insert 函数在 array指定位置插入一个元素，并**将后面所有其他的元素后移。**

    不带位置参数调用 insert，将会在 array**最后位置**插入元素（所以不需要元素移动）

    note:*排序函数有两个参数并且如果在 array 中排序后第一个参数在第二个参数前面，排序函数必须返回 true。如果未提供排序函数，sort 使用默认的小于操作符进行比较*

## 20 string 库

    `string.len(s)`返回字符串 s 的长度；
    `string.rep(s,n)`返回重复 n 次字符串 s 的串；
    你使用 `string.rep("a", 2^20)`可以创建一个 1M bytes 的字符串（比如，为了测试需要） ；
    `string.lower(s)`将 s 中的大写字母转换成小写（`string.upper`将小写转换成大写）
    `string.sub(s,i,j)`函数截取字符串 s 的从第 i 个字符到第 j 个字符之间的串。

    Lua中，*字符串的第一个字符索引从 1 开始。你也可以使用负索引，负索引从字符串的结尾向前计数：-1 指向最后一个字符，-2 指向倒数第二个，以此类推。*
    note:*Lua 中的字符串是恒定不变的。String.sub 函数以及 Lua 中其他的字符串操作函数都不会改变字符串的值，而是返回一个新的字符串。*
    如果你想修改一个字符串变量的值，你必须将变量赋给一个新的字符串：

    ```lua
    s = string.sub(s, 2, -2)
    print(string.char(97)) --> a
    i = 99; print(string.char(i, i+1, i+2)) --> cde
    print(string.byte("abc")) --> 97
    print(string.byte("abc", 2)) --> 98
    print(string.byte("abc", -1)) --> 99

    print(string.format("pi = %.4f", PI)) --> pi = 3.1416
    d = 5; m = 11; y = 1990
    print(string.format("%02d/%02d/%04d", d, m, y)) --> 05/11/1990
    tag, title = "h1", "a title"
    print(string.format("<%s>%s</%s>", tag, title, tag)) --> <h1>a title</h1>
    ```

### 20.1 模式匹配

Lua并不使用POSIX规范的正则表达式（也写作**regexp**）来进行模式匹配。

```lua
s = "hello world"
i, j = string.find(s, "hello")
print(i, j) --> 1 5
print(string.sub(s, i, j)) --> hello
print(string.find(s, "world")) --> 7 11
i, j = string.find(s, "l")
print(i, j) --> 3 3
print(string.find(s, "lll")) --> nil

local t = {} -- table to store the indices
local i = 0
while true do
    i = string.find(s, "\n", i+1) -- find 'next' newline
    if i == nil then break end
    table.insert(t, i)
end

s = string.gsub("Lua is cute", "cute", "great")
print(s) --> Lua is great
s = string.gsub("all lii", "l", "x")
print(s) --> axx xii
s = string.gsub("Lua is great", "perl", "tcl")
print(s) --> Lua is great

s = string.gsub("all lii", "l", "x", 1)
print(s) --> axl lii
s = string.gsub("all lii", "l", "x", 2)
print(s) --> axx lii
_, count = string.gsub(str, " ", " ")
```

note:*_ 只是一个哑元变量*

### 20.2 模式

    + 匹配前一字符 1 次或多次
    * 匹配前一字符 0 次或多次
    - 匹配前一字符 0 次或多次
    ? 匹配前一字符 0 次或 1 次
    '[_%a][_%w]*' 匹配 Lua 程序中的标示符：字母或者下划线开头的字母下划线数字序列。
    匹配一对圆括号()或者括号之间的空白，可以使用 '%(%s*%)'

```lua
s = "Deadline is 30/05/1999, firm"
date = "%d%d/%d%d/%d%d%d%d"
print(string.sub(s, string.find(s, date))) --> 30/05/1999

print(string.gsub("hello, up-down!", "%A", ".")) --> hello..up.down. 4

print(string.gsub("one, and two; and three", "%a+", "word")) --> word, word word; word word

i, j = string.find("the number 1298 is even", "%d+")
print(i,j) --> 12 15
```

### 20.3 捕获

```lua
pair = "name = Anna"
_, _, key, value = string.find(pair, "(%a+)%s*=%s*(%a+)")
print(key, value) --> name Anna

date = "17/7/1990"
_, _, d, m, y = string.find(date, "(%d+)/(%d+)/(%d+)")
print(d, m, y) --> 17 7 1990

s = [[then he said: "it's all right"!]]
a, b, c, quotedPart = string.find(s, "([\"'])(.-)%1")
print(quotedPart) --> it's all right
print(c) --> "
```

## 21. IO 库

### 21.1 简单 I/O 模式

io.input 和 io.output 函数来改变当前文件。
例如io.input(filename)就是打开给定文件（以读模式），并将其设置为当前输入文件。
接下来所有的输入都来自于该文，直到再次使用 io.input。io.output 函数。
一旦产生错误两个函数都会产生错误。

```lua
> io.write("sin (3) = ", math.sin(3), "\n")
--> sin (3) = 0.1411200080598672
> io.write(string.format("sin (3) = %.4f\n", math.sin(3)))
--> sin (3) = 0.1411
```

在编写代码时应当避免像 io.write(a..b..c)；这样的书写，这同 io.write(a,b,c)的效果是一样的。但是后者因为避免了串联操作，而消耗较少的资源。

Write 函数与 print 函数不同在于，write 不附加任何额外的字符到输出中去，例如制表符，换行符等等。
write 函数是使用当前输出文件，而 print 始终使用标准输出。
print函数会自动调用参数的 tostring方法，所以可以显示出表（tables）函数（functions）和 nil。

"*all" 读取整个文件
"*line" 读取下一行
"*number" 从串中转换出一个数值
num 读取 num 个字符到串

io.read("*all")函数从当前位置读取整个输入文件。如果当前位置在文件末尾，或者文件为空，函数将返回空串。
io.read("*line")函数返回当前输入文件的下一行（不包含最后的换行符）。当到达文件末尾，返回值为 nil（表示没有下一行可返回）
*该读取方式是 read 函数的默认方式，所以可以简写为 io.read()。*
io.read("*number")函数从当前输入文件中读取出一个数值。只有在该参数下 read 函数才返回数值，而不是字符串。
如果在当前位置找不到一个数字（由于格式不对，或者是到了文件的结尾），则返回 nil 可以对每个参数设置选项，函数将返回各自的结果。

```lua
--[[
6.0 -3.23 15e12
4.3 234 1000001
...
]]
while true do
local n1, n2, n3 = io.read("*number", "*number", "*number")
if not n1 then break end
print(math.max(n1, n2, n3))
end

local size = 2^13 -- good buffer size (8K)
while true do
local block = io.read(size)
if not block then break end
io.write(block)
end
```

### 21.2 完全 I/O 模式

```lua
local f = assert(io.open(filename, "r"))
local t = f:read("*all")
f:close()

local temp = io.input() -- save current file
io.input("newinput") -- open a new current file
... -- do something with new input
io.input():close() -- close current file
io.input(temp) -- restore previous current file
```

I/O 优化的一个小技巧:
通常 Lua 中读取整个文件要比一行一行的读取一个文件快的多。

```lua
local lines, rest = f:read(BUFSIZE, "*line")

local BUFSIZE = 2^13 -- 8K
local f = io.input(arg[1]) -- open input file
local cc, lc, wc = 0, 0, 0 -- char, line, and word counts
while true do
    local lines, rest = f:read(BUFSIZE, "*line")
    if not lines then break end
    if rest then lines = lines .. rest .. '\n' end
    cc = cc + string.len(lines)
    -- count words in the chunk
    local _,t = string.gsub(lines, "%S+", "")
    wc = wc + t
    -- count newlines in the chunk
    _,t = string.gsub(lines, "\n", "\n")
    lc = lc + t
end
print(lc, wc, cc)

local inp = assert(io.open(arg[1], "rb"))
local out = assert(io.open(arg[2], "wb"))
local data = inp:read("*all")
data = string.gsub(data, "\r\n", "\n")
out:write(data)
assert(out:close())

function fsize (file)
local current = file:seek() -- get current position
local size = file:seek("end") -- get file size
file:seek("set", current) -- restore position
return size
end
```

## 22 操作系统库

Lua 是以 ANSI C 写成的

```lua
-- obs: 10800 = 3*60*60 (3 hours)
print(os.time{year=1970, month=1, day=1, hour=0})
--> 10800
print(os.time{year=1970, month=1, day=1, hour=0, sec=1})
--> 10801
print(os.time{year=1970, month=1, day=1})
--> 54000 (obs: 54000 = 10800 + 12*60*60)

temp = os.date("*t", 906000490)

--[[
{year = 1998, month = 9, day = 16, yday = 259, wday = 4,
hour = 23, min = 48, sec = 10, isdst = false}

%a abbreviated weekday name (e.g., Wed)
%A full weekday name (e.g., Wednesday)
%b abbreviated month name (e.g., Sep)
%B full month name (e.g., September)
%c date and time (e.g., 09/16/98 23:48:10)
%d day of the month (16) [01-31]
%H hour, using a 24-hour clock (23) [00-23]
%I hour, using a 12-hour clock (11) [01-12]
%M minute (48) [00-59]
%m month (09) [01-12]
%p either "am" or "pm" (pm)
%S second (10) [00-61]
%w weekday (3) [0-6 = Sunday-Saturday]
%x date (e.g., 09/16/98)
%X time (e.g., 23:48:10)
%Y full year (1998)
%y two-digit year (98) [00-99]
%% the character '%'
]]

-- 事实上如果不使用任何参数就调用 date，就是以%c 的形式输出。
print(os.date("today is %A, in %B"))
--> today is Tuesday, in May
print(os.date("%x", 906000490))
--> 09/16/1998

print(os.getenv("HOME")) --> /home/lua

function createDir (dirname)
    os.execute("mkdir " .. dirname)
end
```

## 23. debug 库

debug 库由两种函数组成：自省(`introspective`)函数和 `hooks`。

自省函数 *使得我们可以检查运行程序的某些方面，比如活动函数栈、当前执行代码的行号、本地变量的名和值。*
Hooks *可以跟踪程序的执行情况。*

```lua
debug.getinfo(foo)
```

以数字 n 调用 `debug.getinfo(n)`时，返回在 **n 级栈**的活动函数的信息数据。
比如，如果 n=1，返回的是正在进行调用的那个函数的信息。（n=0 表示 C 函数 getinfo 本身）
如果 n 比栈中活动函数的个数大的话，debug.getinfo 返回 nil。

```lua
function traceback ()
    local level = 1
    while true do
        local info = debug.getinfo(level, "Sl")
        if not info then break end
        if info.what == "C" then -- is a C function?
            print(level, "C function")
        else -- a Lua function
            print(string.format("[%s]:%d",
            info.short_src, info.currentline))
        end
        level = level + 1
    end
end

--[[
a 10
b 20
x nil
a 4
]]
function foo (a,b)
    local x
    do local c = a - b end
    local a = 1
    while true do
        local name, value = debug.getlocal(1, a)
        if not name then break end
        print(name, value)
        a = a + 1
    end
end
foo(10, 20)

function getvarvalue (name)
    local value, found
    -- try local variables
    local i = 1
    while true do
        local n, v = debug.getlocal(2, i)
        if not n then break end
        if n == name then
        value = v
        found = true
        end
        i = i + 1
    end
    if found then return value end
    -- try upvalues
    local func = debug.getinfo(2).func
    i = 1
    while true do
        local n, v = debug.getupvalue(func, i)
        if not n then break end
        if n == name then return v end
        i = i + 1
    end
    -- not found; get global
    return getfenv(func)[name]
end
```

### 23.2 hooks

Lua 使用单个参数调用 hooks，参数为一个描述产生调用的事件："call"、"return"、"line" 或 "count"。

有四种可以触发一个 hook 的事件：

- 当 Lua 调用一个函数的时候 call 事件发生；
- 每次函数返回的时候，return 事件发生；
- Lua 开始执行代码的新行时候，line 事件发生；
- 运行指定数目的指令之后，count 事件发生。

> C API

## 24. C API 纵览

Lua 解释器是一个使用 Lua 标准库实现的独立的解释器，她是一个很小的应用（总共不超过 500 行的代码）。

解释器负责程序和使用者的接口：*从使用者那里获取文件或者字符串，并传给 Lua 标准库，Lua 标准库负责最终的代码运行。*

第一种，C 作为应用程序语言，Lua 作为一个**库**使用；
第二种，反过来，Lua 作为程序语言，C 作为库使用。

C API:
    - 读写 Lua 全局变量的函数，
    - 调用 Lua 函数的函数，
    - 运行 Lua 代码片断的函数，
    - 注册 C 函数然后可以在Lua 中被调用的函数，等等。

压栈函数:

    - 空值（nil）用 lua_pushnil，
    - 数值型（double）用 lua_pushnumber，
    - 布尔型（在 C 中用整数表示）用lua_pushboolean，
    - 任意的字符串（char*类型，**允许包含'\0'字符**）用 lua_pushlstring，C语言风格（以'\0'结束）的字符串（const char*）用 lua_pushstring：

Lua 中的字符串不是以零为结束符的；它们依赖于一个明确的长度，因此可以包含任意的二进制数据。
Lua 从来不保持一个指向**外部字符串**（或任何其它对象，除了 C 函数——它总是静态指针）的指针。

```lua
int lua_checkstack (lua_State *L, int sz);
```

lua_isnumber 和 lua_isstring 函数不检查这个值是否是指定的类型，而是看它**是否能被转换成指定的那种类型**。例如，任何数字类型都满足 lua_isstring

lua_type 函数，它返回栈中元素的类型。

给定的元素的类型不正确,lua_toboolean、lua_tonumber 和 lua_strlen 返回 0，其他函数返回 NULL

当一个 C 函数返回后，Lua 会清理他的栈

```C
const char *s = lua_tostring(L, -1); /* any Lua string */
size_t l = lua_strlen(L, -1); /* its length */
assert(s[l] == '\0');
assert(strlen(s) <= l);
```

函数 lua_gettop 返回堆栈中的元素个数，它也是栈顶元素的索引

一个负数索引-x 对应于正数索引 gettop-x+1。

lua_settop 设置栈顶（也就是堆栈中的元素个数）为一个指定的值。
    - 如果开始的栈顶高于新的栈顶，顶部的值被丢弃。
    - 否则，为了得到指定的大小这个函数压入相应个数的空值（nil）到栈上。

lua_settop(L,0)清空堆栈。

函数 lua_pushvalue 压入堆栈上指定索引的一个抟贝到栈顶；
lua_remove 移除指定索引位置的元素，并将其上面所有的元素下移来填补这个位置的空白；
lua_insert 移动栈顶元素到指定索引的位置，并将这个索引位置上面的元素全部上移至栈顶被移动留下的空隔；
最后，lua_replace 从栈顶弹出元素值并将其设置到指定索引位置，没有任何移动操作。

```c
static void stackDump (lua_State *L) {
    int i;
    int top = lua_gettop(L);
    for(i=1;i<=top;i++){ /*repeatforeachlevel*/
        int t = lua_type(L, i);
        switch (t) {
        case LUA_TSTRING: /* strings */
            printf("`%s'", lua_tostring(L, i));
            break;
        case LUA_TBOOLEAN: /* booleans */
            printf(lua_toboolean(L, i) ? "true" : "false");
            break;
        case LUA_TNUMBER: /* numbers */
            printf("%g", lua_tonumber(L, i));
            break;
        default: /* other values */
            printf("%s", lua_typename(L, t)); 
            break;
    }
    printf(" "); /* put a separator */ }
    printf("\n"); /* end the listing */
}

int main (void) {
    lua_State *L = lua_open();
    lua_pushboolean(L, 1); lua_pushnumber(L, 10);
    lua_pushnil(L); lua_pushstring(L, "hello");
    stackDump(L);
    /* true 10 nil `hello' */
    lua_pushvalue(L, -4); stackDump(L);
    /* true 10 nil `hello' true */
    lua_replace(L, 3); stackDump(L);
    /* true 10 true `hello' */
    lua_settop(L, 6); stackDump(L);
    /* true 10 true `hello' nil nil */
    lua_remove(L, -3); stackDump(L);
    /* true 10 true nil nil */
    lua_settop(L, -5); stackDump(L);
    /* true */
    lua_close(L);
    return 0;
}
```

### 24.3 C API 的错误处理

当我们写一个库代码时（也就是被 Lua 调用的 C 函数）长跳转（long jump）的用处几乎和一个真正的异常处理一样的方便，因为 Lua 抓取了任务偶然的错误。

panic 函数
lua_pcall
lua_cpcall
luaL_error

## 25.调用 lua 函数

## 26. 调用 C 函数

```c
lua_pushcfunction(l, l_sin);
lua_setglobal(l, "mysin");

static int l_sin (lua_State *L) {
    double d = luaL_checknumber(L, 1);
    lua_pushnumber(L, sin(d));
    return 1; /* number of results */
}

// C函数库
LUAMOD_API int
luaopen_rmq_core(lua_State *L) {
    luaL_Reg l[] = {
        { "lwrite", lrmq_write },
        { "pack", lrmq_pack },
        { "unpack", lrmq_unpack },
        { "bind", lrmq_bind },
        { NULL, NULL },
    };
    luaL_checkversion(L);
    luaL_newlib(L,l);

    return 1;
}
```

## 28. user-defined types in C

接口访问形式:

```lua
a = array.new(1000)
print(a) --> userdata: 0x8064d48
print(array.size(a)) --> 1000
for i=1,1000 do
array.set(a, i, 1/i)
end
```

```C

static int newarray (lua_State *L) {
    int n = luaL_checkint(L, 1);
    size_t nbytes = sizeof(NumArray) + (n - 1)*sizeof(double);
    NumArray *a = (NumArray *)lua_newuserdata(L, nbytes);
    luaL_getmetatable(L, "LuaBook.array");
    lua_setmetatable(L, -2);
    a->size = n;
    return 1; /* new userdatum is already on the stack */
}

static NumArray *checkarray (lua_State *L) {
    void *ud = luaL_checkudata(L, 1, "LuaBook.array");
    luaL_argcheck(L, ud != NULL, 1, "`array' expected");
    return (NumArray *)ud;
}

static int getsize (lua_State *L) {
    NumArray *a = checkarray(L);
    lua_pushnumber(L, a->size);
    return 1;
}

static double *getelem (lua_State *L) {
    NumArray *a = checkarray(L);
    int index = luaL_checkint(L, 2);
    luaL_argcheck(L, 1 <= index && index <= a->size, 2,
    "index out of range");
    /* return element address */
    return &a->values[index - 1];
}

static int setarray (lua_State *L) {
    double newvalue = luaL_checknumber(L, 3);
    *getelem(L) = newvalue;
    return 0;
}
static int getarray (lua_State *L) {
    lua_pushnumber(L, *getelem(L));
    return 1;
}

static const struct luaL_reg arraylib_f [] = {
    {"new", newarray},
    {NULL, NULL}
};
static const struct luaL_reg arraylib_m [] = {
    {"__tostring", array2string},
    {"set", setarray},
    {"get", getarray},
    {"size", getsize},
    {NULL, NULL}
};

int array2string (lua_State *L) {
    NumArray *a = checkarray(L);
    lua_pushfstring(L, "array(%d)", a->size);
    return 1;
}

int luaopen_array (lua_State *L) {
    luaL_newmetatable(L, "LuaBook.array");
    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2); /* pushes the metatable */
    lua_settable(L, -3); /* metatable.__index = metatable */
    
    luaL_openlib(L, NULL, arraylib_m, 0);
    luaL_openlib(L, "array", arraylib_f, 0);
    return 1;
}
```

note:*luaL_openlib 的另一个特征，第一次调用，当我们传递一个 NULL作为库名时，luaL_openlib 并没有创建任何包含函数的表；相反，他认为封装函数的表在栈内，位于临时的 upvalues 的下面。*

在这个例子中，封装函数的表是 metatable 本身，也就是 luaL_openlib 放置方法的地方。*

面向对象访问形式:

```lua
a = array.new(1000)
print(a:size()) --> 1000
a:set(10, 3.4)
print(a:get(10)) --> 3.4
```

## 29. 资源管理

```C
#include <dirent.h>
#include <errno.h>
/* forward declaration for the iterator function */
static int dir_iter (lua_State *L);
static int l_dir (lua_State *L) {
    const char *path = luaL_checkstring(L, 1);
    /* create a userdatum to store a DIR address */
    DIR **d = (DIR **)lua_newuserdata(L, sizeof(DIR *));
    /* set its metatable */
    luaL_getmetatable(L, "LuaBook.dir");
    lua_setmetatable(L, -2);
    /* try to open the given directory */
    *d = opendir(path);
    if (*d == NULL) /* error opening the directory? */
    luaL_error(L, "cannot open %s: %s", path,
    strerror(errno));
    /* creates and returns the iterator function
        (its sole upvalue, the directory userdatum,
        is already on the stack top */
    lua_pushcclosure(L, dir_iter, 1);
    return 1;
}

static int dir_iter (lua_State *L) {
    DIR *d = *(DIR **)lua_touserdata(L, lua_upvalueindex(1));
    struct dirent *entry;
    if ((entry = readdir(d)) != NULL) {
    lua_pushstring(L, entry->d_name);
    return 1;
    }
    else return 0; /* no more values to return */
}

static int dir_gc (lua_State *L) {
    DIR *d = *(DIR **)lua_touserdata(L, 1);
    if (d) closedir(d);
    return 0;
}

int luaopen_dir (lua_State *L) {
    luaL_newmetatable(L, "LuaBook.dir");
    /* set its __gc field */
    lua_pushstring(L, "__gc");
    lua_pushcfunction(L, dir_gc);
    lua_settable(L, -3);
    /* register the `dir' function */
    lua_pushcfunction(L, l_dir);
    lua_setglobal(L, "dir");
    return 0;
}
```