SELECT
 /** 
            Creación: 29-04-2022. Andrés Del Río. Reporte de documentos y responsable de tarea de última revisión, con base en la consulta estándar de documento-consulta-documento 
            Ambiente: https://sgi.grupoaguas.cl/softexpert 
            Versión SE Suite: 2.1.2.100 
            Panel de análisis:  REPDOCRES - Reporte de Documentos y Responsables SGI 2.0
            
            Modificaciones: 
            DD-MM-AAAA. Autor. Descripción.
**/
REVVIG.ID_DOCUMENTO ID_DOCUMENTO_VIG,
REVVIG.TITULO_DOCUMENTO TITULO_DOCUMENTO_VIG,
REVVIG.AUTOR_DOCUMENTO AUTOR_DOCUMENTO_VIG,
REVVIG.REVISION REVISION_VIG,
REVVIG.FECHA_REVISION FECHA_REVISION_VIG,
REVVIG.FECHA_VALIDEZ_DOCUMENTO FECHA_VALIDEZ_DOCUMENTO_VIG,
REVVIG.VALIDEZ VALIDEZ_DOCUMENTO_VIG,
REVVIG.DIAS_VENCIMIENTO DIAS_VENCIMIENTO_VIG,

REVVIG.FECHA_VALIDEZ_CON_REVISION VALIDEZ_REV_DOCUMENTO_VIG,
CASE WHEN  REVVIG.FECHA_VALIDEZ_CON_REVISION IS NULL
    THEN 'Sin Vencimiento'
     WHEN  REVVIG.FECHA_VALIDEZ_CON_REVISION > <!%TODAY%> + 5
    THEN 'Vigente'
     WHEN  REVVIG.FECHA_VALIDEZ_CON_REVISION > <!%TODAY%> AND  REVVIG.FECHA_VALIDEZ_CON_REVISION <= <!%TODAY%>
    THEN 'Próximo al Vencimiento'
    WHEN   REVVIG.FECHA_VALIDEZ_CON_REVISION < <!%TODAY%>
    THEN 'Vencido'
END VALIDEZ_REV_VIG,

CASE WHEN ULTREV.ETAPA = ULTREV.ESTADO_REVISION
    THEN 1
    ELSE 0
END FILTRO_PENDIENTE,

ULTREV.*


FROM
(SELECT
        DR.CDDOCUMENT CD_DOCUMENTO,
        DR.IDDOCUMENT ID_DOCUMENTO,
        DR.NMTITLE TITULO_DOCUMENTO,
        DR.NMAUTHOR AUTOR_DOCUMENTO,
        DR.NRHITS NUMERO_HITS,
        GR.IDREVISION REVISION,
        
        (SELECT IDREVISION FROM GNREVISION WHERE CDREVISION IN (SELECT MAX(CDREVISION) FROM DCDOCREVISION WHERE CDDOCUMENT = DR.CDDOCUMENT)) REVISION_MAX,
        
        CASE 
            WHEN DR.FGCURRENT = 1 THEN 'Vigente' 
            ELSE 'Obsoleta' 
        END TIPO,
        CAST (CASE              
            WHEN DC.FGSTATUS=1 THEN '#{103645}'              
            WHEN DC.FGSTATUS=2 THEN '#{104235}'              
            WHEN DC.FGSTATUS=3 THEN '#{104705}'              
            WHEN DC.FGSTATUS=4 THEN '#{104230}'              
            WHEN DC.FGSTATUS=5 THEN '#{200421}'              
            WHEN DC.FGSTATUS=6 THEN '#{100263}'              
            WHEN DC.FGSTATUS=7 THEN '#{209484}'          
        END AS VARCHAR(255)) AS ESTADO_DOCUMENTO,
        GR.DTREVISION FECHA_REVISION,

        CASE WHEN CT.IDCATEGORY LIKE 'GA01%' OR  CT.IDCATEGORY LIKE 'GA02%' OR CT.IDCATEGORY LIKE 'GA03%' 
            THEN ADD_MONTHS(GR.DTREVISION, 12) 
            WHEN  CT.IDCATEGORY LIKE 'GA04%' OR CT.IDCATEGORY LIKE 'GA05%' 
            THEN ADD_MONTHS(GR.DTREVISION, 24) 
            ELSE NULL
        END FECHA_VALIDEZ_CON_REVISION,

        TO_CHAR(GR.DTREVISION,
        'MON') AS MES_REVISION,
        TO_CHAR(GR.DTREVISION,
        'YYYY') AS ANIO_REVISION, 

        GR.DTVALIDITY FECHA_VALIDEZ_DOCUMENTO,

        SYSDATE - GR.DTVALIDITY DIAS_VENCIMIENTO,
        
        CASE WHEN  GR.DTVALIDITY IS NULL
    THEN 'Sin Vencimiento'
     WHEN  GR.DTVALIDITY > <!%TODAY%> + 5
    THEN 'Vigente'
     WHEN  GR.DTVALIDITY > <!%TODAY%> AND  GR.DTVALIDITY <= <!%TODAY%>
    THEN 'Próximo al Vencimiento'
    WHEN   GR.DTVALIDITY < <!%TODAY%>
    THEN 'Vencido'
END VALIDEZ,



CASE WHEN  CT.IDCATEGORY LIKE 'GA01%' OR  CT.IDCATEGORY LIKE 'GA02%' 
OR CT.IDCATEGORY LIKE 'GA03%' 
    THEN '1 Año - Políticas Manuales Estándares'
    WHEN  CT.IDCATEGORY LIKE 'GA04%' 
    THEN '2 Años - Procedimientos'
    WHEN  CT.IDCATEGORY LIKE 'GA05%' 
    THEN '2 años - Instructivos'
    ELSE 'Sin Definir - Otros Documentos'
END FILTRO_VALIDEZ,

        
        
        CT.IDCATEGORY ID_CATEGORIA,
        CT.NMCATEGORY NOMBRE_CATEGORIA,
        CAST (CASE              
            WHEN GR.FGSTATUS=1 THEN '#{103222}'              
            WHEN GR.FGSTATUS=2 THEN '#{104231}'              
            WHEN GR.FGSTATUS=3 THEN '#{100263}'              
            WHEN GR.FGSTATUS=4 THEN '#{104236}'              
            WHEN GR.FGSTATUS=5 THEN '#{104238}'              
            WHEN GR.FGSTATUS=6 THEN '#{101237}'          
        END AS VARCHAR(255)) AS ESTADO_REVISION,
             
        
        
        (SELECT
            NMATTRIBUTE /*SUB*/
        FROM
            ADATTRIBVALUE ADATV 
        INNER JOIN
            DCDOCUMENTATTRIB ATT 
                ON (
                    ATT.CDATTRIBUTE=ADATV.CDATTRIBUTE 
                    AND ATT.CDVALUE=ADATV.CDVALUE
                ) 
        WHERE
            ATT.CDATTRIBUTE=1 
            AND ATT.CDDOCUMENT=DR.CDDOCUMENT 
            AND ATT.CDREVISION=DR.CDREVISION) AS ATTRIB1,
        (SELECT
            LISTAGG( CAST(AVD.NMATTRIBUTE AS VARCHAR(4000)),
            '; ') WITHIN 
        GROUP (/*SUB*/ORDER /*SUB*/BY
            1) /*SUB*/
        FROM
            DCDOCMULTIATTRIB DM 
        INNER JOIN
            ADATTRIBVALUE AVD 
                ON AVD.CDATTRIBUTE=DM.CDATTRIBUTE 
                AND AVD.CDVALUE=DM.CDVALUE 
        WHERE
            DM.CDATTRIBUTE=13 
            AND DM.CDDOCUMENT=DR.CDDOCUMENT 
            AND DM.CDREVISION=DR.CDREVISION) AS ATTRIB13,
        (SELECT
            LISTAGG( CAST(AVD.NMATTRIBUTE AS VARCHAR(4000)),
            '; ') WITHIN 
        GROUP (/*SUB*/ORDER /*SUB*/BY
            1) /*SUB*/
        FROM
            DCDOCMULTIATTRIB DM 
        INNER JOIN
            ADATTRIBVALUE AVD 
                ON AVD.CDATTRIBUTE=DM.CDATTRIBUTE 
                AND AVD.CDVALUE=DM.CDVALUE 
        WHERE
            DM.CDATTRIBUTE=7 
            AND DM.CDDOCUMENT=DR.CDDOCUMENT 
            AND DM.CDREVISION=DR.CDREVISION) AS ATTRIB7,
        (SELECT
            LISTAGG( CAST(AVD.NMATTRIBUTE AS VARCHAR(4000)),
            '; ') WITHIN 
        GROUP (/*SUB*/ORDER /*SUB*/BY
            1) /*SUB*/
        FROM
            DCDOCMULTIATTRIB DM 
        INNER JOIN
            ADATTRIBVALUE AVD 
                ON AVD.CDATTRIBUTE=DM.CDATTRIBUTE 
                AND AVD.CDVALUE=DM.CDVALUE 
        WHERE
            DM.CDATTRIBUTE=8 
            AND DM.CDDOCUMENT=DR.CDDOCUMENT 
            AND DM.CDREVISION=DR.CDREVISION) AS ATTRIB8,
        (SELECT
            LISTAGG( CAST(AVD.NMATTRIBUTE AS VARCHAR(4000)),
            '; ') WITHIN 
        GROUP (/*SUB*/ORDER /*SUB*/BY
            1) /*SUB*/
        FROM
            DCDOCMULTIATTRIB DM 
        INNER JOIN
            ADATTRIBVALUE AVD 
                ON AVD.CDATTRIBUTE=DM.CDATTRIBUTE 
                AND AVD.CDVALUE=DM.CDVALUE 
        WHERE
            DM.CDATTRIBUTE=2 
            AND DM.CDDOCUMENT=DR.CDDOCUMENT 
            AND DM.CDREVISION=DR.CDREVISION) AS ATTRIB2,
        (SELECT
            NMATTRIBUTE /*SUB*/
        FROM
            ADATTRIBVALUE ADATV 
        INNER JOIN
            DCDOCUMENTATTRIB ATT 
                ON (
                    ATT.CDATTRIBUTE=ADATV.CDATTRIBUTE 
                    AND ATT.CDVALUE=ADATV.CDVALUE
                ) 
        WHERE
            ATT.CDATTRIBUTE=9 
            AND ATT.CDDOCUMENT=DR.CDDOCUMENT 
            AND ATT.CDREVISION=DR.CDREVISION) AS ATTRIB9,
        (SELECT
            NMATTRIBUTE /*SUB*/
        FROM
            ADATTRIBVALUE ADATV 
        INNER JOIN
            DCDOCUMENTATTRIB ATT 
                ON (
                    ATT.CDATTRIBUTE=ADATV.CDATTRIBUTE 
                    AND ATT.CDVALUE=ADATV.CDVALUE
                ) 
        WHERE
            ATT.CDATTRIBUTE=15 
            AND ATT.CDDOCUMENT=DR.CDDOCUMENT 
            AND ATT.CDREVISION=DR.CDREVISION) AS ATTRIB15,
        (SELECT
            NMATTRIBUTE /*SUB*/
        FROM
            ADATTRIBVALUE ADATV 
        INNER JOIN
            DCDOCUMENTATTRIB ATT 
                ON (
                    ATT.CDATTRIBUTE=ADATV.CDATTRIBUTE 
                    AND ATT.CDVALUE=ADATV.CDVALUE
                ) 
        WHERE
            ATT.CDATTRIBUTE=18 
            AND ATT.CDDOCUMENT=DR.CDDOCUMENT 
            AND ATT.CDREVISION=DR.CDREVISION) AS ATTRIB18,
        (SELECT
            NMATTRIBUTE /*SUB*/
        FROM
            ADATTRIBVALUE ADATV 
        INNER JOIN
            DCDOCUMENTATTRIB ATT 
                ON (
                    ATT.CDATTRIBUTE=ADATV.CDATTRIBUTE 
                    AND ATT.CDVALUE=ADATV.CDVALUE
                ) 
        WHERE
            ATT.CDATTRIBUTE=16 
            AND ATT.CDDOCUMENT=DR.CDDOCUMENT 
            AND ATT.CDREVISION=DR.CDREVISION) AS ATTRIB16,
        
        
        1 AS CANTIDAD 
    FROM
        DCDOCREVISION DR 
    LEFT JOIN
        DCDOCUMENT DC 
            ON DC.CDDOCUMENT = DR.CDDOCUMENT   
    LEFT JOIN
        DCCATEGORY CT 
            ON DR.CDCATEGORY = CT.CDCATEGORY   
    LEFT JOIN
        GNREVISION GR 
            ON GR.CDREVISION =  DR.CDREVISION
    WHERE DR.FGCURRENT = 1

) REVVIG
LEFT JOIN
(SELECT
        DR.CDDOCUMENT CD_DOCUMENTO,
        DR.IDDOCUMENT ID_DOCUMENTO,
        DR.NMTITLE TITULO_DOCUMENTO,
        DR.NMAUTHOR AUTOR_DOCUMENTO,
        DR.NRHITS NUMERO_HITS,
        GR.IDREVISION REVISION,
        
        GR.IDREVISION REVISION_MAX,
                
        CASE 
            WHEN DR.FGCURRENT = 1 THEN 'Vigente' 
            ELSE 'Obsoleta' 
        END TIPO,
        CAST (CASE              
            WHEN DC.FGSTATUS=1 THEN '#{103645}'              
            WHEN DC.FGSTATUS=2 THEN '#{104235}'              
            WHEN DC.FGSTATUS=3 THEN '#{104705}'              
            WHEN DC.FGSTATUS=4 THEN '#{104230}'              
            WHEN DC.FGSTATUS=5 THEN '#{200421}'              
            WHEN DC.FGSTATUS=6 THEN '#{100263}'              
            WHEN DC.FGSTATUS=7 THEN '#{209484}'          
        END AS VARCHAR(255)) AS ESTADO_DOCUMENTO,
        GR.DTREVISION FECHA_REVISION,

        TO_CHAR(GR.DTREVISION,
        'MON') AS MES_REVISION,
        TO_CHAR(GR.DTREVISION,
        'YYYY') AS ANIO_REVISION, 

        GR.DTVALIDITY FECHA_VALIDEZ_DOCUMENTO,
        
        CASE WHEN  GR.DTVALIDITY IS NULL
    THEN 'Sin Vencimiento'
     WHEN  GR.DTVALIDITY > <!%TODAY%> + 5
    THEN 'Vigente'
     WHEN  GR.DTVALIDITY > <!%TODAY%> AND  GR.DTVALIDITY <= <!%TODAY%>
    THEN 'Próximo al Vencimiento'
    WHEN   GR.DTVALIDITY < <!%TODAY%>
    THEN 'Vencido'
END VALIDEZ,

CASE WHEN  CT.IDCATEGORY LIKE 'GA01%' OR  CT.IDCATEGORY LIKE 'GA02%' 
OR CT.IDCATEGORY LIKE 'GA03%' 
    THEN '1 Año - Políticas Manuales Estándares'
    WHEN  CT.IDCATEGORY LIKE 'GA04%' 
    THEN '2 Años - Procedimientos'
    WHEN  CT.IDCATEGORY LIKE 'GA05%' 
    THEN '2 años - Instructivos'
    ELSE 'Sin Definir - Otros Documentos'
END FILTRO_VALIDEZ,

        
        
        CT.IDCATEGORY ID_CATEGORIA,
        CT.NMCATEGORY NOMBRE_CATEGORIA,
        CAST (CASE              
            WHEN GR.FGSTATUS=1 THEN '#{103222}'              
            WHEN GR.FGSTATUS=2 THEN '#{104231}'              
            WHEN GR.FGSTATUS=3 THEN '#{100263}'              
            WHEN GR.FGSTATUS=4 THEN '#{104236}'              
            WHEN GR.FGSTATUS=5 THEN '#{104238}'              
            WHEN GR.FGSTATUS=6 THEN '#{101237}'          
        END AS VARCHAR(255)) AS ESTADO_REVISION,
        CASE  
            WHEN RM.FGSTAGE = 1 THEN 'Elaboración'  
            WHEN RM.FGSTAGE = 2 THEN 'Consenso'  
            WHEN RM.FGSTAGE = 3 THEN 'Revisión'  
            WHEN RM.FGSTAGE = 4 THEN 'Aprobación'  
        END ETAPA,
        RM.NRCYCLE CICLO_REVISION,
        RM.NRSEQUENCE SECUENCIA_ETAPA,
        RM.QTDEADLINE CANTIDAD_DIAS_ETAPA,
        RM.DTDEADLINE PLAZO,
        (SELECT
            IDUSER 
        FROM
            ADUSER 
        WHERE
            CDUSER = RM.CDUSER) MATRICULA_USUARIO_RESPONSABLE_ETAPA,
        (SELECT
            NMUSER 
        FROM
            ADUSER 
        WHERE
            CDUSER = RM.CDUSER) NOMBRE_USUARIO_RESPONSABLE_ETAPA,
        (SELECT
            IDDEPARTMENT 
        FROM
            ADDEPARTMENT 
        WHERE
            CDDEPARTMENT = RM.CDDEPARTMENT) ID_AREA_RESPONSABLE_ETAPA,
        (SELECT
            NMDEPARTMENT 
        FROM
            ADDEPARTMENT 
        WHERE
            CDDEPARTMENT = RM.CDDEPARTMENT) NOMBRE_AREA_RESPONSABLE_ETAPA,
        (SELECT
            IDPOSITION 
        FROM
            ADPOSITION 
        WHERE
            CDPOSITION = RM.CDPOSITION) ID_CARGO_RESPONSABLE_ETAPA,
        (SELECT
            NMPOSITION 
        FROM
            ADPOSITION 
        WHERE
            CDPOSITION = RM.CDPOSITION) NOMBRE_CARGO_RESPONSABLE_ETAPA,
        (SELECT
            IDTEAM 
        FROM
            ADTEAM 
        WHERE
            CDTEAM = RM.CDTEAM) ID_GRUPO_RESPONSABLE_ETAPA,
        (SELECT
            NMTEAM 
        FROM
            ADTEAM 
        WHERE
            CDTEAM = RM.CDTEAM) NOMBRE_GRUPO_RESPONSABLE_ETAPA,
        CASE 
            WHEN RM.FGAPPROVAL = 1 THEN 'SI' 
            ELSE 'NO' 
        END APROBADO,
        RM.DTAPPROVAL FECHA_LIBERACION,
        
        
        (SELECT
            NMATTRIBUTE /*SUB*/
        FROM
            ADATTRIBVALUE ADATV 
        INNER JOIN
            DCDOCUMENTATTRIB ATT 
                ON (
                    ATT.CDATTRIBUTE=ADATV.CDATTRIBUTE 
                    AND ATT.CDVALUE=ADATV.CDVALUE
                ) 
        WHERE
            ATT.CDATTRIBUTE=1 
            AND ATT.CDDOCUMENT=DR.CDDOCUMENT 
            AND ATT.CDREVISION=DR.CDREVISION) AS ATTRIB1,
        (SELECT
            LISTAGG( CAST(AVD.NMATTRIBUTE AS VARCHAR(4000)),
            '; ') WITHIN 
        GROUP (/*SUB*/ORDER /*SUB*/BY
            1) /*SUB*/
        FROM
            DCDOCMULTIATTRIB DM 
        INNER JOIN
            ADATTRIBVALUE AVD 
                ON AVD.CDATTRIBUTE=DM.CDATTRIBUTE 
                AND AVD.CDVALUE=DM.CDVALUE 
        WHERE
            DM.CDATTRIBUTE=13 
            AND DM.CDDOCUMENT=DR.CDDOCUMENT 
            AND DM.CDREVISION=DR.CDREVISION) AS ATTRIB13,
        (SELECT
            LISTAGG( CAST(AVD.NMATTRIBUTE AS VARCHAR(4000)),
            '; ') WITHIN 
        GROUP (/*SUB*/ORDER /*SUB*/BY
            1) /*SUB*/
        FROM
            DCDOCMULTIATTRIB DM 
        INNER JOIN
            ADATTRIBVALUE AVD 
                ON AVD.CDATTRIBUTE=DM.CDATTRIBUTE 
                AND AVD.CDVALUE=DM.CDVALUE 
        WHERE
            DM.CDATTRIBUTE=7 
            AND DM.CDDOCUMENT=DR.CDDOCUMENT 
            AND DM.CDREVISION=DR.CDREVISION) AS ATTRIB7,
        (SELECT
            LISTAGG( CAST(AVD.NMATTRIBUTE AS VARCHAR(4000)),
            '; ') WITHIN 
        GROUP (/*SUB*/ORDER /*SUB*/BY
            1) /*SUB*/
        FROM
            DCDOCMULTIATTRIB DM 
        INNER JOIN
            ADATTRIBVALUE AVD 
                ON AVD.CDATTRIBUTE=DM.CDATTRIBUTE 
                AND AVD.CDVALUE=DM.CDVALUE 
        WHERE
            DM.CDATTRIBUTE=8 
            AND DM.CDDOCUMENT=DR.CDDOCUMENT 
            AND DM.CDREVISION=DR.CDREVISION) AS ATTRIB8,
        (SELECT
            LISTAGG( CAST(AVD.NMATTRIBUTE AS VARCHAR(4000)),
            '; ') WITHIN 
        GROUP (/*SUB*/ORDER /*SUB*/BY
            1) /*SUB*/
        FROM
            DCDOCMULTIATTRIB DM 
        INNER JOIN
            ADATTRIBVALUE AVD 
                ON AVD.CDATTRIBUTE=DM.CDATTRIBUTE 
                AND AVD.CDVALUE=DM.CDVALUE 
        WHERE
            DM.CDATTRIBUTE=2 
            AND DM.CDDOCUMENT=DR.CDDOCUMENT 
            AND DM.CDREVISION=DR.CDREVISION) AS ATTRIB2,
        (SELECT
            NMATTRIBUTE /*SUB*/
        FROM
            ADATTRIBVALUE ADATV 
        INNER JOIN
            DCDOCUMENTATTRIB ATT 
                ON (
                    ATT.CDATTRIBUTE=ADATV.CDATTRIBUTE 
                    AND ATT.CDVALUE=ADATV.CDVALUE
                ) 
        WHERE
            ATT.CDATTRIBUTE=9 
            AND ATT.CDDOCUMENT=DR.CDDOCUMENT 
            AND ATT.CDREVISION=DR.CDREVISION) AS ATTRIB9,
        (SELECT
            NMATTRIBUTE /*SUB*/
        FROM
            ADATTRIBVALUE ADATV 
        INNER JOIN
            DCDOCUMENTATTRIB ATT 
                ON (
                    ATT.CDATTRIBUTE=ADATV.CDATTRIBUTE 
                    AND ATT.CDVALUE=ADATV.CDVALUE
                ) 
        WHERE
            ATT.CDATTRIBUTE=15 
            AND ATT.CDDOCUMENT=DR.CDDOCUMENT 
            AND ATT.CDREVISION=DR.CDREVISION) AS ATTRIB15,
        (SELECT
            NMATTRIBUTE /*SUB*/
        FROM
            ADATTRIBVALUE ADATV 
        INNER JOIN
            DCDOCUMENTATTRIB ATT 
                ON (
                    ATT.CDATTRIBUTE=ADATV.CDATTRIBUTE 
                    AND ATT.CDVALUE=ADATV.CDVALUE
                ) 
        WHERE
            ATT.CDATTRIBUTE=18 
            AND ATT.CDDOCUMENT=DR.CDDOCUMENT 
            AND ATT.CDREVISION=DR.CDREVISION) AS ATTRIB18,
        (SELECT
            NMATTRIBUTE /*SUB*/
        FROM
            ADATTRIBVALUE ADATV 
        INNER JOIN
            DCDOCUMENTATTRIB ATT 
                ON (
                    ATT.CDATTRIBUTE=ADATV.CDATTRIBUTE 
                    AND ATT.CDVALUE=ADATV.CDVALUE
                ) 
        WHERE
            ATT.CDATTRIBUTE=16 
            AND ATT.CDDOCUMENT=DR.CDDOCUMENT 
            AND ATT.CDREVISION=DR.CDREVISION) AS ATTRIB16,
        
        
        1 AS CANTIDAD 
    FROM
        DCDOCREVISION DR 
    LEFT JOIN
        DCDOCUMENT DC 
            ON DC.CDDOCUMENT = DR.CDDOCUMENT   
    LEFT JOIN
        DCCATEGORY CT 
            ON DR.CDCATEGORY = CT.CDCATEGORY   
    LEFT JOIN
        GNREVISION GR 
            ON GR.CDREVISION =  DR.CDREVISION  
    LEFT JOIN
        GNREVISIONSTAGMEM RM 
            ON RM.CDREVISION = GR.CDREVISION 
    WHERE 
    GR.CDREVISION IN (SELECT MAX(CDREVISION) FROM DCDOCREVISION WHERE CDDOCUMENT = DR.CDDOCUMENT)

) ULTREV ON ULTREV.ID_DOCUMENTO = REVVIG.ID_DOCUMENTO
