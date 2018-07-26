#include <pthread.h>

class thisclass{

private:

    static void* doSomething(void* arg)
    {
        thisclass* pInstance = (thisclass*) arg;

        pthread_barrier_wait(pInstance->barrier);//所有线程都被阻塞在这里

        //下面是线程具体要做的事
        //...
    }

protected:

    pthread_barrier_t barrier;
    int thread_num; // = 100;
    pthread_t* thread;

public:

    int init()
    { 
        //生成100个等待的线程
        int ret = -1;

        pthread_attr_t attr;
        pthread_attr_init(&attr);

        do{
            if( thread_num == 0 || (thread = (pthread_t*)malloc(thread_num *sizeof(pthread_t))) == NULL)
                break;

            pthread_barrier_init(&barrier, NULL, thread_num+1); //100+1个等待

            for(i = 0; i < thread_num; i++)
                if (pthread_create(thread+i, &attr, doSomething, this)) 
                    break; //100个create成功的线程都进入上面的doSomething函数执行

            if(i!= thread_num) 
                break;

            ret= 0;

        } while(false)

        return ret;
    }

    int activate()
    {   
        //等一切都安排好了调用该函数。起跑枪“砰！”
        pthread_barrier_wait(barrier);
        return 0;
    }
}