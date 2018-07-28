# 锁无关的数据结构与Hazard指针 - 操纵有限的资源

> By Andrei Alexandrescu and Maged Michael
>
> 刘未鹏(pp_liu@msn.com) 译

```text
Andrei Alexandrescu是华盛顿大学计算机科学系的在读研究生，也是《Modern C++ Design》一书的作者。他的邮箱是 andrei@metalanguage.com。

Maged Michael是IBM的Thomas J.Watson研究中心的研究员。
```

首先，我很荣幸向大家介绍Maged Michael，Maged Michael和我共同撰写了本期的Generic<Programming>，他是锁无关（Lock-Free）算法方面的权威，而且对一些困难问题[3]提出了令人惊讶的独创性方案。在你将要阅读的这篇文章中我们就会向你呈上这么一项激动人心的技术。下文将要介绍的算法通过操纵手头有限的资源，以一种近乎神奇的方式达到了其目的。

如果把Generic<Programming>栏目比作肥皂剧的话，这一集中那些反派角色将会被轰走（译注：很遗憾，这位C++大师的幽默水平似乎很crappy，每当看到这类joke我都只能无语）。为了帮你回忆一下这里所谓的“反派角色”是谁，我们回顾一下上期的文章[1]。（下面我先帮你做一个简要回顾，但再后面的内容要求你对上期的文章至少做过一遍粗略的阅读，并且大致知道我们要去解决的问题是什么。）

上期的文章中，在引入了锁无关编程的概念之后我们曾实现了一个锁无关的WRRM（Write-Rarely-Read-Many）Map。我们经常看到这类数据结构以全局表、工厂对象、高速缓存(cache)等形式出现。我们遇到的问题在于内存的回收：既然我们的数据结构得是锁无关的，那么我们该如何来回收内存呢？正如前面讨论过的，这是个棘手的问题，因为锁无关意味着任何线程在任何时候都有不受限的机会去操作任何对象。为了解决这一问题，上篇文章中曾作了以下几点尝试：

对map使用引用计数。该策略是注定要失败的，因为它要求对指针和引用计数变量（它们在内存中处于不同的地方）同时进行（原子地）更新。尽管有少数论文使用了DCAS(Double Compare-And-Swap，该指令的行为正是这里所需要的)，然而这个东西从来也没能流行起来，因为没有它我们照样能够做许多事情，而且它也没有强大到能够高效地实现出任意事务的程度。参考[2]关于DCAS的用途的讨论。
等待并delete。一旦“清理”线程知道某个指针要被delete掉了，它就可以等待一段“足够长的时间”然后delete它。然而问题是这段“足够长的时间”到底应该有多长呢？所以说这个方案听上去跟“分配一块足够大的缓冲区”一样蹩脚，后者怎么样大家是知道的。
将引用计数跟指针紧挨着存放在一起。这个方案使用了要求较少，可以合理实现的CAS2原语，CAS2能够原子地Compare-and-Swap内存中的两个紧邻的字。大多数32位机器都支持这一原语，只不过支持它的64位机器倒没那么多了，不过对于后一种情况我们可以在指针内的位上面做点文章来解决这个问题）。
上面提到的最后一个方案被证明是可行的，只不过它却将我们的漂亮的WRRM Map变成了一个粗陋的WRRMBNTM(Write-Rarely-Read-Many-But-Not-Too-Many) Map，因为其写操作需要等到绝对没有任何读操作正在进行的时候才会去写。这就意味着，只要有一个读操作在所有其它读操作结束之前开始了，写操作就只能干等。而这就不能算是锁无关了。

Bullet探长走进了他的债务人的办公室，坐下，点燃一枝雪茄，以一种绝对冷静的、足以将整个沸腾的办公室冰冻住的声音说道：“除非拿回我的钱，否则我是不会走的。”

基于引用计数的一个可行方案是将引用计数变量跟指针分离开来。这样写操作就不再被读操作所阻塞了，不过它们仍只能在引用计数降为0时才能去delete旧的map[5]。此外，如果采用此方案，我们就只需使用针对单字的CAS，这就使我们的技术可移植于不同的硬件架构之间，包括那些不支持CAS2的。然而，该方案仍存在问题：即我们并没有消除等待，而只不过是将它延期了，这便增加了内存占用方面的问题发生的几率。

Bullet探长怯怯地敲开他的债务人的办公室的门，吞吞吐吐的问：“您现在可以还我的19,990块钱了吗？没有？噢，好吧，好吧。这里是我仅剩的10块钱，给。过些时日我再过来，看看你有没有我的20,000块钱。”

在这种方案下，写函数可能会保留任意多个未被回收的旧map，并眼巴巴的等着（可能会一直等下去）它们的引用计数变成0。换句话说，即使仅有一个读线程被延迟也可能会导致任意量的内存无法被回收，而且该线程拖得越久，情况就越遭。

我们真正需要的是这么一种机制，基于它，读线程可以告诉写线程别在它们的眼皮子底下回收某些旧map，同时读线程还不能强迫写线程在那等着释放一堆也许是任意数量的旧map。实际上，存在着一个不仅是锁无关、而且还是等待无关的解决方案。（回忆一下上期文章中的定义：锁无关意味着系统中总存在某个线程能够得以继续执行；而等待无关则是一个更强的条件，它意味着所有线程都能往下进行。）而且该方案并不要求用到什么特殊的操作，如DCAS、CAS2之类，它只需使用我们可以信赖的CAS原语即可。开始感到有点意思了吧？那就继续往下读。

## Hazard指针

回顾一下上期文章中的代码，我们有一个模板的WRRMMap，它内部有一个指向某个经典的单线程Map对象（如std::map）的指针，同时它还向外界提供了一个多线程的、锁无关的访问接口：

```C++
template <class K, class V>

class WRRMMap {

   Map<K, V> * pMap_;

   ...

};
```

每当WRRMMap需要更新的时候，想要对它进行更新的线程就会首先创建它的一个完整的副本，更新副本，然而再将pMap_指向该副本，最后delete掉pMap_原先所指的旧map。我们认为这种做法算不上低效，因为WRRMMap通常只是被读取，很少被更新。然而，麻烦的问题是我们怎样才能妥善地将旧的pMap_销毁掉，因为任何时候都可能有其它线程正在对它们进行读取。

Hazard指针就是我们所采用的技术，借助于Hazard指针，线程就得以安全高效地将它们的内存使用告知所有其它线程。每一读线程都拥有一个“单个写线程/多个读线程”的共享指针，这便是所谓的“Hazard指针”。当一个读线程将一个map的地址赋给它的hazard指针时，即意味着它在向其它（写）线程宣称：“我正在读该map，如果你原意，你可以将它替换掉，但别改动它的内容，当然更不要去delete它。”

而站在写线程的立场来看，写线程在delete任何被替换下来的旧map之前须得检查读线程的hazard指针（看看该旧的map是否仍在被使用）。也就是说，如果一个写线程是在一个（或多个）读线程已将某个特定map挂到它（们）的hazard指针上之后才将该map替换下来的，那么该写线程就只有等到那些读线程的hazard指针被release之后才能去delete被替换掉的旧map。

每当一个写线程替换某个map的时候，它会将替换下来的旧map放入一个私有链表中。直到该链表中的旧map达到一定数量的时候（待会我们会讨论这个数量的上限是如何选取的），写线程就会扫描读线程的hazard指针，看看旧map列表中有哪些是与这些hazard指针匹配的。如果某个旧map不与任何读线程的hazard指针匹配，那么销毁该map就是安全的。否则写线程就会仍将其保留在链表中，直到下次扫描。

下面就是我们将要使用的数据结构。主要的共享结构是一个关于hazard指针（HPRecType）的单链表，由pHead_所指向。该链表中的每一项都包含一个hazard指针（pHazard_）、一个标志着该hazard指针是否正处于使用中的flag（active_）、以及一个指向下一节点的指针（pNext_）。

HPRecType类提供了两个原语：Acquire和Release。HPRecType::Acquire返回一个指向一个HPRecType节点的指针，姑且称其为p。如此一来，获取了该指针的线程就可以设置p->pHazard_，并以此确保其它线程会小心对待该指针。而当该线程不再使用该指针时，它就会调用HPRecType::Release(p)。

```C++
// Hazard pointer record

class HPRecType {

   HPRecType * pNext_;

   int active_;

   // Global header of the HP list

   static HPRecType * pHead_;

   // The length of the list

   static int listLen_;

public:

   // Can be used by the thread

   // that acquired it

   void * pHazard_;

   static HPRecType * Head() {

      return pHead_;

   }

   // Acquires one hazard pointer

   static HPRecType * Acquire() {

      // Try to reuse a retired HP record

      HPRecType * p = pHead_;

      for (; p; p = p->pNext_) {

         if (p->active_ ||

            !CAS(&p->active_, 0, 1))

           continue;

         // Got one!

         return p;

      }

      // Increment the list length

      int oldLen;

      do {

         oldLen = listLen_;

      } while (!CAS(&listLen_, oldLen,

          oldLen + 1));

      // Allocate a new one

      HPRecType * p = new HPRecType;

      p->active_ = 1;

      p->pHazard_ = 0;

      // Push it to the front

      do {

         old = pHead_;

         p->pNext_ = old;

      } while (!CAS(&pHead_, old, p));

      return p;

   }

   // Releases a hazard pointer

   static void Release(HPRecType* p) {

      p->pHazard_ = 0;

      p->active_ = 0;

   }

};

// Per-thread private variable

__per_thread__ vector<Map<K, V> *> rlist;
```

每个线程都拥有一个“退役链表”（在我们的实现中，这实际上就是一个vector<Map<K,V>*>），“退役链表”是一个容器，负责存放该线程不再需要的、一旦其它线程也不再使用它们就可以被delete掉的指针。“退役链表”的访问不需要被同步，因为它位于每线程存储区中；永远都只有一个线程（即拥有它的线程）能访问它。我们使用__per_thread__修饰符来省却分配线程相关存储的麻烦。通过这一办法，每当一个线程想要销毁旧的pMap_时，它就只需要调用Retire函数即可。（注意，正如上期文章中提到的，为了简单起见，我们并未在代码中插入内存屏障。）

```C++
template <class K, class V>

class WRRMMap {

   Map<K, V> * pMap_;

   ...

private:

   static void Retire(Map<K, V> * pOld) {

   // put it in the retired list

   rlist.push_back(pOld);

   if (rlist.size() >= R) {

      Scan(HPRecType::Head());

      }

   }

};
```

毫无隐瞒，就这些！现在，我们的Scan函数会进行一个差集计算的算法，即当前线程的“退役链表”作为一个集合，其它所有线程的hazard指针作为一个集合，求它们两个的差集。那么，这个差集的意义又是什么呢？让我们停下来考虑一下：前一个集合是当前线程所认为没有用的旧map指针，而后一集合则代表那些正被某个或某几个线程使用着的旧map指针（即那些线程的hazard指针所指的map）但是后者相当于“濒死”指针！根据“退役链表”和hazard指针的定义，如果一个指针“退役”了并且没有被任何一个线程的hazard指针所指（使用）的话，该指针所指的旧map就是可以被安全地销毁的。换言之，第一个集合与第二个集合的差集正是那些可被安全销毁的旧map的指针。

## 主算法

OK，现在就让我们来看看如何实现Scan算法，以及它能够提供什么样的保证。在进行Scan时，我们需要对rlist（退役链表）跟pHead（Hazard指针链表）所代表的两个集合作差集运算。换言之：“对于退役链表中的每个指针，检查它是否同样位于hazard指针链表（pHead）中，如果不是，则它属于差集，即可被安全销毁。”此外，为了对该算法加以优化，我们可以在进行查找之前先对Hazard指针链表进行排序，然后对每个退役指针在其中进行二分查找。下面就是Scan的实现：

```C++
void Scan(HPRecType * head) {

   // Stage 1: Scan hazard pointers list

   // collecting all non-null ptrs

   vector<void*> hp;

   while (head) {

      void * p = head->pHazard_;

      if (p) hp.push_back(p);

      head = head->pNext_;

   }

   // Stage 2: sort the hazard pointers

   sort(hp.begin(), hp.end(),

      less<void*>());

   // Stage 3: Search for'em!

   vector<Map<K, V>*>::iterator i =

      rlist.begin();

   while (i != rlist.end()) {

      if (!binary_search(hp.begin(),

         hp.end(),

         *i) {

         // Aha!

         delete *i;

         if (&*i != &rlist.back()) {

            *i = rlist.back();

         }

      rlist.pop_back();

      } else {

         ++i;

      }

   }

}
```

最后一个循环做了实际的工作。其中运用了一点小小的技巧来避免rlist vector的重排：在delete了rlist中的一个可被删除的指针之后，我们将那个指针的位置用rlist的最后一个元素来填充，然后再将实际的最后一个元素pop掉。这样做是允许的，因为rlist中的元素并不要求有序。此外我们使用了C++标准库函数sort跟binary_search。不过你可以将vector换成你所喜欢的容器，如哈希表这类易于搜索的数据结构。一个均衡的哈希表的期望查找时间是常数，而且建造这样一个哈希表也很容易，因为它是完全私有的，而且在组织它之前你知道其中所有的值。

那么，Scan的效率又如何呢？首先，注意到这整个算法是等待无关的（正如上文所介绍的那样）：每个线程的执行时间都不依赖于其它任何线程的行为。

其次，rlist的平均大小是一个任意值，记为R，我们将该值用作触发Scan的阈值（见上文代码中的WRRMMap<K,V>::Replace函数）。如果我们将hazard指针存放在一个哈希表中（而不是原先用的有序vector），那么Scan算法的期望复杂度就可以降为O(R)。最后，已退役但尚存活在系统中（未被delete）的旧map的最大数目是N*R，其中N为写线程的数目（译注：因为只有写线程才会将旧map替换下来，而每个写线程都有一个私有的rlist退役链表，其最大长度为R）。至于R的具体值，一个良好的选择是(1+K)H，其中H为hazard指针的数目（即我们的代码中的listLen，在我们的例子中这也就是读线程的数目（因为每个读线程有且仅有一个Hazard指针）），而K则是某个小的正常数，如1/4。因此R大于H且与H成正比。这样一来，每次Scan都能保证delete掉R-H（即O(R)）个节点（旧map），而如果我们使用的是哈希表的话，时间复杂度就是O(R)。因此，确定一个节点是否可被安全销毁的分摊时间复杂度为常数。

缝合WRRMMap

下面我们就来把hazard指针缝合进WRRMMap的原语，即Lookup和Update中。对于写线程（执行Update的线程）来说，它们所需要做的就是在正常情况下应当delete pMap_的地方改成调用WRRMMap<K,V>::Retire。

```C++
void Update(const K&k, const V&v){

   Map<K, V> * pNew = 0;

   do {

      Map<K, V> * pOld = pMap_;

      delete pNew;

      pNew = new Map<K, V>(*pOld);

      (*pNew)[k] = v;

   } while (!CAS(&pMap_, pOld, pNew));

   Retire(pOld);

}
```

读线程首先得通过HPRecType::Acquire获得一个Hazard指针，并将其赋为pMap_，以便写线程可以查找到。当读线程使用完毕该指针之后，就通过HPRecType::Release来释放对应的Hazard指针。

```C++
V Lookup(const K&k){

   HPRecType * pRec = HPRecType::Acquire();

   Map<K, V> * ptr;

   do {

      ptr = pMap_;

      pRec->pHazard_ = ptr;

   } while (pMap_ != ptr);

   // Save Willy

   V result = (*ptr)[k];

   // pRec can be released now

   // because it's not used anymore

   HPRecType::Release(pRec);

   return result;

}
```

在上面的代码中，为什么读线程需要重新检查pMap_是否等于ptr呢（while(pMap_!=ptr)）？考虑下面这种情况：pMap_原先指向map m，读线程将ptr赋为pMap_，也就是&m，接着读线程就进入了休眠（此时它还未来得及将hazard指针指向m）。而就在它的休眠期间，一个写线程偷偷溜进来，更新了pMap_，然后将pMap_原先所指的map（即m）放到了退役链表中，并紧接着检查各线程的hazard指针，由于刚才的读线程在进入休眠时还未来得及设置hazard指针，故m被认为是可以销毁的旧map，于是被写线程销毁。而这时读线程醒来了，并接着未完成的工作，将Hazard指针赋为ptr(即&m)。如果是这样的话，一旦读线程接下来对ptr进行解引用，它就会读取到被破坏的数据或访问了未被映射的内存。以上就是读线程需要再次检查pMap_的原因。如果结果发现pMap_并不等于&m的话，读线程就无法确定将m退役掉的写线程是否看到了它的hazard指针被置为&m（换句话说，是否已将m销毁）。所以此时读线程继续对m进行读取就是不安全的，所以读线程需要从头来过。

如果读线程而后发现pMap_的确指向m，那么此时从m读取就是安全的。那么，这是否意味着在两次读取pMap_之间，pMap_没有被改动过呢？不一定，在这期间m可能被移除并再次挂到pMap_上（一次或多次），但这并不要紧。要紧的是在第二次读取的时候m挂在pMap_上，而此时读线程的hazard指针也已经指向它了。因此从这个点以后（知道hazard指针被改变），访问m都是安全的。

这样Lookup和Update就都成了锁无关的（不过，仍不是等待无关的）：读线程不会阻塞写线程，多个读线程之间也不会互相撞车（这一点是引用计数方案所做不到的）。所以，我们得到了一个完美的WRRM Map：读取操作非常快，而且不会互相冲突，更新操作仍然很快，而且能够保证整体进展。

如果我们想要Lookup成为等待无关的，我们可以使用“陷阱”（trap）技术[4]，它是基于hazard指针的一门技术。在前面的代码中，当读线程将其hazard指针赋为ptr时，它其实是想捕获某个特定的map（*ptr）。而使用陷阱技术，读线程就可以设置一个“陷阱”，该“陷阱”保证能够捕获住某个有效的map，这样Lookup就成了等待无关的算法，同样，如果我们有自动垃圾收集机制的话，Lookup也是等待无关的（参考专栏上一期的文章）。要想了解“陷阱”技术的细节，可参卡[4]。

## 泛化

到这里为止，我们几乎已经完成了一个坚实的map设计。不过还有一些事情需要考虑，以便让你对该技术形成一个全面的认识。完整的参考见[3]。

我们已经知道如何才能共享一个map，然而倘若我们想要共享的是许多个对象呢？答案很简单：首先，我们的算法可以自然的推广到每线程多个hazard指针的情况。不过，通常在任何特定的时刻，一个线程需要同时保护的指针数目是非常有限的。此外，hazard指针可以被“重载”（因为它们的类型是void*）：一个线程可以将同一个hazard指针用在任何数目的数据结构身上，只要满足同一时刻hazard指针只被用于其中某一个数据结构这一条件即可。大多数时候，每线程拥有一个或两个hazard指针对于整个程序来说就已经足够了。

最后注意一下，Lookup在完成了一次lookup之后立即调用了HPRecType::Release。在一个考虑性能因素的应用程序中，我们可以只获取hazard指针一次，并用它来进行多次lookup，最后才释放它（一次）。

## 结论

长久以来人们一直试图解决锁无关算法的内存释放问题，有时人们甚至觉得对于这个问题并不存在令人满意的答案。然而，实际上我们只需作一点小小的辅助性工作，同时在线程私有跟线程共享数据之间小心操作，我们就能够创造出一种在速度和内存占用方面皆给出了强大且令人满意的保证的算法。此外，尽管我们通篇使用了WRRMMap作为例子，但hazard指针技术实际上能够被运用到复杂得多的数据结构上。对于那些大小可以任意扩充和缩小的动态数据结构来说内存回收问题则更显重要；例如，设想一个拥有上千个链表、其中每个链表的大小都可能增长为上百万个节点的程序，这种场合正是hazard指针展现其强大身手的地方。

一个读线程所能干的最糟糕的事情就是在未能将它的hazard指针置为空的情况下就中止了，这会导致它的每个hazard指针所指向的对象永远也不能被释放。

Bullet探长冲进了他的债务人的办公室，并立即认识到他今天是不可能拿回他的钱了。于是他立即说道：“伙计，你已经上了我的黑名单了。日后我会再来拜访你，除非你死了。而且就算你‘不幸’故去，你欠的债也将不会超过100块。再见！”

---

References

[1] Alexandrescu, Andrei. "Generic<Programming>: Lock-Free Data Structures," C++ Users Journal, October 2004.

[2] Doherty, Simon, David L. Detlefs, Lindsay Grove, Christine H. Flood, Victor Luchangco, Paul A. Martin, Mark Moir, Nir Shavit, and Jr. Guy L. Steele. "DCAS is not a silver bullet for nonblocking algorithm design." Proceedings of the Sixteenth Annual ACM Symposium on Parallelism in Algorithms and Architectures, pages 216-224. ACM Press, 2004. ISBN 1-58113-840-7.

[3] Michael, Maged M. "Hazard Pointers: Safe Memory Reclamation for Lock-Free Objects," IEEE Transactions on Parallel and Distributed Systems, pages 491-504. IEEE, 2004.

[4] Michael, Maged M. "Practical Lock-Free and Wait-Free LL/SC/VL Implementations Using 64-Bit CAS," Proceedings of the 18th International Conference on Distributed Computing, LNCS volume 3274, pages 144-158, October 2004.

[5] Tang, Hong, Kai Shen, and Tao Yang. "Program Transformation and Runtime Support for Threaded MPI Execution on Shared-memory Machines," ACM Transactions on Programming Languages and Systems, 22(4):673-700, 2000 (citeseer.ist.psu.edu/tang99program.html).