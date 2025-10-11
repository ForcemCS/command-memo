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
### mvpboss
```
SELECT *
FROM LOG_MVPBOSS_KILL_RECORD
WHERE 
  (
    (sid = 20001 AND time_stamp >= '2025-06-12' AND time_stamp < '2025-06-18')
    OR
    (sid = 20002 AND time_stamp >= '2025-06-13' AND time_stamp < '2025-06-19')
    OR
    (sid = 20003 AND time_stamp >= '2025-07-02' AND time_stamp < '2025-07-08')
  )
  AND gsitems IS NOT NULL AND gsitems != '';

```
### 某天充值次数玩家统计
```
SELECT recharge_times, COUNT(*) AS player_count
FROM (
    SELECT uid, COUNT(*) AS recharge_times
    FROM T_ORDER
    WHERE server_id = 20001
      AND status = 2
      AND create_time LIKE '%2025-06-25%'
    GROUP BY uid
) AS t
WHERE recharge_times IN (1, 2, 3)
GROUP BY recharge_times
ORDER BY recharge_times;

```
### 购买月卡并且充值两笔以上的
```
SELECT uid
FROM T_ORDER
WHERE server_id IN (40001, 40002)
  AND status = 2
GROUP BY uid
HAVING COUNT(*) >= 2
   AND SUM(CASE WHEN product_id = 270030001 THEN 1 ELSE 0 END) >= 1;
```
### 开服连续三天充值的玩家
```
SELECT
    o.uid,
    o.server_id
FROM
    T_ORDER o
    JOIN T_SERVER s ON o.server_id = s.id
WHERE
    s.site_id = 4
    AND o.status = 2
    AND o.server_id NOT IN (40001, 40002, 40003, 40004)
    AND DATEDIFF(o.create_time, s.open_time) BETWEEN 0 AND 2
GROUP BY
    o.uid,
    o.server_id
HAVING
    COUNT(DISTINCT DATEDIFF(o.create_time, s.open_time)) = 3
ORDER BY
    o.server_id, o.uid;

```
### 开服当天充值，最后登录时间停留在第二天
```
SELECT 
    r3.*, 
    ROUND(SUM(r4.amount) / 100, 2) AS amount
FROM 
    T_ORDER r4 
JOIN (
    SELECT  
        r1.uid, 
        r1.nickname, 
        r1.sid, 
        r1.viplv, 
        r1.last_login_time 
    FROM 
        SNAP_ROLE r1
    JOIN (
        SELECT DISTINCT 
            o.uid, 
            o.server_id, 
            DATE(s.open_time) AS open_time
        FROM 
            T_ORDER o
        JOIN 
            T_SERVER s ON s.id = o.server_id
        WHERE 
            o.status = 2 
            AND DATE(s.open_time) = DATE(o.create_time)
    ) AS r2
    ON 
        r1.uid = r2.uid 
        AND r1.sid = r2.server_id 
        AND DATE(r1.last_login_time) = DATE(DATE_ADD(r2.open_time, INTERVAL 1 DAY))
) AS r3 
ON 
    r4.uid = r3.uid 
    AND r4.server_id = r3.sid 
GROUP BY 
    r4.uid
ORDER BY 
    RIGHT(r4.uid, 5);

```
