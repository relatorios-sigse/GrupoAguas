create view REPORTEAREAS as
select
cddepartment,
iddepartment,
nmdepartment,
parent,
full_path,
case when cddireccion1 is not null and cddireccion2 is null and parent <> '-' then cddireccion2 else cddireccion1 end cddireccion1,
case when cddireccion1 is not null and cddireccion2 is null and parent <> '-' then iddireccion2 else iddireccion1 end iddireccion1,
case when cddireccion1 is not null and cddireccion2 is null and parent <> '-' then direccion2 else direccion1 end direccion1,
case when cddireccion1 is not null and cddireccion2 is null and parent <> '-' then cddireccion1 else cddireccion2 end cddireccion2,
case when cddireccion1 is not null and cddireccion2 is null and parent <> '-' then iddireccion1 else iddireccion2 end iddireccion2,
case when cddireccion1 is not null and cddireccion2 is null and parent <> '-' then direccion1 else direccion2 end direccion2,
cdgerencia,
idgerencia,
gerencia,
cdsubgerencia,
idsubgerencia,
subgerencia,
cdjefagencia,
idjefagencia,
jefatura_agencia
from
(select 
cddepartment,
iddepartment,
nmdepartment,
 parent,
full_path,
(select cddepartment from addepartment where nmdepartment = direccion1) cddireccion1,
(select iddepartment from addepartment where nmdepartment = direccion1) iddireccion1,
direccion1,
(select cddepartment from addepartment where nmdepartment = direccion2) cddireccion2,
(select iddepartment from addepartment where nmdepartment = direccion2) iddireccion2,
direccion2,
(select cddepartment from addepartment where nmdepartment = gerencia) cdgerencia,
(select iddepartment from addepartment where nmdepartment = gerencia) idgerencia,
gerencia,
(select cddepartment from addepartment where nmdepartment = subgerencia) cdsubgerencia,
(select iddepartment from addepartment where nmdepartment = subgerencia) idsubgerencia,
subgerencia,
(select cddepartment from addepartment where nmdepartment = jefatura_agencia) cdjefagencia,
(select iddepartment from addepartment where nmdepartment = jefatura_agencia) idjefagencia,
jefatura_agencia
from
(
select
  cddepartment,
  iddepartment,
  nmdepartment, 
  parent,
  full_path,
  nvl( TRIM('-' FROM REGEXP_SUBSTR(full_path, '(-(DIRECCION|Direccion)[^-]+){1}')), '-' )   AS direccion1, 
    nvl( TRIM('-' FROM REGEXP_SUBSTR(full_path, '(-(DIRECCION|Direccion)[^-]+){1}',1,2)),'-')   AS direccion2, 
  nvl( TRIM('-' FROM REGEXP_SUBSTR(full_path, '(-(GERENCIA|Gerencia)[^-]+){1}')), '-' )    AS gerencia,
  nvl( TRIM('-' FROM REGEXP_SUBSTR(full_path, '(-(SUBGERENCIA|Subgerencia)[^-]+){1}',1)), '-' ) AS subgerencia, 
  nvl( TRIM('-' FROM REGEXP_SUBSTR(full_path, '(-(JEFATURA|Jefatura|AGENCIA|Agencia)[^-]+){1}')), '-' )    AS  jefatura_agencia
from (
  select 
    cddepartment 
  , iddepartment
  , nmdepartment
  , sys_connect_by_path( nmdepartment, '-' ) full_path
  , level as lvl
  , case 
     when cddeptowner is null then '-' 
     else to_char( cddeptowner )
    end parent
  from ADDEPARTMENT
  start with cddeptowner is null
  connect by cddeptowner = prior cddepartment 
  order by level, cddeptowner, cddepartment
)));