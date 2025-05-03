-- ====================================
-- 📌 문제 설명
-- ====================================
-- 문제: 플레이어별 평균 점수가 전체 평균 이상인 사람 구하기
-- 테이블: players, scores

-- ====================================
-- 📦 예시 데이터 생성
-- ====================================

CREATE TABLE players (
    player_id INTEGER NOT NULL,
    player_name VARCHAR(50) NOT NULL,
    UNIQUE(player_id)
);

CREATE TABLE scores (
    score_id INTEGER NOT NULL,
    player_id INTEGER NOT NULL,
    score INTEGER NOT NULL,
    score_date DATE NOT NULL,
    UNIQUE(score_id)
);

INSERT INTO players (player_id, player_name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'David'),
(5, 'Eve');

INSERT INTO scores (score_id, player_id, score, score_date) VALUES
(1, 1, 80, '2024-01-01'),
(2, 1, 90, '2024-01-02'),
(3, 2, 50, '2024-01-01'),
(4, 2, 60, '2024-01-03'),
(5, 3, 95, '2024-01-02'),
(6, 3, 85, '2024-01-05'),
(7, 4, 40, '2024-01-01'),
(8, 5, 70, '2024-01-03'),
(9, 5, 75, '2024-01-04');

-- ====================================
-- 📝 문제 조건
-- ====================================
-- 조건:
-- 1) 플레이어별 평균 점수를 계산하시오.
-- 2) 전체 플레이어 평균 점수 이상인 플레이어만 결과에 포함합니다.
-- 3) 결과는 평균 점수 내림차순 → player_id 오름차순으로 정렬합니다.

-- ====================================
-- ✅ 정답 SQL 쿼리
-- ====================================

SELECT
    s.player_id,
    p.player_name,
    AVG(s.score) AS avg_score
FROM scores s
JOIN players p
    ON s.player_id = p.player_id
GROUP BY s.player_id, p.player_name
HAVING AVG(s.score) >= (SELECT AVG(score) FROM scores)
ORDER BY avg_score DESC, s.player_id ASC;