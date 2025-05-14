-- 🎮 문제: “7일 연속 로그인 유저 찾기”
-- 
-- 1. 설명
-- 
-- 게임 회사는 **신규 유저의 잔존율(Retention)**을 중요하게 생각합니다.
-- 다음은 유저들의 로그인 기록입니다. 이 중에서 처음 로그인한 날로부터 7일간 연속으로 로그인한 유저만 골라주세요.
-- 	•	단, 로그인 날짜는 중복이 있을 수 있으며, 중복은 제거하고 연속 여부를 판단합니다.
-- 	•	로그인은 유저 기준으로 확인합니다.
-- 	•	7일 연속 로그인은 “예: 2025-05-01, 02, 03, 04, 05, 06, 07”처럼 끊김 없이 7일이 존재해야 합니다.
-- 
-- 2. 테이블 구조
CREATE TABLE user_logins (
    user_id INT,
    login_date DATE
);

-- 3. 테이블 INSERT
INSERT INTO user_logins (user_id, login_date) VALUES
-- 유저 1: 연속 로그인 (정답)
(1, '2025-05-01'), (1, '2025-05-02'), (1, '2025-05-03'),
(1, '2025-05-04'), (1, '2025-05-05'), (1, '2025-05-06'),
(1, '2025-05-07'),

-- 유저 2: 하루 빠짐 (오답)
(2, '2025-05-01'), (2, '2025-05-02'), (2, '2025-05-03'),
(2, '2025-05-04'), (2, '2025-05-06'), (2, '2025-05-07'),
(2, '2025-05-08'),

-- 유저 3: 중복 있음 (정답)
(3, '2025-05-01'), (3, '2025-05-01'), (3, '2025-05-02'),
(3, '2025-05-03'), (3, '2025-05-04'), (3, '2025-05-05'),
(3, '2025-05-06'), (3, '2025-05-07'),

-- 유저 4: 너무 짧음 (오답)
(4, '2025-05-01'), (4, '2025-05-02'), (4, '2025-05-03');

-- 4. 정답
WITH distinct_logins AS (
    SELECT DISTINCT user_id, login_date
    FROM user_logins
),
ranked_logins AS (
    SELECT
        user_id,
        login_date,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY login_date) AS rn
    FROM distinct_logins
),
grouped_logins AS (
    SELECT
        user_id,
        login_date,
        login_date - (rn * INTERVAL '1 day') AS grp
    FROM ranked_logins
),
grouped_counts AS (
    SELECT
        user_id,
        COUNT(*) AS streak_length
    FROM grouped_logins
    GROUP BY user_id, grp
)
SELECT DISTINCT user_id
FROM grouped_counts
WHERE streak_length >= 7
ORDER BY user_id;