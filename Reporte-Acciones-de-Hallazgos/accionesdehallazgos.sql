SELECT
 /** 
            Creación: 27-04-2022. Andrés Del Río. Reporte de acciones y planes de hallazgos con base en la consulta estándar del menú PB014
            Ambiente: https://sgi.grupoaguas.cl/softexpert 
            Versión SE Suite: 2.1.2.100 
            Panel de análisis:  REPACCHAL - Reporte de Acciones y Planes de Hallazgos SGI 2.0
            
            Modificaciones: 
            DD-MM-AAAA. Autor. Descripción.
**/
        CASE 
            WHEN GNACT.FGSTATUS=1 
            OR GNACT.FGSTATUS=2 THEN CASE 
                WHEN (TMCPLAN.FGIMMEDIATEACTION=2 
                OR TMCPLAN.FGIMMEDIATEACTION IS NULL) THEN CASE 
                    WHEN (TMCPLAN.FGIMMEDIATEACTION=1)  THEN '#{100900}' 
                    WHEN (GNACT.DTSTARTPLAN IS NOT NULL 
                    AND GNACT.DTSTARTPLAN < <!%TODAY%>) THEN '#{100899}' 
                    WHEN (GNACT.DTSTARTPLAN IS NULL 
                    OR GNACT.DTSTARTPLAN >= <!%TODAY%>) THEN '#{100900}' 
                END 
                ELSE '#{100900}' 
            END 
            WHEN GNACT.FGSTATUS=3 
            OR GNACT.FGSTATUS=13 THEN CASE 
                WHEN (GNACT.DTFINISH IS NOT NULL) THEN CASE 
                    WHEN (GNACT.DTFINISH <= GNACT.DTFINISHPLAN) THEN '#{100900}' 
                    WHEN (GNACT.DTFINISH > GNACT.DTFINISHPLAN) THEN '#{100899}' 
                END 
                WHEN (GNACT.DTFINISH IS NULL) THEN CASE 
                    WHEN (GNACT.DTFINISHPLAN < <!%TODAY%>) THEN '#{100899}' 
                    WHEN (GNACT.DTFINISHPLAN > SEF_DTEND_WK_DAYS_PERIOD(<!%TODAY%>,
                    3,
                    (CASE 
                        WHEN GNACT2.CDGENACTIVITY IS NOT NULL THEN GNACT2.CDCALENDAR 
                        ELSE GNACT.CDCALENDAR 
                    END))) THEN '#{100900}' 
                    ELSE '#{201639}' 
                END 
            END 
            WHEN GNACT.FGSTATUS=5 
            OR GNACT.FGSTATUS=4 THEN CASE 
                WHEN (GNACT.DTSTARTPLAN IS NULL 
                OR GNACT.DTFINISH <= GNACT.DTFINISHPLAN) THEN '#{100900}' 
                ELSE '#{100899}' 
            END 
        END AS NMDEADLINE,
        CASE 
            WHEN GNACT.FGSTATUS=1 THEN '#{100470}' 
            WHEN GNACT.FGSTATUS=2 THEN '#{200135}' 
            WHEN GNACT.FGSTATUS=3 THEN '#{200002}' 
            WHEN GNACT.FGSTATUS=4 
            AND GNACT.CDACTIVITYOWNER IS NOT NULL THEN '#{218317}' 
            WHEN GNACT.FGSTATUS=4 
            AND GNACT.CDACTIVITYOWNER IS NULL THEN '#{100476}' 
            WHEN GNACT.FGSTATUS=5 THEN '#{101237}' 
            WHEN GNACT.FGSTATUS=6 THEN '#{104230}' 
        END AS NMACTSTATUS,
        CASE 
            WHEN GNACT2.FGSTATUS=1 THEN '#{100470}' 
            WHEN GNACT2.FGSTATUS=2 THEN '#{200135}' 
            WHEN GNACT2.FGSTATUS=3 THEN '#{200002}' 
            WHEN GNACT2.FGSTATUS=4 
            AND GNACT2.CDACTIVITYOWNER IS NOT NULL THEN '#{218317}' 
            WHEN GNACT2.FGSTATUS=4 
            AND GNACT2.CDACTIVITYOWNER IS NULL THEN '#{100476}' 
            WHEN GNACT2.FGSTATUS=5 THEN '#{101237}' 
            WHEN GNACT2.FGSTATUS=6 THEN '#{104230}' 
        END AS NMACTIONPLANSTATUS,
        GNACT.CDGENACTIVITY,
        GNACT.DTSTARTPLAN,
        GNACT.DTSTART,
        GNACT.DTFINISHPLAN,
        GNACT.DTFINISH,
        GNACT.VLPERCENTAGEM,
        GNCOST.MNCOSTPROG,
        GNCOST.MNCOSTREAL,
        GNACT2.IDACTIVITY AS IDACTIONPLAN,
        GNACT2.NMACTIVITY AS NMACTIONPLAN,
        GNACT.IDACTIVITY,
        GNACT.NMACTIVITY,
        GNGNTP.IDGENTYPE,
        GNGNTP.NMGENTYPE,
        ADUSR.IDUSER AS IDTASKRESP,
        CASE 
            WHEN GNACT.CDUSER IS NULL THEN ADEXTUSR.NMUSER 
            ELSE ADUSR.NMUSER 
        END AS NMTASKRESP,
        ADUSRESPACTION3.NMUSER AS NMACTIONPLANRESP,
        GNRESUACT.NMEVALRESULT AS NMEVALRESULTACT,
        (CASE 
            WHEN (ATEAM.IDTEAM IS NOT NULL) THEN ATEAM.IDTEAM || ' - ' || ATEAM.NMTEAM 
            ELSE CAST(NULL AS VARCHAR2(255)) 
        END) AS IDNMTEAM,
        CASE 
            WHEN (AD.IDDEPARTMENT IS NOT NULL) THEN AD.IDDEPARTMENT || ' - ' || AD.NMDEPARTMENT 
            ELSE CAST(NULL AS VARCHAR2(255)) 
        END AS IDNMDEPTUSERRESP,
        CASE 
            WHEN (AP.IDPOSITION IS NOT NULL) THEN AP.IDPOSITION || ' - ' || AP.NMPOSITION 
            ELSE CAST(NULL AS VARCHAR2(255)) 
        END AS IDNMPOSUSERRESP,
        GNT.CDCYCLEPLAN,
        CASE 
            WHEN GNAPR.FGAPPROV=1 THEN '#{100558}' 
            WHEN GNAPR.FGAPPROV=2 THEN '#{100761}' 
            ELSE NULL 
        END AS FGAPPROV,
        1 AS QTD,
        CASE 
            WHEN GNAPRACT.FGAPPROV=1 THEN '#{100558}' 
            WHEN (GNAPRACT.FGAPPROV IS NULL 
            AND GNAPPEXECACTION.NRLASTCYCLE > 1) THEN '#{100761}' 
            ELSE NULL 
        END AS FGAPPROVACTOPM,
        GNAPPEXECACTION.NRLASTCYCLE AS CDCYCLEACTION,
        P.IDPROCESS,
        P.NMPROCESS,
        GNGNTP2.IDGENTYPE AS IDPLANTYPE,
        TO_TIMESTAMP( TO_CHAR( P.DTSTART,
        'YYYY-MM-DD') || ' ' || P.TMSTART,
        'YYYY-MM-DD HH24:MI:SS') AS DTSTARTOCCURRENCE,
        TO_TIMESTAMP( TO_CHAR( P.DTSTART,
        'YYYY-MM-DD') || ' ' || P.TMSTART,
        'YYYY-MM-DD HH24:MI:SS') AS DTFINISHOCCURRENCE,
        WFGNT.IDGENTYPE AS GENTYPEOCCURRENCE,
        CASE 
            WHEN P.FGCONCLUDEDSTATUS IS NOT NULL THEN (CASE 
                WHEN P.FGCONCLUDEDSTATUS=1 THEN 'Al día' 
                WHEN P.FGCONCLUDEDSTATUS=2 THEN 'Atrasado' 
            END) 
            ELSE (CASE 
                WHEN (( P.DTESTIMATEDFINISH > (CAST(<!%TODAY%> AS DATE) + COALESCE((SELECT
                    QTDAYS 
                FROM
                    ADMAILTASKEXEC 
                WHERE
                    CDMAILTASKEXEC=(SELECT
                        TASK.CDAHEAD 
                    FROM
                        ADMAILTASKREL TASK 
                    WHERE
                        TASK.CDMAILTASKREL=(SELECT
                            TBL.CDMAILTASKSETTINGS 
                        FROM
                            CONOTIFICATION TBL))),1))) 
                OR (P.DTESTIMATEDFINISH IS NULL)) THEN 'Al día' 
                WHEN (( P.DTESTIMATEDFINISH=CAST(<!%TODAY%> AS DATE) 
                AND P.NRTIMEESTFINISH >= 1067) 
                OR (P.DTESTIMATEDFINISH > CAST(<!%TODAY%> AS DATE))) THEN 'Próximo del vencimiento' 
                ELSE 'Atrasado' 
            END) 
        END AS NMDEADLINEOCCURRENCE,
        CASE P.FGSTATUS 
            WHEN 1 THEN 'En marcha' 
            WHEN 2 THEN 'Suspendido' 
            WHEN 3 THEN 'Cancelado' 
            WHEN 4 THEN 'Finalizado' 
            WHEN 5 THEN 'Bloqueado para edición' 
        END AS IDSITUATION 
    FROM
        (SELECT
            CDGENACTIVITY,
            CDTASK,
            2 AS FGPLAN,
            NULL AS CDACTIONPLAN,
            CDTASKTYPE AS CDACTIONPLANTYPE,
            CDISOSYSTEM,
            FGOBJECT,
            2 AS FGMODEL,
            NULL AS CDFAVORITE,
            FGIMMEDIATEACTION 
        FROM
            GNTASK) TMCPLAN 
    INNER JOIN
        GNACTIVITY GNACT 
            ON (
                GNACT.CDGENACTIVITY=TMCPLAN.CDGENACTIVITY 
                AND GNACT.CDISOSYSTEM=174
            ) 
    LEFT OUTER JOIN
        ADUSER ADUSR 
            ON (
                ADUSR.CDUSER=GNACT.CDUSER
            ) 
    LEFT OUTER JOIN
        ADUSER ADUSR2 
            ON (
                ADUSR2.CDUSER=GNACT.CDUSERACTIVRESP
            ) 
    LEFT OUTER JOIN
        GNGENTYPE GNGNTP 
            ON (
                GNGNTP.CDGENTYPE=TMCPLAN.CDACTIONPLANTYPE
            ) 
    LEFT OUTER JOIN
        GNCOSTCONFIG GNCOST 
            ON (
                GNACT.CDCOSTCONFIG=GNCOST.CDCOSTCONFIG
            ) 
    LEFT OUTER JOIN
        GNEVALRESULTUSED GNEVALRESACT 
            ON (
                GNEVALRESACT.CDEVALRESULTUSED=GNACT.CDEVALRSLTPRIORITY
            ) 
    LEFT OUTER JOIN
        GNEVALRESULT GNRESUACT 
            ON (
                GNRESUACT.CDEVALRESULT=GNEVALRESACT.CDEVALRESULT
            ) 
    LEFT OUTER JOIN
        GNACTIVITY GNACT2 
            ON (
                GNACT2.CDGENACTIVITY=GNACT.CDACTIVITYOWNER 
                AND GNACT2.CDISOSYSTEM=174
            ) 
    LEFT OUTER JOIN
        ADUSER ADUSR4 
            ON (
                ADUSR4.CDUSER=GNACT2.CDUSERACTIVRESP
            ) 
    LEFT OUTER JOIN
        GNACTIONPLAN GNACTPL 
            ON (
                GNACTPL.CDGENACTIVITY=GNACT2.CDGENACTIVITY
            ) 
    LEFT OUTER JOIN
        GNGENTYPE GNGNTP2 
            ON (
                GNGNTP2.CDGENTYPE=GNACTPL.CDACTIONPLANTYPE
            ) 
    LEFT OUTER JOIN
        ADTEAM ATEAM 
            ON (
                ATEAM.CDTEAM=GNACT.CDTEAM
            ) 
    LEFT OUTER JOIN
        GNTASK GNTASK_ 
            ON (
                TMCPLAN.CDGENACTIVITY=GNTASK_.CDGENACTIVITY
            ) 
    INNER JOIN
        GNASSOCACTIONPLAN INGNAP 
            ON (
                INGNAP.CDACTIONPLAN=GNACTPL.CDGENACTIVITY 
                OR INGNAP.CDACTIONPLAN=GNTASK_.CDGENACTIVITY
            ) 
    INNER JOIN
        GNACTIVITY WFGNAT 
            ON (
                INGNAP.CDASSOC=WFGNAT.CDASSOC
            ) 
    INNER JOIN
        WFPROCESS P 
            ON (
                WFGNAT.CDGENACTIVITY=P.CDGENACTIVITY
            ) 
    INNER JOIN
        INOCCURRENCE INO 
            ON (
                P.IDOBJECT=INO.IDWORKFLOW
            ) 
    LEFT OUTER JOIN
        GNGENTYPE WFGNT 
            ON (
                INO.CDOCCURRENCETYPE=WFGNT.CDGENTYPE
            ) 
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
                                AND WF.FGACCESSEXCEPTION IS NULL 
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
                                AND WF.FGACCESSEXCEPTION IS NULL 
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
                                AND WF.FGACCESSEXCEPTION IS NULL 
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
                                AND WF.FGACCESSEXCEPTION IS NULL 
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
                                AND WF.FGACCESSEXCEPTION IS NULL 
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
                                AND WF.FGACCESSEXCEPTION IS NULL 
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
                                AND WF.FGACCESSEXCEPTION IS NULL 
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
                                AND WF.FGACCESSEXCEPTION IS NULL 
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
                                AND WF.FGACCESSEXCEPTION IS NULL
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
            WHERE
                1=1 
                AND PERMISSION.FGPERMISSION=1 
                AND P.FGSTATUS <= 5 
                AND (
                    P.FGMODELWFSECURITY IS NULL 
                    OR P.FGMODELWFSECURITY=0
                ) 
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
    WHERE
        1=1 
        AND T.FGPERMISSION=1 
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
WHERE
    1=1 
    AND T.FGPERMISSION=1 
UNION
ALL SELECT
    WFP.IDOBJECT 
FROM
    WFPROCESS WFP 
INNER JOIN
    WFPROCSECURITYLIST WFLIST 
        ON WFP.IDOBJECT=WFLIST.IDPROCESS 
INNER JOIN
    WFPROCSECURITYCTRL WFCTRL 
        ON WFLIST.CDACCESSLIST=WFCTRL.CDACCESSLIST 
        AND WFLIST.IDPROCESS=WFCTRL.IDPROCESS 
WHERE
    WFCTRL.CDACCESSROLEFIELD=501 
    AND WFLIST.CDUSER=1 
    AND WFLIST.FGACCESSTYPE=5 
    AND WFLIST.FGACCESSEXCEPTION=1 
    AND WFLIST.FGPERMISSION=1 
    AND WFP.FGSTATUS <= 5
) Z 
WHERE
1=1
) MYPERM 
ON (
P.IDOBJECT=MYPERM.IDOBJECT
) 
LEFT OUTER JOIN
ADUSER ADUSRESPACTION3 
ON (
ADUSRESPACTION3.CDUSER=GNACT2.CDUSERACTIVRESP
) 
LEFT OUTER JOIN
GNTASK GNT 
ON (
GNT.CDGENACTIVITY=GNACT.CDGENACTIVITY 
AND GNT.CDCYCLEPLAN IS NOT NULL
) 
LEFT OUTER JOIN
ADUSERDEPTPOS ADUD 
ON (
ADUD.CDUSER=ADUSR.CDUSER 
AND ADUD.FGDEFAULTDEPTPOS=1
) 
LEFT OUTER JOIN
ADDEPARTMENT AD 
ON (
AD.CDDEPARTMENT=ADUD.CDDEPARTMENT
) 
LEFT OUTER JOIN
ADPOSITION AP 
ON (
AP.CDPOSITION=ADUD.CDPOSITION
) 
LEFT OUTER JOIN
GNAPPROV GNAPPEXECACTION 
ON (
GNAPPEXECACTION.CDPROD=GNACT.CDPRODROUTE 
AND GNACT.CDEXECROUTE=GNAPPEXECACTION.CDAPPROV
) 
LEFT OUTER JOIN
(
SELECT
GNAPPROVRESP.CDAPPROV,
GNAPPROVRESP.CDCYCLE,
GNAPPROVRESP.CDPROD,
MAX(GNAPPROVRESP.FGAPPROV) AS FGAPPROV 
FROM
GNAPPROVRESP 
INNER JOIN
GNACTIVITY 
ON (
    GNACTIVITY.CDEXECROUTE=GNAPPROVRESP.CDAPPROV 
    AND GNACTIVITY.CDPRODROUTE=GNAPPROVRESP.CDPROD
) 
INNER JOIN
GNACTIONPLAN 
ON (
    GNACTIONPLAN.CDGENACTIVITY=GNACTIVITY.CDGENACTIVITY
) 
GROUP BY
GNAPPROVRESP.CDAPPROV,
GNAPPROVRESP.CDCYCLE,
GNAPPROVRESP.CDPROD
) GNAPR 
ON (
GNACT2.CDEXECROUTE=GNAPR.CDAPPROV 
AND GNACT2.CDPRODROUTE=GNAPR.CDPROD 
AND GNAPR.CDCYCLE=GNT.CDCYCLEPLAN
) 
LEFT OUTER JOIN
(
SELECT
GNAPPROVRESP.CDAPPROV,
GNAPPROVRESP.CDCYCLE,
GNAPPROVRESP.CDPROD,
MAX(GNAPPROVRESP.FGAPPROV) AS FGAPPROV 
FROM
GNAPPROVRESP 
INNER JOIN
GNACTIVITY 
ON GNACTIVITY.CDEXECROUTE=GNAPPROVRESP.CDAPPROV 
AND GNACTIVITY.CDPRODROUTE=GNAPPROVRESP.CDPROD 
INNER JOIN
GNTASK 
ON GNTASK.CDGENACTIVITY=GNACTIVITY.CDGENACTIVITY 
GROUP BY
GNAPPROVRESP.CDAPPROV,
GNAPPROVRESP.CDCYCLE,
GNAPPROVRESP.CDPROD
) GNAPRACT 
ON GNAPRACT.CDAPPROV=GNACT.CDEXECROUTE 
AND GNAPRACT.CDPROD=GNACT.CDPRODROUTE 
AND GNAPRACT.CDCYCLE=GNAPPEXECACTION.NRLASTCYCLE 
LEFT OUTER JOIN
ADEXTERNALUSER ADEXTUSR 
ON GNACT.CDEXTERNALUSER=ADEXTUSR.CDEXTERNALUSER 
WHERE
1=1 
AND (
GNACTPL.FGMODEL <> 1 
OR GNACTPL.CDGENACTIVITY IS NULL
) 
AND (
GNACT.CDACTIVITYOWNER IS NULL 
OR (
GNACT.CDACTIVITYOWNER IS NOT NULL 
AND EXISTS (
SELECT
    1 
FROM
    ADMINISTRATION 
WHERE
    COALESCE(GNACTPL.FGOBJECT,-1) <> 9 /*sub*/
UNION
/*sub*/ ALL SELECT
    1 
FROM
    ADMINISTRATION 
WHERE
    GNACTPL.FGOBJECT=9 
    AND  (
        NOT EXISTS (
            SELECT
                1 
            FROM
                GNASSOCACTIONPLAN GNACPLAPDI 
            WHERE
                GNACPLAPDI.CDACTIONPLAN=GNACTPL.CDGENACTIVITY
        ) 
        OR EXISTS (
            SELECT
                1 
            FROM
                GNACTIVITY GNACTPDI 
            INNER JOIN
                GNASSOCACTIONPLAN GNACPLAPDI 
                    ON (
                        GNACPLAPDI.CDACTIONPLAN=GNACTPDI.CDGENACTIVITY
                    ) 
            INNER JOIN
                TRHISTORICAL HIPDI 
                    ON (
                        GNACPLAPDI.CDASSOC=HIPDI.CDASSOC
                    ) 
            LEFT OUTER JOIN
                (
                    /* Pares */ SELECT
                        ADU1.CDUSER,
                        CAST(1 AS NUMBER(10)) AS CDUSERDATA 
                    FROM
                        ADUSER ADU1 
                    INNER JOIN
                        ADUSER ADU2 
                            ON (
                                ADU2.CDUSER <> ADU1.CDUSER
                            ) 
                    INNER JOIN
                        ADPARAMS ADP0 
                            ON (
                                ADP0.CDPARAM=3  
                                AND ADP0.CDISOSYSTEM=153  
                                AND ADP0.VLPARAM=1
                            ) 
                    INNER JOIN
                        ADPARAMS ADP1 
                            ON (
                                ADP1.CDPARAM=20  
                                AND ADP1.CDISOSYSTEM=153
                            ) 
                    INNER JOIN
                        ADPARAMS ADP2 
                            ON (
                                ADP2.CDPARAM=21  
                                AND ADP2.CDISOSYSTEM=153
                            ) 
                    INNER JOIN
                        ADPARAMS ADP3 
                            ON (
                                ADP3.CDPARAM=22  
                                AND ADP3.CDISOSYSTEM=153
                            ) 
                    WHERE
                        1=1 
                        AND EXISTS (
                            SELECT
                                1  
                            FROM
                                ADMINISTRATION  
                            WHERE
                                ADU2.CDLEADER=ADU1.CDLEADER  
                                AND ADP1.VLPARAM=1  
                                AND (
                                    ADP2.VLPARAM <> 1 
                                    OR ADP3.VLPARAM=2
                                ) /*sub*/
                            UNION
                            /*sub*/ ALL SELECT
                                1  
                            FROM
                                ADUSERDEPTPOS ADUDP1 
                            INNER JOIN
                                ADUSERDEPTPOS ADUDP2 
                                    ON (
                                        ADUDP2.CDDEPARTMENT=ADUDP1.CDDEPARTMENT 
                                        AND ADUDP2.CDPOSITION=ADUDP1.CDPOSITION
                                    )  
                            WHERE
                                ADUDP1.CDUSER=ADU1.CDUSER  
                                AND ADUDP2.CDUSER=ADU2.CDUSER  
                                AND ADP2.VLPARAM=1  
                                AND (
                                    ADP1.VLPARAM <> 1 
                                    OR ADP3.VLPARAM=2
                                ) /*sub*/
                            UNION
                            /*sub*/ ALL SELECT
                                1  
                            FROM
                                ADUSERDEPTPOS ADUDP1 
                            INNER JOIN
                                ADUSERDEPTPOS ADUDP2 
                                    ON (
                                        ADUDP2.CDDEPARTMENT=ADUDP1.CDDEPARTMENT 
                                        AND ADUDP2.CDPOSITION=ADUDP1.CDPOSITION
                                    )  
                            WHERE
                                ADUDP1.CDUSER=ADU1.CDUSER  
                                AND ADUDP2.CDUSER=ADU2.CDUSER  
                                AND ADU2.CDLEADER=ADU1.CDLEADER  
                                AND ADP1.VLPARAM=1  
                                AND ADP2.VLPARAM=1  
                                AND ADP3.VLPARAM=1
                        ) 
                        AND ADU2.CDUSER=1 
                    GROUP BY
                        ADU1.CDUSER /*sub*/
                    UNION
                    /*sub*/ /* Lider */ SELECT
                        ADL.CDLEADER AS CDUSER,
                        CAST(1 AS NUMBER(10)) AS CDUSERDATA 
                    FROM
                        ADUSER ADL 
                    INNER JOIN
                        ADPARAMS ADP 
                            ON (
                                ADP.CDPARAM=4  
                                AND ADP.CDISOSYSTEM=153  
                                AND ADP.VLPARAM=1
                            ) 
                    WHERE
                        ADL.CDLEADER IS NOT NULL 
                        AND ADL.CDUSER=1 
                    GROUP BY
                        ADL.CDLEADER /*sub*/
                    UNION
                    /*sub*/ /* Liderados */ SELECT
                        T.CDUSER,
                        CAST(1 AS NUMBER(10)) AS CDUSERDATA 
                    FROM
                        (SELECT
                            ADU1.CDUSER,
                            ADU0.CDUSER AS CDLEADER,
                            1 AS NRLEVEL 
                        FROM
                            ADUSER ADU0 
                        INNER JOIN
                            ADUSER ADU1 
                                ON (
                                    ADU1.CDLEADER=ADU0.CDUSER
                                ) 
                        WHERE
                            ADU0.CDUSER=1 /*sub*/
                        UNION
                        /*sub*/ SELECT
                            ADU2.CDUSER,
                            ADU0.CDUSER AS CDLEADER,
                            2 AS NRLEVEL 
                        FROM
                            ADUSER ADU0 
                        INNER JOIN
                            ADUSER ADU1 
                                ON (
                                    ADU1.CDLEADER=ADU0.CDUSER
                                ) 
                        INNER JOIN
                            ADUSER ADU2 
                                ON (
                                    ADU2.CDLEADER=ADU1.CDUSER
                                ) 
                        WHERE
                            ADU0.CDUSER=1 /*sub*/
                        UNION
                        /*sub*/ SELECT
                            ADU3.CDUSER,
                            ADU0.CDUSER AS CDLEADER,
                            3 AS NRLEVEL 
                        FROM
                            ADUSER ADU0 
                        INNER JOIN
                            ADUSER ADU1 
                                ON (
                                    ADU1.CDLEADER=ADU0.CDUSER
                                ) 
                        INNER JOIN
                            ADUSER ADU2 
                                ON (
                                    ADU2.CDLEADER=ADU1.CDUSER
                                ) 
                        INNER JOIN
                            ADUSER ADU3 
                                ON (
                                    ADU3.CDLEADER=ADU2.CDUSER
                                ) 
                        WHERE
                            ADU0.CDUSER=1 /*sub*/
                        UNION
                        /*sub*/ SELECT
                            ADU4.CDUSER,
                            ADU0.CDUSER AS CDLEADER,
                            4 AS NRLEVEL 
                        FROM
                            ADUSER ADU0 
                        INNER JOIN
                            ADUSER ADU1 
                                ON (
                                    ADU1.CDLEADER=ADU0.CDUSER
                                ) 
                        INNER JOIN
                            ADUSER ADU2 
                                ON (
                                    ADU2.CDLEADER=ADU1.CDUSER
                                ) 
                        INNER JOIN
                            ADUSER ADU3 
                                ON (
                                    ADU3.CDLEADER=ADU2.CDUSER
                                ) 
                        INNER JOIN
                            ADUSER ADU4 
                                ON (
                                    ADU4.CDLEADER=ADU3.CDUSER
                                ) 
                        WHERE
                            ADU0.CDUSER=1 /*sub*/
                        UNION
                        /*sub*/ SELECT
                            ADU5.CDUSER,
                            ADU0.CDUSER AS CDLEADER,
                            5 AS NRLEVEL 
                        FROM
                            ADUSER ADU0 
                        INNER JOIN
                            ADUSER ADU1 
                                ON (
                                    ADU1.CDLEADER=ADU0.CDUSER
                                ) 
                        INNER JOIN
                            ADUSER ADU2 
                                ON (
                                    ADU2.CDLEADER=ADU1.CDUSER
                                ) 
                        INNER JOIN
                            ADUSER ADU3 
                                ON (
                                    ADU3.CDLEADER=ADU2.CDUSER
                                ) 
                        INNER JOIN
                            ADUSER ADU4 
                                ON (
                                    ADU4.CDLEADER=ADU3.CDUSER
                                ) 
                        INNER JOIN
                            ADUSER ADU5 
                                ON (
                                    ADU5.CDLEADER=ADU4.CDUSER
                                ) 
                        WHERE
                            ADU0.CDUSER=1
                    ) T 
                INNER JOIN
                    ADPARAMS ADP 
                        ON (
                            ADP.CDPARAM=2  
                            AND ADP.CDISOSYSTEM=153  
                            AND ADP.VLPARAM=1
                        ) 
                GROUP BY
                    T.CDUSER /*sub*/
                UNION
                /*sub*/ /* Proprio usuario */ SELECT
                    CAST(1 AS NUMBER(10)) AS CDUSER,
                    CAST(1 AS NUMBER(10)) AS CDUSERDATA 
                FROM
                    ADMINISTRATION /*sub*/
                UNION
                /*sub*/ /* Equipe de controle por unidade organizacional */ SELECT
                    ADUDPPOS.CDUSER,
                    CAST(1 AS NUMBER(10)) AS CDUSERDATA 
                FROM
                    ADDEPARTMENT ADP 
                INNER JOIN
                    ADDEPTSUBLEVEL ADDPSUB 
                        ON (
                            ADDPSUB.CDOWNER=ADP.CDDEPARTMENT
                        ) 
                INNER JOIN
                    ADUSERDEPTPOS ADUDPPOS 
                        ON (
                            ADUDPPOS.CDDEPARTMENT=ADDPSUB.CDDEPT
                        ) 
                INNER JOIN
                    ADTEAMUSER ADTU 
                        ON (
                            ADTU.CDTEAM=ADP.CDSECURITYTEAM
                        ) 
                WHERE
                    ADTU.CDUSER=1 
                GROUP BY
                    ADUDPPOS.CDUSER
            ) USERPERM 
                ON (
                    USERPERM.CDUSER=HIPDI.CDUSER 
                    AND USERPERM.CDUSERDATA=1
                ) 
        WHERE
            GNACTPDI.CDGENACTIVITY=GNACTPL.CDGENACTIVITY 
            AND (
                EXISTS (
                    SELECT
                        ADT1.CDUSER 
                    FROM
                        ADTEAMUSER ADT1  
                    INNER JOIN
                        ADPARAMS ADP  
                            ON (
                                ADP.CDPARAM=1 
                                AND ADP.CDISOSYSTEM=153 
                                AND ADP.VLPARAM=ADT1.CDTEAM
                            ) 
                    WHERE
                        ADT1.CDUSER=1
                )  
                OR USERPERM.CDUSER IS NOT NULL
            )
        )
)
)
)
) 
AND (
GNACT2.CDGENACTIVITY IS NOT NULL 
OR (
GNACT2.CDGENACTIVITY IS NULL 
AND (
GNACT.CDACTACCESSROLE IS NULL 
OR EXISTS (
SELECT
NULL 
FROM
(SELECT
CHKUSRPERMTYPEROLE.CDTYPEROLE AS CDTYPEROLE,
CHKUSRPERMTYPEROLE.CDUSER 
FROM
(SELECT
    PM.FGPERMISSIONTYPE,
    PM.CDUSER,
    PM.CDTYPEROLE 
FROM
    GNUSERPERMTYPEROLE PM 
WHERE
    1=1 
    AND PM.CDUSER <> -1 
    AND PM.CDPERMISSION=5 /* Nao retirar este comentario */
UNION
ALL SELECT
    PM.FGPERMISSIONTYPE,
    US.CDUSER AS CDUSER,
    PM.CDTYPEROLE 
FROM
    GNUSERPERMTYPEROLE PM CROSS 
JOIN
    ADUSER US 
WHERE
    1=1 
    AND PM.CDUSER=-1 
    AND US.FGUSERENABLED=1 
    AND PM.CDPERMISSION=5
) CHKUSRPERMTYPEROLE 
GROUP BY
CHKUSRPERMTYPEROLE.CDTYPEROLE,
CHKUSRPERMTYPEROLE.CDUSER 
HAVING
MAX(CHKUSRPERMTYPEROLE.FGPERMISSIONTYPE)=1) CHKPERMTYPEROLE 
WHERE
CHKPERMTYPEROLE.CDTYPEROLE=GNACT.CDACTACCESSROLE 
AND (
CHKPERMTYPEROLE.CDUSER=1 
OR 1=-1
)
)))
) 
AND (
GNACT2.CDGENACTIVITY IS NULL 
OR (
GNACT2.CDGENACTIVITY IS NOT NULL 
AND (
GNACT2.CDACTACCESSROLE IS NULL 
OR EXISTS (
SELECT
NULL 
FROM
(SELECT
CHKUSRPERMTYPEROLE.CDTYPEROLE AS CDTYPEROLE,
CHKUSRPERMTYPEROLE.CDUSER 
FROM
(SELECT
    PM.FGPERMISSIONTYPE,
    PM.CDUSER,
    PM.CDTYPEROLE 
FROM
    GNUSERPERMTYPEROLE PM 
WHERE
    1=1 
    AND PM.CDUSER <> -1 
    AND PM.CDPERMISSION=5 /* Nao retirar este comentario */
UNION
ALL SELECT
    PM.FGPERMISSIONTYPE,
    US.CDUSER AS CDUSER,
    PM.CDTYPEROLE 
FROM
    GNUSERPERMTYPEROLE PM CROSS 
JOIN
    ADUSER US 
WHERE
    1=1 
    AND PM.CDUSER=-1 
    AND US.FGUSERENABLED=1 
    AND PM.CDPERMISSION=5
) CHKUSRPERMTYPEROLE 
GROUP BY
CHKUSRPERMTYPEROLE.CDTYPEROLE,
CHKUSRPERMTYPEROLE.CDUSER 
HAVING
MAX(CHKUSRPERMTYPEROLE.FGPERMISSIONTYPE)=1) CHKPERMTYPEROLE 
WHERE
CHKPERMTYPEROLE.CDTYPEROLE=GNACT2.CDACTACCESSROLE 
AND (
CHKPERMTYPEROLE.CDUSER=1 
OR 1=-1
)
)))
) 
AND (
GNGNTP.CDTYPEROLE IS NULL 
OR EXISTS (
SELECT
NULL 
FROM
(SELECT
CHKUSRPERMTYPEROLE.CDTYPEROLE AS CDTYPEROLE,
CHKUSRPERMTYPEROLE.CDUSER 
FROM
(SELECT
PM.FGPERMISSIONTYPE,
PM.CDUSER,
PM.CDTYPEROLE 
FROM
GNUSERPERMTYPEROLE PM 
WHERE
1=1 
AND PM.CDUSER <> -1 
AND PM.CDPERMISSION=5 /* Nao retirar este comentario */
UNION
ALL SELECT
PM.FGPERMISSIONTYPE,
US.CDUSER AS CDUSER,
PM.CDTYPEROLE 
FROM
GNUSERPERMTYPEROLE PM CROSS 
JOIN
ADUSER US 
WHERE
1=1 
AND PM.CDUSER=-1 
AND US.FGUSERENABLED=1 
AND PM.CDPERMISSION=5
) CHKUSRPERMTYPEROLE 
GROUP BY
CHKUSRPERMTYPEROLE.CDTYPEROLE,
CHKUSRPERMTYPEROLE.CDUSER 
HAVING
MAX(CHKUSRPERMTYPEROLE.FGPERMISSIONTYPE)=1) CHKPERMTYPEROLE 
WHERE
CHKPERMTYPEROLE.CDTYPEROLE=GNGNTP.CDTYPEROLE 
AND (
CHKPERMTYPEROLE.CDUSER=1 
OR 1=-1
)
)) 
AND (GNGNTP2.CDTYPEROLE IS NULL 
OR EXISTS (SELECT
NULL 
FROM
(SELECT
CHKUSRPERMTYPEROLE.CDTYPEROLE AS CDTYPEROLE,
CHKUSRPERMTYPEROLE.CDUSER 
FROM
(SELECT
PM.FGPERMISSIONTYPE,
PM.CDUSER,
PM.CDTYPEROLE 
FROM
GNUSERPERMTYPEROLE PM 
WHERE
1=1 
AND PM.CDUSER <> -1 
AND PM.CDPERMISSION=5 /* Nao retirar este comentario */
UNION
ALL SELECT
PM.FGPERMISSIONTYPE,
US.CDUSER AS CDUSER,
PM.CDTYPEROLE 
FROM
GNUSERPERMTYPEROLE PM CROSS 
JOIN
ADUSER US 
WHERE
1=1 
AND PM.CDUSER=-1 
AND US.FGUSERENABLED=1 
AND PM.CDPERMISSION=5
) CHKUSRPERMTYPEROLE 
GROUP BY
CHKUSRPERMTYPEROLE.CDTYPEROLE,
CHKUSRPERMTYPEROLE.CDUSER 
HAVING
MAX(CHKUSRPERMTYPEROLE.FGPERMISSIONTYPE)=1) CHKPERMTYPEROLE 
WHERE
CHKPERMTYPEROLE.CDTYPEROLE=GNGNTP2.CDTYPEROLE 
AND (
CHKPERMTYPEROLE.CDUSER=1 
OR 1=-1
)
)) 
AND (GNACTPL.FGOBJECT IN (1,
7,
8) 
OR TMCPLAN.FGOBJECT IN (1,
7,
8)) 
AND INO.FGOCCURRENCETYPE=2 
AND INO.CDOCCURRENCETYPE IN (23) 
AND (WFGNT.CDTYPEROLE IS NULL 
OR EXISTS (SELECT
NULL 
FROM
(SELECT
CHKUSRPERMTYPEROLE.CDTYPEROLE AS CDTYPEROLE,
CHKUSRPERMTYPEROLE.CDUSER 
FROM
(SELECT
PM.FGPERMISSIONTYPE,
PM.CDUSER,
PM.CDTYPEROLE 
FROM
GNUSERPERMTYPEROLE PM 
WHERE
1=1 
AND PM.CDUSER <> -1 
AND PM.CDPERMISSION=5 /* Nao retirar este comentario */
UNION
ALL SELECT
PM.FGPERMISSIONTYPE,
US.CDUSER AS CDUSER,
PM.CDTYPEROLE 
FROM
GNUSERPERMTYPEROLE PM CROSS 
JOIN
ADUSER US 
WHERE
1=1 
AND PM.CDUSER=-1 
AND US.FGUSERENABLED=1 
AND PM.CDPERMISSION=5
) CHKUSRPERMTYPEROLE 
GROUP BY
CHKUSRPERMTYPEROLE.CDTYPEROLE,
CHKUSRPERMTYPEROLE.CDUSER 
HAVING
MAX(CHKUSRPERMTYPEROLE.FGPERMISSIONTYPE)=1) CHKPERMTYPEROLE 
WHERE
CHKPERMTYPEROLE.CDTYPEROLE=WFGNT.CDTYPEROLE 
AND (
CHKPERMTYPEROLE.CDUSER=1 
OR 1=-1
)
))