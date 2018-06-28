--sqlplus ./this.sql &1 &2 &3
--report for exchange information with peers
--return xml formated file
--&1 = date start
--&2 = date end
--&3 = some/where/spoolfile.name

set pagesize 0;
set newpage 0;
set space 0;
set linesize 1000;
set heading off;
set long 9999999;
--set markup html on;
set trimspool on;
set trimout off;


spool '&3'
SELECT DBMS_XMLGEN.GETXML('
SELECT ''cyber security institute'' AS something_tag
    , B.INC_ID AS something_tag
    , A.CV78 AS something_tag
    , A.CV79 AS something_tag
    , C.NAME AS something_tag
    , B.INC_ID AS something_tag
    , C.NAME AS something_tag
    , (SELECT TO_CHAR(MIN(D.CHILD_EVT_TIME) + 8 / 24, ''YYYY-MM-DD HH24:MI:SS'') || ''.00'' FROM ESECDBA.CORRELATED_EVENTS D WHERE  A.EVT_ID = D.PARENT_EVT_ID) AS something_tag
    , (SELECT TO_CHAR(MAX(D.CHILD_EVT_TIME) + 8 / 24, ''YYYY-MM-DD HH24:MI:SS'') || ''.00'' FROM ESECDBA.CORRELATED_EVENTS D WHERE  A.EVT_ID = D.PARENT_EVT_ID) AS something_tag
    , A.RV24 AS something_tag
    , CONVER_NIP(A.SIP) AS something_tag
    , CONVER_NIP(A.DIP) AS something_tag
    , NVL(A.SP, A.SP_INT) AS something_tag
    , NVL(A.DP, A.DP_INT) AS something_tag
    , ''NULL'' AS something_tag
    , ''NULL'' AS something_tag
    , NVL(F.RULE_CUST_DESC, ''NULL'') AS something_tag
    , NVL(C.INC_RES , ''NULL'') AS something_tag
    , F.CUST_COM AS something_tag
    , ''NULL'' AS something_tag
    , C.SEVERITY * 2 AS something_tag
    , NVL(E.DEVICE_CTGRY, CONVER_NIP(A.OBSRVR_IP)) AS something_tag
    , C.NAME AS something_tag
    , C.NAME AS something_tag
    , ''NULL'' AS something_tag
    , ''NULL'' AS something_tag
    , (SELECT COUNT(D.CHILD_EVT_ID) FROM ESECDBA.CORRELATED_EVENTS D WHERE  A.EVT_ID = D.PARENT_EVT_ID) AS something_tag
    , ''NULL'' AS something_tag
FROM ESECDBA.EVENTS A
    , ESECDBA.INCIDENTS_EVENTS B
    , ESECDBA.INCIDENTS C
    , ESECDBA.EVT_AGENT E
    , ISPMGR.SOC_KM F
WHERE A.EVT_ID = B.EVT_ID
    AND B.INC_ID = C.INC_ID
    AND A.AGENT_ID = E.AGENT_ID
    AND A.MSG = F.RULE_ID
    AND A.CV78 IS NOT NULL AND A.CV79 IS NOT NULL
    AND A.EVT_TIME BETWEEN TO_DATE(''&1''||''000000'' , ''yyyymmddhh24miss'')-8/24 AND TO_DATE(''&2''||''235959'' , ''yyyymmddhh24miss'')-8/24
        ')
from dual;
exit


