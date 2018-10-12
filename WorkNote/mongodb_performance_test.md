# **mongodb performance test**

- cpu: i5-7500 (`4 core|3.40GHz|cache 6144 KB`)
- mem: 2G
- clinet: skynet(`skynet mongo driver`)
- mongodb handle query average: 4000 req/s
- mongodb handle insert average: 3400 ~ 3900 req/s

## 1. **tb_player test**

> **query**

- test interface: **_testtbplayer.lua_**: `FindPlayer(uid, player_id)`
- query request size: 88 ~ 119 bytes
- everytime query request count: 12830
- request cost time average: 186 ~ 225 us

| test time | req count | req cost max(us) | req cost min(us) |  req cost avg(us) | req cost(>1ms) count/ratio |
| :-------: | :-------: | :--------------: | :--------------: |  :--------------: | :------------------------: |
|      1    |   12830   |       4631       |        131       |       186.30      |         24/0.18706%
|      2    |   12830   |       4930       |        129       |       198.63      |         35/0.27279%
|      3    |   12830   |       6633       |        128       |       186.69      |         20/0.16155%
|      4    |   12830   |       9047       |        134       |       197.96      |         38/0.29618%
|      5    |   25660   |       7813       |        126       |       226.65      |         59/0.22993%

|     |     |     |
| :-: | :-: | :-: |
|![test 1][tbplayer_query_1] |![test 2][tbplayer_query_2] | |
|![test 3][tbplayer_query_3] |![test 4][tbplayer_query_4] | |
|![test 5][tbplayer_query_5]

## 2. **tb_system_param test**

> **inesrt**

- test interface: **_testtbsystemparam.lua_**: `MT.db:Insert({id=id, name="test", value=0})`
- query request size: 203 bytes
- query request count: 1048576
- request cost time average: 225.34 us
- request cost time max: 110052 us
- request cost time max: 112 us

|   |
|:-:|
|![insert diagram][tbsystemparam_insert]|

> **query**

- test interface: **_testtbsystemparam.lua_**: `MT:GetValue(commondef.DBSystemParam.player_id)`
- query request size: 78 bytes
- everytime query request count: 1048576
- request cost time average: 225.34 us

| test time | req count | req cost max(us) | req cost min(us) |  req cost avg(us) | req cost(>1ms) count/ratio |
| :-------: | :-------: | :--------------: | :--------------: |  :--------------: | :------------------------: |
|      1    |   248103  |       8432       |        117       |       218.77      |         396/0.15961%
|      2    |   50000   |       25897      |        119       |       266.15      |         1.348/0.27279%
|      3    |   50000   |       7231       |        117       |       224.56      |         159/0.318%
|      4    |   50000   |       5840       |        117       |       219.57      |         53/0.106%
|      5    |   50000   |       5399       |        117       |       223.11      |         106/0.212%

|     |     |     |
| :-: | :-: | :-: |
|![test 1][tbsystemparam_query_1] |![test 2][tbsystemparam_query_2] | |
|![test 3][tbsystemparam_query_3] |![test 4][tbsystemparam_query_4] | |
|![test 5][tbsystemparam_query_5]

---

[tbplayer_query_1]: https://raw.githubusercontent.com/Zirpon/hero/master/resource/tbplayer_query_1.png "tbplayer_query_1"
[tbplayer_query_2]: https://raw.githubusercontent.com/Zirpon/hero/master/resource/tbplayer_query_2.png "tbplayer_query_2"
[tbplayer_query_3]: https://raw.githubusercontent.com/Zirpon/hero/master/resource/tbplayer_query_3.png "tbplayer_query_3"
[tbplayer_query_4]: https://raw.githubusercontent.com/Zirpon/hero/master/resource/tbplayer_query_4.png "tbplayer_query_4"
[tbplayer_query_5]: https://raw.githubusercontent.com/Zirpon/hero/master/resource/tbplayer_query_5.png "tbplayer_query_5"
[tbsystemparam_insert]: https://raw.githubusercontent.com/Zirpon/hero/master/resource/tbsystemparam_insert.png "tbsystemparam_insert"
[tbsystemparam_query_1]: https://raw.githubusercontent.com/Zirpon/hero/master/resource/tbsystemparam_query_1.png "tbsystemparam_query_1"
[tbsystemparam_query_2]: https://raw.githubusercontent.com/Zirpon/hero/master/resource/tbsystemparam_query_2.png "tbsystemparam_query_2"
[tbsystemparam_query_3]: https://raw.githubusercontent.com/Zirpon/hero/master/resource/tbsystemparam_query_3.png "tbsystemparam_query_3"
[tbsystemparam_query_4]: https://raw.githubusercontent.com/Zirpon/hero/master/resource/tbsystemparam_query_4.png "tbsystemparam_query_4"
[tbsystemparam_query_5]: https://raw.githubusercontent.com/Zirpon/hero/master/resource/tbsystemparam_query_5.png "tbsystemparam_query_5"