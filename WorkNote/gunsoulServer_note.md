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