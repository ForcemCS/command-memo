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
