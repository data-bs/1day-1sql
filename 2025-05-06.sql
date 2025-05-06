-- ====================================
-- 📌 문제 설명
-- ====================================
-- 문제: 사용자별로 하루에 한 번만 접속할 수 있는 시스템 로그가 있습니다.
-- 사용자가 접속한 일자별로 "이전 접속일로부터 며칠 후 접속했는지" 와
-- "다음 접속일까지 며칠 남았는지"를 계산하시오.

-- 계산 결과는 다음 컬럼을 포함합니다.
-- user_id, login_date, days_since_prev_login, days_until_next_login

-- 이전 접속이 없는 경우 days_since_prev_login은 NULL
-- 다음 접속이 없는 경우 days_until_next_login은 NULL

-- ====================================
-- 📦 예시 데이터 생성
-- ====================================

CREATE TABLE login_logs (
    user_id INTEGER,
    login_date DATE
);

INSERT INTO login_logs (user_id, login_date) VALUES
(1, '2024-01-01'),
(1, '2024-01-10'),
(1, '2024-01-25'),
(1, '2024-02-20'),
(2, '2024-03-01'),
(2, '2024-03-05'),
(2, '2024-03-20');

-- ====================================
-- 📝 문제 조건
-- ====================================
-- 조건:
-- 1. user_id별로 login_date 오름차순 정렬 기준으로 이전과 다음 로그인 날짜의 차이를 계산하시오.
-- 2. days_since_prev_login과 days_until_next_login 컬럼을 구할 것.
-- 3. 결과는 user_id, login_date 오름차순으로 정렬하시오.

-- ====================================
-- ✅ 정답 SQL 쿼리
-- ====================================

SELECT
    user_id,
    login_date,
    -- 이전 로그인과 차이
    login_date - LAG(login_date) OVER (PARTITION BY user_id ORDER BY login_date) AS days_since_prev_login,
    -- 다음 로그인과 차이
    LEAD(login_date) OVER (PARTITION BY user_id ORDER BY login_date) - login_date AS days_until_next_login
FROM
    login_logs
ORDER BY
    user_id,
    login_date;