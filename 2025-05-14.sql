-- 🎮 문제: “VIP 유저 등급 분류 및 최근 과금 이탈 여부 분석”
-- 
-- 1. 설명
-- 
-- 다음은 유저의 과금 기록과 유저 프로필이다.
-- 
-- 조건은 다음과 같다:
-- 	1.	유저의 누적 과금액 기준으로 VIP 등급을 분류한다:
-- 	•	VIP_S: 1,000,000원 이상
-- 	•	VIP_A: 500,000원 이상 1,000,000원 미만
-- 	•	VIP_B: 100,000원 이상 500,000원 미만
-- 	•	일반: 그 미만
-- 	2.	각 유저가 마지막으로 과금한 시점부터 오늘(2025-05-14)까지의 일 수를 계산한다.
-- 	3.	마지막 과금이 30일 이상 전이면 is_churned = TRUE, 아니면 FALSE로 표시한다.
-- 
-- 2. 테이블 구조
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    nickname TEXT,
    join_date DATE
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    payment_date DATE,
    amount INT -- 단위: 원
);

-- 3. INSERT 예시
INSERT INTO users (user_id, nickname, join_date) VALUES
(1, 'A', '2025-01-01'),
(2, 'B', '2025-02-01'),
(3, 'C', '2025-03-10'),
(4, 'D', '2025-01-20');

INSERT INTO payments (user_id, payment_date, amount) VALUES
-- A: VIP_S, 최근 결제
(1, '2025-01-10', 200000),
(1, '2025-02-15', 300000),
(1, '2025-03-10', 600000),

-- B: VIP_A, 마지막 결제 오래됨
(2, '2025-02-02', 300000),
(2, '2025-02-10', 250000),

-- C: VIP_B, 최근 결제
(3, '2025-05-10', 150000),

-- D: 일반, 결제 없음
-- 없음
;

-- 4. 정답
WITH total_payments AS (
    SELECT
        u.user_id,
        u.nickname,
        COALESCE(SUM(p.amount), 0) AS total_amount,
        MAX(p.payment_date) AS last_payment_date
    FROM users u
    LEFT JOIN payments p ON u.user_id = p.user_id
    GROUP BY u.user_id, u.nickname
),
classified AS (
    SELECT *,
        CASE
            WHEN total_amount >= 1000000 THEN 'VIP_S'
            WHEN total_amount >= 500000 THEN 'VIP_A'
            WHEN total_amount >= 100000 THEN 'VIP_B'
            ELSE '일반'
        END AS vip_grade,
        CASE
            WHEN last_payment_date IS NULL THEN TRUE
            WHEN CURRENT_DATE - last_payment_date >= 30 THEN TRUE
            ELSE FALSE
        END AS is_churned
    FROM total_payments
)
SELECT *
FROM classified
ORDER BY user_id;

