# cj工作内容总结

- 选服系统 based on Skynet Redis driver, Redis watch 订阅节点同步, socketchannel, keepalive haproxy 负载均衡 安装脚本, Redis sentinel 主从部署,webbench 压测
- 投降系统
- UDP tcpdump 捉包
- bug 追踪:
    1. 客户端登录token 不一致,不同阵营出生点相同bug,帧同步结束帧bug
    2. 客户端第一帧标志空帧bug
    3. 优先未满队列匹配 内存泄漏 bug
    4. RocketMQ topic session 映射混淆 bug
    5. 配置表热更服务 codecache clear bug
    6. Raknet 消息消费者 spinlock 初始化 bug
- 协助客户端调试
- 服务器部署
- 帧同步定时快照
- 流程图
- 战场录像 录像分包 RocketMQ 无序收包重排, MongoDB 存储 bson/写文件, 录像压缩 zlib、lz4、facebook  zstd
- 战场帧校验 skiplist 存储帧序列权重
- 配置表热更 基于 Skynet sharedata
- 机器人 基于 Raknet UDP 协议 设计 Raknet client接口,自定义消息包体 协议类型 包体长度等
- 机器人压测:
    1. MongoDB benchmark
    2. 登录各个协议并发耗时压测:单服支持2万并发4 core cpu/8g RAM
- Python excel 表格导成 Lua 表 旧表合并迁移 并生成相关协议号枚举文件
- Raknet 转 KCP 协议调试
- 共享内存清理脚本 部署脚本 编译脚本 项目 Cmake 编译脚本

---

- hazard version 设计
- 消息中间件 RocketMQ
- Raknet
- zlib
- lz4
