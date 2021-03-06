-- java에서는 날짜 포맷의 대소문자를 가린다.(MM/mm 달/분)
-- 주간일자(1~7) : 월요일1, 화요일2 .... 토요일 7
-- 주차 IW : ISO표준 해당주의 목요일을 기준으로 주차를 산정
--          2019/12/31 화요일 -> 2020/01/02(목요일) --> 그렇기 때문에 1주차로 산정
SELECT TO_CHAR(SYSDATE, 'YYYY-MM/DD HH24:MI:SS'),
       TO_CHAR(SYSDATE,'D'),
       TO_CHAR(SYSDATE,'IW'),
       TO_CHAR(TO_DATE('2019/12/31','YYYY/MM/DD'),'IW')
FROM dual;

--emp 테이블의 hiredate(입사일자)컬럼의 년월일 시:분:초
SELECT ename, hiredate, TO_CHAR(hiredate, 'YYYY-MM-DD HH24:MI:SS'),
        TO_CHAR(hiredate+ 1, 'YYYY-MM-DD HH24:MI:SS'),
        TO_CHAR(hiredate+ 1/24, 'YYYY-MM-DD HH24:MI:SS'),
        TO_CHAR(hiredate + 30/1440 , 'YYYY-MM-DD HH24:MI:SS')
FROM emp;

SELECT SYSDATE DT_DASH, 
TO_CHAR(sysdate,'YYYY-MM-DD HH24-MI-SS') DT_DASH_WITH_TIME, 
TO_CHAR(sysdate,'DD-MM-YYYY') DT_DD_MM_YYYY
FROM dual;

--MONTHS_BETWEEN(DATE, DATE)
-- 인자로 들어온 두 날짜 사이의 개월수를 리턴
SELECT empno, hiredate,
       MONTHS_BETWEEN(sysdate, hiredate),
       MONTHS_BETWEEN(TO_DATE('2020-01-17','yyyy-mm-dd'),hiredate)
FROM emp
WHERE ename = 'SMITH';

--ADD_MONTHS(DATE,정수-가감할 개월수)
SELECT ADD_MONTHS(SYSDATE,5), --2020/01/29 --> 2020/06/29
       ADD_MONTHS(SYSDATE,-5)
FROM dual;

-- NEXT_DAY(DATE, 주간일자), ex) NEXT_DAY(SYSDATE,5)--> SYSDATE이후 처음 등장하는 주간일자 5에 해당하는 일자
                            -- SYSDATE 2020/01/29(수) 이후 처음 등장하는 5(목요일)->2020/01/30(목)
SELECT NEXT_DAY(SYSDATE,5) 
FROM DUAL;

-- LAST_DAY(DATE) DATE가 속한 월의 마지막 일자를 리턴
SELECT LAST_DAY(SYSDATE)
FROM dual;

-- LAST_DAY를 통해 인자로 들어온 date가 속한 월의 마지막 일자를 구할 수 있는데 date의 첫번째 일자는 어떻게 구할까?
SELECT  SYSDATE,
        LAST_DAY(SYSDATE),
        LAST_DAY(ADD_MONTHS(SYSDATE,-1))+1 FIRST_DAY
FROM dual;

-- hiredate 값을 이용하여 해당 월의 첫번째 일자로 표현
SELECT ename, hiredate,LAST_DAY(ADD_MONTHS(hiredate,-1))+1 FIRST_DAY
FROM emp;


-- empno는 NUMBER 타입, 인자는 문자열
-- 타입이 맞지 않기 때문에 묵시적 형변환이 일어남.
-- 테이블 컬럼의 타입에 맞게 올바른 인자 값을 주는게 중요
SELECT *
FROM emp
WHERE empno = '7369';

SELECT *
FROM emp
WHERE empno = 7369;

--hiredate 타입은 date타입, 인자는 문자열로 주었기때문에 묵시적 형변환이 발생
-- 날짜 문자열보다 날짜 타입으로 명시적으로 기술하는 것이 좋음
SELECT *
FROM emp
WHERE hiredate = '1980/12/17';

SELECT *
FROM emp
WHERE hiredate = to_date('1980/12/17','yyyy/mm/dd');

EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE empno = '7369';

SELECT*
FROM table(dbms_xplan.display);

-- 숫자를 문자열로 변경하는 경우 : 포맷
-- 천단위
-- 한국 1,000.50
-- 독일 1.000,50

-- emp sal 컬럼(NUMBER 타입)을 포맷팅
-- 9 : 숫자
-- 0 : 강제 자리 맞춤(0으로 표기)
-- L : 통화단위


SELECT ename, sal, TO_CHAR(sal,'L0,999')
FROM emp;

-- NULL에 대한 연산의 결과는 항상 NULL
-- emp 테이블의 sal컬럼에는 null 데이터가 존재하지 않음(14건의 데이터에 대해)
-- emp 테이블의 comm컬럼에는 null 데이터가 존재 (14건의 데이터에 대해)
-- sal + comm -> comm이 null인 행에 대해서는 결과 null로 나온다.
-- 요구사항이 comm이 null이면 sal컬럼의 값만 조회
-- 요구사항이 충족 시키지 못한다 -> sw에서는 결함

--NVL(타겟, 대체값) 타겟의 값이 null이면 대체값을 반환, null값이 아니면 타겟값 반환
SELECT ename, sal, NVL(comm,0), NVL(sal + comm,sal)
FROM emp;

--NVL2(expr1, expr2, expr3)
--if(expr1 != null) return expr2 else return expr3
SELECT ename, sal, comm, NVL2(comm,10000,0)
FROM emp;

--nullif(expr1, expr2)
--if(expr1 == expr2) return null else return expr1
SELECT ename, sal, comm, nullif(sal,1250) -- sal값이 1250인 사원은 null값 아닌사람은 sal값을 리턴
FROM emp;

-- 가변인자
-- COALESCE 인자중에 가장 처음으로 등장하는 NULL값이 아닌값을 찾아 리턴
-- COALESCE(expr1,expr2...)
-- if(expr1 != null) return expr1 else return COALESCE(expr2, expr3...)...
SELECT ename, sal, comm, COALESCE(comm, sal)
FROM emp;

SELECT empno,ename,mgr, nvl(mgr,9999) mgr_n, nvl2(mgr,mgr,9999) mgr_n_1, coalesce(mgr,9999) mgr_n_2
FROM emp;

SELECT userid, usernm, reg_dt, NVL(reg_dt,SYSDATE) n_reg_dt
FROM users
WHERE usernm != '브라운';

--CASE : JAVA의 if - else if - else
--CASE 
--    WHEN 조건 THEN 리턴값1
--    WHEN 조건 THEN 리턴값2
--    ELSE 기본값
--END
--emp 테이블에서 job컬럼의 값이 SALESMAN이면 SAL * 1.05 리턴 MANAGER 이면 SAL * 1.1 리턴 PRESIDENT이면 SAL * 1.2 리턴 그밖의 사람은 SAL을 리턴

SELECT ename, sal, job, 
    case 
        when job = 'SALESMAN' then sal * 1.05
        when job = 'MANAGER' then sal * 1.1
        when job = 'PRESIDENT' then sal * 1.2
        ELSE SAL
    END AS total
FROM emp;

--DECODE 함수 : CASE절과 유사
--(다른점 CASE 절 : WHEN 절에 조건비교가 자유롭다.
--       DECODE 함수 : 하나의 값에 대해서 = 비교만 허용)
--DECODE 함수도 가변인자(인자의 개수가 상황에 따라서 바뀜)
--DECODE(col|expr, 첫번째 인자와 비교할 값1, 첫번째 이자와 두번째 인자가 같을경우 반환 값, 첫번째 인자와 비교할 값2, 첫번째 인자와 네번째 인자가 같을경우
--반환값2,..., option - else 최종적으로 반활할 기본값)

SELECT ename, sal, job, 
    DECODE(JOB,'SALESMAN',SAL * 1.05,'MANAGER', SAL * 1.1,'PRESIDENT',SAL * 1.2,SAL)
     AS total
FROM emp;

--emp 테이블에서 job컬럼의 값이 SALESMAN이면서 SAL값이 1400보다 크면 SAL * 1.05 리턴 
--                          MANAGER 이면서 SAL값이 1400보다 작으면 SAL * 1.1 리턴
--                          MANAGER 이면 SAL * 1.1 리턴
--                          PRESIDENT이면 SAL * 1.2 리턴 그밖의 사람은 SAL을 리턴

SELECT ename, sal, job, 
    case 
        when job = 'SALESMAN' AND SAL > 1400 then sal * 1.05
        when job = 'MANAGER' AND SAL < 1400 then sal * 1.1
        when job = 'MANAGER' then sal * 1.1
        when job = 'PRESIDENT' then sal * 1.2
        ELSE SAL
    END AS total
FROM emp;

SELECT ename, sal, job, 
    DECODE(JOB,'SALESMAN', (CASE 
                                WHEN SAL > 1400 THEN SAL * 1.05 
                                ELSE SAL END),
                'MANAGER', (CASE
                                WHEN SAL < 1400 THEN SAL * 1.1
                                ELSE SAL * 1.1 END),
                'PRESIDENT',SAL * 1.2, SAL)
     AS total
FROM emp;