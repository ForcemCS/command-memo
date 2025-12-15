## 查询多条数据中时间戳最大的
```
SELECT
    log.uid,
    log.sid,
    log.stagetype,
    CASE log.stagetype 
        WHEN 1 THEN '欢乐冒险' 
        WHEN 2 THEN '极限挑战' 
        ELSE '未知' 
    END AS mode_name,
    log.stageid,
    log.time_stamp
FROM
    poli_island_log log
INNER JOIN (
    /* 子查询：找出每个玩家(uid)在每种模式(stagetype)下，指定日期的最大ID */
    SELECT
        MAX(id) AS max_id
    FROM
        poli_island_log
    WHERE
        /* 筛选 2025-12-07 当天 */
        time_stamp >= '2025-12-07 00:00:00'
        AND time_stamp <= '2025-12-07 23:59:59'
    GROUP BY
        uid,
        stagetype
) latest ON log.id = latest.max_id;
```
