
-- 💡 SQL 문제: 유저별 최장 연속 로그인 기록

-- 📌 문제 설명
-- user_logins 테이블에는 사용자별 로그인 날짜 기록이 있습니다.
-- 각 사용자가 가장 길게 연속해서 로그인한 날짜 구간(start_date ~ end_date)과 
-- 그 연속 일수(streak_length)를 구하세요.

-- 결과 컬럼:
-- user_id         : 사용자 고유 ID
-- start_date      : 연속 로그인 시작 날짜
-- end_date        : 연속 로그인 마지막 날짜
-- streak_length   : 연속 로그인 일수

-- 🗃️ 테이블 생성
CREATE TABLE user_logins (
    user_id INT,
    login_date DATE
);

-- ✅ 예시 데이터 삽입
INSERT INTO user_logins (user_id, login_date) VALUES
-- user 1: 4일 연속, 3일 연속, 단발
(1, '2024-01-01'),
(1, '2024-01-02'),
(1, '2024-01-03'),
(1, '2024-01-04'),
(1, '2024-01-06'),
(1, '2024-01-10'),
(1, '2024-01-11'),
(1, '2024-01-12'),

-- user 2: 5일 연속 + 이틀씩 짝지은 기록
(2, '2024-02-01'),
(2, '2024-02-02'),
(2, '2024-02-03'),
(2, '2024-02-04'),
(2, '2024-02-05'),
(2, '2024-02-10'),
(2, '2024-02-11'),
(2, '2024-02-20'),
(2, '2024-02-21'),

-- user 3: 7일 연속 + 비정기적 기록
(3, '2024-03-01'),
(3, '2024-03-02'),
(3, '2024-03-03'),
(3, '2024-03-04'),
(3, '2024-03-05'),
(3, '2024-03-06'),
(3, '2024-03-07'),
(3, '2024-03-10'),
(3, '2024-03-11'),
(3, '2024-03-13');

-- ✅ 정답 쿼리 (PostgreSQL 기준)
-- login_date - RANK()를 이용해 날짜 차이 기반 그룹핑
-- 각 그룹에서 MIN, MAX로 구간을 정리하고
-- 각 유저별 최장 구간만 추출

WITH t AS (
    SELECT
        user_id,
        login_date,
        login_date - INTERVAL '1 day' * RANK() OVER (PARTITION BY user_id ORDER BY login_date) AS grp
    FROM user_logins
),
grouped AS (
    SELECT
        user_id,
        grp,
        MIN(login_date) AS start_date,
        MAX(login_date) AS end_date,
        COUNT(*) AS streak_length
    FROM t
    GROUP BY user_id, grp
),
ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY streak_length DESC) AS rn
    FROM grouped
)
SELECT user_id, start_date, end_date, streak_length
FROM ranked
WHERE rn = 1
ORDER BY user_id;
