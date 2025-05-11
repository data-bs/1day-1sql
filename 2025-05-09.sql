
-- 💡 SQL 문제: 유저별 누적 로그인 일 수 계산

-- 📌 문제 설명
-- user_logins 테이블에는 사용자별 로그인 날짜 기록이 있습니다.
-- 각 유저에 대해 로그인 날짜를 기준으로 정렬했을 때,
-- 매일 현재까지 몇 번이나 로그인했는지를 나타내는 누적 로그인 일수를 구하세요.

-- 결과 컬럼:
-- user_id         : 사용자 고유 ID
-- login_date      : 로그인 날짜
-- cumulative_days : 해당 날짜까지 누적 로그인 일 수

-- 🗃️ 테이블 생성
CREATE TABLE user_logins (
    user_id INT,
    login_date DATE
);

-- ✅ 예시 데이터 삽입
INSERT INTO user_logins (user_id, login_date) VALUES
-- user 1: 5번 로그인
(1, '2024-01-01'),
(1, '2024-01-02'),
(1, '2024-01-05'),
(1, '2024-01-10'),
(1, '2024-01-12'),

-- user 2: 4번 로그인
(2, '2024-02-01'),
(2, '2024-02-03'),
(2, '2024-02-04'),
(2, '2024-02-10'),

-- user 3: 3번 로그인
(3, '2024-03-01'),
(3, '2024-03-05'),
(3, '2024-03-07');

-- ✅ 정답 쿼리 (PostgreSQL 기준)
-- 각 로그인 날짜까지의 누적 로그인 횟수를 출력
-- PARTITION BY user_id + ORDER BY login_date 조합으로 해결 가능

SELECT
    user_id,
    login_date,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY login_date) AS cumulative_days
FROM user_logins
ORDER BY user_id, login_date;
