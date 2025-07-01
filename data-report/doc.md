### 战力排行
```
SELECT uid, power
FROM SNAP_ROLE
WHERE sid BETWEEN 20000 AND 29999
ORDER BY power DESC
LIMIT 11;
```
### 查询工作室账号
```
SELECT sr.*
FROM db_ro3_operation_log.SNAP_ROLE sr
JOIN (
    SELECT uid
    FROM db_ro3_sdk2.T_ORDER
    WHERE status = 2
    GROUP BY uid
    HAVING SUM(amount) = 600
) o ON sr.uid = o.uid
WHERE sr.sid LIKE '2000%'                        -- sid以2000开头
  AND sr.max_base_lv = 55                        -- 等于55级
  AND sr.total_online_time > 11 * 60 * 60        -- 超过12小时
  AND sr.last_login_time >= '2025-06-25 00:00:00'; -- 登录时间
#附加IP信息
SELECT sr.*, o.total_amount, o.last_order_ip
FROM db_ro3_operation_log.SNAP_ROLE sr
JOIN (
    SELECT
        t.uid,
        SUM(t.amount) AS total_amount,
        (
            SELECT ip
            FROM db_ro3_sdk2.T_ORDER
            WHERE uid = t.uid AND status = 2
            ORDER BY create_time DESC
            LIMIT 1
        ) AS last_order_ip
    FROM db_ro3_sdk2.T_ORDER t
    WHERE t.status = 2
    GROUP BY t.uid
    HAVING SUM(t.amount) = 600
) o ON sr.uid = o.uid
WHERE sr.sid LIKE '2000%'
  AND sr.max_base_lv = 55
  AND sr.total_online_time > 43200
  AND sr.last_login_time >= '2025-06-25 00:00:00';

```
### 用户登陆天数，注册时间，创角色时间，充值情况
```
SELECT
    li.uid,
    li.account,
    li.server_id,
    li.regist_time,
    li.last_login_time,
    CASE 
        WHEN EXISTS (SELECT 1 FROM db_ro3_sdk2.T_ORDER o WHERE o.uid = li.uid AND o.status = 2) THEN '是'
        ELSE '否'
    END AS 是否充值,
    (
        SELECT MIN(delivery_time)
        FROM db_ro3_sdk2.T_ORDER o
        WHERE o.uid = li.uid AND o.status = 2
    ) AS 首充时间,
    u.online_status AS 连续登录天数,
    sr.create_stamp AS 创角时间  -- Added create time from SNAP_ROLE
FROM
    db_ro3_sdk2.T_LOGIN_INFO li
LEFT JOIN db_ro3_sdk2.T_USER u ON li.account = u.id
LEFT JOIN db_ro3_operation_log.SNAP_ROLE sr ON li.uid = sr.uid
WHERE
    sr.sid LIKE '2%';
```
### 玩家升级的最新记录
```
SELECT l.*
FROM level_change_log l
JOIN (
    SELECT uid, MAX(time_stamp) AS max_time
    FROM level_change_log
    WHERE sid LIKE '2%'
    GROUP BY uid
) AS latest
ON l.uid = latest.uid AND l.time_stamp = latest.max_time
WHERE l.sid LIKE '2%';
```
