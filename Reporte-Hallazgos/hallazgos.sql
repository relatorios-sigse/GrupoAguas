select 
/**
 Creada en 2018 en el contexto del proyecto de migración de la base SE Suite a la 2.0
 **/
case when tmp2.estado_tarea is null then 'Cerrado/Cancelado' else tmp2.estado_tarea end estado_mod_tarea, tmp2.* from (SELECT
        (select
            CASE 
                    WHEN S.FGCONCLUDEDSTATUS IS NOT NULL THEN (CASE 
                        WHEN S.FGCONCLUDEDSTATUS=1 THEN 'Al día' 
                        WHEN S.FGCONCLUDEDSTATUS=2 THEN 'Atrasado' 
                    END) 
                    ELSE (CASE 
                        WHEN S.FGTYPE=1 THEN (CASE 
                            WHEN (((SELECT
                                WFPD.DTESTIMATEDFINISH 
                            FROM
                                WFSTRUCT STRUCT 
                            INNER JOIN
                                WFSUBPROCESS SUB 
                                    ON STRUCT.IDOBJECT=SUB.IDOBJECT 
                            INNER JOIN
                                WFPROCESS WFPD 
                                    ON WFPD.IDOBJECT=SUB.IDSUBPROCESS 
                            WHERE
                                STRUCT.IDOBJECT=S.IDOBJECT) > CAST((trunc(sysdate) + 1) AS DATE)) 
                            OR (( SELECT
                                WFPD.DTESTIMATEDFINISH 
                            FROM
                                WFSTRUCT STRUCT 
                            INNER JOIN
                                WFSUBPROCESS SUB 
                                    ON STRUCT.IDOBJECT=SUB.IDOBJECT 
                            INNER JOIN
                                WFPROCESS WFPD 
                                    ON WFPD.IDOBJECT=SUB.IDSUBPROCESS 
                            WHERE
                                STRUCT.IDOBJECT=S.IDOBJECT) IS NULL)) THEN 'Al día' 
                            WHEN (((SELECT
                                WFPD.DTESTIMATEDFINISH 
                            FROM
                                WFSTRUCT STRUCT 
                            INNER JOIN
                                WFSUBPROCESS SUB 
                                    ON STRUCT.IDOBJECT=SUB.IDOBJECT 
                            INNER JOIN
                                WFPROCESS WFPD 
                                    ON WFPD.IDOBJECT=SUB.IDSUBPROCESS 
                            WHERE
                                STRUCT.IDOBJECT=S.IDOBJECT)=CAST( trunc(sysdate) AS DATE) 
                            AND (SELECT
                                WFPD.NRTIMEESTFINISH 
                            FROM
                                WFSTRUCT STRUCT 
                            INNER JOIN
                                WFSUBPROCESS SUB 
                                    ON STRUCT.IDOBJECT=SUB.IDOBJECT 
                            INNER JOIN
                                WFPROCESS WFPD 
                                    ON WFPD.IDOBJECT=SUB.IDSUBPROCESS 
                            WHERE
                                STRUCT.IDOBJECT=S.IDOBJECT) >= (to_char(to_timestamp(to_char(sysdate,
                            'dd-mon-yy hh24:mi:ss'),
                            'DD-MON-YYYY HH24:MI:SS'),
                            'MI') + to_char(to_timestamp(to_char(sysdate,
                            'dd-mon-yy hh24:mi:ss'),
                            'DD-MON-YYYY HH24:MI:SS'),
                            'HH24') * 60)) 
                            OR (( SELECT
                                WFPD.DTESTIMATEDFINISH 
                            FROM
                                WFSTRUCT STRUCT 
                            INNER JOIN
                                WFSUBPROCESS SUB 
                                    ON STRUCT.IDOBJECT=SUB.IDOBJECT 
                            INNER JOIN
                                WFPROCESS WFPD 
                                    ON WFPD.IDOBJECT=SUB.IDSUBPROCESS 
                            WHERE
                                STRUCT.IDOBJECT=S.IDOBJECT)=CAST((trunc(sysdate) + 1) AS DATE))) THEN 'Próximo del vencimiento' 
                            ELSE 'Atrasado' 
                        END) 
                        ELSE (CASE 
                            WHEN (( S.DTESTIMATEDFINISH > CAST((trunc(sysdate) + 1) AS DATE)) 
                            OR (S.DTESTIMATEDFINISH IS NULL)) THEN 'Al día' 
                            WHEN (( S.DTESTIMATEDFINISH=CAST( trunc(sysdate) AS DATE) 
                            AND S.NRTIMEESTFINISH >= (to_char(to_timestamp(to_char(sysdate,
                            'dd-mon-yy hh24:mi:ss'),
                            'DD-MON-YYYY HH24:MI:SS'),
                            'MI') + to_char(to_timestamp(to_char(sysdate,
                            'dd-mon-yy hh24:mi:ss'),
                            'DD-MON-YYYY HH24:MI:SS'),
                            'HH24') * 60)) 
                            OR (S.DTESTIMATEDFINISH=CAST((trunc(sysdate) + 1) AS DATE))) THEN 'Próximo del vencimiento' 
                            ELSE 'Atrasado' 
                        END) 
                    END) 
                END AS estado_tarea 
        from
            wfprocess p 
        join
            WFSTRUCT S  
                ON (
                    S.IDPROCESS=P.IDOBJECT 
                ) 
        join
            INOCCURRENCE incid  
                on (
                    INCID.IDWORKFLOW = P.IDOBJECT 
                    AND INCID.cdstatus = s.cdrevisionstatus 
                ) 
        where
            s.fgstatus in (
                2
            ) 
            and s.fgtype in (
                2,3
            ) 
            and p.idprocess = tmp.ID_HALLAZGO
        ) estado_tarea,   (
            SELECT
                CDDEPARTMENT 
            FROM
                ADDEPARTMENT 
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_RESP_HALLAZGO
        ) CD_AREA_RESP_HALLAZGO, (
            SELECT
                CDJEFAGENCIA
            FROM
                REPORTEAREAS 
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_RESP_HALLAZGO
        ) CD_JEFATURA_RESP_HALLAZGO, (
            SELECT
                CDSUBGERENCIA 
            FROM
                REPORTEAREAS 
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_RESP_HALLAZGO
        ) CD_SUBGERENCIA_RESP_HALLAZGO, (
            SELECT
                CDGERENCIA 
            FROM
                REPORTEAREAS
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_RESP_HALLAZGO
        ) CD_GERENCIA_RESP_HALLAZGO, (
            SELECT
                CDDIRECCION1
            FROM
                REPORTEAREAS 
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_RESP_HALLAZGO
        ) CD_DIR1_RESP_HALLAZGO,  (
            SELECT
                CDDIRECCION2
            FROM
                REPORTEAREAS 
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_RESP_HALLAZGO
        ) CD_DIR2_RESP_HALLAZGO,  (
            SELECT
                CDJEFAGENCIA
            FROM
                REPORTEAREAS
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_HALL
        ) CD_JEF_HALL, (
            SELECT
                CDSUBGERENCIA
            FROM
                REPORTEAREAS
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_HALL
        ) CD_SUB_HALL, (
            SELECT
                CDGERENCIA
            FROM
                REPORTEAREAS
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_HALL
        ) CD_GER_HALL, (
            SELECT
                CDDIRECCION1
            FROM
                REPORTEAREAS
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_HALL
        ) CD_DIR1_HALL,  (
            SELECT
                CDDIRECCION2
            FROM
                REPORTEAREAS
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_HALL
	) CD_DIR2_HALL
        , 


	(
            SELECT
                IDJEFAGENCIA
            FROM
                REPORTEAREAS 
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_RESP_HALLAZGO
        ) ID_JEFATURA_RESP_HALLAZGO, (
            SELECT
                IDSUBGERENCIA 
            FROM
                REPORTEAREAS 
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_RESP_HALLAZGO
        ) ID_SUBGERENCIA_RESP_HALLAZGO, (
            SELECT
                IDGERENCIA 
            FROM
                REPORTEAREAS
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_RESP_HALLAZGO
        ) ID_GERENCIA_RESP_HALLAZGO, (
            SELECT
                IDDIRECCION1
            FROM
                REPORTEAREAS 
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_RESP_HALLAZGO
        ) ID_DIR1_RESP_HALLAZGO,  (
            SELECT
                IDDIRECCION2
            FROM
                REPORTEAREAS 
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_RESP_HALLAZGO
        ) ID_DIR2_RESP_HALLAZGO,  (
            SELECT
                IDJEFAGENCIA
            FROM
                REPORTEAREAS
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_HALL
        ) ID_JEF_HALL, (
            SELECT
                IDSUBGERENCIA
            FROM
                REPORTEAREAS
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_HALL
        ) ID_SUB_HALL, (
            SELECT
                IDGERENCIA
            FROM
                REPORTEAREAS
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_HALL
        ) ID_GER_HALL, (
            SELECT
                IDDIRECCION1
            FROM
                REPORTEAREAS
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_HALL
        ) ID_DIR1_HALL,  (
            SELECT
                IDDIRECCION2
            FROM
                REPORTEAREAS
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_HALL
	) ID_DIR2_HALL,



	(
            SELECT
                JEFATURA_AGENCIA
            FROM
                REPORTEAREAS 
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_RESP_HALLAZGO
        ) JEFATURA_RESP_HALLAZGO, (
            SELECT
                SUBGERENCIA 
            FROM
                REPORTEAREAS 
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_RESP_HALLAZGO
        ) SUBGERENCIA_RESP_HALLAZGO, (
            SELECT
                GERENCIA 
            FROM
                REPORTEAREAS
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_RESP_HALLAZGO
        ) GERENCIA_RESP_HALLAZGO, (
            SELECT
                DIRECCION1
            FROM
                REPORTEAREAS 
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_RESP_HALLAZGO
        ) DIR1_RESP_HALLAZGO,  (
            SELECT
                DIRECCION2
            FROM
                REPORTEAREAS 
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_RESP_HALLAZGO
        ) DIR2_RESP_HALLAZGO,  (
            SELECT
                JEFATURA_AGENCIA
            FROM
                REPORTEAREAS
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_HALL
        ) JEF_HALL, (
            SELECT
                SUBGERENCIA
            FROM
                REPORTEAREAS
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_HALL
        ) SUB_HALL, (
            SELECT
                GERENCIA
            FROM
                REPORTEAREAS
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_HALL
        ) GER_HALL, (
            SELECT
                DIRECCION1
            FROM
                REPORTEAREAS
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_HALL
        ) DIR1_HALL,  (
            SELECT
                DIRECCION2
            FROM
                REPORTEAREAS
            WHERE
                IDDEPARTMENT = TMP.ID_AREA_HALL
	) DIR2_HALL,


TMP.* 
    FROM
        (SELECT
            QTD_BI,
            IDSITUATION,
            CASE WHEN NMREVISIONSTATUS = 'Finalizado' then 'Cancelado' else NMREVISIONSTATUS END NMREVISIONSTATUS,
            IDSLASTATUS,
            NMDEADLINE,
            IDOCCURRENCETYPE,
            NMEVALRESULT,
            NMUSERSTART,
            DTSTART,
            DTFINISH,
            DTSLAFINISH,
            DTDEADLINEFIELD,
            ID_HALLAZGO,
            TITULO_HALLAZGO,
            ID_AREA_HALL,
	    AREA_HALL,
            FECHA_HALL,
            EMP_PERTENECE_HALL,
            EMP_PERTENECE_HALL_AC,
            EMP_PERTENECE_HALL_AM,
            EMP_PERTENECE_HALL_AA,
            CANTIDAD_HALL_AC,
            CANTIDAD_HALL_AM,
            CANTIDAD_HALL_AA,
            MACROPROCESO,
            PROCESO,
            SUBPROCESO,
            ORIGEN,
            DETALLE_ORIGEN,
            CLASIFICACION,
            CRITICIDAD,
            RECINTO,
            SISTEMA_GESTION_CALIDAD,
            SISTEMA_GESTION_EFICIENCIA,
            SISTEMA_GESTION_SEGURIDAD,
            SISTEMA_GESTION_CONTINUIDAD,
            SISTEMA_GESTION_AMBIENTE,
            SISTEMA_GESTION_IGUALDAD,
            SISTEMA_GESTION_ANTISOBORNO,
            CANTIDAD_GESTION_CALIDAD,
            CANTIDAD_GESTION_EFICIENCIA,
            CANTIDAD_GESTION_SEGURIDAD,
            CANTIDAD_GESTION_CONTINUIDAD,
            CANTIDAD_GESTION_AMBIENTE,
            CANTIDAD_GESTION_IGUALDAD,
            CANTIDAD_GESTION_ANTISOBORNO,
            TEMATICA_01,
            TEMATICA_02,
            TEMATICA_03,
            TEMATICA_04,
            TEMATICA_05,
            TEMATICA_06,
            TEMATICA_07,
            TEMATICA_08,
            TEMATICA_09,
            TEMATICA_10,
            TEMATICA_11,
            TEMATICA_12,
            TEMATICA_13,
            TEMATICA_14,
            TEMATICA_15,
            TEMATICA_16,
            TEMATICA_17,
            TEMATICA_18,
            TEMATICA_19,
            TEMATICA_20,
            TEMATICA_21,
            TEMATICA_22,
            DESCRIPCION_HALLAZGO,
            ID_RESPONSABLE_REGISTRO,
            RESPONSABLE_REGISTRO,

   	    ID_GRUPO_APROB_HALL,
            GRUPO_APROB_HALL,
	    ID_RESPONSABLE_APROB_HALL,
	    RESPONSABLE_APROB_HALL  , 
            
            ID_GRUPO_ANALISIS,
            GRUPO_ANALISIS,
            ID_RESPONSABLE_ANALISIS,
            RESPONSABLE_ANALISIS,
         
            ID_GRUPO_APROBACION,
            GRUPO_APROBACION,
            ID_RESPONSABLE_APROBACION,
            RESPONSABLE_APROBACION,
      
            ID_GRUPO_VERIFICACION,
            GRUPO_VERIFICACION,
            ID_RESPONSABLE_VERIFICACION,
            RESPONSABLE_VERIFICACION,
        
            CASE 
                when IDREVISIONSTATUS = '01' then CD_RESPONSABLE_REGISTRO       
                when IDREVISIONSTATUS = '02' then CD_RESPONSABLE_APROB_HALL       
                when IDREVISIONSTATUS = '03' then CD_RESPONSABLE_ANALISIS       
                when IDREVISIONSTATUS = '04' then CD_RESPONSABLE_APROBACION      
                when IDREVISIONSTATUS = '05' then CD_RESPONSABLE_ANALISIS       
                when IDREVISIONSTATUS = '06' then CD_RESPONSABLE_VERIFICACION       
                else 0 
            END CD_RESPONSABLE_HALLAZGO,
            CASE 
                when IDREVISIONSTATUS = '01' then ID_RESPONSABLE_REGISTRO || '-' || RESPONSABLE_REGISTRO      
                when IDREVISIONSTATUS = '02' then ID_RESPONSABLE_APROB_HALL || '-' || RESPONSABLE_APROB_HALL      
                when IDREVISIONSTATUS = '03' then ID_RESPONSABLE_ANALISIS || '-' || RESPONSABLE_ANALISIS      
                when IDREVISIONSTATUS = '04' then ID_RESPONSABLE_APROBACION || '-' || RESPONSABLE_APROBACION     
                when IDREVISIONSTATUS = '05' then ID_RESPONSABLE_ANALISIS || '-' || RESPONSABLE_ANALISIS      
                when IDREVISIONSTATUS = '06' then ID_RESPONSABLE_VERIFICACION || '-' || RESPONSABLE_VERIFICACION      
                else 'Cerrado' 
            END RESPONSABLE_HALLAZGO,
            CASE 
                when IDREVISIONSTATUS = '01' then ID_AREA_HALL     
                when IDREVISIONSTATUS = '02' then (select iddepartment from aduserdeptpos udp join addepartment d on d.cddepartment = udp.cddepartment join aduser u on u.cduser = udp.cduser where udp.fgdefaultdeptpos = 1 and u.iduser = ID_RESPONSABLE_APROB_HALL)     
                when IDREVISIONSTATUS = '03' then (select iddepartment from aduserdeptpos udp join addepartment d on d.cddepartment = udp.cddepartment join aduser u on u.cduser = udp.cduser where udp.fgdefaultdeptpos = 1 and u.iduser = ID_RESPONSABLE_ANALISIS)     
                when IDREVISIONSTATUS = '04' then (select iddepartment from aduserdeptpos udp join addepartment d on d.cddepartment = udp.cddepartment join aduser u on u.cduser = udp.cduser where udp.fgdefaultdeptpos = 1 and u.iduser = ID_RESPONSABLE_APROBACION)   
                when IDREVISIONSTATUS = '05' then (select iddepartment from aduserdeptpos udp join addepartment d on d.cddepartment = udp.cddepartment join aduser u on u.cduser = udp.cduser where udp.fgdefaultdeptpos = 1 and u.iduser = ID_RESPONSABLE_ANALISIS)     
                when IDREVISIONSTATUS = '06' then (select iddepartment from aduserdeptpos udp join addepartment d on d.cddepartment = udp.cddepartment join aduser u on u.cduser = udp.cduser where udp.fgdefaultdeptpos = 1 and u.iduser = ID_RESPONSABLE_VERIFICACION)     
                else 'Cerrado' 
            END ID_AREA_RESP_HALLAZGO,
            CASE 
                when IDREVISIONSTATUS = '01' then AREA_HALL       
                when IDREVISIONSTATUS = '02' then (select nmdepartment from aduserdeptpos udp join addepartment d on d.cddepartment = udp.cddepartment join aduser u on u.cduser = udp.cduser where udp.fgdefaultdeptpos = 1 and u.iduser = ID_RESPONSABLE_APROB_HALL)     
                when IDREVISIONSTATUS = '03' then (select nmdepartment from aduserdeptpos udp join addepartment d on d.cddepartment = udp.cddepartment join aduser u on u.cduser = udp.cduser where udp.fgdefaultdeptpos = 1 and u.iduser = ID_RESPONSABLE_ANALISIS)     
                when IDREVISIONSTATUS = '04' then (select nmdepartment from aduserdeptpos udp join addepartment d on d.cddepartment = udp.cddepartment join aduser u on u.cduser = udp.cduser where udp.fgdefaultdeptpos = 1 and u.iduser = ID_RESPONSABLE_APROBACION)     
                when IDREVISIONSTATUS = '05' then (select nmdepartment from aduserdeptpos udp join addepartment d on d.cddepartment = udp.cddepartment join aduser u on u.cduser = udp.cduser where udp.fgdefaultdeptpos = 1 and u.iduser = ID_RESPONSABLE_ANALISIS)     
                when IDREVISIONSTATUS = '06' then (select nmdepartment from aduserdeptpos udp join addepartment d on d.cddepartment = udp.cddepartment join aduser u on u.cduser = udp.cduser where udp.fgdefaultdeptpos = 1 and u.iduser = ID_RESPONSABLE_VERIFICACION)     
                else 'Cerrado'       
            END AREA_RESP_HALLAZGO,
            IMPLEMENTAR_OMJ,
            JUSTIFICACION_IMPL_OMJ,
            APRUEBA_HALLAZGO,
            JUSTIFICACION_APROB_HALLAZGO,
            EFICACIA_HALLAZGO,
            JUSTIFICACION_EFICACIA,
            ACCSSO_PARTE_AFECT_CABEZA,
            ACCSSO_PARTE_AFECT_ESPALDA,
            ACCSSO_PARTE_AFECT_BRADER,
            ACCSSO_PARTE_AFECT_BRAIZQ,
            ACCSSO_PARTE_AFECT_MANDER,
            ACCSSO_PARTE_AFECT_MANIZQ,
            ACCSSO_PARTE_AFECT_PIERNA_DER,
            ACCSSO_PARTE_AFECT_PIERNA_IZQ,
            ACCSSO_PARTE_AFECT_PIE_DER,
            ACCSSO_PARTE_AFECT_PIE_IZQ   
        FROM
            (SELECT
                1 AS QTD_BI,
                P.IDOBJECT,
                P.IDPROCESS AS ID_HALLAZGO,
                P.NMPROCESS AS TITULO_HALLAZGO,
                P.CDPROCESSMODEL,
                P.CDREVISION,
                P.IDPROCESSMODEL,
                P.NMPROCESSMODEL,
                P.FGSTATUS AS FGSTATUS,
                TO_TIMESTAMP(TO_CHAR(P.DTSTART,
                'YYYY-MM-DD') || ' ' || P.TMSTART,
                'YYYY-MM-DD HH24:MI:SS') AS DTSTART,
                CASE                  
                    WHEN P.DTFINISH IS NOT NULL THEN TO_TIMESTAMP(TO_CHAR(P.DTFINISH,
                    'YYYY-MM-DD') || ' ' || P.TMFINISH,
                    'YYYY-MM-DD HH24:MI:SS')                  
                    ELSE NULL              
                END AS DTFINISH,
                CASE                  
                    WHEN SLACTRL.BNSLAFINISH IS NOT NULL THEN TO_TIMESTAMP(TO_CHAR(SEF_DTEND_WK_SECS_PERIOD(TO_DATE('1970-01-01',
                    'YYYY-MM-DD HH24:MI:SS'),
                    (SLACTRL.BNSLAFINISH / 1000) -10800,
                    -2),
                    'YYYY-MM-DD HH24:MI:SS'),
                    'YYYY-MM-DD HH24:MI:SS')                  
                    ELSE NULL              
                END AS DTSLAFINISH,
                P.TMSTART,
                P.TMFINISH,
                P.CDUSERSTART,
                P.NMUSERSTART,
                P.CDFAVORITE,
                P.FGSLASTATUS,
                CASE P.FGSTATUS                  
                    WHEN 1 THEN 'En marcha'                  
                    WHEN 2 THEN 'Suspendido'                  
                    WHEN 3 THEN 'Cancelado'                  
                    WHEN 4 THEN 'Cerrado'                  
                    WHEN 5 THEN 'Bloqueado para edición'              
                END AS IDSITUATION,
                CASE P.FGSLASTATUS                  
                    WHEN 10 THEN 'En marcha'                  
                    WHEN 30 THEN 'Suspendido'                  
                    WHEN 40 THEN 'Cerrado'              
                END AS IDSLASTATUS,
                CASE                  
                    WHEN P.VLTIMEFINISH IS NULL THEN 9999999999                  
                    ELSE P.VLTIMEFINISH              
                END AS VLTIMEFINISH,
                GREV.IDREVISION,
                SLACTRL.BNSLAFINISH,
                PT.CDACTTYPE,
                PT.IDACTTYPE,
                PT.NMACTTYPE,
                PP.NMACTIVITY AS PROCESSMODEL,
                GNRS.IDREVISIONSTATUS,
                GNRS.NMREVISIONSTATUS,
                GNRS.CDREVISIONSTATUS,
                GNRS.FGLOGO AS FGLOGOREVISIONSTATUS,
                GNRUS.VLEVALRESULT,
                GNR.NMEVALRESULT,
                GNR.FGSYMBOL,
                CASE                  
                    WHEN GNR.NRORDER IS NULL THEN -999999999                  
                    ELSE GNR.NRORDER              
                END AS NRORDERPRIORITY,
                P.DTESTIMATEDFINISH AS DTDEADLINEFIELD,
                P.NRTIMEESTFINISH AS NRHRDEADLINEFIELD,
                CAST('VLTIMEFINISH' AS VARCHAR(50)) AS NRDEADLINEFIELD_IMG,
                CAST('VLTIMEFINISH' AS VARCHAR(50)) AS DEADLINEFIELD_DT,
                (SELECT
                    COUNT(1)              
                FROM
                    WFPROCDOCUMENT T_QTD_DOC              
                WHERE
                    T_QTD_DOC.IDPROCESS=P.IDOBJECT) AS QTD_DOC,
                (SELECT
                    COUNT(1)              
                FROM
                    WFPROCATTACHMENT T_QTD_ATT              
                WHERE
                    T_QTD_ATT.IDPROCESS=P.IDOBJECT                  
                    AND T_QTD_ATT.CDUSER IS NOT NULL) AS QTD_ATT,
                ROWNUM AS ROW_NUM,
                CASE                  
                    WHEN P.FGCONCLUDEDSTATUS IS NOT NULL THEN (CASE                      
                        WHEN P.FGCONCLUDEDSTATUS=1 THEN 1                      
                        WHEN P.FGCONCLUDEDSTATUS=2 THEN 3                  
                    END)                  
                    ELSE (CASE                      
                        WHEN (( P.DTESTIMATEDFINISH > CAST(TO_DATE('2017-03-16',
                        'YYYY-MM-DD') AS DATE))                      
                        OR (P.DTESTIMATEDFINISH IS NULL)) THEN 1                      
                        WHEN (( P.DTESTIMATEDFINISH=CAST(TO_DATE('2017-03-15',
                        'YYYY-MM-DD') AS DATE)                      
                        AND P.NRTIMEESTFINISH >= 890)                      
                        OR (P.DTESTIMATEDFINISH=CAST(TO_DATE('2017-03-16',
                        'YYYY-MM-DD') AS DATE))) THEN 2                      
                        ELSE 3                  
                    END)              
                END AS FGDEADLINE,
                CASE                  
                    WHEN (( P.DTESTIMATEDFINISH > CAST(TO_DATE('2017-03-15',
                    'YYYY-MM-DD') AS DATE))                  
                    OR (P.DTESTIMATEDFINISH=CAST(TO_DATE('2017-03-15',
                    'YYYY-MM-DD') AS DATE)                  
                    AND P.NRTIMEESTFINISH >= 890)                  
                    OR (P.DTESTIMATEDFINISH IS NULL)) THEN 1                  
                    ELSE 3              
                END AS FGDEADLINE2,
                CASE                  
                    WHEN P.FGCONCLUDEDSTATUS IS NOT NULL THEN (CASE                      
                        WHEN P.FGCONCLUDEDSTATUS=1 THEN 'Al día'                      
                        WHEN P.FGCONCLUDEDSTATUS=2 THEN 'Atrasado'                  
                    END)                  
                    ELSE (CASE                      
                        WHEN (( P.DTESTIMATEDFINISH > CAST(TO_DATE('2017-03-16',
                        'YYYY-MM-DD') AS DATE))                      
                        OR (P.DTESTIMATEDFINISH IS NULL)) THEN 'Al día'                      
                        WHEN (( P.DTESTIMATEDFINISH=CAST(TO_DATE('2017-03-15',
                        'YYYY-MM-DD') AS DATE)                      
                        AND P.NRTIMEESTFINISH >= 890)                      
                        OR (P.DTESTIMATEDFINISH=CAST(TO_DATE('2017-03-16',
                        'YYYY-MM-DD') AS DATE))) THEN 'Próximo del vencimiento'                      
                        ELSE 'Atrasado'                  
                    END)              
                END AS NMDEADLINE ,
                P.QTHOURS AS QTHOURS,
                P.FGDURATIONUNIT AS FGDURATIONUNIT,
                P.CDPROCESS,
                GNT.IDGENTYPE AS IDOCCURRENCETYPE,
                GNT.NMGENTYPE AS NMOCCURRENCETYPE,
                INCID.CDOCCURRENCETYPE AS CDOCCURRENCETYPE,
                GNT.FGLOGO AS FGLOGOOCCURRENCETYPE,
                identificador ID_HALLAZGO_FORM,
                titulo TITULO_HALLAZGO_FORM,
                
                dtdeteccion FECHA_HALL,
                emp EMP_PERTENECE_HALL,
                CASE 
                    WHEN empac = 1 then 'Aguas Cordillera' 
                    else '' 
                END EMP_PERTENECE_HALL_AC,
                CASE 
                    WHEN empam = 1 then 'Aguas Manquehue' 
                    else '' 
                END EMP_PERTENECE_HALL_AM,
                CASE 
                    WHEN empaa = 1 then 'Aguas Andinas' 
                    else '' 
                END EMP_PERTENECE_HALL_AA,
                CASE 
                    WHEN empac = 1 then 1 
                    else 0 
                END CANTIDAD_HALL_AC,
                CASE 
                    WHEN empam = 1 then 1 
                    else 0 
                END CANTIDAD_HALL_AM,
                CASE 
                    WHEN empaa = 1 then 1 
                    else 0 
                END CANTIDAD_HALL_AA,
                macro MACROPROCESO,
                proceso PROCESO,
                subproceso SUBPROCESO,
                origen ORIGEN,
                dor DETALLE_ORIGEN,
                clasificacion CLASIFICACION,
                criticidad CRITICIDAD,
                recinto RECINTO,
                CASE 
                    when sg01 = 1 then 'Calidad' 
                    else '' 
                END SISTEMA_GESTION_CALIDAD,
                CASE 
                    when sg02 = 1 then 'Eficiencia' 
                    else '' 
                END SISTEMA_GESTION_EFICIENCIA,
                CASE 
                    when sg03 = 1 then 'Seguridad' 
                    else '' 
                END SISTEMA_GESTION_SEGURIDAD,
                CASE 
                    when sg04 = 1 then 'Continuidad' 
                    else '' 
                END SISTEMA_GESTION_CONTINUIDAD,
                CASE 
                    when sg05 = 1 then 'Medio Ambiente' 
                    else '' 
                END SISTEMA_GESTION_AMBIENTE,
                CASE 
                    when sg06 = 1 then 'Igualdad' 
                    else '' 
                END SISTEMA_GESTION_IGUALDAD,
                CASE 
                    when sg07 = 1 then 'Antisoborno' 
                    else '' 
                END SISTEMA_GESTION_ANTISOBORNO,
                CASE 
                    when sg01 = 1 then 1 
                    else 0 
                END CANTIDAD_GESTION_CALIDAD,
                CASE 
                    when sg02 = 1 then 1 
                    else 0 
                END CANTIDAD_GESTION_EFICIENCIA,
                CASE 
                    when sg03 = 1 then 1 
                    else 0 
                END CANTIDAD_GESTION_SEGURIDAD,
                CASE 
                    when sg04 = 1 then 1 
                    else 0 
                END CANTIDAD_GESTION_CONTINUIDAD,
                CASE 
                    when sg05 = 1 then 1 
                    else 0 
                END CANTIDAD_GESTION_AMBIENTE,
                CASE 
                    when sg06 = 1 then 1 
                    else 0 
                END CANTIDAD_GESTION_IGUALDAD,
                CASE 
                    when sg07 = 1 then 1 
                    else 0 
                END CANTIDAD_GESTION_ANTISOBORNO,
                CASE 
                    when tm01 = 1 then 1 
                    else 0 
                END TEMATICA_01,
                CASE 
                    when tm02 = 1 then 1 
                    else 0 
                END TEMATICA_02,
                CASE 
                    when tm03 = 1 then 1 
                    else 0 
                END TEMATICA_03,
                CASE 
                    when tm04 = 1 then 1 
                    else 0 
                END TEMATICA_04,
                CASE 
                    when tm05 = 1 then 1 
                    else 0 
                END TEMATICA_05,
                CASE 
                    when tm06 = 1 then 1 
                    else 0 
                END TEMATICA_06,
                CASE 
                    when tm07 = 1 then 1 
                    else 0 
                END TEMATICA_07,
                CASE 
                    when tm08 = 1 then 1 
                    else 0 
                END TEMATICA_08,
                CASE 
                    when tm09 = 1 then 1 
                    else 0 
                END TEMATICA_09,
                CASE 
                    when tm10 = 1 then 1 
                    else 0 
                END TEMATICA_10,
                CASE 
                    when tm11 = 1 then 1 
                    else 0 
                END TEMATICA_11,
                CASE 
                    when tm12 = 1 then 1 
                    else 0 
                END TEMATICA_12,
                CASE 
                    when tm13 = 1 then 1 
                    else 0 
                END TEMATICA_13,
                CASE 
                    when tm14 = 1 then 1 
                    else 0 
                END TEMATICA_14,
                CASE 
                    when tm15 = 1 then 1 
                    else 0 
                END TEMATICA_15,
                CASE 
                    when tm16 = 1 then 1 
                    else 0 
                END TEMATICA_16,
                CASE 
                    when tm17 = 1 then 1 
                    else 0 
                END TEMATICA_17,
                CASE 
                    when tm18 = 1 then 1 
                    else 0 
                END TEMATICA_18,
                CASE 
                    when tm19 = 1 then 1 
                    else 0 
                END TEMATICA_19,
                CASE 
                    when tm20 = 1 then 1 
                    else 0 
                END TEMATICA_20,
                CASE 
                    when tm21 = 1 then 1 
                    else 0 
                END TEMATICA_21,
                CASE 
                    when tm22 = 1 then 1 
                    else 0 
                END TEMATICA_22,

                descripcion DESCRIPCION_HALLAZGO,
                (select cduser from aduser where iduser = iddetecta) CD_RESPONSABLE_REGISTRO,
                iddetecta ID_RESPONSABLE_REGISTRO,
                nmdetecta RESPONSABLE_REGISTRO,
                (select iddepartment from aduserdeptpos udp join addepartment d on d.cddepartment = udp.cddepartment join aduser u on u.cduser = udp.cduser where udp.fgdefaultdeptpos = 1 and u.iduser = iddetecta) ID_AREA_HALL,
                (select nmdepartment from aduserdeptpos udp join addepartment d on d.cddepartment = udp.cddepartment join aduser u on u.cduser = udp.cduser where udp.fgdefaultdeptpos = 1 and u.iduser = iddetecta) AREA_HALL,                

                idgruaprobhall ID_GRUPO_APROB_HALL,
                nmgruaprohall GRUPO_APROB_HALL,
                (select cduser from aduser where iduser = HALL.idusuaprohal) CD_RESPONSABLE_APROB_HALL,
                idusuaprohal ID_RESPONSABLE_APROB_HALL,
                nmusuaprohall RESPONSABLE_APROB_HALL,

                idgruanalisis ID_GRUPO_ANALISIS,
                nmgruanalisis GRUPO_ANALISIS,
                (select cduser from aduser where iduser = idusuanalisis) CD_RESPONSABLE_ANALISIS,
                idusuanalisis ID_RESPONSABLE_ANALISIS,
                nmusuanalisis RESPONSABLE_ANALISIS,
                
      
                idgruaprob ID_GRUPO_APROBACION,
                nmgruaprob GRUPO_APROBACION,
                (select cduser from aduser where iduser = idusuaprob) CD_RESPONSABLE_APROBACION,
                idusuaprob ID_RESPONSABLE_APROBACION,
                nmusuaprob RESPONSABLE_APROBACION,
   
     
                idgruverif ID_GRUPO_VERIFICACION,
                nmgruverif GRUPO_VERIFICACION,
                (select cduser from aduser where iduser = idusuverif) CD_RESPONSABLE_VERIFICACION,
                idusuverif ID_RESPONSABLE_VERIFICACION,
                nmusuverif RESPONSABLE_VERIFICACION,
                
                empresver EMPRESA_VERIFICACION,
                CASE 
                    when impomj = 1 then 'SI' 
                    else 'NO' 
                END IMPLEMENTAR_OMJ,
                jusimpomj JUSTIFICACION_IMPL_OMJ,
                CASE 
                    when aprobanaplan = 1 then 'SI' 
                    else 'NO' 
                END APRUEBA_HALLAZGO,
                jusaprobanaplan JUSTIFICACION_APROB_HALLAZGO,
                CASE 
                    when eficaz = 1 then 'EFICAZ' 
                    else 'NO EFICAZ' 
                END EFICACIA_HALLAZGO,
                jusaprobaefic JUSTIFICACION_EFICACIA,
                CASE 
                    when accssoparafe01 = 1 then 1 
                    else 0 
                END ACCSSO_PARTE_AFECT_CABEZA,
                CASE 
                    when accssoparafe02 = 1 then 1 
                    else 0  
                END ACCSSO_PARTE_AFECT_ESPALDA,
                CASE 
                    when accssoparafe03 = 1 then 1 
                    else 0  
                END ACCSSO_PARTE_AFECT_BRADER,
                CASE 
                    when accssoparafe04 = 1 then 1 
                    else 0  
                END ACCSSO_PARTE_AFECT_BRAIZQ,
                CASE 
                    when accssoparafe05 = 1 then 1 
                    else 0  
                END  ACCSSO_PARTE_AFECT_MANDER,
                CASE 
                    when accssoparafe06 = 1 then 1 
                    else 0  
                END ACCSSO_PARTE_AFECT_MANIZQ,
                CASE 
                    when accssoparafe07 = 1 then 1 
                    else 0  
                END  ACCSSO_PARTE_AFECT_PIERNA_DER,
                CASE 
                    when accssoparafe08 = 1 then 1 
                    else 0  
                END ACCSSO_PARTE_AFECT_PIERNA_IZQ,
                CASE 
                    when accssoparafe09 = 1 then 1 
                    else 0  
                END  ACCSSO_PARTE_AFECT_PIE_DER,
                CASE 
                    when accssoparafe10 = 1 then 1 
                    else 0 
                END ACCSSO_PARTE_AFECT_PIE_IZQ            
            FROM
                WFPROCESS P          
            LEFT OUTER JOIN
                GNREVISION GREV                  
                    ON (
                        P.CDREVISION=GREV.CDREVISION                 
                    )          
            LEFT OUTER JOIN
                GNSLACONTROL SLACTRL                  
                    ON (
                        P.CDSLACONTROL=SLACTRL.CDSLACONTROL                 
                    )          
            LEFT OUTER JOIN
                PMACTIVITY PP                  
                    ON (
                        PP.CDACTIVITY=P.CDPROCESSMODEL                 
                    )          
            LEFT OUTER JOIN
                PMACTTYPE PT                  
                    ON (
                        PT.CDACTTYPE=PP.CDACTTYPE                 
                    )          
            LEFT OUTER JOIN
                GNREVISIONSTATUS GNRS                  
                    ON (
                        P.CDSTATUS=GNRS.CDREVISIONSTATUS                 
                    )   
            LEFT JOIN
                GNASSOCFORMREG AREG 
                    ON (
                        AREG.CDASSOC=P.CDASSOCREG
                    ) 
            LEFT JOIN
                DYNgha HALL 
                    ON (
                        HALL.OID = AREG.OIDENTITYREG
                    )          
            LEFT OUTER JOIN
                GNEVALRESULTUSED GNRUS                  
                    ON (
                        GNRUS.CDEVALRESULTUSED=P.CDEVALRSLTPRIORITY                 
                    )          
            LEFT OUTER JOIN
                GNEVALRESULT GNR                  
                    ON (
                        GNRUS.CDEVALRESULT=GNR.CDEVALRESULT                 
                    )          
            INNER JOIN
                INOCCURRENCE INCID                  
                    ON (
                        P.IDOBJECT=INCID.IDWORKFLOW                 
                    )          
            LEFT OUTER JOIN
                GNGENTYPE GNT                  
                    ON (
                        INCID.CDOCCURRENCETYPE=GNT.CDGENTYPE                 
                    )          
            INNER JOIN
                PBPROBLEM PB                  
                    ON PB.CDOCCURRENCE=INCID.CDOCCURRENCE          
            INNER JOIN
                (
                    SELECT
                        DISTINCT Z.IDOBJECT                  
                    FROM
                        (SELECT
                            P.IDOBJECT                      
                        FROM
                            WFPROCESS P                      
                        INNER JOIN
                            (
                                SELECT
                                    PERM.USERCD,
                                    PERM.IDPROCESS,
                                    MIN(PERM.FGPERMISSION) AS FGPERMISSION                              
                                FROM
                                    (SELECT
                                        WF.FGPERMISSION,
                                        WF.IDPROCESS,
                                        TM.CDUSER AS USERCD,
                                        WF.CDACCESSLIST                                  
                                    FROM
                                        WFPROCSECURITYLIST WF                                  
                                    INNER JOIN
                                        ADTEAMUSER TM                                          
                                            ON WF.CDTEAM=TM.CDTEAM                                  
                                    WHERE
                                        1=1                                      
                                        AND WF.FGACCESSTYPE=1                                      
                                        AND TM.CDUSER=1                                  
                                    UNION
                                    ALL SELECT
                                        WF.FGPERMISSION,
                                        WF.IDPROCESS,
                                        UDP.CDUSER AS USERCD,
                                        WF.CDACCESSLIST                                  
                                    FROM
                                        WFPROCSECURITYLIST WF                                  
                                    INNER JOIN
                                        ADUSERDEPTPOS UDP                                          
                                            ON WF.CDDEPARTMENT=UDP.CDDEPARTMENT                                  
                                    WHERE
                                        1=1                                      
                                        AND WF.FGACCESSTYPE=2                                      
                                        AND UDP.CDUSER=1                                  
                                    UNION
                                    ALL SELECT
                                        WF.FGPERMISSION,
                                        WF.IDPROCESS,
                                        UDP.CDUSER AS USERCD,
                                        WF.CDACCESSLIST                                  
                                    FROM
                                        WFPROCSECURITYLIST WF                                  
                                    INNER JOIN
                                        ADUSERDEPTPOS UDP                                          
                                            ON WF.CDDEPARTMENT=UDP.CDDEPARTMENT                                          
                                            AND WF.CDPOSITION=UDP.CDPOSITION                                  
                                    WHERE
                                        1=1                                      
                                        AND WF.FGACCESSTYPE=3                                      
                                        AND UDP.CDUSER=1                                  
                                    UNION
                                    ALL SELECT
                                        WF.FGPERMISSION,
                                        WF.IDPROCESS,
                                        UDP.CDUSER AS USERCD,
                                        WF.CDACCESSLIST                                  
                                    FROM
                                        WFPROCSECURITYLIST WF                                  
                                    INNER JOIN
                                        ADUSERDEPTPOS UDP                                          
                                            ON WF.CDPOSITION=UDP.CDPOSITION                                  
                                    WHERE
                                        1=1                                      
                                        AND WF.FGACCESSTYPE=4                                      
                                        AND UDP.CDUSER=1                                  
                                    UNION
                                    ALL SELECT
                                        WF.FGPERMISSION,
                                        WF.IDPROCESS,
                                        WF.CDUSER AS USERCD,
                                        WF.CDACCESSLIST                                  
                                    FROM
                                        WFPROCSECURITYLIST WF                                  
                                    WHERE
                                        1=1                                      
                                        AND WF.FGACCESSTYPE=5                                      
                                        AND WF.CDUSER=1                                  
                                    UNION
                                    ALL SELECT
                                        WF.FGPERMISSION,
                                        WF.IDPROCESS,
                                        US.CDUSER AS USERCD,
                                        WF.CDACCESSLIST                                  
                                    FROM
                                        WFPROCSECURITYLIST WF CROSS                                  
                                    JOIN
                                        ADUSER US                                  
                                    WHERE
                                        1=1                                      
                                        AND WF.FGACCESSTYPE=6                                      
                                        AND US.CDUSER=1                                  
                                    UNION
                                    ALL SELECT
                                        WF.FGPERMISSION,
                                        WF.IDPROCESS,
                                        RL.CDUSER AS USERCD,
                                        WF.CDACCESSLIST                                  
                                    FROM
                                        WFPROCSECURITYLIST WF                                  
                                    INNER JOIN
                                        ADUSERROLE RL                                          
                                            ON RL.CDROLE=WF.CDROLE                                  
                                    WHERE
                                        1=1                                      
                                        AND WF.FGACCESSTYPE=7                                      
                                        AND RL.CDUSER=1                                  
                                    UNION
                                    ALL SELECT
                                        WF.FGPERMISSION,
                                        WF.IDPROCESS,
                                        WFP.CDUSERSTART AS USERCD,
                                        WF.CDACCESSLIST                                  
                                    FROM
                                        WFPROCSECURITYLIST WF                                  
                                    INNER JOIN
                                        WFPROCESS WFP                                          
                                            ON WFP.IDOBJECT=WF.IDPROCESS                                  
                                    WHERE
                                        1=1                                      
                                        AND WF.FGACCESSTYPE=30                                      
                                        AND WFP.CDUSERSTART=1                                  
                                    UNION
                                    ALL SELECT
                                        WF.FGPERMISSION,
                                        WF.IDPROCESS,
                                        US.CDLEADER AS USERCD,
                                        WF.CDACCESSLIST                                  
                                    FROM
                                        WFPROCSECURITYLIST WF                                  
                                    INNER JOIN
                                        WFPROCESS WFP                                          
                                            ON WFP.IDOBJECT=WF.IDPROCESS                                  
                                    INNER JOIN
                                        ADUSER US                                          
                                            ON US.CDUSER=WFP.CDUSERSTART                                  
                                    WHERE
                                        1=1                                      
                                        AND WF.FGACCESSTYPE=31                                      
                                        AND US.CDLEADER=1                             
                                ) PERM                          
                            INNER JOIN
                                WFPROCSECURITYCTRL GNASSOC                                  
                                    ON GNASSOC.CDACCESSLIST=PERM.CDACCESSLIST                                  
                                    AND GNASSOC.IDPROCESS=PERM.IDPROCESS                          
                            WHERE
                                1=1                              
                                AND GNASSOC.CDACCESSROLEFIELD=501                          
                            GROUP BY
                                PERM.USERCD,
                                PERM.IDPROCESS                     
                        ) PERMISSION                          
                            ON PERMISSION.IDPROCESS=P.IDOBJECT                  
                    INNER JOIN
                        INOCCURRENCE INCID                          
                            ON INCID.IDWORKFLOW=P.IDOBJECT                  
                    WHERE
                        1=1                      
                        AND PERMISSION.FGPERMISSION=1                      
                        AND P.FGSTATUS <= 5                      
                        AND (
                            P.FGMODELWFSECURITY IS NULL                          
                            OR P.FGMODELWFSECURITY=0                     
                        )                      
                        AND INCID.FGOCCURRENCETYPE=2                  
                    UNION
                    ALL SELECT
                        T.IDOBJECT                  
                    FROM
                        (SELECT
                            PERM.IDOBJECT,
                            MIN(PERM.FGPERMISSION) AS FGPERMISSION                      
                        FROM
                            (SELECT
                                WFP.IDOBJECT,
                                PMA.FGUSETYPEACCESS,
                                PERM1.FGPERMISSION                          
                            FROM
                                (SELECT
                                    PM.FGPERMISSION,
                                    PM.CDACTTYPE,
                                    PM.CDACCESSLIST,
                                    TM.CDUSER AS USERCD                              
                                FROM
                                    PMACTTYPESECURLIST PM                              
                                INNER JOIN
                                    ADTEAMUSER TM                                      
                                        ON PM.CDTEAM=TM.CDTEAM                              
                                WHERE
                                    1=1                                  
                                    AND PM.FGACCESSTYPE=1                                  
                                    AND TM.CDUSER=1                              
                                UNION
                                ALL SELECT
                                    PM.FGPERMISSION,
                                    PM.CDACTTYPE,
                                    PM.CDACCESSLIST,
                                    UDP.CDUSER AS USERCD                              
                                FROM
                                    PMACTTYPESECURLIST PM                              
                                INNER JOIN
                                    ADUSERDEPTPOS UDP                                      
                                        ON PM.CDDEPARTMENT=UDP.CDDEPARTMENT                              
                                WHERE
                                    1=1                                  
                                    AND PM.FGACCESSTYPE=2                                  
                                    AND UDP.CDUSER=1                              
                                UNION
                                ALL SELECT
                                    PM.FGPERMISSION,
                                    PM.CDACTTYPE,
                                    PM.CDACCESSLIST,
                                    UDP.CDUSER AS USERCD                              
                                FROM
                                    PMACTTYPESECURLIST PM                              
                                INNER JOIN
                                    ADUSERDEPTPOS UDP                                      
                                        ON PM.CDDEPARTMENT=UDP.CDDEPARTMENT                                      
                                        AND PM.CDPOSITION=UDP.CDPOSITION                              
                                WHERE
                                    1=1                                  
                                    AND PM.FGACCESSTYPE=3                                  
                                    AND UDP.CDUSER=1                              
                                UNION
                                ALL SELECT
                                    PM.FGPERMISSION,
                                    PM.CDACTTYPE,
                                    PM.CDACCESSLIST,
                                    UDP.CDUSER AS USERCD                              
                                FROM
                                    PMACTTYPESECURLIST PM                              
                                INNER JOIN
                                    ADUSERDEPTPOS UDP                                      
                                        ON PM.CDPOSITION=UDP.CDPOSITION                              
                                WHERE
                                    1=1                                  
                                    AND PM.FGACCESSTYPE=4                                  
                                    AND UDP.CDUSER=1                              
                                UNION
                                ALL SELECT
                                    PM.FGPERMISSION,
                                    PM.CDACTTYPE,
                                    PM.CDACCESSLIST,
                                    PM.CDUSER AS USERCD                              
                                FROM
                                    PMACTTYPESECURLIST PM                              
                                WHERE
                                    1=1                                  
                                    AND PM.FGACCESSTYPE=5                                  
                                    AND PM.CDUSER=1                              
                                UNION
                                ALL SELECT
                                    PM.FGPERMISSION,
                                    PM.CDACTTYPE,
                                    PM.CDACCESSLIST,
                                    US.CDUSER AS USERCD                              
                                FROM
                                    PMACTTYPESECURLIST PM CROSS                              
                                JOIN
                                    ADUSER US                              
                                WHERE
                                    1=1                                  
                                    AND PM.FGACCESSTYPE=6                                  
                                    AND US.CDUSER=1                              
                                UNION
                                ALL SELECT
                                    PM.FGPERMISSION,
                                    PM.CDACTTYPE,
                                    PM.CDACCESSLIST,
                                    RL.CDUSER AS USERCD                              
                                FROM
                                    PMACTTYPESECURLIST PM                              
                                INNER JOIN
                                    ADUSERROLE RL                                      
                                        ON RL.CDROLE=PM.CDROLE                              
                                WHERE
                                    1=1                                  
                                    AND PM.FGACCESSTYPE=7                                  
                                    AND RL.CDUSER=1                         
                            ) PERM1                      
                        INNER JOIN
                            PMACTTYPESECURCTRL GNASSOC                              
                                ON PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST                              
                                AND PERM1.CDACTTYPE=GNASSOC.CDACTTYPE                      
                        INNER JOIN
                            PMACCESSROLEFIELD GNCTRL                              
                                ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD                      
                        INNER JOIN
                            PMACCESSROLEFIELD GNCTRL_F                              
                                ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD                      
                        INNER JOIN
                            PMACTIVITY PMA                              
                                ON PERM1.CDACTTYPE=PMA.CDACTTYPE                      
                        INNER JOIN
                            WFPROCESS WFP                              
                                ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL                      
                        WHERE
                            1=1                          
                            AND GNCTRL_F.CDRELATEDFIELD=501                          
                            AND WFP.FGSTATUS <= 5                          
                            AND PMA.FGUSETYPEACCESS=1                          
                            AND WFP.FGMODELWFSECURITY=1                      
                        UNION
                        ALL SELECT
                            WFP.IDOBJECT,
                            PMA.FGUSETYPEACCESS,
                            PERM2.FGPERMISSION                      
                        FROM
                            (SELECT
                                PM.FGPERMISSION,
                                PM.CDACTTYPE,
                                PM.CDACCESSLIST,
                                PMA.CDCREATEDBY AS USERCD                          
                            FROM
                                PMACTTYPESECURLIST PM                          
                            INNER JOIN
                                PMACTIVITY PMA                                  
                                    ON PM.CDACTTYPE=PMA.CDACTTYPE                          
                            WHERE
                                1=1                              
                                AND PM.FGACCESSTYPE=8                              
                                AND PMA.CDCREATEDBY=1                          
                            UNION
                            ALL SELECT
                                PM.FGPERMISSION,
                                PM.CDACTTYPE,
                                PM.CDACCESSLIST,
                                DEP2.CDUSER                          
                            FROM
                                PMACTTYPESECURLIST PM                          
                            INNER JOIN
                                PMACTIVITY PMA                                  
                                    ON PM.CDACTTYPE=PMA.CDACTTYPE                          
                            INNER JOIN
                                ADUSERDEPTPOS DEP1                                  
                                    ON DEP1.CDUSER=PMA.CDCREATEDBY                          
                            INNER JOIN
                                ADUSERDEPTPOS DEP2                                  
                                    ON DEP2.CDDEPARTMENT=DEP1.CDDEPARTMENT                          
                            WHERE
                                1=1                              
                                AND PM.FGACCESSTYPE=9                              
                                AND DEP2.CDUSER=1                          
                            UNION
                            ALL SELECT
                                PM.FGPERMISSION,
                                PM.CDACTTYPE,
                                PM.CDACCESSLIST,
                                DEP2.CDUSER                          
                            FROM
                                PMACTTYPESECURLIST PM                          
                            INNER JOIN
                                PMACTIVITY PMA                                  
                                    ON PM.CDACTTYPE=PMA.CDACTTYPE                          
                            INNER JOIN
                                ADUSERDEPTPOS DEP1                                  
                                    ON DEP1.CDUSER=PMA.CDCREATEDBY                          
                            INNER JOIN
                                ADUSERDEPTPOS DEP2                                  
                                    ON DEP2.CDDEPARTMENT=DEP1.CDDEPARTMENT                                  
                                    AND DEP2.CDPOSITION=DEP1.CDPOSITION                          
                            WHERE
                                1=1                              
                                AND PM.FGACCESSTYPE=10                              
                                AND DEP2.CDUSER=1                          
                            UNION
                            ALL SELECT
                                PM.FGPERMISSION,
                                PM.CDACTTYPE,
                                PM.CDACCESSLIST,
                                DEP2.CDUSER                          
                            FROM
                                PMACTTYPESECURLIST PM                          
                            INNER JOIN
                                PMACTIVITY PMA                                  
                                    ON PM.CDACTTYPE=PMA.CDACTTYPE                          
                            INNER JOIN
                                ADUSERDEPTPOS DEP1                                  
                                    ON DEP1.CDUSER=PMA.CDCREATEDBY                          
                            INNER JOIN
                                ADUSERDEPTPOS DEP2                                  
                                    ON DEP2.CDPOSITION=DEP1.CDPOSITION                          
                            WHERE
                                1=1                              
                                AND PM.FGACCESSTYPE=11                              
                                AND DEP2.CDUSER=1                          
                            UNION
                            ALL SELECT
                                PM.FGPERMISSION,
                                PM.CDACTTYPE,
                                PM.CDACCESSLIST,
                                US.CDLEADER                          
                            FROM
                                PMACTTYPESECURLIST PM                          
                            INNER JOIN
                                PMACTIVITY PMA                                  
                                    ON PM.CDACTTYPE=PMA.CDACTTYPE                          
                            INNER JOIN
                                ADUSER US                                  
                                    ON US.CDUSER=PMA.CDCREATEDBY                          
                            WHERE
                                1=1                              
                                AND PM.FGACCESSTYPE=12                              
                                AND US.CDLEADER=1                     
                        ) PERM2                  
                    INNER JOIN
                        PMACTTYPESECURCTRL GNASSOC                          
                            ON PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST                          
                            AND PERM2.CDACTTYPE=GNASSOC.CDACTTYPE                  
                    INNER JOIN
                        PMACCESSROLEFIELD GNCTRL                          
                            ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD                  
                    INNER JOIN
                        PMACCESSROLEFIELD GNCTRL_F                          
                            ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD                  
                    INNER JOIN
                        PMACTIVITY PMA                          
                            ON PERM2.CDACTTYPE=PMA.CDACTTYPE                  
                    INNER JOIN
                        WFPROCESS WFP                          
                            ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL                  
                    WHERE
                        1=1                      
                        AND GNCTRL_F.CDRELATEDFIELD=501                      
                        AND WFP.FGSTATUS <= 5                      
                        AND PMA.FGUSETYPEACCESS=1                      
                        AND WFP.FGMODELWFSECURITY=1                  
                    UNION
                    ALL SELECT
                        PERM3.IDOBJECT,
                        PMA.FGUSETYPEACCESS,
                        PERM3.FGPERMISSION                  
                    FROM
                        (SELECT
                            PM.FGPERMISSION,
                            PM.CDACTTYPE,
                            PM.CDACCESSLIST,
                            WFP.CDUSERSTART AS USERCD,
                            WFP.IDOBJECT                      
                        FROM
                            PMACTTYPESECURLIST PM                      
                        INNER JOIN
                            PMACTIVITY PMA                              
                                ON PM.CDACTTYPE=PMA.CDACTTYPE                      
                        INNER JOIN
                            WFPROCESS WFP                              
                                ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL                      
                        WHERE
                            1=1                          
                            AND PM.FGACCESSTYPE=30                          
                            AND WFP.CDUSERSTART=1                          
                            AND WFP.FGSTATUS <= 5                          
                            AND WFP.FGMODELWFSECURITY=1                      
                        UNION
                        ALL SELECT
                            PM.FGPERMISSION,
                            PM.CDACTTYPE,
                            PM.CDACCESSLIST,
                            US.CDLEADER AS USERCD,
                            WFP.IDOBJECT                      
                        FROM
                            PMACTTYPESECURLIST PM                      
                        INNER JOIN
                            PMACTIVITY PMA                              
                                ON PM.CDACTTYPE=PMA.CDACTTYPE                      
                        INNER JOIN
                            WFPROCESS WFP                              
                                ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL                      
                        INNER JOIN
                            ADUSER US                              
                                ON US.CDUSER=WFP.CDUSERSTART                      
                        WHERE
                            1=1                          
                            AND PM.FGACCESSTYPE=31                          
                            AND US.CDLEADER=1                          
                            AND WFP.FGSTATUS <= 5                          
                            AND WFP.FGMODELWFSECURITY=1                 
                    ) PERM3              
                INNER JOIN
                    PMACTTYPESECURCTRL GNASSOC                      
                        ON PERM3.CDACCESSLIST=GNASSOC.CDACCESSLIST                      
                        AND PERM3.CDACTTYPE=GNASSOC.CDACTTYPE              
                INNER JOIN
                    PMACCESSROLEFIELD GNCTRL                      
                        ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD              
                INNER JOIN
                    PMACCESSROLEFIELD GNCTRL_F                      
                        ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD              
                INNER JOIN
                    PMACTIVITY PMA                      
                        ON PERM3.CDACTTYPE=PMA.CDACTTYPE              
                WHERE
                    1=1                  
                    AND GNCTRL_F.CDRELATEDFIELD=501                  
                    AND PMA.FGUSETYPEACCESS=1) PERM          
            WHERE
                1=1          
            GROUP BY
                PERM.IDOBJECT) T          
            INNER JOIN
                INOCCURRENCE INCID                  
                    ON INCID.IDWORKFLOW=T.IDOBJECT          
            WHERE
                1=1              
                AND T.FGPERMISSION=1              
                AND INCID.FGOCCURRENCETYPE=2          
            UNION
            ALL SELECT
                T.IDOBJECT          
            FROM
                (SELECT
                    MIN(PERM99.FGPERMISSION) AS FGPERMISSION,
                    PERM99.IDOBJECT              
                FROM
                    (SELECT
                        WFP.IDOBJECT,
                        PERM1.FGPERMISSION                  
                    FROM
                        (SELECT
                            PP.FGPERMISSION,
                            PP.CDPROC,
                            PP.CDACCESSLIST,
                            TM.CDUSER AS USERCD                      
                        FROM
                            PMPROCACCESSLIST PP                      
                        INNER JOIN
                            ADTEAMUSER TM                              
                                ON PP.CDTEAM=TM.CDTEAM                      
                        WHERE
                            1=1                          
                            AND PP.FGACCESSTYPE=1                          
                            AND TM.CDUSER=1                      
                        UNION
                        ALL SELECT
                            PP.FGPERMISSION,
                            PP.CDPROC,
                            PP.CDACCESSLIST,
                            UDP.CDUSER AS USERCD                      
                        FROM
                            PMPROCACCESSLIST PP                      
                        INNER JOIN
                            ADUSERDEPTPOS UDP                              
                                ON PP.CDDEPARTMENT=UDP.CDDEPARTMENT                      
                        WHERE
                            1=1                          
                            AND PP.FGACCESSTYPE=2                          
                            AND UDP.CDUSER=1                      
                        UNION
                        ALL SELECT
                            PP.FGPERMISSION,
                            PP.CDPROC,
                            PP.CDACCESSLIST,
                            UDP.CDUSER AS USERCD                      
                        FROM
                            PMPROCACCESSLIST PP                      
                        INNER JOIN
                            ADUSERDEPTPOS UDP                              
                                ON PP.CDDEPARTMENT=UDP.CDDEPARTMENT                              
                                AND PP.CDPOSITION=UDP.CDPOSITION                      
                        WHERE
                            1=1                          
                            AND PP.FGACCESSTYPE=3                          
                            AND UDP.CDUSER=1                      
                        UNION
                        ALL SELECT
                            PP.FGPERMISSION,
                            PP.CDPROC,
                            PP.CDACCESSLIST,
                            UDP.CDUSER AS USERCD                      
                        FROM
                            PMPROCACCESSLIST PP                      
                        INNER JOIN
                            ADUSERDEPTPOS UDP                              
                                ON PP.CDPOSITION=UDP.CDPOSITION                      
                        WHERE
                            1=1                          
                            AND PP.FGACCESSTYPE=4                          
                            AND UDP.CDUSER=1                      
                        UNION
                        ALL SELECT
                            PP.FGPERMISSION,
                            PP.CDPROC,
                            PP.CDACCESSLIST,
                            PP.CDUSER AS USERCD                      
                        FROM
                            PMPROCACCESSLIST PP                      
                        WHERE
                            1=1                          
                            AND PP.FGACCESSTYPE=5                          
                            AND PP.CDUSER=1                      
                        UNION
                        ALL SELECT
                            PP.FGPERMISSION,
                            PP.CDPROC,
                            PP.CDACCESSLIST,
                            US.CDUSER AS USERCD                      
                        FROM
                            PMPROCACCESSLIST PP CROSS                      
                        JOIN
                            ADUSER US                      
                        WHERE
                            1=1                          
                            AND PP.FGACCESSTYPE=6                          
                            AND US.CDUSER=1                      
                        UNION
                        ALL SELECT
                            PP.FGPERMISSION,
                            PP.CDPROC,
                            PP.CDACCESSLIST,
                            RL.CDUSER AS USERCD                      
                        FROM
                            PMPROCACCESSLIST PP                      
                        INNER JOIN
                            ADUSERROLE RL                              
                                ON RL.CDROLE=PP.CDROLE                      
                        WHERE
                            1=1                          
                            AND PP.FGACCESSTYPE=7                          
                            AND RL.CDUSER=1                 
                    ) PERM1              
                INNER JOIN
                    PMPROCSECURITYCTRL GNASSOC                      
                        ON PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST                      
                        AND PERM1.CDPROC=GNASSOC.CDPROC              
                INNER JOIN
                    PMACCESSROLEFIELD GNCTRL                      
                        ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD              
                INNER JOIN
                    PMACTIVITY OBJ                      
                        ON GNASSOC.CDPROC=OBJ.CDACTIVITY              
                INNER JOIN
                    WFPROCESS WFP                      
                        ON WFP.CDPROCESSMODEL=PERM1.CDPROC              
                WHERE
                    1=1                  
                    AND GNCTRL.CDRELATEDFIELD=501                  
                    AND (
                        OBJ.FGUSETYPEACCESS=0                      
                        OR OBJ.FGUSETYPEACCESS IS NULL                 
                    )                  
                    AND WFP.FGMODELWFSECURITY=1                  
                    AND WFP.FGSTATUS <= 5              
                UNION
                ALL SELECT
                    PERM2.IDOBJECT,
                    PERM2.FGPERMISSION              
                FROM
                    (SELECT
                        PP.FGPERMISSION,
                        WFP.IDOBJECT,
                        PP.CDPROC,
                        PP.CDACCESSLIST,
                        WFP.CDUSERSTART AS USERCD                  
                    FROM
                        PMPROCACCESSLIST PP                  
                    INNER JOIN
                        WFPROCESS WFP                          
                            ON WFP.CDPROCESSMODEL=PP.CDPROC                  
                    WHERE
                        1=1                      
                        AND PP.FGACCESSTYPE=30                      
                        AND WFP.CDUSERSTART=1                      
                        AND WFP.FGMODELWFSECURITY=1                      
                        AND WFP.FGSTATUS <= 5                  
                    UNION
                    ALL SELECT
                        PP.FGPERMISSION,
                        WFP.IDOBJECT,
                        PP.CDPROC,
                        PP.CDACCESSLIST,
                        US.CDLEADER AS USERCD                  
                    FROM
                        PMPROCACCESSLIST PP                  
                    INNER JOIN
                        WFPROCESS WFP                          
                            ON WFP.CDPROCESSMODEL=PP.CDPROC                  
                    INNER JOIN
                        ADUSER US                          
                            ON US.CDUSER=WFP.CDUSERSTART                  
                    WHERE
                        1=1                      
                        AND PP.FGACCESSTYPE=31                      
                        AND US.CDLEADER=1                      
                        AND WFP.FGMODELWFSECURITY=1                      
                        AND WFP.FGSTATUS <= 5             
                ) PERM2          
            INNER JOIN
                PMPROCSECURITYCTRL GNASSOC                  
                    ON PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST                  
                    AND PERM2.CDPROC=GNASSOC.CDPROC          
            INNER JOIN
                PMACCESSROLEFIELD GNCTRL                  
                    ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD          
            INNER JOIN
                PMACTIVITY OBJ                  
                    ON GNASSOC.CDPROC=OBJ.CDACTIVITY          
            WHERE
                1=1              
                AND GNCTRL.CDRELATEDFIELD=501              
                AND (
                    OBJ.FGUSETYPEACCESS=0                  
                    OR OBJ.FGUSETYPEACCESS IS NULL             
                )) PERM99      
        WHERE
            1=1      
        GROUP BY
            PERM99.IDOBJECT) T      
        INNER JOIN
            INOCCURRENCE INCID              
                ON INCID.IDWORKFLOW=T.IDOBJECT      
        WHERE
            1=1          
            AND T.FGPERMISSION=1          
            AND INCID.FGOCCURRENCETYPE=2 
    ) Z  
WHERE
    1=1 
) MYPERM  
ON (
    P.IDOBJECT=MYPERM.IDOBJECT 
)  
WHERE
1=1  
AND P.FGSTATUS <= 5  
AND INCID.FGOCCURRENCETYPE=2 
) TEMPTB 
) TMP) tmp2