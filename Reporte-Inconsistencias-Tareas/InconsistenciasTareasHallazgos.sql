SELECT
/** 
Creación:  
31-03-2022. Andrés Del Río. Muestra las tareas de ejecución de actividad del módulo hallazgo y los datos del formulario de hallazgos,
con el propósito de detectar diferencias entre el responsable de la tarea y el registrado en el formulario
Versión: 2.1.2.100
Ambiente: sgi.grupoaguas.cl
Panel de análisis: REPINCTAR - Reporte de Inconsistencias de Tareas de "Ejecución de actividad" en módulo Hallazgos
        
Modificaciones: 
12-04-2022. Andrés Del Río. Verificación de ceros al inicio de rut de responsable de cada etapa de hallazgo.    
**/
        
TAREAS.ID_HALLAZGO_TAREA,
TAREAS.TITULO_HALLAZGO_TAREA,
TAREAS.ID_ACTIVIDAD,
TAREAS.ACTIVIDAD,
TAREAS.CD_USUARIO_TAREA,
(SELECT IDUSER FROM ADUSER WHERE CDUSER = TAREAS.CD_USUARIO_TAREA) ID_USUARIO_TAREA,
TAREAS.USUARIO_TAREA,
TAREAS.SITUACION,
1 AS CANT,


CASE
/** APROBACIÓN DE HALLAZGO **/
WHEN TAREAS.ID_ACTIVIDAD = 'TRAD-051' THEN HALLAZGOS.CD_RESP_APRO_HALL
/** ANÁLISIS DE CAUSA Y PLAN DE ACCIÓN **/
WHEN TAREAS.ID_ACTIVIDAD = 'TRAA-195' THEN HALLAZGOS.CD_RESP_ANAL_PLAN
/** APROBACIÓN DE ANÁLISIS DE CAUSA Y PLAN DE ACCIÓN **/
WHEN TAREAS.ID_ACTIVIDAD = 'TRAA-196' THEN HALLAZGOS.CD_RESP_APRO_PLAN
/** EJECUCIÓN DE PLAN DE ACCIÓN **/
WHEN TAREAS.ID_ACTIVIDAD = 'TRAA-197' THEN HALLAZGOS.CD_RESP_ANAL_PLAN
/**VERIFICACIÓN DE EFICACIA **/
WHEN TAREAS.ID_ACTIVIDAD = 'TRAA-199' THEN HALLAZGOS.CD_RESP_VERI_EFIC
END CD_USUARIO_TAREA_FORMULARIO,

CASE
/** APROBACIÓN DE HALLAZGO **/
WHEN TAREAS.ID_ACTIVIDAD = 'TRAD-051' THEN HALLAZGOS.ID_RESP_APRO_HALL
/** ANÁLISIS DE CAUSA Y PLAN DE ACCIÓN **/
WHEN TAREAS.ID_ACTIVIDAD = 'TRAA-195' THEN HALLAZGOS.ID_RESP_ANAL_PLAN
/** APROBACIÓN DE ANÁLISIS DE CAUSA Y PLAN DE ACCIÓN **/
WHEN TAREAS.ID_ACTIVIDAD = 'TRAA-196' THEN HALLAZGOS.ID_RESP_APRO_PLAN
/** EJECUCIÓN DE PLAN DE ACCIÓN **/
WHEN TAREAS.ID_ACTIVIDAD = 'TRAA-197' THEN HALLAZGOS.ID_RESP_ANAL_PLAN
/**VERIFICACIÓN DE EFICACIA **/
WHEN TAREAS.ID_ACTIVIDAD = 'TRAA-199' THEN HALLAZGOS.ID_RESP_VERI_EFIC
END ID_USUARIO_TAREA_FORMULARIO,

CASE
/** APROBACIÓN DE HALLAZGO **/
WHEN TAREAS.ID_ACTIVIDAD = 'TRAD-051' THEN HALLAZGOS.RESP_APRO_HALL
/** ANÁLISIS DE CAUSA Y PLAN DE ACCIÓN **/
WHEN TAREAS.ID_ACTIVIDAD = 'TRAA-195' THEN HALLAZGOS.RESP_ANAL_PLAN
/** APROBACIÓN DE ANÁLISIS DE CAUSA Y PLAN DE ACCIÓN **/
WHEN TAREAS.ID_ACTIVIDAD = 'TRAA-196' THEN HALLAZGOS.RESP_APRO_PLAN
/** EJECUCIÓN DE PLAN DE ACCIÓN **/
WHEN TAREAS.ID_ACTIVIDAD = 'TRAA-197' THEN HALLAZGOS.RESP_ANAL_PLAN
/**VERIFICACIÓN DE EFICACIA **/
WHEN TAREAS.ID_ACTIVIDAD = 'TRAA-199' THEN HALLAZGOS.RESP_VERI_EFIC
END USUARIO_TAREA_FORMULARIO,

HALLAZGOS.*       

    FROM
        (SELECT
            WFP.IDPROCESS ID_HALLAZGO_TAREA,
            WFP.NMPROCESS TITULO_HALLAZGO_TAREA,
            WFP.NMPROCESSMODEL,
            WFS.IDSTRUCT ID_ACTIVIDAD,
            WFS.NMSTRUCT ACTIVIDAD,
            WFS.FGSTATUS,
            CASE                                                                                                            
                WHEN WFS.FGSTATUS=1 THEN '#{114667}'                                                                                                            
                WHEN WFS.FGSTATUS=2 THEN '#{114666}'                                                                                                            
                WHEN WFS.FGSTATUS=3 THEN '#{107507}'                                                                                                            
                WHEN WFS.FGSTATUS=4 THEN '#{108240}'                                                                                                            
                WHEN WFS.FGSTATUS=5 THEN '#{102338}'                                                                                                            
                WHEN WFS.FGSTATUS=6 THEN '#{206049}'                                                                                                            
                WHEN WFS.FGSTATUS=7 THEN '#{214511}'                                                                                
            END AS SITUACION,
            WFA.CDUSER CD_USUARIO_TAREA,
            WFA.NMUSER USUARIO_TAREA,
            WFA.NMEXECUTEDACTION,
            1 CANTIDAD                                       
        FROM
            WFPROCESS WFP                                                    
        INNER JOIN
            WFSTRUCT WFS                                                                                                            
                ON WFS.IDPROCESS=WFP.IDOBJECT                                                    
        INNER JOIN
            WFACTIVITY WFA                                                                                                            
                ON WFS.IDOBJECT=WFA.IDOBJECT                                 
        WHERE
            WFP.FGSTATUS <= 5                                    
            AND   WFS.FGSTATUS = 2) TAREAS                    
    LEFT JOIN
        (
            SELECT
                HALL.IDPROCESS ID_HALLAZGO,
                HALL.NMPROCESS TITULO_HALLAZGO,
                FORMGH.IDENTIFICADOR,
                FORMGH.TITULO,
                FORMGH.cdusuaprohal CD_RESP_APRO_HALL,
                FORMGH.idusuaprohal ID_RESP_APRO_HALL,
                FORMGH.nmusuaprohall RESP_APRO_HALL,

                FORMGH.cdusuanalisis CD_RESP_ANAL_PLAN,
                FORMGH.idusuanalisis ID_RESP_ANAL_PLAN,
                FORMGH.nmusuanalisis RESP_ANAL_PLAN,

                FORMGH.cdusuaprob CD_RESP_APRO_PLAN,
                FORMGH.idusuaprob ID_RESP_APRO_PLAN,
                FORMGH.nmusuaprob RESP_APRO_PLAN,

                FORMGH.cdusuverif CD_RESP_VERI_EFIC,
                FORMGH.idusuverif ID_RESP_VERI_EFIC,
                FORMGH.nmusuverif RESP_VERI_EFIC,

                CASE WHEN FORMGH.idusuaprohal LIKE '0%' OR FORMGH.idusuanalisis LIKE '0%' OR FORMGH.idusuaprob LIKE '0%' OR FORMGH.idusuverif LIKE '0%' THEN 'SI' ELSE 'NO' END RUT_COMIENZA_CERO,

                1 CANTIDAD                            
            FROM
                WFPROCESS HALL                                              
            JOIN
                GNASSOCFORMREG REG                                                                                      
                    ON HALL.CDASSOCREG = REG.CDASSOC                                              
            JOIN
                DYNGHA FORMGH                                                                                      
                    ON REG.OIDENTITYREG=FORMGH.OID                              
            ) HALLAZGOS                                   
                ON HALLAZGOS.ID_HALLAZGO = TAREAS.ID_HALLAZGO_TAREA

