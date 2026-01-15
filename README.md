# RedisShake: Redis Data Transformation and Migration Tool

[![CI](https://img.shields.io/github/actions/workflow/status/tair-opensource/RedisShake/ci.yml?branch=v4&label=CI
)](https://github.com/tair-opensource/RedisShake/actions/workflows/ci.yml)
[![Website](https://img.shields.io/website?url=https%3A%2F%2Ftair-opensource.github.io%2FRedisShake%2F&up_message=%E4%B8%AD%E6%96%87%20%2F%20English&up_color=red&label=Doc
)](https://tair-opensource.github.io/RedisShake/)
[![Release](https://img.shields.io/github/v/release/tair-opensource/RedisShake?color=blue&label=Release)](https://github.com/tair-opensource/RedisShake/releases)
[![ghcr.io](https://ghcr-badge.egpl.dev/tair-opensource/redisshake/latest_tag?color=%231d63ed&ignore=latest&label=ghcr.io&trim=)](https://github.com/tair-opensource/RedisShake/pkgs/container/redisshake)

- [中文文档](https://tair-opensource.github.io/RedisShake/)
- [English Documentation](https://tair-opensource.github.io/RedisShake/en/)

![](./docs/intro.png)

## Overview

RedisShake is a powerful tool for Redis data transformation and migration, offering:

1. **Zero Downtime Migration**: Enables seamless data migration without data loss or service interruption, ensuring continuous operation during the transfer process.

2. **Valkey/Redis Compatibility**: Supports Redis (2.8 to 8.x) and Valkey (8.x to 9.x) across standalone, master–slave, sentinel, and cluster deployments. See [Version Compatibility](https://tair-opensource.github.io/RedisShake/zh/others/compatibility.html) for detailed feature support.

3. **Cloud Service Integration**: Seamlessly works with Redis-like databases from major cloud providers:
   - Alibaba Cloud: [Tair (Redis® OSS-Compatible)](https://www.alibabacloud.com/en/product/tair)
   - AWS: [ElastiCache](https://aws.amazon.com/elasticache/), [MemoryDB](https://aws.amazon.com/memorydb/)  

4. **Module Support**: Compatible with [TairString](https://github.com/tair-opensource/TairString), [TairZSet](https://github.com/tair-opensource/TairZset), and [TairHash](https://github.com/tair-opensource/TairHash).

5. **Flexible Data Source**: Supports [PSync](https://tair-opensource.github.io/RedisShake/zh/reader/sync_reader.html), [RDB](https://tair-opensource.github.io/RedisShake/zh/reader/rdb_reader.html), and [Scan](https://tair-opensource.github.io/RedisShake/zh/reader/scan_reader.html) data fetch methods.

6. **Advanced Data Processing**: Enables custom [script-based data transformation](https://tair-opensource.github.io/RedisShake/zh/filter/function.html) and easy-to-use [data filter rules](https://tair-opensource.github.io/RedisShake/zh/filter/filter.html).

## How to Get RedisShake

1. Download from [Releases](https://github.com/tair-opensource/RedisShake/releases).

2. Use Docker:
```shell
docker run --network host \
    -e SYNC=true \
    -e SHAKE_SRC_ADDRESS=127.0.0.1:6379 \
    -e SHAKE_DST_ADDRESS=127.0.0.1:6380 \
    ghcr.io/tair-opensource/redisshake:latest
```

3. Build it yourself:
```shell
git clone https://github.com/tair-opensource/RedisShake
cd RedisShake
sh build.sh
```

## How to Use RedisShake

To move data between two Redis instances and skip some keys:

1. Make a file called `shake.toml` with these settings:
```toml
[sync_reader]
address = "127.0.0.1:6379"

[redis_writer]
address = "127.0.0.1:6380"

[filter]
# skip keys with "temp:" or "cache:" prefix
block_key_prefix = ["temp:", "cache:"] 
```

2. Run RedisShake:
```shell
./redis-shake shake.toml
```

## 迁移模式变量详解：

| 迁移模式 | 对应变量 | 详述                                                         |
| -------- | -------- | ------------------------------------------------------------ |
| PSync    | SYNC     | 设置为true表示启用sync迁移，一个迁移任务只能设置一种迁移模式 |
| SCAN     | SCAN     | 设置为true表示启用scan迁移，一个迁移任务只能设置一种迁移模式 |
| RDB      | RDB      | 设置为true表示启用rdb迁移，一个迁移任务只能设置一种迁移模式  |
| AOF      | AOF      | 设置为true表示启用aof迁移，一个迁移任务只能设置一种迁移模式  |

### sync_reader相关变量

| 变量名称                 | 变量默认值 | 详述                                                         |
| ------------------------ | ---------- | ------------------------------------------------------------ |
| SHAKE_SRC_CLUSTER        | false      | 若数据源为 Redis 集群（Redis Cluster），请将该值设为 true    |
| SHAKE_SRC_ADDRESS        |            | 指定源数据库地址，如果是redis cluster设置集群内的一个节点即可 |
| SHAKE_SRC_USERNAME       |            | 若未使用 Redis ACL（访问控制列表）功能，保持该字段为空即可   |
| SHAKE_SRC_PASSWORD       |            | 若 Redis 无需身份验证（无密码），保持该字段为空即可          |
| SHAKE_SRC_TLS            | false      | 若需要启用 TLS 加密连接（保障传输安全），请将该值设为 true   |
| SHAKE_SRC_SYNC_RDB       | true       | 若不需要 RDB 全量同步，将该值设为 false；首次数据迁移时建议设为 true |
| SHAKE_SRC_SYNC_AOF       | true       | 若不需要 AOF 增量同步，将该值设为 false；首次数据迁移时建议设为 true |
| SHAKE_SRC_PREFER_REPLICA | false      | 若希望从从节点（replica node）同步数据，将该值设为 true      |
| SHAKE_SRC_TRY_DISKLESS   | false      | 若数据源 Redis 已配置 repl-diskless-sync=yes（无盘复制开启），将该值设为 true 以启用无盘同步 |

### scan_reader相关变量

| 变量名称           | 变量默认值 | 详述                                                         |
| ------------------ | ---------- | ------------------------------------------------------------ |
| SHAKE_SRC_CLUSTER  | false      | 若数据源为 Redis 集群（Redis Cluster），请将该值设为 true    |
| SHAKE_SRC_ADDRESS  |            | 指定源数据库地址，如果是redis cluster设置集群内的一个节点即可 |
| SHAKE_SRC_USERNAME |            | 若未使用 Redis ACL（访问控制列表）功能，保持该字段为空即可   |
| SHAKE_SRC_PASSWORD |            | 若 Redis 无需身份验证（无密码），保持该字段为空即可          |
| SHAKE_SRC_TLS      | false      | 若需要启用 TLS 加密连接（保障传输安全），请将该值设为 true   |
| SHAKE_SRC_DBS      |            | 配置需要扫描的数据库编号，示例：[1,5,7]；若留空（不配置），则扫描所有数据库 |
| SHAKE_SRC_SCAN     | true       | 若不需要扫描 Redis 中的键（key），请将该值设为 false         |
| SHAKE_SRC_KSN      | false      | 设为 true 以启用 Redis 键空间通知（Keyspace Notifications，简称 KSN）订阅功能 |
| SHAKE_SRC_COUNT    | 100        | 每次迭代（扫描循环）中要扫描的键（key）的数量                |

### rdb_reader相关变量

| 变量名称           | 变量默认值    | 详述                                           |
| ------------------ | ------------- | ---------------------------------------------- |
| SHAKE_RDB_FILEPATH | /tmp/dump.rdb | 定义dump.rdb文件的存储位置，需要设置为绝对路径 |

### aof_reader相关变量

| 变量名称           | 变量默认值          | 详述                                                 |
| ------------------ | ------------------- | ---------------------------------------------------- |
| SHAKE_AOF_FILEPATH | /tmp/appendonly.aof | 定义appendonly.aof文件的存储位置，需要设置为绝对路径 |

### redis_writer相关变量（写入数据库相关）

| 变量名称            | 变量默认值 | 详述                                                         |
| ------------------- | ---------- | ------------------------------------------------------------ |
| SHAKE_DST_CLUSTER   | false      | 若数据源为 Redis 集群（Redis Cluster），请将该值设为 true    |
| SHAKE_DST_ADDRESS   |            | 指定目标数据库地址，如果是redis cluster设置集群内的一个节点即可 |
| SHAKE_DST_USERNAME  |            | 若未使用 Redis ACL（访问控制列表）功能，保持该字段为空即可   |
| SHAKE_DST_PASSWORD  |            | 若 Redis 无需身份验证（无密码），保持该字段为空即可          |
| SHAKE_DST_TLS       | false      | 若需要启用 TLS 加密连接（保障传输安全），请将该值设为 true   |
| SHAKE_DST_OFF_REPLY | false      | 关闭服务器响应（禁用 Redis 服务端的返回应答信息），一般情况设置为false，保证数据一致性 |


For more help, check the [docs](https://tair-opensource.github.io/RedisShake/zh/guide/mode.html).

## Cross-Version Migration

Before migrating data between different major versions of Redis, we recommend using the **[resp-compatibility](https://github.com/tair-opensource/resp-compatibility/)** tool for a compatibility check and consulting the **[compatibility report](https://github.com/tair-opensource/resp-compatibility/blob/main/compatibility_report_en_US.md)** to avoid known breaking changes and bugs.


## History

RedisShake, actively maintained by the [Tair team](https://github.com/tair-opensource) at Alibaba Cloud, evolved from [redis-port](https://github.com/CodisLabs/redis-port). Key milestones:

- [RedisShake 2.x](https://github.com/tair-opensource/RedisShake/tree/v2): Improved stability and performance.
- [RedisShake 3.x](https://github.com/tair-opensource/RedisShake/tree/v3): Complete codebase rewrite, enhancing efficiency and usability.
- [RedisShake 4.x](https://github.com/tair-opensource/RedisShake/tree/v4): Enhanced readers, configuration, observability, and functions.

## License

RedisShake is open-sourced under the [MIT license](https://github.com/tair-opensource/RedisShake/blob/v2/license.txt).
