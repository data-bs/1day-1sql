-- ====================================
-- 📌 문제 설명
-- ====================================
-- 문제: 팀별 총 승점과 득실차 구하기 (경기 수 2회 이상 팀만 포함)
-- 테이블: teams, matches

-- ====================================
-- 📦 예시 데이터 생성
-- ====================================

CREATE TABLE teams (
    team_id INTEGER NOT NULL,
    team_name VARCHAR(30) NOT NULL,
    UNIQUE(team_id)
);

CREATE TABLE matches (
    match_id INTEGER NOT NULL,
    host_team INTEGER NOT NULL,
    guest_team INTEGER NOT NULL,
    host_goals INTEGER NOT NULL,
    guest_goals INTEGER NOT NULL,
    UNIQUE(match_id)
);

INSERT INTO teams (team_id, team_name) VALUES
(10, 'Give'),
(20, 'Never'),
(30, 'You'),
(40, 'Up'),
(50, 'Gonna');

INSERT INTO matches (match_id, host_team, guest_team, host_goals, guest_goals) VALUES
(1, 30, 20, 1, 0),
(2, 10, 20, 1, 2),
(3, 20, 50, 2, 2),
(4, 10, 30, 1, 0),
(5, 30, 50, 0, 1);

-- ====================================
-- 📝 문제 조건
-- ====================================
-- 조건:
-- 1) 각 팀의 총 승점을 계산하시오.
--    - 승리 시 3점, 무승부 1점, 패배 0점
-- 2) 총 득실차(득점 - 실점)를 계산하시오.
-- 3) 총 경기 수가 2경기 이상인 팀만 결과에 포함합니다.
-- 4) 승점 내림차순 → 득실차 내림차순 → team_id 오름차순으로 정렬합니다.

-- ====================================
-- ✅ 정답 SQL 쿼리
-- ====================================

WITH all_results AS (
    -- 홈팀 결과
    SELECT
        host_team AS team_id,
        host_goals AS goals_for,
        guest_goals AS goals_against,
        CASE
            WHEN host_goals > guest_goals THEN 3
            WHEN host_goals = guest_goals THEN 1
            ELSE 0
        END AS points
    FROM matches

    UNION ALL

    -- 원정팀 결과
    SELECT
        guest_team AS team_id,
        guest_goals AS goals_for,
        host_goals AS goals_against,
        CASE
            WHEN guest_goals > host_goals THEN 3
            WHEN guest_goals = host_goals THEN 1
            ELSE 0
        END AS points
    FROM matches
),

aggregated AS (
    SELECT
        team_id,
        COUNT(*) AS games_played,
        SUM(points) AS total_points,
        SUM(goals_for) - SUM(goals_against) AS goal_diff
    FROM all_results
    GROUP BY team_id
),

filtered AS (
    SELECT *
    FROM aggregated
    WHERE games_played >= 2
)

SELECT
    t.team_id,
    t.team_name,
    f.total_points AS num_points,
    f.goal_diff
FROM filtered f
JOIN teams t
    ON f.team_id = t.team_id
ORDER BY
    f.total_points DESC,
    f.goal_diff DESC,
    t.team_id ASC;