
-- 💡 SQL 문제 모음: PostgreSQL 날짜/시간 함수 연습 (초~중급)

-- 📌 문제 설명
-- 아래 문제들은 PostgreSQL의 다양한 날짜/시간 관련 함수들을 연습하기 위한 것입니다.
-- 각각의 문제를 해결하며, date_trunc, age, interval, extract 등 핵심 함수들을 익혀보세요.

-- 🗃️ 예시 테이블: user_events
CREATE TABLE user_events (
    event_id SERIAL PRIMARY KEY,
    user_id INT,
    event_type TEXT,
    event_time TIMESTAMP
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
-- 각 이벤트의 날짜(YYYY-MM-DD)를 출력하시오.
-- 사용 함수: ::DATE 또는 DATE_TRUNC

SELECT event_id, event_time::DATE AS event_date FROM user_events;

-- --------------------------------------
-- 🧪 문제 2: 시간만 추출 (HH:MI:SS)
-- 각 이벤트에서 시간만 추출하시오.
-- 사용 함수: TO_CHAR 또는 EXTRACT

SELECT event_id, TO_CHAR(event_time, 'HH24:MI:SS') AS event_time_only FROM user_events;

-- --------------------------------------
-- 🧪 문제 3: 이벤트의 요일 구하기
-- 각 이벤트가 무슨 요일(월~일)인지 구하시오.
-- 사용 함수: TO_CHAR 또는 EXTRACT(DOW)

SELECT event_id, TO_CHAR(event_time, 'Day') AS day_of_week FROM user_events;

-- --------------------------------------
-- 🧪 문제 4: 이벤트가 일어난 주차 계산
-- event_time 기준으로 몇 번째 주(Week of Year)에 해당하는지 구하시오.
-- 사용 함수: EXTRACT(WEEK FROM ...)

SELECT event_id, EXTRACT(WEEK FROM event_time) AS week_of_year FROM user_events;

-- --------------------------------------
-- 🧪 문제 5: 이벤트 간 시간 차이 계산
-- 같은 user_id의 login → logout 이벤트 간의 시간 차이를 구하시오.
-- 사용 함수: LAG, LEAD, AGE, INTERVAL 등

-- 예시: 로그인 시간과 다음 로그아웃 시간의 차이
-- 힌트: window 함수 + 조건절 필요

WITH ordered_events AS (
  SELECT *,
         LAG(event_type) OVER (PARTITION BY user_id ORDER BY event_time) AS prev_event_type,
         LAG(event_time) OVER (PARTITION BY user_id ORDER BY event_time) AS prev_event_time
  FROM user_events
)
SELECT
  user_id,
  prev_event_time AS login_time,
  event_time AS logout_time,
  event_time - prev_event_time AS session_duration
FROM ordered_events
WHERE event_type = 'logout'
  AND prev_event_type = 'login';

-- --------------------------------------
-- 🧪 문제 6: 월 단위 집계
-- 각 유저가 월별로 몇 번 로그인했는지 출력하시오.
-- 사용 함수: DATE_TRUNC, COUNT, GROUP BY

SELECT user_id,
        DATE_TRUNC('month', event_time) AS month,
        COUNT(*) FILTER (WHERE event_type = 'login') AS login_count
 FROM user_events
 GROUP BY user_id, month
 ORDER BY user_id, month;

-- --------------------------------------
-- 🧪 문제 7: 3일 이내 재접속한 경우 찾기
-- 같은 user_id가 로그인한 후 3일 이내 다시 로그인한 경우를 찾으시오.
-- 사용 함수: LAG, event_time + INTERVAL '3 days', 비교 연산자

WITH login_events AS (
  SELECT *
  FROM user_events
  WHERE event_type = 'login'
),
ordered_logins AS (
  SELECT *,
         LAG(event_time) OVER (PARTITION BY user_id ORDER BY event_time) AS prev_login_time
  FROM login_events
)
SELECT
  user_id,
  prev_login_time,
  event_time AS current_login_time,
  event_time - prev_login_time AS gap
FROM ordered_logins
WHERE prev_login_time IS NOT NULL
  AND event_time <= prev_login_time + INTERVAL '3 days';

-- --------------------------------------
-- 🧪 문제 8: 오늘 날짜와의 차이
-- 각 이벤트가 오늘(now()) 기준으로 며칠 전인지 구하시오.
-- 사용 함수: AGE, CURRENT_DATE, NOW

SELECT event_id, AGE(CURRENT_DATE, event_time::DATE) AS days_ago FROM user_events;

-- --------------------------------------

-- 📝 참고: PostgreSQL 주요 날짜 함수
-- - NOW(), CURRENT_DATE, CURRENT_TIMESTAMP
-- - AGE(a, b), a - b
-- - DATE_TRUNC('day'|'month'|'year', ts)
-- - TO_CHAR(ts, 'YYYY-MM-DD'), 'Day', 'HH24:MI'
-- - EXTRACT(YEAR|MONTH|DAY|DOW|WEEK FROM ts)
-- - INTERVAL '1 day', '2 hours'

-- TO_CHAR(NOW(), 'YYYY-MM-DD')        → '2025-05-11'
-- TO_CHAR(NOW(), 'HH24:MI:SS')        → '15:22:45'
-- TO_CHAR(NOW(), 'Day')               → 'Sunday   '
-- EXTRACT(YEAR FROM NOW())     → 2025
-- EXTRACT(MONTH FROM NOW())    → 5
-- EXTRACT(DAY FROM NOW())      → 11
-- EXTRACT(DOW FROM NOW())      → 0 (일요일, 0~6)
-- EXTRACT(EPOCH FROM INTERVAL '2 hours 30 min') → 9000 (초 단위)
-- DATE_TRUNC('month', TIMESTAMP '2024-02-12 14:25:00') → 2024-02-01 00:00:00
-- DATE_TRUNC('day',   TIMESTAMP '2024-02-12 14:25:00') → 2024-02-12 00:00:00
-- DATE_TRUNC('hour',  TIMESTAMP '2024-02-12 14:25:00') → 2024-02-12 14:00:00
