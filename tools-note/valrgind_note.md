# valgrind note

## Valgrind包括如下一些工具：

- Memcheck。这是valgrind应用最广泛的工具，一个重量级的内存检查器，能够发现开发中绝大多数内存错误使用情况，比如：使用未初始化的内存，使用已经释放了的内存，内存访问越界等。这也是本文将重点介绍的部分。
- Callgrind。它主要用来检查程序中函数调用过程中出现的问题。
- Cachegrind。它主要用来检查程序中缓存使用出现的问题。
- Helgrind。它主要用来检查多线程程序中出现的竞争问题。
- Massif。它主要用来检查程序中堆栈使用中出现的问题。
- Extension。可以利用core提供的功能，自己编写特定的内存调试工具。

## 一个典型的Linux C程序内存空间由如下几部分组成：

- 代码段（.text）。这里存放的是CPU要执行的指令。代码段是可共享的，相同的代码在内存中只会有一个拷贝，同时这个段是只读的，防止程序由于错误而修改自身的指令。
- 初始化数据段（.data）。这里存放的是程序中需要明确赋初始值的变量，例如位于所有函数之外的全局变量：int val=100。需要强调的是，以上两段都是位于程序的可执行文件中，内核在调用exec函数启动该程序时从源程序文件中读入。
- 未初始化数据段（.bss）。位于这一段中的数据，内核在执行该程序前，将其初始化为0或者null。例如出现在任何函数之外的全局变量：int sum;
- 堆（Heap）。这个段用于在程序中进行动态内存申请，例如经常用到的malloc，new系列函数就是从这个段中申请内存。
- 栈（Stack）。函数中的局部变量以及在函数调用过程中产生的临时变量都保存在此段中。

## Valgrind 使用

- 第一步：准备好程序
    为了使valgrind发现的错误更精确，如能够定位到源代码行，建议在编译时加上-g参数，编译优化选项请选择O0，虽然这会降低程序的执行效率。
- 第二步：在valgrind下，运行可执行程序。
    利用valgrind调试内存问题，不需要重新编译源程序，它的输入就是二进制的可执行程序。调用Valgrind的通用格式是：valgrind [valgrind-options] your-prog [your-prog-options]