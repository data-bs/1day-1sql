-- ====================================
-- 📌 문제 설명
-- ====================================
-- 문제: 부서별 평균 급여 구하기
-- 테이블: employees

-- ====================================
-- 📦 예시 데이터 생성
-- ====================================

CREATE TABLE employees (
    id INTEGER,
    name VARCHAR(100),
    department VARCHAR(100),
    salary INTEGER,
    join_date DATE
);

INSERT INTO employees (id, name, department, salary, join_date) VALUES
(1, 'Alice', 'HR', 4000, '2022-03-01'),
(2, 'Bob', 'IT', 6000, '2021-07-15'),
(3, 'Charlie', 'IT', 6600, '2020-09-10'),
(4, 'David', 'Sales', 5000, '2023-01-20'),
(5, 'Eve', 'Sales', 5400, '2023-03-15'),
(6, 'Frank', 'HR', 4200, '2020-05-25');

-- ====================================
-- 📝 문제 조건
-- ====================================
-- 조건: 최근 2년 이내 입사한 직원들만 대상으로 부서별 평균 급여를 계산하시오.
-- 평균 급여는 소수점 1자리까지 반올림하며 부서명 기준 오름차순으로 정렬합니다.

-- ====================================
-- ✅ 정답 SQL 쿼리
-- ====================================

SELECT
    department,
    ROUND(AVG(salary), 1) AS avg_salary
FROM
    employees
WHERE
    join_date >= DATE('now', '-2 years')
GROUP BY
    department
ORDER BY
    department;