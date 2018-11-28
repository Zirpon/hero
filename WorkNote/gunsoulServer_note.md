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