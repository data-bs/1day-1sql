-- ====================================
-- 📌 문제 설명
-- ====================================
-- 문제: 2024년 주문 데이터를 기준으로 아래 조건을 모두 만족하는 고객 ID, 고객명, 마지막 주문일자 구하기
-- 테이블: customers, orders, reviews

-- ====================================
-- 📦 예시 데이터 생성
-- ====================================

CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    customer_name VARCHAR(50) NOT NULL,
    UNIQUE(customer_id)
);

CREATE TABLE orders (
    order_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    order_date DATE NOT NULL,
    amount DECIMAL(10,2),
    UNIQUE(order_id)
);

CREATE TABLE reviews (
    review_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    review_date DATE NOT NULL,
    content TEXT,
    UNIQUE(review_id)
);

INSERT INTO customers (customer_id, customer_name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'David'),
(5, 'Eve'),
(6, 'Frank');

INSERT INTO orders (order_id, customer_id, order_date, amount) VALUES
(101, 1, '2024-01-10', 300.00),
(102, 1, '2024-06-10', 500.00),
(103, 2, '2024-05-05', 150.00),
(104, 2, '2024-08-05', 250.00),
(105, 3, '2024-03-20', 700.00),
(106, 3, '2023-12-25', 600.00),
(107, 4, '2024-04-18', 500.00),
(108, 4, '2024-07-22', 800.00),
(109, 5, '2024-05-30', 200.00),
(110, 6, '2024-06-30', 900.00),
(111, 6, '2024-09-01', 950.00);

INSERT INTO reviews (review_id, customer_id, review_date, content) VALUES
(301, 1, '2024-04-01', 'Excellent'),
(302, 4, '2024-07-15', 'Good');

-- ====================================
-- 📝 문제 조건
-- ====================================
-- 조건:
-- 1) 2024년 주문 총 금액이 전체 고객 중 상위 50%에 속하는 고객이어야 함 (PERCENT_RANK 사용)
-- 2) 2024년 주문 중 300 이하 금액으로 주문한 적이 없는 고객만 포함 (MIN + HAVING 사용)
-- 3) 2024년에 리뷰를 작성한 고객만 포함 (EXISTS 사용)
-- 4) 결과는 고객 ID 오름차순 정렬

-- ====================================
-- ✅ 정답 SQL 쿼리
-- ====================================

WITH order_total_2024 AS (
    SELECT
        customer_id,
        SUM(amount) AS total_amount
    FROM orders
    WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31'
    GROUP BY customer_id
),
ranked_customers AS (
    SELECT
        customer_id,
        total_amount,
        PERCENT_RANK() OVER (ORDER BY total_amount DESC) AS amount_rank
    FROM order_total_2024
),
valid_customers AS (
    SELECT
        o.customer_id
    FROM orders o
    WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31'
    GROUP BY o.customer_id
    HAVING MIN(amount) > 300
),
reviewed_customers AS (
    SELECT DISTINCT customer_id
    FROM reviews
    WHERE review_date BETWEEN '2024-01-01' AND '2024-12-31'
)
SELECT
    c.customer_id,
    c.customer_name,
    MAX(o.order_date) AS last_order_date
FROM customers c
JOIN ranked_customers rc
  ON c.customer_id = rc.customer_id
JOIN valid_customers vc
  ON c.customer_id = vc.customer_id
JOIN reviewed_customers rvc
  ON c.customer_id = rvc.customer_id
JOIN orders o
  ON c.customer_id = o.customer_id
WHERE rc.amount_rank <= 0.5
  AND o.order_date BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY c.customer_id, c.customer_name
ORDER BY c.customer_id ASC;