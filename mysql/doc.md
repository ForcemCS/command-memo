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
```
