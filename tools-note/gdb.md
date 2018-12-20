# gdb

## start

> gdb programname / gdb programname corefile
> gdb programname -symbol 符号表 -core corefile -directory srccodePath

## cmd

> list : source code
> break n
> break func
> break ... if i = 100
> info break

---
> run / r
> next / n
> continue / c
> print / p
> bt
> finish 运行到当前函数结束
> 编译时 -g 将看不见 函数名 变量名, 只看到内存地址
> gdb中 执行 shell cmd: make
> set args ...
> show args ...
> path 指定运行路径
> show path
> info terminal
> run > outfile
> info programname

---
> breakpoint, watchpoint, catchpoint, signals,thread stop
> watch expr
> rwatch expr 被读时暂停
> awatch expr 被读写时暂停
> info watchpoint

---
> catch throw
> catch catch
> catcg exec
> catch fork/vfork
> catch load/unload
