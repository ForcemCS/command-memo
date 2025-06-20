## 用户授权
```
DROP TABLE IF EXISTS `T_REDIS_DB`;
CREATE TABLE `T_REDIS_DB` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Redis地址',
  `port` int(11) NOT NULL COMMENT 'Redis端口',
  `auth` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'Redis密码 (nullable if no password)',
  `db` int(11) NOT NULL COMMENT 'Redis DB 编号',
  `state` tinyint(4) NOT NULL DEFAULT 0 COMMENT '状态: 0=可用, 1=使用中, 2=曾使用过(脏)',
  `sid` int(11) UNSIGNED DEFAULT NULL COMMENT '占用的服务器ID (T_SERVER.id)',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_host_port_db` (`host`,`port`,`db`) USING BTREE COMMENT '确保同一实例的DB唯一',
  KEY `idx_state` (`state`) USING BTREE COMMENT '加速查找可用DB'
) ENGINE=InnoDB AUTO_INCREMENT=1 CHARACTER SET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Redis DB 资源池' ROW_FORMAT=DYNAMIC;






GRANT ALL PRIVILEGES ON *.* TO 'root'@'ip' IDENTIFIED BY 'xxxxx' WITH GRANT OPTION;

GRANT ALL PRIVILEGES ON *.* TO 'root'@'10.42.0.1' IDENTIFIED BY 'xxxxx' WITH GRANT OPTION;



ALTER USER 'root'@'%' IDENTIFIED BY 'xxxxx';


FLUSH PRIVILEGES;

#创建一个只读用户
GRANT SELECT ON *.* TO 'r_user'@'%' IDENTIFIED BY 'com.012A';
FLUSH PRIVILEGES;
```
## 修改表结构默认值
```
CREATE TABLE `T_USER`  (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `nickname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `password` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `status` int(11) NULL DEFAULT 1,
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `roles` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `pers` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'e65c3,e71bb,c8c62,1b470,1203e,6dcbc,481e5,4face,6924f,2525f,c2e33,46a0d,5106e,cd443,3fdb7,7b8b3,fdd6d,d7ae7,3e529,f585b,bcde6,742d3,2d339,9ebcc,d49f2,ca1c0,332e8,77141,98ff4,7969b,46a4b,9240d,c6eb6,8ff9a,ea7bb,61947,f12df,fb661,37999,708a0,11c57,6aa0d,deecc,1692f,1b046,2e44c,5f154,67152,6e80f,ec04e,db25f,04414,23930,b90c9,74d36,f6bf7,24607,df0d3,c311b,b5a9c,70f43,f8896,8fdcb,44e6d,f43fd,86207,876eb,79f48,f107f,17de3,62911,435b8,',
  `mark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

SET FOREIGN_KEY_CHECKS = 1;




#修改表结构默认值
ALTER TABLE `T_USER`
MODIFY COLUMN `pers` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'xxx';
#追加权限
UPDATE `T_USER`
SET `pers` = CONCAT(`pers`, '435b8,')
WHERE `pers` NOT LIKE '%435b8,%';
```

创建定时任务

```
#查看定时任务
SHOW EVENTS FROM your_database_name;
#删除事件
DROP EVENT IF EXISTS `export_daily_level_log_v57`;
```
## 分组求和
```
SELECT uid ,SUM(amount) as total_amount  FROM T_ORDER WHERE `status` =2 GROUP BY uid ;

SELECT uid ,SUM(amount) as total_amount  FROM T_ORDER WHERE `status` =2 GROUP BY uid  HAVING total_amount >= 50000;
```
