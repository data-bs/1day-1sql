
-- 💡 퍼널 분석 문제 + 고급 확장 (단계별 시간 차이 계산)

-- ===========================================
-- 🧪 문제: 사용자 행동 퍼널 분석
-- ===========================================
-- 테이블: events(user_id, event_name, event_time)
-- 이벤트 종류: 'visit', 'add_to_cart', 'purchase'

-- 🎯 목표 1: 3단계 모두 수행한 사용자 찾기
-- 🎯 목표 2: 각 사용자에 대해
--           - visit → add_to_cart 간 소요 시간 (분)
--           - add_to_cart → purchase 간 소요 시간 (분)
--           - visit → purchase 전체 시간 (분)
-- 을 구하시오.

-- ✅ 테이블 생성 및 예시 데이터

CREATE TABLE events (
    user_id INTEGER,
    event_name TEXT,
    event_time TEXT
);

INSERT INTO events (user_id, event_name, event_time) VALUES
(1, 'visit', '2024-01-01 08:00:00'),
(1, 'add_to_cart', '2024-01-01 08:10:00'),
(1, 'purchase', '2024-01-01 08:20:00'),
(2, 'visit', '2024-01-02 09:00:00'),
(2, 'add_to_cart', '2024-01-02 09:05:00'),
(3, 'visit', '2024-01-03 10:00:00'),
(3, 'purchase', '2024-01-03 10:15:00'),
(4, 'visit', '2024-01-04 11:00:00'),
(4, 'add_to_cart', '2024-01-04 11:10:00'),
(4, 'purchase', '2024-01-04 11:20:00');

-- ===========================================
-- ✅ 정답 1: 퍼널 3단계 모두 완료한 사용자
SELECT user_id
FROM events
WHERE event_name IN ('visit', 'add_to_cart', 'purchase')
GROUP BY user_id
HAVING COUNT(DISTINCT event_name) = 3;

-- ===========================================
-- ✅ 정답 2: 각 사용자별 단계 간 소요 시간 계산 (분 단위)

WITH filtered AS (
  SELECT *
  FROM events
  WHERE event_name IN ('visit', 'add_to_cart', 'purchase')
),
pivoted AS (
  SELECT
    user_id,
    MAX(CASE WHEN event_name = 'visit' THEN event_time END) AS visit_time,
    MAX(CASE WHEN event_name = 'add_to_cart' THEN event_time END) AS cart_time,
    MAX(CASE WHEN event_name = 'purchase' THEN event_time END) AS purchase_time
  FROM filtered
  GROUP BY user_id
),
final AS (
  SELECT *,
         CAST((julianday(cart_time) - julianday(visit_time)) * 24 * 60 AS INTEGER) AS visit_to_cart_min,
         CAST((julianday(purchase_time) - julianday(cart_time)) * 24 * 60 AS INTEGER) AS cart_to_purchase_min,
         CAST((julianday(purchase_time) - julianday(visit_time)) * 24 * 60 AS INTEGER) AS total_funnel_min
  FROM pivoted
)
SELECT *
FROM final
WHERE visit_time IS NOT NULL AND cart_time IS NOT NULL AND purchase_time IS NOT NULL;
