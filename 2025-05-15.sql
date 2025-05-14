-- ============================================================
-- 문제명: 숨은 고래를 찾아라
-- 게임사에서 고래(Heavy Payer)를 정교하게 분류하기 위한 문제
--
-- [조건]
-- 1. 총 과금액이 1,000,000원 이상
-- 2. 과금 후 7일 이내 로그인한 기록이 있는 과금만 인정
-- 3. 과금일로부터 14일 동안 하루도 빠짐없이 로그인해야 함
-- 4. 위 조건을 만족하는 과금이 2건 이상인 유저만 추출
-- ============================================================

-- =====================
-- 테이블 생성
-- =====================

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    nickname TEXT
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    payment_date DATE,
    amount INT -- 단위: 원
);

CREATE TABLE logins (
    user_id INT,
    login_date DATE
);

-- =====================
-- 예시 데이터 삽입
-- =====================

INSERT INTO users (user_id, nickname) VALUES
(1, '네르케'),
(2, '리유'),
(3, '하루카'),
(4, '스즈나');

INSERT INTO payments (user_id, payment_date, amount) VALUES
-- 유저 1: 3건 모두 조건 만족
(1, '2025-01-01', 500000),
(1, '2025-01-15', 300000),
(1, '2025-02-01', 300000),

-- 유저 2: 총 과금은 충분하지만 로그인 조건 일부 미달
(2, '2025-01-01', 600000),
(2, '2025-03-01', 500000),

-- 유저 3: 금액은 낮지만 과금-로그인 패턴은 좋음
(3, '2025-04-01', 100000),
(3, '2025-04-10', 120000),

-- 유저 4: 과금 없음
-- (none)
;

-- 로그인 기록 삽입
INSERT INTO logins (user_id, login_date) VALUES
-- 유저 1: 과금 이후 14일 연속 로그인
(1, '2025-01-01'), (1, '2025-01-02'), (1, '2025-01-03'), (1, '2025-01-04'), (1, '2025-01-05'),
(1, '2025-01-06'), (1, '2025-01-07'), (1, '2025-01-08'), (1, '2025-01-09'), (1, '2025-01-10'),
(1, '2025-01-11'), (1, '2025-01-12'), (1, '2025-01-13'), (1, '2025-01-14'),

(1, '2025-01-15'), (1, '2025-01-16'), (1, '2025-01-17'), (1, '2025-01-18'), (1, '2025-01-19'),
(1, '2025-01-20'), (1, '2025-01-21'), (1, '2025-01-22'), (1, '2025-01-23'), (1, '2025-01-24'),
(1, '2025-01-25'), (1, '2025-01-26'), (1, '2025-01-27'), (1, '2025-01-28'),

(1, '2025-02-01'), (1, '2025-02-02'), (1, '2025-02-03'), (1, '2025-02-04'), (1, '2025-02-05'),
(1, '2025-02-06'), (1, '2025-02-07'), (1, '2025-02-08'), (1, '2025-02-09'), (1, '2025-02-10'),
(1, '2025-02-11'), (1, '2025-02-12'), (1, '2025-02-13'), (1, '2025-02-14'),

-- 유저 2: 과금 후 로그인은 있으나 14일 연속은 안 됨
(2, '2025-01-02'), (2, '2025-01-03'),
(2, '2025-03-02'), (2, '2025-03-05'), (2, '2025-03-08'),

-- 유저 3: 조건은 맞지만 과금액이 낮음
(3, '2025-04-01'), (3, '2025-04-02'), (3, '2025-04-03'), (3, '2025-04-04'), (3, '2025-04-05'),
(3, '2025-04-06'), (3, '2025-04-07'), (3, '2025-04-08'), (3, '2025-04-09'), (3, '2025-04-10'),
(3, '2025-04-11'), (3, '2025-04-12'), (3, '2025-04-13'), (3, '2025-04-14'),
(3, '2025-04-10'), (3, '2025-04-11'), (3, '2025-04-12'), (3, '2025-04-13'), (3, '2025-04-14'),
(3, '2025-04-15'), (3, '2025-04-16'), (3, '2025-04-17'), (3, '2025-04-18'), (3, '2025-04-19');

-- =====================
-- 정답 쿼리 시작
-- =====================

WITH total_spenders AS (
    SELECT
        user_id,
        SUM(amount) AS total_amount
    FROM payments
    GROUP BY user_id
    HAVING SUM(amount) >= 1000000
),

payments_with_login7d AS (
    SELECT
        p.user_id,
        p.payment_id,
        p.payment_date,
        p.amount,
        EXISTS (
            SELECT 1 FROM logins l
            WHERE l.user_id = p.user_id
              AND l.login_date BETWEEN p.payment_date AND p.payment_date + INTERVAL '7 days'
        ) AS has_login_in_7d
    FROM payments p
    WHERE p.user_id IN (SELECT user_id FROM total_spenders)
),

days_missed_in_14d AS (
    SELECT
        p.user_id,
        p.payment_id,
        COUNT(*) AS missed_days
    FROM (
        SELECT
            p.user_id,
            p.payment_id,
            generate_series(p.payment_date, p.payment_date + INTERVAL '13 days', INTERVAL '1 day')::date AS day
        FROM payments_with_login7d p
        WHERE has_login_in_7d = TRUE
    ) d
    LEFT JOIN logins l ON d.user_id = l.user_id AND d.day = l.login_date
    WHERE l.login_date IS NULL
    GROUP BY p.user_id, p.payment_id
),

qualified_payments AS (
    SELECT
        p.user_id,
        p.payment_id
    FROM payments_with_login7d p
    LEFT JOIN days_missed_in_14d m ON p.payment_id = m.payment_id
    WHERE p.has_login_in_7d = TRUE AND COALESCE(m.missed_days, 0) = 0
),

final_whales AS (
    SELECT
        user_id
    FROM qualified_payments
    GROUP BY user_id
    HAVING COUNT(*) >= 2
)

SELECT
    u.user_id,
    u.nickname
FROM final_whales f
JOIN users u ON f.user_id = u.user_id
ORDER BY u.user_id;