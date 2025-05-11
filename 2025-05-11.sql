
-- 💡 SQL 문제 모음: SQLite 날짜/시간 함수 연습 (초~중급)

-- 📌 문제 설명
-- 아래 문제들은 SQLite의 다양한 날짜/시간 관련 함수들을 연습하기 위한 것입니다.
-- 각각의 문제를 해결하며, date(), time(), strftime(), julianday() 등의 함수를 익혀보세요.

-- 🗃️ 예시 테이블: user_events
CREATE TABLE user_events (
    event_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    event_type TEXT,
    event_time TEXT -- ISO 8601 문자열 형식의 DATETIME (e.g. '2024-01-01 08:12:00')
);

-- ✅ 예시 데이터
INSERT INTO user_events (user_id, event_type, event_time) VALUES
(1, 'login',  '2024-01-01 08:12:00'),
(1, 'logout', '2024-01-01 09:00:00'),
(1, 'login',  '2024-01-02 10:00:00'),
(2, 'login',  '2024-01-01 14:25:00'),
(2, 'logout', '2024-01-01 15:10:00'),
(2, 'login',  '2024-01-03 08:00:00'),
(3, 'login',  '2024-01-01 22:00:00'),
(3, 'logout', '2024-01-02 01:00:00');

-- --------------------------------------
-- 🧪 문제 1: 날짜만 추출
-- strftime('%Y-%m-%d', event_time)

SELECT event_id, strftime('%Y-%m-%d', event_time) AS event_date FROM user_events;

-- --------------------------------------
-- 🧪 문제 2: 시간만 추출 (HH:MM:SS)
-- strftime('%H:%M:%S', event_time)

SELECT event_id, strftime('%H:%M:%S', event_time) AS event_time_only FROM user_events;

-- --------------------------------------
-- 🧪 문제 3: 이벤트의 요일 구하기 (0: 일요일 ~ 6: 토요일)
-- strftime('%w', event_time)

SELECT event_id, strftime('%w', event_time) AS weekday_number FROM user_events;

-- --------------------------------------
-- 🧪 문제 4: 몇 번째 주인지 (Week of Year)
-- strftime('%W', event_time)

SELECT event_id, strftime('%W', event_time) AS week_of_year FROM user_events;

-- --------------------------------------
-- 🧪 문제 5: 로그인 → 로그아웃 간 시간 차이 계산
-- SQLite에는 LAG 함수 없음 -> ROW_NUMBER 대신 JOIN을 활용한 방식 예시

WITH login_events AS (
  SELECT * FROM user_events WHERE event_type = 'login'
),
logout_events AS (
  SELECT * FROM user_events WHERE event_type = 'logout'
),
matched AS (
  SELECT 
    l.user_id,
    l.event_time AS login_time,
    MIN(o.event_time) AS logout_time
  FROM login_events l
  JOIN logout_events o ON o.user_id = l.user_id AND o.event_time > l.event_time
  GROUP BY l.event_id
)
SELECT *,
       julianday(logout_time) - julianday(login_time) AS session_days,
       (julianday(logout_time) - julianday(login_time)) * 24 * 60 AS session_minutes
FROM matched;

-- --------------------------------------
-- 🧪 문제 6: 월 단위 집계
-- strftime('%Y-%m', event_time)

SELECT user_id,
       strftime('%Y-%m', event_time) AS month,
       COUNT(*) FILTER (WHERE event_type = 'login') AS login_count
FROM user_events
GROUP BY user_id, month
ORDER BY user_id, month;

-- --------------------------------------
-- 🧪 문제 7: 3일 이내 재접속한 로그인 찾기
-- SQLite에는 LAG 없음 -> JOIN으로 이전 로그인 시간 비교

WITH logins AS (
  SELECT * FROM user_events WHERE event_type = 'login'
),
with_prev AS (
  SELECT 
    l1.user_id,
    l1.event_time AS current_login,
    MAX(l2.event_time) AS prev_login
  FROM logins l1
  LEFT JOIN logins l2
    ON l1.user_id = l2.user_id AND l2.event_time < l1.event_time
  GROUP BY l1.event_time, l1.user_id
)
SELECT *,
       julianday(current_login) - julianday(prev_login) AS gap_days
FROM with_prev
WHERE prev_login IS NOT NULL AND julianday(current_login) - julianday(prev_login) <= 3;

-- --------------------------------------
-- 🧪 문제 8: 오늘 날짜와의 차이
-- 오늘 날짜: date('now')

SELECT event_id,
       ROUND(julianday(date('now')) - julianday(date(event_time))) AS days_ago
FROM user_events;

-- --------------------------------------
-- 📝 SQLite 날짜/시간 함수 요약
-- - date(), time(), datetime(), julianday()
-- - strftime('%Y'), strftime('%m'), strftime('%d'), strftime('%H:%M')
-- - julianday(a) - julianday(b) : 일수 차이
-- - datetime(a, '+1 day') 등 문자열 기반 연산도 가능
