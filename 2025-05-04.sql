-- ====================================
-- 📌 문제 설명
-- ====================================
-- 문제: 이벤트에 참여했지만 상품을 수령하지 않은 고객 ID와 이름 구하기
-- 테이블: customers, event_participation, prizes

-- ====================================
-- 📦 예시 데이터 생성
-- ====================================

CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    customer_name VARCHAR(50) NOT NULL,
    UNIQUE(customer_id)
);

CREATE TABLE event_participation (
    participation_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    participate_date DATE NOT NULL,
    UNIQUE(participation_id)
);

CREATE TABLE prizes (
    prize_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    prize_date DATE NOT NULL,
    UNIQUE(prize_id)
);

INSERT INTO customers (customer_id, customer_name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'David'),
(5, 'Eve');

INSERT INTO event_participation (participation_id, customer_id, participate_date) VALUES
(100, 1, '2024-02-01'),
(101, 2, '2024-02-03'),
(102, 3, '2024-02-05'),
(103, 5, '2024-02-07');

INSERT INTO prizes (prize_id, customer_id, prize_date) VALUES
(201, 1, '2024-02-10'),
(202, 5, '2024-02-11');

-- ====================================
-- 📝 문제 조건
-- ====================================
-- 조건:
-- 1) 이벤트 참여 기록이 있어야 함 (EXISTS 사용)
-- 2) 상품 수령 기록은 없어야 함 (NOT EXISTS 사용)
-- 3) 고객 ID 오름차순 정렬

-- ====================================
-- ✅ 정답 SQL 쿼리
-- ====================================

SELECT
    c.customer_id,
    c.customer_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM event_participation ep
    WHERE ep.customer_id = c.customer_id
)
AND NOT EXISTS (
    SELECT 1
    FROM prizes p
    WHERE p.customer_id = c.customer_id
)
ORDER BY c.customer_id ASC;