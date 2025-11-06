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

### 开服前三天有任意一天充值的玩家
```
SELECT DISTINCT
    o.server_id,
    o.uid
FROM
    T_ORDER o
    JOIN T_SERVER s ON o.server_id = s.id
WHERE
    s.site_id = 4
    AND s.id NOT IN (40001, 40002, 40003, 40004, 40990)
    AND o.status = 2
    AND DATEDIFF(o.create_time, s.open_time) IN (0, 1, 2)
ORDER BY
    RIGHT(o.uid, 5);

```
```
SELECT
    T2.name AS server_name,
    T1.server_id,
    T1.uid
FROM
    db_ro3_dsk2.T_ORDER AS T1
INNER JOIN
    db_ro3_server.T_SERVER AS T2 ON T1.server_id = T2.id
WHERE
    -- 1. 确保充值成功
    T1.status = 2
    
    -- 2. 充值时间在服务器实际开放之后 
    AND T1.create_time >= T2.open_time
    
    -- 3. 充值时间在开服日期的两天后午夜之前（自然天1和2）
    AND T1.create_time < DATE_ADD(DATE(T2.open_time), INTERVAL 2 DAY)
    
    -- 4. 新增条件：服务器 ID 必须以 4 开头
    -- CAST(T1.server_id AS CHAR) 将整数转换为字符串，然后使用 LIKE '4%' 匹配
    AND CAST(T1.server_id AS CHAR) LIKE '4%'

GROUP BY
    T1.server_id,
    T1.uid,
    T2.name
ORDER BY
    T1.server_id,
    T1.uid;
```
### 前两天任意一天充值，最后登录第二天
```
SELECT
    T2.name AS server_name,
    T1.server_id,
    T1.uid,
    T3.last_login_time -- 新增：显示最后登录时间
FROM
    db_ro3_dsk2.T_ORDER AS T1
INNER JOIN
    db_ro3_server.T_SERVER AS T2 ON T1.server_id = T2.id
INNER JOIN
    db_ro3_operation_log.SNAP_ROLE AS T3 ON T1.uid = T3.uid AND T1.server_id = T3.sid
WHERE
    -- 1. 确保充值成功
    T1.status = 2
    
    -- 2. 充值时间在开服自然天 1 或 2 之间 (起始点：开服时刻；截止点：开服日期的两天后零点)
    AND T1.create_time >= T2.open_time
    AND T1.create_time < DATE_ADD(DATE(T2.open_time), INTERVAL 2 DAY)
    
    -- 3. 服务器 ID 必须以 4 开头
    AND CAST(T1.server_id AS CHAR) LIKE '4%'

    -- 4. 最后登录时间 (T3.last_login_time) 必须在开服的第二天
    -- 开服第二天的零点
    AND T3.last_login_time >= DATE_ADD(DATE(T2.open_time), INTERVAL 1 DAY)
    -- 开服第三天的零点
    AND T3.last_login_time < DATE_ADD(DATE(T2.open_time), INTERVAL 2 DAY)

GROUP BY
    T1.server_id,
    T1.uid,
    T2.name,
    T3.last_login_time -- 确保符合 GROUP BY 规范
ORDER BY
    T1.server_id,
    T1.uid;
```
### 第一次选择的职业
```
SELECT
    t1.*
FROM
    LOG_ADD_HERO_RECORD t1
JOIN (
    SELECT
        uid,
        MIN(time_stamp) AS min_time
    FROM
        LOG_ADD_HERO_RECORD
    GROUP BY
        uid
) t2
ON t1.uid = t2.uid AND t1.time_stamp = t2.min_time
WHERE
    t1.sid LIKE '4%';
```
### 职业占比
```
SELECT
  e.job_id,
  COUNT(DISTINCT e.uid) AS uid_count,
  ROUND(
    COUNT(DISTINCT e.uid) /
    (SELECT COUNT(DISTINCT t.uid)
     FROM (
       SELECT t1.uid
       FROM LOG_ADD_HERO_RECORD t1
       JOIN (
         SELECT uid, MIN(time_stamp) AS min_time
         FROM LOG_ADD_HERO_RECORD
         GROUP BY uid
       ) t2 ON t1.uid = t2.uid AND t1.time_stamp = t2.min_time
       WHERE CAST(t1.sid AS CHAR) LIKE '4%'
     ) AS t
    ) * 100, 2
  ) AS percentage
FROM (
  SELECT t1.uid, t1.job_id
  FROM LOG_ADD_HERO_RECORD t1
  JOIN (
    SELECT uid, MIN(time_stamp) AS min_time
    FROM LOG_ADD_HERO_RECORD
    GROUP BY uid
  ) t2 ON t1.uid = t2.uid AND t1.time_stamp = t2.min_time
  WHERE CAST(t1.sid AS CHAR) LIKE '4%'
) AS e
WHERE e.job_id IN (1,2,3,4,5)   -- 如果只关心 1-5 职业，可保留此行
GROUP BY e.job_id
ORDER BY e.job_id;
```
```
-- 1) 创建临时表（会话级别）
CREATE TEMPORARY TABLE earliest_records AS
SELECT t1.uid, t1.job_id
FROM LOG_ADD_HERO_RECORD t1
JOIN (
  SELECT uid, MIN(time_stamp) AS min_time
  FROM LOG_ADD_HERO_RECORD
  GROUP BY uid
) t2 ON t1.uid = t2.uid AND t1.time_stamp = t2.min_time
WHERE CAST(t1.sid AS CHAR) LIKE '4%';

-- 2) 统计并计算百分比
SELECT
  job_id,
  COUNT(*) AS uid_count,
  ROUND(COUNT(*) / (SELECT COUNT(*) FROM earliest_records) * 100, 2) AS percentage
FROM earliest_records
WHERE job_id IN (1,2,3,4,5)
GROUP BY job_id
ORDER BY job_id;

-- 3) （可选）删除临时表（会话结束后会自动删除）
DROP TEMPORARY TABLE IF EXISTS earliest_records;
```
### 2V2数据
```
SELECT *
FROM `item_log_2025-10-22`
WHERE change_type = 2
  AND itemid = 24601861
  AND sid LIKE '4%' 
  AND (
        (TIME(time_stamp) BETWEEN '12:00:00' AND '13:00:00')
        OR
        (TIME(time_stamp) BETWEEN '19:00:00' AND '20:00:00')
      )

UNION ALL

SELECT *
FROM `item_log_2025-10-23`
WHERE change_type = 2
  AND itemid = 24601861
  AND sid LIKE '4%' 
  AND (
        (TIME(time_stamp) BETWEEN '12:00:00' AND '13:00:00')
        OR
        (TIME(time_stamp) BETWEEN '19:00:00' AND '20:00:00')
      );

```
### dau
```
select sid,ifnull(sum(1),0) as dau, `date` from KPI_ACTIVE where `date`>='2025-11-01' and `date`<="2025-11-04" group by sid,date
```
### 玩家累计充值
```
SELECT
    uid,
    server_id,
    SUM(T.amount / 100) AS 累计充值金额
FROM
    T_ORDER AS T
WHERE
    T.status = 2 -- 筛选出成功订单（已发货）
    AND T.uid IS NOT NULL -- 排除uid为空的记录
GROUP BY
    uid
HAVING
    累计充值金额 >= 2000 -- 可选：只显示有成功充值的玩家
ORDER BY
    累计充值金额 DESC; -- 可选：按累计充值金额降序排列


SELECT
    T1.玩家ID AS uid,
    T1.累计充值金额,
    T2.nickname AS 昵称,
    T2.sid AS 服务器ID,
    T2.viplv AS VIP等级,
    T2.diamond AS 钻石余额,
    T2.max_base_lv AS 最高基础等级
FROM
    (
        -- 子查询：计算累计充值金额并过滤
        SELECT
            uid AS 玩家ID,
            SUM(T.amount / 100) AS 累计充值金额
        FROM
            T_ORDER AS T
        WHERE
            T.status = 2        -- 筛选出成功订单
            AND T.uid IS NOT NULL
        GROUP BY
            uid
        HAVING
            累计充值金额 > 2000 -- 过滤：只保留累计充值金额大于 2000 的玩家
    ) AS T1
INNER JOIN
    db_ro3_operation_log.SNAP_ROLE AS T2 ON T1.玩家ID = T2.uid -- 【修正：使用完整的数据库.表名】
ORDER BY
    T1.累计充值金额 DESC; -- 按累计充值金额降序排列
```
### 充值统计
```
SELECT 
    DATE_FORMAT(create_time, '%Y-%m') AS month,
    ROUND(SUM(amount / 100), 2) AS total_amount
FROM T_ORDER
WHERE 
    site_id = 4
    AND status = 2
    AND server_id NOT IN (40990)
    AND create_time >= '2025-08-01 00:00:00'
    AND create_time <  '2025-12-01 00:00:00'
GROUP BY 
    DATE_FORMAT(create_time, '%Y-%m')
ORDER BY 
    month;

```
