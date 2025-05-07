-- ====================================
-- 📌 문제 설명
-- ====================================
-- 문제: 온라인 상점에서 고객별 주문 기록이 있습니다.
-- 각 주문 건에 대해 다음 3가지 정보를 계산하시오.
-- 1. 해당 고객의 모든 이전 주문을 포함한 현재까지의 누적 총 주문 금액.
-- 2. 해당 고객의 현재 주문을 제외한 모든 이전 주문들의 평균 주문 금액. (첫 주문의 경우 NULL)
-- 3. 해당 고객의 전체 주문 중에서 현재 주문 금액이 차지하는 순위 (주문 금액이 높은 순서대로 1위). 동일 금액은 공동 순위 처리.

-- 계산 결과는 다음 컬럼을 포함합니다.
-- order_id, customer_id, order_date, order_amount, cumulative_sales, average_prev_orders, order_rank_by_amount

-- ====================================
-- 📦 예시 데이터 생성 (PostgreSQL)
-- ====================================

CREATE TABLE orders (
order_id SERIAL PRIMARY KEY,
customer_id INTEGER,
order_date DATE,
order_amount DECIMAL(10, 2)
);

INSERT INTO orders (customer_id, order_date, order_amount) VALUES
(101, '2024-01-15', 50.00), -- Customer 101 First Order
(102, '2024-01-20', 75.00), -- Customer 102 First Order
(101, '2024-02-10', 120.00), -- Customer 101 Second Order
(103, '2024-02-15', 30.00), -- Customer 103 First Order
(101, '2024-03-01', 80.00), -- Customer 101 Third Order (Amount between first and second)
(102, '2024-03-05', 90.00), -- Customer 102 Second Order (Higher than first)
(101, '2024-03-20', 200.00), -- Customer 101 Fourth Order (Highest amount)
(103, '2024-04-01', 30.00), -- Customer 103 Second Order (Same amount)
(102, '2024-04-10', 60.00); -- Customer 102 Third Order (Lower than first)

-- ====================================
-- 📝 문제 조건
-- ====================================
-- 조건:
-- 1. 각 계산은 customer_id별로 독립적으로 수행되어야 합니다.
-- 2. order_date를 기준으로 시간 순서대로 계산합니다.
-- 3. 누적 주문 금액 (cumulative_sales)은 해당 주문을 포함하여 이전 모든 주문의 합계입니다.
-- 4. 이전 주문 평균 (average_prev_orders)은 현재 주문을 제외한, 해당 고객의 이전 모든 주문의 금액 평균입니다. 이전 주문이 없는 경우 (첫 주문)는 NULL로 표시합니다.
-- 5. 주문 금액 순위 (order_rank_by_amount)는 해당 고객의 전체 주문 금액 중 현재 주문 금액의 순위입니다 (높은 금액이 1위).
-- 6. 결과는 customer_id, order_date 오름차순으로 정렬해야 합니다.

-- ====================================
-- ✅ 정답 SQL 쿼리 (PostgreSQL)
-- ====================================

SELECT
    order_id,
    customer_id,
    order_date,
    order_amount,
    SUM(order_amount) OVER (PARTITION BY customer_id ORDER BY order_date) AS cumulative_sales,
    SUM(order_amount) OVER (PARTITION BY customer_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)
    /
    NULLIF(COUNT(order_amount) OVER (PARTITION BY customer_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0) AS average_prev_orders,
    RANK() OVER (PARTITION BY customer_id ORDER BY order_amount DESC) AS order_rank_by_amount
FROM
    orders
ORDER BY
    customer_id,
    order_date;