# note-book note

## 二叉树

```C++
// 二叉树前序遍历
template<class DataType>
void BiTree<DataType>::PreOrder(BiNode<DataType> *bt) {
    if (bt == NULL) return;
    else {
        count << bt->data;
        PreOrder(bt->lchild);
        PreOrder(bt->rchild);
    }
}

// 中序遍历
template<class DataType>
void BiTree<DataType>::InOrder(BiNode<DataType> *bt) {
    if (bt == NULL) return;
    else {
        InOrder(bt->lchild);
        count << bt->data;
        InOrder(bt->rchild);
    }
}

// 层序遍历
template<class DataType>
void BiTree<DataType>::levelOrder() {
    front = rear = -1;
    if (root == NULL) return;
    Q[++rear] = root;
    while (front != rear) {
        q = Q[++front];
        count = q->data;
        if (q->lchild != NULL) Q[++rear] = q->lchild;
        if (q->rchild != NULL) Q[++rear] = q->rchild;
    }
}
```

## 二叉链表

```C++
template<class DataType>
BiNode<DataType>* BiTree<DataType>::Create(BiNode<DataType>* bt) {
    cin >> ch;
    if (ch == 'H') bt == NULL;
    else {
        bt = new BiNode;
        bt->data = ch;
        bt->lchild = Create(bt->lchild);
        bt->rchild = Create(bt->rchild);
    }
    return bt;
}

// 前序遍历 非递归
template<class DataType>
void BiTree<DataType>::PreOrder(BiNode<DataType>* bt) {
    top = -1;
    while (bt != NULL || top != -1) {
        while (bt != NULL) {
            count << bt->data;
            s[top] = bt;
            bt = bt->lchild;
        }
        if (top != -1) {
            bt = s[top--];
            bt = bt->rchild;
        }
    }
}

template<class DataType>
void BiTree<DataType>::InOrder(BiNode<DataType>* bt) {
    top = -1;
    while (bt != NULL || top != -1) {
        while (bt != NULL) {
            s[++top]= bt;
            bt = bt->lchild;
        }
        if (top != -1) {
            bt = s[top--];
            count << bt->data;
            bt = bt->rchild;
        }
    }
}
```

## 试题

- 除以7 余数
- n = n & (n-1) 二进制 1 的个数

## 引用 与 指针

- 指针实体 引用别名
- 引用使用无需解引用 指针需要解引用
- 引用在定义时被初始化一次 之后不可变 指针可变
- 引用没有 const 指针有 const
- 引用不为空 指针可为空
- 指针需分配内存 引用不需要

## 二叉排序树

- 原理

查找技术:
    线性表
        顺序 O(n)
        折半 log2(n+1)-1 O(log2n)
    树表
        二叉排序树
        平衡二叉树
    散列表

```C++
// 二叉排序树 删除
void BiSortTree::DeleteBST(BiNode<int>* p, BiNode<int>* f) {
    if ((p->lchild == NULL) && (p->rchild == NULL)) {
        f->lchild =NULL;
        delete p;
    } else {
        // todo
    }
}

```

## 循环双向链表 插入 删除

插入排序

- 直接插入排序 $O(n^2)$
- 希尔排序  $O(n\log_{2}n)$~$O(n^2)$

交换排序

- 冒泡 $O(n^2)$
- 快排 $O(nlog_{2}n)$

选择排序 $O(n^2)$

- 堆排 $O(nlog_{2}n)$
- 归并 $O(nlog_{2}n)$

分配排序

- 桶排 $O(N+M)$