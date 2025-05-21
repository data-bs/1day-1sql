-- 물론! 아래는 위의 SQL 문제를 Markdown 형식으로 깔끔하게 정리한 내용이야.
-- 
-- ⸻
-- 
-- 📘 SQL 문제: 두 번째로 높은 월급을 받는 직원의 이름 구하기
-- 
-- 🔹 테이블 구조: employees
-- 
-- 컬럼명	자료형	설명
-- id	INTEGER	직원 ID (Primary)
-- name	TEXT	직원 이름
-- salary	INTEGER	월급
-- 
-- 
-- ⸻
-- 
-- ❓ 문제 설명
-- 	•	두 번째로 높은 고유한 월급을 받는 직원의 이름을 구하시오.
-- 	•	같은 월급을 받는 사람이 여러 명 있을 수 있습니다.
-- 	•	결과는 두 번째로 높은 월급을 받는 모든 직원의 이름을 포함해야 합니다.
-- 
-- ⸻
-- 
-- ✅ 정답 SQL

SELECT name
FROM employees
WHERE salary = (
    SELECT DISTINCT salary
    FROM employees
    ORDER BY salary DESC
    LIMIT 1 OFFSET 1
);