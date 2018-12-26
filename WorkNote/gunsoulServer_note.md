# gunsoul Server note

## player服务 与 playerDao 与 hibernate 注解

```java
@Service
public class PlayerService {
    private IPlayerService basePlayerService;
    ...
}

@Service
public class BasePlayerService extends UniversalManagerImpl implements IPlayerService {
    @javax.annotation.Resource
    private IPlayerDao dao;
    ...
}

@Repository
public class PlayerDao extends UniversalDaoHibernate implements IPlayerDao {
     /**
     * 根据账户id，返回相对应玩家列表
     *
     * @param gameAccountId 据账户id
     * @return              玩家列表
     */
    @SuppressWarnings("unchecked")
    public List<Player> getPlayerList(int gameAccountId) {
        StringBuffer hsql = new StringBuffer();
        hsql.append(" FROM Player WHERE 1 = 1 ");
        hsql.append(" AND gameAccountId = ? ");
        return getList(hsql.toString(), new Object[] { gameAccountId});
    }

    /**
     * 根据分区账号ID获取玩家信息
     * @param gameAccountId     分区账号ID
     * @return                  玩家信息(id，name)
     */
    @SuppressWarnings("unchecked")
    public List<Object[]> getPlayerInfoList(int gameAccountId) {
        StringBuffer hsql = new StringBuffer();
        hsql.append("SELECT id, name FROM Player WHERE 1 = 1 ");
        hsql.append(" AND gameAccountId = ? ");
        return getList(hsql.toString(), new Object[] { gameAccountId});
    }
    ...
}

@Entity
@Table(name = "tab_player")
@Message
public class Player implements java.io.Serializable {
    private static final long serialVersionUID = 1L;
    // Fields
    private Integer id;

    /** default constructor */
    public Player() {
    }

    public Player(int id) {
        this.id = id;
    }

    // Property accessors
    @Id
    @GenericGenerator(name = "tp_id", strategy = "assigned")
    @GeneratedValue(generator = "tp_id")
    @Column(name = "tp_id")
    public Integer getId() {
        return this.id;
    }
```

PlayerDao getPlayerList方法中的 hsql `from Player`中的 player 就是Player 类 具体参阅 [Hibernate注解使用以及Spring整合](https://www.cnblogs.com/younggun/archive/2013/05/19/3086659.html)

## World Server main mina 网络通信应用框架

```java
public class Server {
    public static void main(String[] args) {
    }

    static class ConnectSessionHandler extends WorldHandler {
        public ConnectSessionHandler(SessionRegistry paramSessionRegistry, ThreadService threadService) {
            super(paramSessionRegistry, threadService);
        }

        @Override
        public Session createSession(IoSession session) {
            return new ConnectSession(session);
        }
    }
}

public abstract class WorldHandler implements IoHandler {
    @Override
    public void sessionCreated(IoSession session) throws Exception {
    }

    public Session sessionCreated2(IoSession session) throws Exception {
        Session s = createSession(session);
        if (s != null) {
            this.registry.registry(s);
            s.created();
            return s;
        } else {
            return null;
        }
    }

    @Override
    public void sessionIdle(IoSession session, IdleStatus status) throws Exception {
    }

    @Override
    public void sessionOpened(IoSession session) throws Exception {
    }

    public abstract Session createSession(IoSession paramIoSession);

    /**
     * 服务端接收到的数据
     */
    @Override
    public void messageReceived(IoSession ioSession, Object msg) throws Exception {
        AbstractData abstractData = (AbstractData) msg;
        Session session = this.registry.getSession(ioSession);
        if (session != null) {
            final IDataHandler handler = ProtocolFactory.getDataHandler(abstractData);
            if (handler == null) {
                session.handle(abstractData);
            } else {
                ConnectSession connectSession = (ConnectSession) session;
                // 设置加入队列时时间
                abstractData.setCurrentTimeMillis(System.currentTimeMillis());
                this.dealInGameThread(connectSession, abstractData, handler);
            }
        }
    }

    private void dealInGameThread(final ConnectSession connectSession, final AbstractData abstractData, final IDataHandler handler) {
    }
}
```

main 类 Server:ConnectSessionHandler 继承 WorldHandler, WorldHandler messageReceived方法找不到协议的handler 就用 ConnectSession handler

mina 框架 参考:

- [mina框架详解](https://www.cnblogs.com/duanxz/p/5143227.html)
- [I/O通信模型(BIO,NIO,AIO)](https://www.cnblogs.com/duanxz/p/5143234.html)

## ConfigService spring Hibernate DAO

```java
Class<E> clazz = configInfo.getClazz();
List<E> list;
// 如果需要排序
if (configInfo.getOrderBy() != null && configInfo.getOrderBy().length > 0) {
    list = SM.getManager().getConfigService().getAll(clazz, configInfo.getOrderBy());
} else {
    list = SM.getManager().getConfigService().getAll(clazz);
}

@Service
public class ConfigService extends UniversalManagerImpl implements IConfigService {}
```

configInfo 是MySQL表结构信息 getOrderBy返回的是表的某一列名字
getConfigService 返回 ConfigService, ConfigService 继承 UniversalManagerImpl, UniversalManagerImpl 能够获取 注册hibernate的dao Bean对象
getAll是获取整张表数据 list 就是数据列表

## 配置表

TM.java 的 effectRemarkMap 来源于 私有成员prop(str2value_CN.properties)
CPT.java  configparam 来源于 configParam.properties
worldPlayer:playerdata

```java
String[] multiEffectIds = effectIds.split(Common.SPLIT_CHART);
            String oneEffectIds;
            int len = multiEffectIds.length;
            if (len == 1) {
                oneEffectIds = multiEffectIds[0];
            } else {
                int index = RandomUtils.nextInt(0, len);
                oneEffectIds = multiEffectIds[index];
            }
String effectId;
    if (oneEffectIds.contains("-")) {
        String[] strEffectIds = oneEffectIds.split("-");
        int start = Integer.parseInt(strEffectIds[0]);
        int end = Integer.parseInt(strEffectIds[1]);
        if (start == end) {
            effectId = start + "";
        }
    }
```

## Thread Service

```java
public class ThreadService {
    private final GameExecutor[]              gameExec;
    private final ExecutorService             dbExec;
    private final ScheduledThreadPoolExecutor scheduledExec;

    public ThreadService(int gameThreadCount, int dbThreadCount) {
        dbExec = new ThreadPoolExecutor(dbThreadCount / 2, dbThreadCount, 60L,
            TimeUnit.SECONDS, new LinkedTransferQueue<Runnable>(),
            new ThreadFactory() {
                private final AtomicInteger idCounter = new AtomicInteger(0);

                @Override
                public Thread newThread(Runnable r) {
                    Thread t = new Thread(r, "DB_WORKER_" + idCounter.getAndIncrement());
                    t.setPriority(Thread.NORM_PRIORITY);
                    return t;
                }
            }
        );

        int scheduledThreadCount = 8;
        scheduledExec = new ScheduledThreadPoolExecutor(scheduledThreadCount,
            new ThreadFactory() {
                private final AtomicInteger idCounter = new AtomicInteger(0);

                @Override
                public Thread newThread(Runnable r) {
                    Thread t = new Thread(r);
                    t.setPriority(Thread.MAX_PRIORITY);
                    t.setName("UPDATE_WORKER_" + idCounter.getAndIncrement());
                    return t;
                }
            }
        );
}
```

ThreadPoolExecutor, ScheduledThreadPoolExecutor 这两个线程池

```java
public class MergeFrameService {
    private final Pair<IntHashMap<FightScene>, ReusableIterator<FightScene>>[] scenes;

    public MergeFrameService(final ThreadService threadService) {
        this.threadService = threadService;
        scenes = new Pair[threadService.getGameThreadCount()];
        for (int i = 0; i < scenes.length; i++) {
            IntHashMap<FightScene> map = new IntHashMap<FightScene>();
            scenes[i] = Pair.of(map, map.newValueIterator());
        }
        threadService.getScheduledExecutorService().scheduleAtFixedRate(
            new Runnable() {
                public void run() {
                    try {
                        for (int i = 0; i < scenes.length; i++) {
                            final Pair<IntHashMap<FightScene>, ReusableIterator<FightScene>> pair = scenes[i];
                            threadService.getExecutor(i).execute(
                                new Runnable() {
                                    public void run() {
                                        ReusableIterator<FightScene> iterator = pair.right;
                                        for (iterator.rewind(); iterator.hasNext();) {
                                            FightScene scene = iterator.next();
                                            boolean isRemove = scene.tickAndSend();
                                            if (isRemove) {
                                                iterator.remove();
                                                scene.onThisBeenRemoved(true);
                                            }
                                        }
                                        iterator.cleanUp();
                                    }
                                }
                            );
                        }
                    } catch (Throwable e) {
                        e.printStackTrace();
                    }
                }
            }, 0, Common.FRAME_PERIOD, TimeUnit.MILLISECONDS
        );// TODO 优化可以把tick分开在不同时间执行，分散系统压力
    }
}
```

## CacheConfig

```java
    /**
     * 增加其它缓存配置信息值（主要用于缓存值只有一个字段）
     *
     * @param strings 多个字段名（默认最后一个为value）
     * @throws Exception 参数出错时抛出上异常
     */
    void addOtherFieldValue(String... strings) throws Exception {
        int len = strings.length;
        if (len < 2) {
            throw new Exception("strings length error: " + strings.length);
        }
        if (otherDataMapList == null) {
            otherDataMapList = new ArrayList<>();
        }
        if (this.otherFileMap == null) {
            this.otherFileMap = new java.util.LinkedHashMap<>();
        }
        int valueIndex = len - 1;
        String[] key = new String[valueIndex];
        System.arraycopy(strings, 0, key, 0, valueIndex);
        String value = strings[valueIndex];
        this.otherFileMap.put(key, new String[]{value});
        this.otherDataMapList.add(new HashMap<>());
    }

    /**
     * 设置其它字段缓存信息
     *
     * @param configInfo       缓存配置信息
     * @param otherDataMapList 其它字段缓存信息配置信息
     * @param e                元素信息
     * @throws Exception 设置值出错时抛出此异常
     */
    private static <E> void setOtherFieldObject(ConfigInfo<E> configInfo, List<Map<Object, Object>> otherDataMapList,
            E e) throws Exception {
        Map<String[], String[]> otherFieldMap = configInfo.getOtherFileMap();
        if (otherFieldMap != null && !otherFieldMap.isEmpty()) {
            int sort = 0;
            for (Map.Entry<String[], String[]> entry : otherFieldMap.entrySet()) {
                Map<Object, Object> tempOtherMap = otherDataMapList.get(sort);
                Object keyValue = CacheUtil.getFieldKeysValue(entry.getKey(), e);
                Object objValue = null;
                // 对其它缓存信息做特殊处理，当其它缓存信息为类本身时，设置自身值
                if (entry.getValue().length == 1 && entry.getValue()[0].equals(configInfo.getClazzName())) {
                    objValue = e;
                } else {
                    objValue = CacheUtil.getFieldValues(entry.getValue(), e);
                }
                if (objValue != null) {
                    tempOtherMap.put(keyValue, objValue);
                }
                sort++;
            }
        }
    }

    // 随机名称
    ConfigInfo<RandomName> randomNameConfigInfo = new ConfigInfo<>(RandomName.class, false);
    randomNameConfigInfo.setNeedList(false);
    randomNameConfigInfo.addOtherFieldValue("id", "name");
    CacheUtil.addConfig(CacheUtil.getCacheDataMapKey(RandomName.class), randomNameConfigInfo);
```
