# gunsoul Server note

```java

@Repository
public class PlayerDao extends UniversalDaoHibernate implements IPlayerDao {
    ...
}

@Service
public class BasePlayerService extends UniversalManagerImpl implements IPlayerService {
    @javax.annotation.Resource
    private IPlayerDao dao;
    ...
}

@Service
public class PlayerService {
    private IPlayerService basePlayerService;
    ...
}

```

[Hibernate注解使用以及Spring整合](https://www.cnblogs.com/younggun/archive/2013/05/19/3086659.html)