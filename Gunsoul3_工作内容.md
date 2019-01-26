# Gunsoul 3 工作内容

---

## 周报总结

- 熟悉枪战3 服务器代码:
    1. 协议封装规则
    2. 缓存服务设计结构
    3. 配置服务设计结构
    4. Spring Hibernate Annotation 管理实务机制
    5. 了解mina网络通信应用框架 IoHandlerAdapter, ProtocolCodecFilter 协议编解码， IoSession Context
    6. 了解 服务器架构 CenterServer AccountServer WorldServer IpdServer DispatchServer, Redis Mysql
- 服务器部署
- 设计天命系统
- 设计挑战副本通缉令系统
- 设计挑战副本拆雷模式系统
- 迁移生化基地系统
- 协助前端调试
- 追踪bug
    追踪无法进入关卡错误
    追踪创角近战武器初始化问题
    协助指引飞车组后端定位追踪线程独占CPU的死循环bug

---

## 周报

### 11月5日-11月11日

阅读 IPDServer 代码
阅读 Protocol 封装规则
阅读 Dispatch 消息包分发逻辑

阅读 WorldServer 消息调度处理代码
阅读 CenterServer 代码
阅读 AccountServer 代码

### 11月12日-11月18日

跟踪玩家建立连接 登录流程
部署本地虚拟机redis集群
协助前端调试GetPackListOk 协议 枪支ID BUG, roleActorLoginOk协议 缺少currChapterId, currAllstar, animationIndexCode bug
了解mina网络通信应用框架：IoHandlerAdapter, ProtocolCodecFilter 协议编解码， IoSession Context
尝试使用shadowsocks+dnsmasq+ipset+iptables 实现办公网络透明代理（智能翻墙）

### 11月19日-11月25日

阅读技能系统
阅读宝石镶嵌系统
阅读关卡，任务系统与玩家属性加成接口
设计天命系统

#### 11月26日-12月2日

设计天命系统数据字段 配表结构
单台物理机部署服务器 以防影响内网数据
阅读了PlayerService的私有成员BasePlayerService接口的设计
阅读了CacheService缓存服务
阅读了ConfigService配置服务
了解了Spring hibernate 基于Annotation注解方式管理实务机制
结合服务器数据库数据结构设计与存储机制 优化Mysql部分配置
配合前端调试

### 12月3日-12月9日

设计天命系统接口
联调天命系统

### 12月10日-12月16日

联调天命系统
阅读kcp java 开源代码
阅读battleService 网络通信模块

### 12月17日-12月23日

阅读世界服 SkillService 服务代码
了解枪一技能解锁相关功能

### 12月24日-12月30日

新版天命系统修改 调试
配合客户端调试
追踪无法进入关卡错误
追踪创角近战武器初始化问题

### 12月31日-1月6日

阅读通缉令相关代码
配合前端调试

### 1月7日-1月13日

调试通缉令协议 逻辑
追踪掉落相关bug
优化天命代码
协助前端调试

### 1月14日-1月20日

阅读拆雷模式代码
阅读生化基地代码

### 1月21日-1月27日

添加拆雷模式
迁移生化基地系统