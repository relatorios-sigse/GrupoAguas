SELECT
 /** 
            Creación: 14-04-2022. Andrés Del Río. Reporte de hallazgos con base en Analytics Instancia y Actividad de la consulta estándar de Hallazgo.
            Ambiente: https://sgi.grupoaguas.cl/softexpert 
            Versión SE Suite: 2.1.2.100 
            Panel de análisis:  REPHAL - Reporte de Hallazgos SGI 2.0
            
            Modificaciones: 
            28-04-2022. Andrés Del Río. Inclusión de nombre de sistemas de gestión. 
            25-05-2022. Andrés Del Río. Inclusión de sistema Gestión de Activos.
            26-05-2022. Andrés Del Río. Inclusión de fechas de ejecución de las etapas: Registro, Aprobación, Análisis y Planificación,
            Aprobación del Análisis, Ejecución Planificación, Verificación de Eficacia.
            01-06-2022. Andrés Del Río. Inclusión de campos Proceso_SGI_20 y Subproceso_SGI_20
**/ 
        TAREAS.TPIDPROCESS TAREA_IDHALLAZGO,
        TAREAS.TPNMPROCESS TAREA_NMHALLAZGO,
        TAREAS.TPNMPROCESSMODEL,
        TAREAS.TPNMSTRUCT TAREA_NMACTIVIDAD,
        TAREAS.TPCDUSER TAREA_CDEJECUTOR,
        (SELECT IDUSER FROM ADUSER WHERE CDUSER = TAREAS.TPCDUSER) TAREA_IDEJECUTOR_ADMIN,
        (SELECT NMUSER FROM ADUSER WHERE CDUSER = TAREAS.TPCDUSER) TAREA_NMEJECUTOR_ADMIN,

        TAREAS.TPNMUSER TAREA_NMEJECUTOR,

        TAREAS.TPNMEXECUTEDACTION TAREA_NMACCION,
        TAREAS.TPDTEXECUTION TAREA_DTEJECUCIÓN,
        CASE              
            WHEN TAREAS.TPNMDEADLINE IS NULL THEN 'Cerrado/Cancelado'              
            else TAREAS.TPNMDEADLINE         
        end TPNMDEADLINE,
        CASE              
            WHEN TAREAS.TPIDPROCESS IS NULL THEN 0              
            ELSE 1          
        END TAREA_CANTIDAD,
        1 AS CANTIDAD,
		HALLAZGOS.IDREVISIONSTATUS || ' - ' || HALLAZGOS.NMREVISIONSTATUS ETAPA_HALLAZGO,
		
		CASE WHEN HALLAZGOS.SG01 = 1 THEN 'Calidad de Servicio (ISO 9001)' ELSE '' END SISTEMA_GESTION_ISO9001,
		CASE WHEN HALLAZGOS.SG02 = 1 THEN 'Eficiencia Energética (ISO 50001)' ELSE '' END SISTEMA_GESTION_50001,
		CASE WHEN HALLAZGOS.SG03 = 1 THEN 'Seguridad y Salud Ocupacional (ISO 45001)' ELSE '' END SISTEMA_GESTION_45001,
		CASE WHEN HALLAZGOS.SG04 = 1 THEN 'Continuidad de Negocio (ISO 22301)' ELSE '' END SISTEMA_GESTION_22301,
		CASE WHEN HALLAZGOS.SG05 = 1 THEN 'Medio Ambiente (ISO 14001)' ELSE '' END SISTEMA_GESTION_14001,
		CASE WHEN HALLAZGOS.SG06 = 1 THEN 'Igualdad de Género y Conciliación (NCh 3262)' ELSE '' END SISTEMA_GESTION_3262,
		CASE WHEN HALLAZGOS.SG07 = 1 THEN 'Anti-soborno (ISO 37001)' ELSE '' END SISTEMA_GESTION_37001,
		CASE WHEN HALLAZGOS.SG08 = 1 THEN 'Seguridad de la Información ISO 27001' ELSE '' END SISTEMA_GESTION_27001,
		CASE WHEN HALLAZGOS.SG09 = 1 THEN 'Gestión de Activos (ISO 55001)' ELSE '' END SISTEMA_GESTION_55001,

          (SELECT 
            WFS.DTEXECUTION
            FROM WFPROCESS WFP
            INNER JOIN WFSTRUCT WFS ON WFS.IDPROCESS=WFP.IDOBJECT
            INNER JOIN WFACTIVITY WFA ON WFS.IDOBJECT=WFA.IDOBJECT
            WHERE WFS.NMSTRUCT = 'Registro de Hallazgo'
            AND WFA.NMEXECUTEDACTION = 'Enviar'
            AND WFS.FGSTATUS = 3
            AND WFP.IDPROCESS = HALLAZGOS.IDPROCESS) AS FECHA_REGISTRO_HALLAZGO,    

            (SELECT 
            WFS.DTEXECUTION
            FROM WFPROCESS WFP
            INNER JOIN WFSTRUCT WFS ON WFS.IDPROCESS=WFP.IDOBJECT
            INNER JOIN WFACTIVITY WFA ON WFS.IDOBJECT=WFA.IDOBJECT
            WHERE WFS.NMSTRUCT = 'Aprobación de Hallazgo'
            AND WFA.NMEXECUTEDACTION = 'Enviar'
            AND WFS.FGSTATUS = 3
            AND WFP.IDPROCESS = HALLAZGOS.IDPROCESS) AS FECHA_APROBACION_HALLAZGO,

            (SELECT 
            WFS.DTEXECUTION
            FROM WFPROCESS WFP
            INNER JOIN WFSTRUCT WFS ON WFS.IDPROCESS=WFP.IDOBJECT
            INNER JOIN WFACTIVITY WFA ON WFS.IDOBJECT=WFA.IDOBJECT
            WHERE WFS.NMSTRUCT = 'Análisis de Causa y Plan de Acción'
            AND WFA.NMEXECUTEDACTION = 'Enviar'
            AND WFS.FGSTATUS = 3
            AND WFP.IDPROCESS = HALLAZGOS.IDPROCESS) AS FECHA_ANALISIS_Y_PLANACCION,

            (SELECT 
            WFS.DTEXECUTION
            FROM WFPROCESS WFP
            INNER JOIN WFSTRUCT WFS ON WFS.IDPROCESS=WFP.IDOBJECT
            INNER JOIN WFACTIVITY WFA ON WFS.IDOBJECT=WFA.IDOBJECT
            WHERE WFS.NMSTRUCT = 'Aprobación de Análisis de Causa y Plan de Acción'
            AND WFA.NMEXECUTEDACTION = 'Enviar'
            AND WFS.FGSTATUS = 3
            AND WFP.IDPROCESS = HALLAZGOS.IDPROCESS) AS FECHA_APROBACION_ANALISIS,

            (SELECT 
            WFS.DTEXECUTION
            FROM WFPROCESS WFP
            INNER JOIN WFSTRUCT WFS ON WFS.IDPROCESS=WFP.IDOBJECT
            INNER JOIN WFACTIVITY WFA ON WFS.IDOBJECT=WFA.IDOBJECT
            WHERE WFS.NMSTRUCT = 'Ejecución de Plan de Acción'
            AND WFA.NMEXECUTEDACTION = 'Enviar'
            AND WFS.FGSTATUS = 3
            AND WFP.IDPROCESS = HALLAZGOS.IDPROCESS) AS FECHA_EJECUCION_PLANACCION,

            (SELECT 
            WFS.DTEXECUTION
            FROM WFPROCESS WFP
            INNER JOIN WFSTRUCT WFS ON WFS.IDPROCESS=WFP.IDOBJECT
            INNER JOIN WFACTIVITY WFA ON WFS.IDOBJECT=WFA.IDOBJECT
            WHERE WFS.NMSTRUCT = 'Verificación de Eficacia'
            AND WFA.NMEXECUTEDACTION = 'Enviar'
            AND WFS.FGSTATUS = 3
            AND WFP.IDPROCESS = HALLAZGOS.IDPROCESS) AS FECHA_VERIFICACION_EFICACIA,  

            CASE
            WHEN HALLAZGOS.MACROPROCESO = 'PROCESOS TRANSVERSALES' THEN
            CASE
                  WHEN HALLAZGOS.PROCESO = 'COMPRAS Y CONTRATOS' THEN 'GESTION TRANSVERSAL COMPRAS'
                  WHEN HALLAZGOS.PROCESO = 'REGULACION ' THEN 'GESTION TRANSVERSAL REGULATORIA'
                  WHEN HALLAZGOS.PROCESO = 'GESTION ENERGETICA' THEN 'GESTION TRANSVERSAL ENERGETICA'
                  WHEN HALLAZGOS.PROCESO = 'SISTEMA DE GESTION' THEN 'GESTION INTEGRADA'
                  WHEN HALLAZGOS.PROCESO = 'INVERSIONES Y PMO' THEN 'INVERSIONES Y PMO'
                  WHEN HALLAZGOS.PROCESO = 'MEDIO AMBIENTE' THEN 'GESTION TRANSVERAL MEDIO AMBIENTE'
                  WHEN HALLAZGOS.PROCESO = 'COMPRAS Y CONTRATOS' THEN 'GESTION TRANSVERSAL PROVEEDORES'
                  WHEN HALLAZGOS.PROCESO = 'GESTION DE PERSONAS' THEN 'GESTION TRANSVERSAL PERSONAS'
                  WHEN HALLAZGOS.PROCESO = 'TIC' THEN 'TIC'
                  WHEN HALLAZGOS.PROCESO = 'CONTROL DE GESTION ' THEN 'CONTROL DE GESTION '
                  WHEN HALLAZGOS.PROCESO = 'PREVENCION DE RIESGOS LABORALES' THEN 'GESTION TRANSVERSAL SALUD Y SEGURIDAD EN EL TRABAJO'
                  WHEN HALLAZGOS.PROCESO = 'CONTINUIDAD DE NEGOCIO' THEN 'GESTION TRANSVERSAL CONTINUIDAD DE NEGOCIO'
                  WHEN HALLAZGOS.PROCESO = 'LOGISTICA' THEN 'LOGISTICA'
                  WHEN HALLAZGOS.PROCESO = 'COMUNICACIONES' THEN 'GESTION TRANSVERSAL COMUNICACIONES'
                  WHEN HALLAZGOS.PROCESO = 'SERVICIOS GENERALES' THEN 'SERVICIOS GENERALES'
                  WHEN HALLAZGOS.PROCESO = 'SEGURIDAD' THEN 'SEGURIDAD CORPORATIVA'
                  WHEN HALLAZGOS.PROCESO = 'CUMPLIMIENTO DE REQUISITOS' THEN 'GESTION TRANSVERSAL ANTISOBORNO'
                  WHEN HALLAZGOS.PROCESO = 'RIESGO' THEN 'GESTION TRANSVERSAL RIESGOS'
                  WHEN HALLAZGOS.PROCESO = 'RIESGO TECNOLOGICO' THEN 'GESTION TRANSVERSAL SEGURIDAD DE LA INFORMACION'
                  ELSE 'SIN DEFINIR'
            END
            ELSE HALLAZGOS.PROCESO

            END PROCESO_SGI_20,

            CASE
            WHEN HALLAZGOS.MACROPROCESO = 'PROCESOS TRANSVERSALES' THEN
            CASE
                  WHEN HALLAZGOS.SUBPROCESO = 'COMPRAS' THEN 'GESTION TRANSVERSAL COMPRAS'
                  WHEN HALLAZGOS.SUBPROCESO = 'REGULACION ' THEN 'GESTION TRANSVERSAL REGULATORIA'
                  WHEN HALLAZGOS.SUBPROCESO = 'GESTION ENERGETICA' THEN 'GESTION TRANSVERSAL ENERGETICA'
                  WHEN HALLAZGOS.SUBPROCESO = 'SISTEMAS DE GESTION' THEN 'GESTION INTEGRADA'
                  WHEN HALLAZGOS.SUBPROCESO = 'INVERSIONES Y PMO' THEN 'INVERSIONES Y PMO'
                  WHEN HALLAZGOS.SUBPROCESO = 'MEDIO AMBIENTE' THEN 'GESTION TRANSVERAL MEDIO AMBIENTE'
                  WHEN HALLAZGOS.SUBPROCESO = 'CONTRATOS' THEN 'GESTION TRANSVERSAL PROVEEDORES'
                  WHEN HALLAZGOS.SUBPROCESO = 'GESTION DE PERSONAS' THEN 'GESTION TRANSVERSAL IGUALDAD DE GENERO'
                  WHEN HALLAZGOS.SUBPROCESO = 'TIC' THEN 'TIC'
                  WHEN HALLAZGOS.SUBPROCESO = 'CONTROL DE GESTION ' THEN 'CONTROL DE GESTION '
                  WHEN HALLAZGOS.SUBPROCESO = 'PREVENCION DE RIESGOS LABORALES' THEN 'GESTION TRANSVERSAL SALUD Y SEGURIDAD EN EL TRABAJO'
                  WHEN HALLAZGOS.SUBPROCESO = 'CONTNUIDAD DE NEGOCIO' THEN 'GESTION TRANSVERSAL CONTINUIDAD DE NEGOCIO'
                  WHEN HALLAZGOS.SUBPROCESO = 'LOGISTICA' THEN 'LOGISTICA'
                  WHEN HALLAZGOS.SUBPROCESO = 'COMUNICACIONES' THEN 'GESTION TRANSVERSAL COMUNICACIONES INTERNAS'
                  WHEN HALLAZGOS.SUBPROCESO = 'SERVICIOS GENERALES' THEN 'SERVICIOS GENERALES'
                  WHEN HALLAZGOS.SUBPROCESO = 'SEGURIDAD' THEN 'SEGURIDAD CORPORATIVA'
                  WHEN HALLAZGOS.SUBPROCESO = 'CUMPLIMIENTO DE REQUISITOS' THEN 'GESTION TRANSVERSAL ANTISOBORNO'
                  WHEN HALLAZGOS.SUBPROCESO = 'RIESGO' THEN 'GESTION TRANSVERSAL RIESGOS'
                  WHEN HALLAZGOS.SUBPROCESO = 'RIESGO TECNOLOGICO' THEN 'GESTION TRANSVERSAL SEGURIDAD DE LA INFORMACION'
                  ELSE 'SIN DEFINIR'
            END
            ELSE HALLAZGOS.SUBPROCESO

            END SUBPROCESO_SGI_20,

		
        HALLAZGOS.*      
    FROM
        (SELECT
            NMDEADLINE,
            IDPROCESS,
            NMUSERSTART,
            TYPEUSER,
            DTSTART,
            IDLEVEL,
            DTDEADLINEFIELD,
            NMEVALRESULT,
            NMPROCESSMODEL,
            IDSITUATION,
            IDSLASTATUS,
            NMPROCESS,
            DTFINISH,
            DTSLAFINISH,
            IDREVISION,
            NMACTTYPE,
            NMOCCURRENCETYPE,
            IDREVISIONSTATUS,
            NMREVISIONSTATUS,
            TABLE0__ACCSSOACCGRA_3,
            TABLE0__ACCAMBACCPRO_2,
            TABLE0__ACCSSOACCPRO_2,
            TABLE0__TM05_7,
            TABLE0__ACCSSOOJOACL_1,
            TABLE0__ACCSSOCAUINM_2,
            TABLE0__ACCSSOPARAFE12_7,
            TABLE0__SG07_7 SG07,
            TABLE0__ANTTRABACCTRA_3,
            TABLE0__ANTTRABACCEMP_3,
            TABLE0__APROBANAPLAN_3,
            TABLE0__ARENMDETECTA_1,
            TABLE0__NMAREAAPROHALL_1,
            TABLE0__NMAREADETEC_1,
            TABLE0__TM16_7,
            TABLE0__ACCAMBACC04_7,
            TABLE0__ACCSSOPARAFE23_7,
            TABLE0__ACCSSOPARAFE03_7,
            TABLE0__ACCSSOPARAFE04_7,
            TABLE0__ACCSSOPARAFE01_7,
            TABLE0__SG01_7 SG01,
            TABLE0__CAPTRABACC_1,
            TABLE0__ACCSSOPARAFE13_7,
            TABLE0__CARNMDETECTA_1,
            TABLE0__NMCARAPROHALL_1,
            TABLE0__CARANALISIS_1,
            TABLE0__CARAPROBANAPLAN_1,
            TABLE0__CARVER_1,
            TABLE0__ACCSSOCARTES01_1,
            TABLE0__ACCSSOCARTES02_1,
            TABLE0__CDAREANALISIS_1,
            TABLE0__CDAREAAPROB_1,
            TABLE0__CDAREADETEC_3,
            TABLE0__CDAREAVERIF_1,
            TABLE0__CDGCOHAL_3,
            TABLE0__CDGERHAL_3,
            TABLE0__CDJEFHAL_3,
            TABLE0__CDSUBHAL_3,
            TABLE0__CDUSUANALISIS_3,
            TABLE0__CDUSUAPROB_3,
            TABLE0__CDUSUAPROHAL_3,
            TABLE0__CDDETECTA_3,
            TABLE0__CDUSUVERIF_3,
            TABLE0__ACCSSOTP01_7,
            TABLE0__CLASIFICACION_1,
            TABLE0__ACCSSOPARAFE14_7,
            TABLE0__OBSCOM01_2,
            TABLE0__OBSCOM02_2,
            TABLE0__OBSCOM03_2,
            TABLE0__OBSCOM04_2,
            TABLE0__OBSCOM05_2,
            TABLE0__TM06_7,
            TABLE0__OBSAS01_3,
            TABLE0__OBSAS02_3,
            TABLE0__OBSAS03_3,
            TABLE0__OBSAS04_3,
            TABLE0__OBSAS05_3,
            TABLE0__TM19_7,
            TABLE0__TM21_7,
            TABLE0__TM09_7,
            TABLE0__ACCSSOCONANA_2,
            TABLE0__CONDDETEC1_1,
            TABLE0__CONDDETEC2_1,
            TABLE0__CONDDETEC3_1,
            TABLE0__ACCSSOCAUINM02_2,
            TABLE0__ACCSSOTP02_7,
            TABLE0__ACCSSOTP04_7,
            TABLE0__ACCSSOTP19_7,
            TABLE0__ACCAMBIMP03_7,
            TABLE0__ACCAMBIMP04_7,
            TABLE0__ACCAMBIMP02_7,
            TABLE0__ACCAMBACC06_7,
            TABLE0__SG04_7 SG04,
            TABLE0__ACCSSONATLES06_7,
            TABLE0__CRITICIDAD_1,
            TABLE0__ACCSSONATLESCUA_1,
            TABLE0__ACCAMBACC08_1,
            TABLE0__ACCAMBIMP07_1,
            TABLE0__ACCAMBPQ12_1,
            TABLE0__ACCSSOPARAFE15_7,
            TABLE0__ACCSSOOJO01_7,
            TABLE0__ACCSSOCPA03_7,
            TABLE0__ACCSSOPARAFE16_7,
            TABLE0__ACCSSOPARAFE20_7,
            TABLE0__ACCSSOACC01_7,
            TABLE0__ACCAMBTP01_7,
            TABLE0__ACCAMBTP03_7,
            TABLE0__ACCSSOTP10_7,
            TABLE0__ACCSSOPQ01_7,
            TABLE0__ACCAMBPQ10_7,
            TABLE0__ACCSSOPQ04_7,
            TABLE0__DESCRIPCION_2,
            TABLE0__ACCSSODES_2,
            TABLE0__ACCAMBDESCRIP_2,
            TABLE0__ACCSSONATLES09_7,
            TABLE0__DOR_1,
            TABLE0__ACCAMBDETALLE_2,
            TABLE0__ACCSSODET_2,
            TABLE0__ACCSSOACC05_7,
            TABLE0__TM07_7,
            TABLE0__ACCSSODIA_1,
            TABLE0__ACCAMBACC05_7,
            TABLE0__ACCSSONATLES11_7,
            TABLE0__EDADTRABACC_3,
            TABLE0__ACCAMBIMP01_7,
            TABLE0__ACCAMBIMP05_7,
            TABLE0__EFICAZ_3,
            TABLE0__SG02_7 SG02,
            TABLE0__EMP_1,
            TABLE0__EMPAA_7,
            TABLE0__EMPAC_7,
            TABLE0__EMPAM_7,
            TABLE0__EMPRESAPR_1,
            TABLE0__EMPRESAPROHALL_1,
            TABLE0__EMPRESVER_1,
            TABLE0__EMPRESREG_1,
            TABLE0__EMPRESANA_1,
            TABLE0__TM01_7,
            TABLE0__TM22_7,
            TABLE0__ESCANTTRA_3,
            TABLE0__ESCANTEMP_3,
            TABLE0__ACCSSOPARAFE02_7,
            TABLE0__ESTTRABACC_1,
            TABLE0__TM20_7,
            TABLE0__ACCSSOCAUBAS02_2,
            TABLE0__ACCSSOCAUBAS01_2,
            TABLE0__ACCAMBPQ08_7,
            TABLE0__ACCAMBPQ07_7,
            TABLE0__ACCAMBPQ04_7,
            TABLE0__ACCAMBPQ06_7,
            TABLE0__ACCAMBPQ02_7,
            TABLE0__ACCAMBPQ01_7,
            TABLE0__ACCAMBPQ03_7,
            TABLE0__DTACCSSO_6,
            TABLE0__DTDETECCION_6,
            TABLE0__DTPRIAUX_6,
            TABLE0__ACCSSONATLES05_7,
            TABLE0__ACCAMBTP10_7,
            TABLE0__ACCSSOTP17_7,
            TABLE0__GCORESANA_1,
            TABLE0__GCORESAPR_1,
            TABLE0__NMGCOHAL_1,
            TABLE0__GCORESAPROHAL_1,
            TABLE0__GCORESVER_1,
            TABLE0__GCORESREG_1,
            TABLE0__NMGERHAL_1,
            TABLE0__GERRESAPROHAL_1,
            TABLE0__GERRESANA_1,
            TABLE0__GERRESAPR_1,
            TABLE0__GERRESREG_1,
            TABLE0__GERRESVER_1,
            TABLE0__GRUREG_1,
            TABLE0__NMGRUAPROHALL_1,
            TABLE0__ACCSSONATLES01_7,
            TABLE0__ACCSSOPARAFE17_7,
            TABLE0__HRACCSSO_5,
            TABLE0__HRINGTRAB_5,
            TABLE0__HRPRIAUX_5,
            TABLE0__NRHORASTRAB_3,
            TABLE0__ACCSSOATEHOS_7,
            TABLE0__IDAREAANALISIS_1,
            TABLE0__IDAREAAPROB_1,
            TABLE0__IDAREAAPROBHALL_1,
            TABLE0__IDAREADETEC_1,
            TABLE0__AREAIDDETECTA_1,
            TABLE0__IDAREAVERIF_1,
            TABLE0__ACCSSOIDCAR01_1,
            TABLE0__ACCSSOIDCAR02_1,
            TABLE0__ACCSSOIDCAR03_1,
            TABLE0__ACCSSOIDCAR04_1,
            TABLE0__ACCSSOIDCAR05_1,
            TABLE0__ACCSSOIDCAR06_1,
            TABLE0__IDCARDETECTA_1,
            TABLE0__IDCARGOTRABACC_1,
            TABLE0__IDDUENOPROCESO_1,
            TABLE0__IDENCARGADOSGI_1,
            TABLE0__IDGCOHAL_1,
            TABLE0__IDGCORESANA_1,
            TABLE0__IDGCORESAPR_1,
            TABLE0__IDGCORESAPROHAL_1,
            TABLE0__IDGCORESREG_1,
            TABLE0__IDGCORESVER_1,
            TABLE0__IDGERHAL_1,
            TABLE0__IDGERRESANA_1,
            TABLE0__IDGERRESAPR_1,
            TABLE0__IDGERRESAPROHAL_1,
            TABLE0__IDGERRESVER_1,
            TABLE0__IDGERRESREG_1,
            TABLE0__IDGRUANALISIS_1,
            TABLE0__IDGRUAPROBHALL_1,
            TABLE0__IDGRUAPROB_1,
            TABLE0__IDGRUVERIF_1,
            TABLE0__ACCSSOIDINV01_1,
            TABLE0__ACCSSOIDINV02_1,
            TABLE0__ACCSSOIDINV03_1,
            TABLE0__ACCSSOIDINV04_1,
            TABLE0__ACCSSOIDINV05_1,
            TABLE0__ACCSSOIDINV06_1,
            TABLE0__IDJEFHAL_1,
            TABLE0__IDJEFRESANA_1,
            TABLE0__IDJEFRESAPR_1,
            TABLE0__IDJEFRESAPROHAL_1,
            TABLE0__IDSUBRESAPROHAL_1,
            TABLE0__IDJEFRESVER_1,
            TABLE0__IDJEFRESREG_1,
            TABLE0__IDSUBHAL_1,
            TABLE0__IDSUBRESANA_1,
            TABLE0__IDSUBRESAPR_1,
            TABLE0__IDSUBRESVER_1,
            TABLE0__IDSUBRESREG_1,
            TABLE0__IDTRABACC_1,
            TABLE0__ACCSSOIDTRA01_1,
            TABLE0__ACCSSOIDTRA02_1,
            TABLE0__IDUSUANALISIS_1,
            TABLE0__IDUSUAPROB_1,
            TABLE0__IDUSUAPROHAL_1,
            TABLE0__IDDETECTA_1,
            TABLE0__IDUSUVERIF_1,
            TABLE0__IDENTIFICADOR_1,
            TABLE0__SG06_7 SG06,
            TABLE0__IMPOMJ_3,
            TABLE0__ACCAMBTP09_7,
            TABLE0__ACCSSOACC02_7,
            TABLE0__TM14_7,
            TABLE0__ACCSSOTP09_7,
            TABLE0__ACCSSOTP16_7,
            TABLE0__ACCSSOTP06_7,
            TABLE0__JEFRESANA_1,
            TABLE0__JEFRESAPR_1,
            TABLE0__JEFRESAPROHAL_1,
            TABLE0__JEFRESVER_1,
            TABLE0__JEFRESREG_1,
            TABLE0__NMJEFHAL_1,
            TABLE0__JORLAB_1,
            TABLE0__ACCSSOCPA04_7,
            TABLE0__JUSAPROBANAPLAN_2,
            TABLE0__JUSAPROBAEFIC_2,
            TABLE0__JUSIMPOMJ_2,
            TABLE0__ACCSSOTP18_7,
            TABLE0__TM15_7,
            TABLE0__ACCAMBACC02_7,
            TABLE0__ACCAMBLUG_3,
            TABLE0__ACCSSONATLES10_7,
            TABLE0__ACCSSONATLES08_7,
            TABLE0__MACRO_1 MACROPROCESO,
            TABLE0__ACCAMBPQ09_7,
            TABLE0__ACCAMBPQ05_7,
            TABLE0__ACCSSOPARAFE05_7,
            TABLE0__ACCSSOPARAFE06_7,
            TABLE0__SG05_7 SG05,
            TABLE0__ACCSSOMEDTRA_3,
            TABLE0__TM17_7,
            TABLE0__TM10_7,
            TABLE0__ACCSSOPARAFE18_7,
            TABLE0__ACCSSOATEMUT_7,
            TABLE0__ACCSSOOJONAT_2,
            TABLE0__TM04_7,
            TABLE0__ACCSSOPQ03_7,
            TABLE0__ACCSSOPQ02_7,
            TABLE0__ACCSSOTP13_7,
            TABLE0__ACCSSOTP11_7,
            TABLE0__ACCSSOTP14_7,
            TABLE0__ACCSSOTP20_7,
            TABLE0__ACCSSOTP15_7,
            TABLE0__NMAREAANALISIS_1,
            TABLE0__NMAREAAPROB_1,
            TABLE0__NMAREAVERIF_1,
            TABLE0__ACCSSONMCAR01_1,
            TABLE0__ACCSSONMCAR02_1,
            TABLE0__ACCSSONMCAR03_1,
            TABLE0__ACCSSONMCAR04_1,
            TABLE0__ACCSSONMCAR05_1,
            TABLE0__ACCSSONMCAR06_1,
            TABLE0__NMCARGOTRABACC_1,
            TABLE0__NMDETECTA_1,
            TABLE0__ACCSOONMSUM_1,
            TABLE0__NMDUENOPROCESO_1,
            TABLE0__NMENCARGADOSGI_1,
            TABLE0__NMGRUANALISIS_1,
            TABLE0__NMGRUAPROB_1,
            TABLE0__NMGRUVERIF_1,
            TABLE0__ACCSSONMINV01_1,
            TABLE0__ACCSSONMINV02_1,
            TABLE0__ACCSSONMINV03_1,
            TABLE0__ACCSSONMINV04_1,
            TABLE0__ACCSSONMINV05_1,
            TABLE0__ACCSSONMINV06_1,
            TABLE0__ACCSSONMTES01_1,
            TABLE0__ACCSSONMTES02_1,
            TABLE0__NMTRABACC_1,
            TABLE0__ACCSSONMTRA01_1,
            TABLE0__ACCSSONMTRA02_1,
            TABLE0__NMUSUANALISIS_1,
            TABLE0__NMUSUAPROB_1,
            TABLE0__NMUSUVERIF_1,
            TABLE0__TM03_7,
            TABLE0__ACCSSOPARAFE24_7,
            TABLE0__TM23_7,
            TABLE0__ORIGEN_1,
            TABLE0__ACCAMBACC07_7,
            TABLE0__ACCSSONMOTRAATE_1,
            TABLE0__ACCSSOOJO03_7,
            TABLE0__ACCAMBPQ11_7,
            TABLE0__ACCSSOATEOTR_7,
            TABLE0__ACCSSONATLES12_7,
            TABLE0__ACCAMBTP11_7,
            TABLE0__ACCAMBIMP06_7,
            TABLE0__ACCAMBTP12_1,
            TABLE0__ACCAMBACC01_7,
            TABLE0__ACCSSOPARAFE19_7,
            TABLE0__ACCSSONATLES02_7,
            TABLE0__PERUSUREG_1,
            TABLE0__ACCSSOPARAFE09_7,
            TABLE0__ACCSSOPARAFE10_7,
            TABLE0__ACCSSOPARAFE07_7,
            TABLE0__ACCSSOPARAFE08_7,
            TABLE0__TM18_7,
            TABLE0__TM08_7,
            TABLE0__ACCSSOATEPOS_7,
            TABLE0__ACCAMBTP02_7,
            TABLE0__ACCAMBTP04_7,
            TABLE0__ACCAMBTP07_7,
            TABLE0__ACCAMBTP08_7,
            TABLE0__ACCAMBTP06_7,
            TABLE0__PROCESO_1 PROCESO,
            TABLE0__ACCSSONATLES04_7,
            TABLE0__ACCSSOOJO02_7,
            TABLE0__OBSRAZONESOBS_2,
            TABLE0__ACCSSOTP05_7,
            TABLE0__ACCSSOTP08_7,
            TABLE0__ACCSSOTP07_7,
            TABLE0__RECINTO_1,
            TABLE0__TM12_7,
            TABLE0__ACCSSOREG02_3,
            TABLE0__ACCSSOREG_3,
            TABLE0__ACCSOOREQPRIAUX_3,
            TABLE0__NMUSUAPROHALL_1,
            TABLE0__RESPAPROBANA_2,
            TABLE0__RESPVERIFEFICAC_2,
            TABLE0__TM13_7,
            TABLE0__ACCSSOCPA02_7,
            TABLE0__ACCSSOCPA01_7,
            TABLE0__RIESGOS1_2,
            TABLE0__RIESGOS2_2,
            TABLE0__RIESGOS3_2,
            TABLE0__ACCSSOPARAFE21_7,
            TABLE0__TM02_7,
            TABLE0__ACCSSORUNTES01_1,
            TABLE0__ACCSSORUNTES02_1,
            TABLE0__RUTTRABACC_1,
            TABLE0__SG08_7 SG08,
            TABLE0__SG09_7 SG09,
            TABLE0__SG03_7 SG03,
            TABLE0__ACCAMBACC03_7,
            TABLE0__ACCSSOACC03_7,
            TABLE0__SEXOTRABACC_3,
            TABLE0__ACCSSONATLES03_7,
            TABLE0__TM11_7,
            TABLE0__ACCSSOTP03_7,
            TABLE0__ACCSSOACC06_7,
            TABLE0__ACCSSOACC04_7,
            TABLE0__NMSUBHAL_1,
            TABLE0__SUBRESAPROHAL_1,
            TABLE0__SUBRESANA_1,
            TABLE0__SUBRESAPR_1,
            TABLE0__SUBRESVER_1,
            TABLE0__SUBRESREG_1,
            TABLE0__SUBPROCESO_1 SUBPROCESO,
            TABLE0__OBSTAREASOBS_1,
            TABLE0__ACCSSONUMTES01_1,
            TABLE0__ACCSSONUMTES02_1,
            TABLE0__ACCSOOTIPACC_3,
            TABLE0__TIPESTHAL_1,
            TABLE0__TIPESTANA_1,
            TABLE0__TIPESTAPROHAL_1,
            TABLE0__TIPESTAPR_1,
            TABLE0__TIPESTREG_1,
            TABLE0__TIPESTVERIF_1,
            TABLE0__TITULO_1,
            TABLE0__ACCSSOPARAFE22_7,
            TABLE0__ACCSSOPARAFE11_7,
            TABLE0__ACCSSONATLES07_7,
            TABLE0__ACCSOOTRAS_3,
            TABLE0__ACCSSOTP12_7,
            TABLE0__DTAPROBANA_6,
            TABLE0__DTAPROBHALL_6,
            TABLE0__DTEJECPLAN_6,
            TABLE0__DTANAPLAN_6,
            TABLE0__DTVERIFICACION_6,
            TABLE0__ACCAMBTP05_7,
            TABLE0__ACCAMBZIM_3,
            TABLE0__OBS01_7,
            TABLE0__OBS10_7,
            TABLE0__OBS11_7,
            TABLE0__OBS12_7,
            TABLE0__OBS13_7,
            TABLE0__OBS14_7,
            TABLE0__OBS15_7,
            TABLE0__OBS16_7,
            TABLE0__OBS17_7,
            TABLE0__OBS18_7,
            TABLE0__OBS19_7,
            TABLE0__OBS02_7,
            TABLE0__OBS20_7,
            TABLE0__OBS21_7,
            TABLE0__OBS22_7,
            TABLE0__OBS23_7,
            TABLE0__OBS24_7,
            TABLE0__OBS25_7,
            TABLE0__OBS03_7,
            TABLE0__OBS04_7,
            TABLE0__OBS05_7,
            TABLE0__OBS06_7,
            TABLE0__OBS07_7,
            TABLE0__OBS08_7,
            TABLE0__OBS09_7          
        FROM
            (SELECT
                NMDEADLINE,
                IDPROCESS,
                NMUSERSTART,
                TYPEUSER,
                DTSTART,
                IDLEVEL,
                DTDEADLINEFIELD,
                NMEVALRESULT,
                NMPROCESSMODEL,
                IDSITUATION,
                IDSLASTATUS,
                NMPROCESS,
                DTFINISH,
                DTSLAFINISH,
                IDREVISION,
                NMACTTYPE,
                NMOCCURRENCETYPE,
                IDREVISIONSTATUS,
                NMREVISIONSTATUS,
                TABLE0__ACCSSOACCGRA_3,
                TABLE0__ACCAMBACCPRO_2,
                TABLE0__ACCSSOACCPRO_2,
                TABLE0__TM05_7,
                TABLE0__ACCSSOOJOACL_1,
                TABLE0__ACCSSOCAUINM_2,
                TABLE0__ACCSSOPARAFE12_7,
                TABLE0__SG07_7,
                TABLE0__ANTTRABACCTRA_3,
                TABLE0__ANTTRABACCEMP_3,
                TABLE0__APROBANAPLAN_3,
                TABLE0__ARENMDETECTA_1,
                TABLE0__NMAREAAPROHALL_1,
                TABLE0__NMAREADETEC_1,
                TABLE0__TM16_7,
                TABLE0__ACCAMBACC04_7,
                TABLE0__ACCSSOPARAFE23_7,
                TABLE0__ACCSSOPARAFE03_7,
                TABLE0__ACCSSOPARAFE04_7,
                TABLE0__ACCSSOPARAFE01_7,
                TABLE0__SG01_7,
                TABLE0__CAPTRABACC_1,
                TABLE0__ACCSSOPARAFE13_7,
                TABLE0__CARNMDETECTA_1,
                TABLE0__NMCARAPROHALL_1,
                TABLE0__CARANALISIS_1,
                TABLE0__CARAPROBANAPLAN_1,
                TABLE0__CARVER_1,
                TABLE0__ACCSSOCARTES01_1,
                TABLE0__ACCSSOCARTES02_1,
                TABLE0__CDAREANALISIS_1,
                TABLE0__CDAREAAPROB_1,
                TABLE0__CDAREADETEC_3,
                TABLE0__CDAREAVERIF_1,
                TABLE0__CDGCOHAL_3,
                TABLE0__CDGERHAL_3,
                TABLE0__CDJEFHAL_3,
                TABLE0__CDSUBHAL_3,
                TABLE0__CDUSUANALISIS_3,
                TABLE0__CDUSUAPROB_3,
                TABLE0__CDUSUAPROHAL_3,
                TABLE0__CDDETECTA_3,
                TABLE0__CDUSUVERIF_3,
                TABLE0__ACCSSOTP01_7,
                TABLE0__CLASIFICACION_1,
                TABLE0__ACCSSOPARAFE14_7,
                TABLE0__OBSCOM01_2,
                TABLE0__OBSCOM02_2,
                TABLE0__OBSCOM03_2,
                TABLE0__OBSCOM04_2,
                TABLE0__OBSCOM05_2,
                TABLE0__TM06_7,
                TABLE0__OBSAS01_3,
                TABLE0__OBSAS02_3,
                TABLE0__OBSAS03_3,
                TABLE0__OBSAS04_3,
                TABLE0__OBSAS05_3,
                TABLE0__TM19_7,
                TABLE0__TM21_7,
                TABLE0__TM09_7,
                TABLE0__ACCSSOCONANA_2,
                TABLE0__CONDDETEC1_1,
                TABLE0__CONDDETEC2_1,
                TABLE0__CONDDETEC3_1,
                TABLE0__ACCSSOCAUINM02_2,
                TABLE0__ACCSSOTP02_7,
                TABLE0__ACCSSOTP04_7,
                TABLE0__ACCSSOTP19_7,
                TABLE0__ACCAMBIMP03_7,
                TABLE0__ACCAMBIMP04_7,
                TABLE0__ACCAMBIMP02_7,
                TABLE0__ACCAMBACC06_7,
                TABLE0__SG04_7,
                TABLE0__ACCSSONATLES06_7,
                TABLE0__CRITICIDAD_1,
                TABLE0__ACCSSONATLESCUA_1,
                TABLE0__ACCAMBACC08_1,
                TABLE0__ACCAMBIMP07_1,
                TABLE0__ACCAMBPQ12_1,
                TABLE0__ACCSSOPARAFE15_7,
                TABLE0__ACCSSOOJO01_7,
                TABLE0__ACCSSOCPA03_7,
                TABLE0__ACCSSOPARAFE16_7,
                TABLE0__ACCSSOPARAFE20_7,
                TABLE0__ACCSSOACC01_7,
                TABLE0__ACCAMBTP01_7,
                TABLE0__ACCAMBTP03_7,
                TABLE0__ACCSSOTP10_7,
                TABLE0__ACCSSOPQ01_7,
                TABLE0__ACCAMBPQ10_7,
                TABLE0__ACCSSOPQ04_7,
                TABLE0__DESCRIPCION_2,
                TABLE0__ACCSSODES_2,
                TABLE0__ACCAMBDESCRIP_2,
                TABLE0__ACCSSONATLES09_7,
                TABLE0__DOR_1,
                TABLE0__ACCAMBDETALLE_2,
                TABLE0__ACCSSODET_2,
                TABLE0__ACCSSOACC05_7,
                TABLE0__TM07_7,
                TABLE0__ACCSSODIA_1,
                TABLE0__ACCAMBACC05_7,
                TABLE0__ACCSSONATLES11_7,
                TABLE0__EDADTRABACC_3,
                TABLE0__ACCAMBIMP01_7,
                TABLE0__ACCAMBIMP05_7,
                TABLE0__EFICAZ_3,
                TABLE0__SG02_7,
                TABLE0__EMP_1,
                TABLE0__EMPAA_7,
                TABLE0__EMPAC_7,
                TABLE0__EMPAM_7,
                TABLE0__EMPRESAPR_1,
                TABLE0__EMPRESAPROHALL_1,
                TABLE0__EMPRESVER_1,
                TABLE0__EMPRESREG_1,
                TABLE0__EMPRESANA_1,
                TABLE0__TM01_7,
                TABLE0__TM22_7,
                TABLE0__ESCANTTRA_3,
                TABLE0__ESCANTEMP_3,
                TABLE0__ACCSSOPARAFE02_7,
                TABLE0__ESTTRABACC_1,
                TABLE0__TM20_7,
                TABLE0__ACCSSOCAUBAS02_2,
                TABLE0__ACCSSOCAUBAS01_2,
                TABLE0__ACCAMBPQ08_7,
                TABLE0__ACCAMBPQ07_7,
                TABLE0__ACCAMBPQ04_7,
                TABLE0__ACCAMBPQ06_7,
                TABLE0__ACCAMBPQ02_7,
                TABLE0__ACCAMBPQ01_7,
                TABLE0__ACCAMBPQ03_7,
                TABLE0__DTACCSSO_6,
                TABLE0__DTDETECCION_6,
                TABLE0__DTPRIAUX_6,
                TABLE0__ACCSSONATLES05_7,
                TABLE0__ACCAMBTP10_7,
                TABLE0__ACCSSOTP17_7,
                TABLE0__GCORESANA_1,
                TABLE0__GCORESAPR_1,
                TABLE0__NMGCOHAL_1,
                TABLE0__GCORESAPROHAL_1,
                TABLE0__GCORESVER_1,
                TABLE0__GCORESREG_1,
                TABLE0__NMGERHAL_1,
                TABLE0__GERRESAPROHAL_1,
                TABLE0__GERRESANA_1,
                TABLE0__GERRESAPR_1,
                TABLE0__GERRESREG_1,
                TABLE0__GERRESVER_1,
                TABLE0__GRUREG_1,
                TABLE0__NMGRUAPROHALL_1,
                TABLE0__ACCSSONATLES01_7,
                TABLE0__ACCSSOPARAFE17_7,
                TABLE0__HRACCSSO_5,
                TABLE0__HRINGTRAB_5,
                TABLE0__HRPRIAUX_5,
                TABLE0__NRHORASTRAB_3,
                TABLE0__ACCSSOATEHOS_7,
                TABLE0__IDAREAANALISIS_1,
                TABLE0__IDAREAAPROB_1,
                TABLE0__IDAREAAPROBHALL_1,
                TABLE0__IDAREADETEC_1,
                TABLE0__AREAIDDETECTA_1,
                TABLE0__IDAREAVERIF_1,
                TABLE0__ACCSSOIDCAR01_1,
                TABLE0__ACCSSOIDCAR02_1,
                TABLE0__ACCSSOIDCAR03_1,
                TABLE0__ACCSSOIDCAR04_1,
                TABLE0__ACCSSOIDCAR05_1,
                TABLE0__ACCSSOIDCAR06_1,
                TABLE0__IDCARDETECTA_1,
                TABLE0__IDCARGOTRABACC_1,
                TABLE0__IDDUENOPROCESO_1,
                TABLE0__IDENCARGADOSGI_1,
                TABLE0__IDGCOHAL_1,
                TABLE0__IDGCORESANA_1,
                TABLE0__IDGCORESAPR_1,
                TABLE0__IDGCORESAPROHAL_1,
                TABLE0__IDGCORESREG_1,
                TABLE0__IDGCORESVER_1,
                TABLE0__IDGERHAL_1,
                TABLE0__IDGERRESANA_1,
                TABLE0__IDGERRESAPR_1,
                TABLE0__IDGERRESAPROHAL_1,
                TABLE0__IDGERRESVER_1,
                TABLE0__IDGERRESREG_1,
                TABLE0__IDGRUANALISIS_1,
                TABLE0__IDGRUAPROBHALL_1,
                TABLE0__IDGRUAPROB_1,
                TABLE0__IDGRUVERIF_1,
                TABLE0__ACCSSOIDINV01_1,
                TABLE0__ACCSSOIDINV02_1,
                TABLE0__ACCSSOIDINV03_1,
                TABLE0__ACCSSOIDINV04_1,
                TABLE0__ACCSSOIDINV05_1,
                TABLE0__ACCSSOIDINV06_1,
                TABLE0__IDJEFHAL_1,
                TABLE0__IDJEFRESANA_1,
                TABLE0__IDJEFRESAPR_1,
                TABLE0__IDJEFRESAPROHAL_1,
                TABLE0__IDSUBRESAPROHAL_1,
                TABLE0__IDJEFRESVER_1,
                TABLE0__IDJEFRESREG_1,
                TABLE0__IDSUBHAL_1,
                TABLE0__IDSUBRESANA_1,
                TABLE0__IDSUBRESAPR_1,
                TABLE0__IDSUBRESVER_1,
                TABLE0__IDSUBRESREG_1,
                TABLE0__IDTRABACC_1,
                TABLE0__ACCSSOIDTRA01_1,
                TABLE0__ACCSSOIDTRA02_1,
                TABLE0__IDUSUANALISIS_1,
                TABLE0__IDUSUAPROB_1,
                TABLE0__IDUSUAPROHAL_1,
                TABLE0__IDDETECTA_1,
                TABLE0__IDUSUVERIF_1,
                TABLE0__IDENTIFICADOR_1,
                TABLE0__SG06_7,
                TABLE0__IMPOMJ_3,
                TABLE0__ACCAMBTP09_7,
                TABLE0__ACCSSOACC02_7,
                TABLE0__TM14_7,
                TABLE0__ACCSSOTP09_7,
                TABLE0__ACCSSOTP16_7,
                TABLE0__ACCSSOTP06_7,
                TABLE0__JEFRESANA_1,
                TABLE0__JEFRESAPR_1,
                TABLE0__JEFRESAPROHAL_1,
                TABLE0__JEFRESVER_1,
                TABLE0__JEFRESREG_1,
                TABLE0__NMJEFHAL_1,
                TABLE0__JORLAB_1,
                TABLE0__ACCSSOCPA04_7,
                TABLE0__JUSAPROBANAPLAN_2,
                TABLE0__JUSAPROBAEFIC_2,
                TABLE0__JUSIMPOMJ_2,
                TABLE0__ACCSSOTP18_7,
                TABLE0__TM15_7,
                TABLE0__ACCAMBACC02_7,
                TABLE0__ACCAMBLUG_3,
                TABLE0__ACCSSONATLES10_7,
                TABLE0__ACCSSONATLES08_7,
                TABLE0__MACRO_1,
                TABLE0__ACCAMBPQ09_7,
                TABLE0__ACCAMBPQ05_7,
                TABLE0__ACCSSOPARAFE05_7,
                TABLE0__ACCSSOPARAFE06_7,
                TABLE0__SG05_7,
                TABLE0__ACCSSOMEDTRA_3,
                TABLE0__TM17_7,
                TABLE0__TM10_7,
                TABLE0__ACCSSOPARAFE18_7,
                TABLE0__ACCSSOATEMUT_7,
                TABLE0__ACCSSOOJONAT_2,
                TABLE0__TM04_7,
                TABLE0__ACCSSOPQ03_7,
                TABLE0__ACCSSOPQ02_7,
                TABLE0__ACCSSOTP13_7,
                TABLE0__ACCSSOTP11_7,
                TABLE0__ACCSSOTP14_7,
                TABLE0__ACCSSOTP20_7,
                TABLE0__ACCSSOTP15_7,
                TABLE0__NMAREAANALISIS_1,
                TABLE0__NMAREAAPROB_1,
                TABLE0__NMAREAVERIF_1,
                TABLE0__ACCSSONMCAR01_1,
                TABLE0__ACCSSONMCAR02_1,
                TABLE0__ACCSSONMCAR03_1,
                TABLE0__ACCSSONMCAR04_1,
                TABLE0__ACCSSONMCAR05_1,
                TABLE0__ACCSSONMCAR06_1,
                TABLE0__NMCARGOTRABACC_1,
                TABLE0__NMDETECTA_1,
                TABLE0__ACCSOONMSUM_1,
                TABLE0__NMDUENOPROCESO_1,
                TABLE0__NMENCARGADOSGI_1,
                TABLE0__NMGRUANALISIS_1,
                TABLE0__NMGRUAPROB_1,
                TABLE0__NMGRUVERIF_1,
                TABLE0__ACCSSONMINV01_1,
                TABLE0__ACCSSONMINV02_1,
                TABLE0__ACCSSONMINV03_1,
                TABLE0__ACCSSONMINV04_1,
                TABLE0__ACCSSONMINV05_1,
                TABLE0__ACCSSONMINV06_1,
                TABLE0__ACCSSONMTES01_1,
                TABLE0__ACCSSONMTES02_1,
                TABLE0__NMTRABACC_1,
                TABLE0__ACCSSONMTRA01_1,
                TABLE0__ACCSSONMTRA02_1,
                TABLE0__NMUSUANALISIS_1,
                TABLE0__NMUSUAPROB_1,
                TABLE0__NMUSUVERIF_1,
                TABLE0__TM03_7,
                TABLE0__ACCSSOPARAFE24_7,
                TABLE0__TM23_7,
                TABLE0__ORIGEN_1,
                TABLE0__ACCAMBACC07_7,
                TABLE0__ACCSSONMOTRAATE_1,
                TABLE0__ACCSSOOJO03_7,
                TABLE0__ACCAMBPQ11_7,
                TABLE0__ACCSSOATEOTR_7,
                TABLE0__ACCSSONATLES12_7,
                TABLE0__ACCAMBTP11_7,
                TABLE0__ACCAMBIMP06_7,
                TABLE0__ACCAMBTP12_1,
                TABLE0__ACCAMBACC01_7,
                TABLE0__ACCSSOPARAFE19_7,
                TABLE0__ACCSSONATLES02_7,
                TABLE0__PERUSUREG_1,
                TABLE0__ACCSSOPARAFE09_7,
                TABLE0__ACCSSOPARAFE10_7,
                TABLE0__ACCSSOPARAFE07_7,
                TABLE0__ACCSSOPARAFE08_7,
                TABLE0__TM18_7,
                TABLE0__TM08_7,
                TABLE0__ACCSSOATEPOS_7,
                TABLE0__ACCAMBTP02_7,
                TABLE0__ACCAMBTP04_7,
                TABLE0__ACCAMBTP07_7,
                TABLE0__ACCAMBTP08_7,
                TABLE0__ACCAMBTP06_7,
                TABLE0__PROCESO_1,
                TABLE0__ACCSSONATLES04_7,
                TABLE0__ACCSSOOJO02_7,
                TABLE0__OBSRAZONESOBS_2,
                TABLE0__ACCSSOTP05_7,
                TABLE0__ACCSSOTP08_7,
                TABLE0__ACCSSOTP07_7,
                TABLE0__RECINTO_1,
                TABLE0__TM12_7,
                TABLE0__ACCSSOREG02_3,
                TABLE0__ACCSSOREG_3,
                TABLE0__ACCSOOREQPRIAUX_3,
                TABLE0__NMUSUAPROHALL_1,
                TABLE0__RESPAPROBANA_2,
                TABLE0__RESPVERIFEFICAC_2,
                TABLE0__TM13_7,
                TABLE0__ACCSSOCPA02_7,
                TABLE0__ACCSSOCPA01_7,
                TABLE0__RIESGOS1_2,
                TABLE0__RIESGOS2_2,
                TABLE0__RIESGOS3_2,
                TABLE0__ACCSSOPARAFE21_7,
                TABLE0__TM02_7,
                TABLE0__ACCSSORUNTES01_1,
                TABLE0__ACCSSORUNTES02_1,
                TABLE0__RUTTRABACC_1,
                TABLE0__SG08_7,
                TABLE0__SG09_7,
                TABLE0__SG03_7,
                TABLE0__ACCAMBACC03_7,
                TABLE0__ACCSSOACC03_7,
                TABLE0__SEXOTRABACC_3,
                TABLE0__ACCSSONATLES03_7,
                TABLE0__TM11_7,
                TABLE0__ACCSSOTP03_7,
                TABLE0__ACCSSOACC06_7,
                TABLE0__ACCSSOACC04_7,
                TABLE0__NMSUBHAL_1,
                TABLE0__SUBRESAPROHAL_1,
                TABLE0__SUBRESANA_1,
                TABLE0__SUBRESAPR_1,
                TABLE0__SUBRESVER_1,
                TABLE0__SUBRESREG_1,
                TABLE0__SUBPROCESO_1,
                TABLE0__OBSTAREASOBS_1,
                TABLE0__ACCSSONUMTES01_1,
                TABLE0__ACCSSONUMTES02_1,
                TABLE0__ACCSOOTIPACC_3,
                TABLE0__TIPESTHAL_1,
                TABLE0__TIPESTANA_1,
                TABLE0__TIPESTAPROHAL_1,
                TABLE0__TIPESTAPR_1,
                TABLE0__TIPESTREG_1,
                TABLE0__TIPESTVERIF_1,
                TABLE0__TITULO_1,
                TABLE0__ACCSSOPARAFE22_7,
                TABLE0__ACCSSOPARAFE11_7,
                TABLE0__ACCSSONATLES07_7,
                TABLE0__ACCSOOTRAS_3,
                TABLE0__ACCSSOTP12_7,
                TABLE0__DTAPROBANA_6,
                TABLE0__DTAPROBHALL_6,
                TABLE0__DTEJECPLAN_6,
                TABLE0__DTANAPLAN_6,
                TABLE0__DTVERIFICACION_6,
                TABLE0__ACCAMBTP05_7,
                TABLE0__ACCAMBZIM_3,
                TABLE0__OBS01_7,
                TABLE0__OBS10_7,
                TABLE0__OBS11_7,
                TABLE0__OBS12_7,
                TABLE0__OBS13_7,
                TABLE0__OBS14_7,
                TABLE0__OBS15_7,
                TABLE0__OBS16_7,
                TABLE0__OBS17_7,
                TABLE0__OBS18_7,
                TABLE0__OBS19_7,
                TABLE0__OBS02_7,
                TABLE0__OBS20_7,
                TABLE0__OBS21_7,
                TABLE0__OBS22_7,
                TABLE0__OBS23_7,
                TABLE0__OBS24_7,
                TABLE0__OBS25_7,
                TABLE0__OBS03_7,
                TABLE0__OBS04_7,
                TABLE0__OBS05_7,
                TABLE0__OBS06_7,
                TABLE0__OBS07_7,
                TABLE0__OBS08_7,
                TABLE0__OBS09_7              
            FROM
                (SELECT
                    1 AS QTD,
                    WFP.IDPROCESS,
                    WFP.NMPROCESS,
                    COALESCE(PML.NMPROCESS,
                    WFP.NMPROCESSMODEL) AS NMPROCESSMODEL,
                    COALESCE(ADU.NMUSER,
                    TBEXT.NMUSER) AS NMUSERSTART,
                    CASE                          
                        WHEN WFP.CDEXTERNALUSERSTART IS NOT NULL THEN '#{303826}'                          
                        WHEN WFP.CDUSERSTART IS NOT NULL THEN '#{305843}'                          
                        ELSE NULL                      
                    END AS TYPEUSER,
                    GNT.NMGENTYPE AS NMOCCURRENCETYPE,
                    GNRS.IDREVISIONSTATUS,
                    GNRS.NMREVISIONSTATUS,
                    CASE                          
                        WHEN WFP.FGCONCLUDEDSTATUS IS NOT NULL THEN (CASE                              
                            WHEN WFP.FGCONCLUDEDSTATUS=1 THEN '#{100900}'                              
                            WHEN WFP.FGCONCLUDEDSTATUS=2 THEN '#{100899}'                          
                        END)                          
                        ELSE (CASE                              
                            WHEN (( WFP.DTESTIMATEDFINISH > (CAST(<!%TODAY%> AS DATE) + COALESCE((SELECT
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
                                        CONOTIFICATION TBL))), 0)))                              
                            OR (WFP.DTESTIMATEDFINISH IS NULL)) THEN '#{100900}'                              
                            WHEN (( WFP.DTESTIMATEDFINISH=CAST(<!%TODAY%> AS DATE)                              
                            AND WFP.NRTIMEESTFINISH >= 608)                              
                            OR (WFP.DTESTIMATEDFINISH > CAST(<!%TODAY%> AS DATE))) THEN '#{201639}'                              
                            ELSE '#{100899}'                          
                        END)                      
                    END AS NMDEADLINE,
                    CASE WFP.FGSLASTATUS                          
                        WHEN 10 THEN '#{218492}'                          
                        WHEN 30 THEN '#{218493}'                          
                        WHEN 40 THEN '#{218494}'                      
                    END AS IDSLASTATUS,
                    CASE WFP.FGSTATUS                          
                        WHEN 1 THEN '#{103131}'                          
                        WHEN 2 THEN '#{107788}'                          
                        WHEN 3 THEN '#{104230}'                          
                        WHEN 4 THEN '#{100667}'                          
                        WHEN 5 THEN '#{200712}'                      
                    END AS IDSITUATION,
                    GNR.NMEVALRESULT,
                    (SELECT
                        MAX(IDLEVEL)                      
                    FROM
                        GNSLACTRLHISTORY                      
                    WHERE
                        CDSLACONTROL=WFP.CDSLACONTROL                          
                        AND FGCURRENT=1) AS IDLEVEL,
                    PT.NMACTTYPE,
                    GNREV.IDREVISION,
                    CASE                          
                        WHEN SLACTRL.BNSLAFINISH IS NOT NULL THEN TO_TIMESTAMP(TO_CHAR(SEF_DTEND_WK_SECS_PERIOD(TO_DATE('1970-01-01',
                        'YYYY-MM-DD HH24:MI:SS'),
                        (SLACTRL.BNSLAFINISH / 1000) -14400,
                        -2),
                        'YYYY-MM-DD HH24:MI:SS'),
                        'YYYY-MM-DD HH24:MI:SS')                          
                        ELSE NULL                      
                    END AS DTSLAFINISH,
                    WFP.DTESTIMATEDFINISH + WFP.NRTIMEESTFINISH/1440 AS DTDEADLINEFIELD,
                    TO_TIMESTAMP(TO_CHAR(WFP.DTSTART,
                    'YYYY-MM-DD') || ' ' || WFP.TMSTART,
                    'YYYY-MM-DD HH24:MI:SS') AS DTSTART,
                    CASE                          
                        WHEN WFP.DTFINISH IS NOT NULL THEN TO_TIMESTAMP(TO_CHAR(WFP.DTFINISH,
                        'YYYY-MM-DD') || ' ' || WFP.TMFINISH,
                        'YYYY-MM-DD HH24:MI:SS')                          
                        ELSE NULL                      
                    END AS DTFINISH,
                    TABLE0_OUTER.TABLE0__ACCSSOACCGRA_3,
                    TABLE0_OUTER.TABLE0__ACCAMBACCPRO_2,
                    TABLE0_OUTER.TABLE0__ACCSSOACCPRO_2,
                    TABLE0_OUTER.TABLE0__TM05_7,
                    TABLE0_OUTER.TABLE0__ACCSSOOJOACL_1,
                    TABLE0_OUTER.TABLE0__ACCSSOCAUINM_2,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE12_7,
                    TABLE0_OUTER.TABLE0__SG07_7,
                    TABLE0_OUTER.TABLE0__ANTTRABACCTRA_3,
                    TABLE0_OUTER.TABLE0__ANTTRABACCEMP_3,
                    TABLE0_OUTER.TABLE0__APROBANAPLAN_3,
                    TABLE0_OUTER.TABLE0__ARENMDETECTA_1,
                    TABLE0_OUTER.TABLE0__NMAREAAPROHALL_1,
                    TABLE0_OUTER.TABLE0__NMAREADETEC_1,
                    TABLE0_OUTER.TABLE0__TM16_7,
                    TABLE0_OUTER.TABLE0__ACCAMBACC04_7,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE23_7,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE03_7,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE04_7,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE01_7,
                    TABLE0_OUTER.TABLE0__SG01_7,
                    TABLE0_OUTER.TABLE0__CAPTRABACC_1,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE13_7,
                    TABLE0_OUTER.TABLE0__CARNMDETECTA_1,
                    TABLE0_OUTER.TABLE0__NMCARAPROHALL_1,
                    TABLE0_OUTER.TABLE0__CARANALISIS_1,
                    TABLE0_OUTER.TABLE0__CARAPROBANAPLAN_1,
                    TABLE0_OUTER.TABLE0__CARVER_1,
                    TABLE0_OUTER.TABLE0__ACCSSOCARTES01_1,
                    TABLE0_OUTER.TABLE0__ACCSSOCARTES02_1,
                    TABLE0_OUTER.TABLE0__CDAREANALISIS_1,
                    TABLE0_OUTER.TABLE0__CDAREAAPROB_1,
                    TABLE0_OUTER.TABLE0__CDAREADETEC_3,
                    TABLE0_OUTER.TABLE0__CDAREAVERIF_1,
                    TABLE0_OUTER.TABLE0__CDGCOHAL_3,
                    TABLE0_OUTER.TABLE0__CDGERHAL_3,
                    TABLE0_OUTER.TABLE0__CDJEFHAL_3,
                    TABLE0_OUTER.TABLE0__CDSUBHAL_3,
                    TABLE0_OUTER.TABLE0__CDUSUANALISIS_3,
                    TABLE0_OUTER.TABLE0__CDUSUAPROB_3,
                    TABLE0_OUTER.TABLE0__CDUSUAPROHAL_3,
                    TABLE0_OUTER.TABLE0__CDDETECTA_3,
                    TABLE0_OUTER.TABLE0__CDUSUVERIF_3,
                    TABLE0_OUTER.TABLE0__ACCSSOTP01_7,
                    TABLE0_OUTER.TABLE0__CLASIFICACION_1,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE14_7,
                    TABLE0_OUTER.TABLE0__OBSCOM01_2,
                    TABLE0_OUTER.TABLE0__OBSCOM02_2,
                    TABLE0_OUTER.TABLE0__OBSCOM03_2,
                    TABLE0_OUTER.TABLE0__OBSCOM04_2,
                    TABLE0_OUTER.TABLE0__OBSCOM05_2,
                    TABLE0_OUTER.TABLE0__TM06_7,
                    TABLE0_OUTER.TABLE0__OBSAS01_3,
                    TABLE0_OUTER.TABLE0__OBSAS02_3,
                    TABLE0_OUTER.TABLE0__OBSAS03_3,
                    TABLE0_OUTER.TABLE0__OBSAS04_3,
                    TABLE0_OUTER.TABLE0__OBSAS05_3,
                    TABLE0_OUTER.TABLE0__TM19_7,
                    TABLE0_OUTER.TABLE0__TM21_7,
                    TABLE0_OUTER.TABLE0__TM09_7,
                    TABLE0_OUTER.TABLE0__ACCSSOCONANA_2,
                    TABLE0_OUTER.TABLE0__CONDDETEC1_1,
                    TABLE0_OUTER.TABLE0__CONDDETEC2_1,
                    TABLE0_OUTER.TABLE0__CONDDETEC3_1,
                    TABLE0_OUTER.TABLE0__ACCSSOCAUINM02_2,
                    TABLE0_OUTER.TABLE0__ACCSSOTP02_7,
                    TABLE0_OUTER.TABLE0__ACCSSOTP04_7,
                    TABLE0_OUTER.TABLE0__ACCSSOTP19_7,
                    TABLE0_OUTER.TABLE0__ACCAMBIMP03_7,
                    TABLE0_OUTER.TABLE0__ACCAMBIMP04_7,
                    TABLE0_OUTER.TABLE0__ACCAMBIMP02_7,
                    TABLE0_OUTER.TABLE0__ACCAMBACC06_7,
                    TABLE0_OUTER.TABLE0__SG04_7,
                    TABLE0_OUTER.TABLE0__ACCSSONATLES06_7,
                    TABLE0_OUTER.TABLE0__CRITICIDAD_1,
                    TABLE0_OUTER.TABLE0__ACCSSONATLESCUA_1,
                    TABLE0_OUTER.TABLE0__ACCAMBACC08_1,
                    TABLE0_OUTER.TABLE0__ACCAMBIMP07_1,
                    TABLE0_OUTER.TABLE0__ACCAMBPQ12_1,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE15_7,
                    TABLE0_OUTER.TABLE0__ACCSSOOJO01_7,
                    TABLE0_OUTER.TABLE0__ACCSSOCPA03_7,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE16_7,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE20_7,
                    TABLE0_OUTER.TABLE0__ACCSSOACC01_7,
                    TABLE0_OUTER.TABLE0__ACCAMBTP01_7,
                    TABLE0_OUTER.TABLE0__ACCAMBTP03_7,
                    TABLE0_OUTER.TABLE0__ACCSSOTP10_7,
                    TABLE0_OUTER.TABLE0__ACCSSOPQ01_7,
                    TABLE0_OUTER.TABLE0__ACCAMBPQ10_7,
                    TABLE0_OUTER.TABLE0__ACCSSOPQ04_7,
                    TABLE0_OUTER.TABLE0__DESCRIPCION_2,
                    TABLE0_OUTER.TABLE0__ACCSSODES_2,
                    TABLE0_OUTER.TABLE0__ACCAMBDESCRIP_2,
                    TABLE0_OUTER.TABLE0__ACCSSONATLES09_7,
                    TABLE0_OUTER.TABLE0__DOR_1,
                    TABLE0_OUTER.TABLE0__ACCAMBDETALLE_2,
                    TABLE0_OUTER.TABLE0__ACCSSODET_2,
                    TABLE0_OUTER.TABLE0__ACCSSOACC05_7,
                    TABLE0_OUTER.TABLE0__TM07_7,
                    TABLE0_OUTER.TABLE0__ACCSSODIA_1,
                    TABLE0_OUTER.TABLE0__ACCAMBACC05_7,
                    TABLE0_OUTER.TABLE0__ACCSSONATLES11_7,
                    TABLE0_OUTER.TABLE0__EDADTRABACC_3,
                    TABLE0_OUTER.TABLE0__ACCAMBIMP01_7,
                    TABLE0_OUTER.TABLE0__ACCAMBIMP05_7,
                    TABLE0_OUTER.TABLE0__EFICAZ_3,
                    TABLE0_OUTER.TABLE0__SG02_7,
                    TABLE0_OUTER.TABLE0__SG09_7,
                    TABLE0_OUTER.TABLE0__EMP_1,
                    TABLE0_OUTER.TABLE0__EMPAA_7,
                    TABLE0_OUTER.TABLE0__EMPAC_7,
                    TABLE0_OUTER.TABLE0__EMPAM_7,
                    TABLE0_OUTER.TABLE0__EMPRESAPR_1,
                    TABLE0_OUTER.TABLE0__EMPRESAPROHALL_1,
                    TABLE0_OUTER.TABLE0__EMPRESVER_1,
                    TABLE0_OUTER.TABLE0__EMPRESREG_1,
                    TABLE0_OUTER.TABLE0__EMPRESANA_1,
                    TABLE0_OUTER.TABLE0__TM01_7,
                    TABLE0_OUTER.TABLE0__TM22_7,
                    TABLE0_OUTER.TABLE0__ESCANTTRA_3,
                    TABLE0_OUTER.TABLE0__ESCANTEMP_3,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE02_7,
                    TABLE0_OUTER.TABLE0__ESTTRABACC_1,
                    TABLE0_OUTER.TABLE0__TM20_7,
                    TABLE0_OUTER.TABLE0__ACCSSOCAUBAS02_2,
                    TABLE0_OUTER.TABLE0__ACCSSOCAUBAS01_2,
                    TABLE0_OUTER.TABLE0__ACCAMBPQ08_7,
                    TABLE0_OUTER.TABLE0__ACCAMBPQ07_7,
                    TABLE0_OUTER.TABLE0__ACCAMBPQ04_7,
                    TABLE0_OUTER.TABLE0__ACCAMBPQ06_7,
                    TABLE0_OUTER.TABLE0__ACCAMBPQ02_7,
                    TABLE0_OUTER.TABLE0__ACCAMBPQ01_7,
                    TABLE0_OUTER.TABLE0__ACCAMBPQ03_7,
                    TABLE0_OUTER.TABLE0__DTACCSSO_6,
                    TABLE0_OUTER.TABLE0__DTDETECCION_6,
                    TABLE0_OUTER.TABLE0__DTPRIAUX_6,
                    TABLE0_OUTER.TABLE0__ACCSSONATLES05_7,
                    TABLE0_OUTER.TABLE0__ACCAMBTP10_7,
                    TABLE0_OUTER.TABLE0__ACCSSOTP17_7,
                    TABLE0_OUTER.TABLE0__GCORESANA_1,
                    TABLE0_OUTER.TABLE0__GCORESAPR_1,
                    TABLE0_OUTER.TABLE0__NMGCOHAL_1,
                    TABLE0_OUTER.TABLE0__GCORESAPROHAL_1,
                    TABLE0_OUTER.TABLE0__GCORESVER_1,
                    TABLE0_OUTER.TABLE0__GCORESREG_1,
                    TABLE0_OUTER.TABLE0__NMGERHAL_1,
                    TABLE0_OUTER.TABLE0__GERRESAPROHAL_1,
                    TABLE0_OUTER.TABLE0__GERRESANA_1,
                    TABLE0_OUTER.TABLE0__GERRESAPR_1,
                    TABLE0_OUTER.TABLE0__GERRESREG_1,
                    TABLE0_OUTER.TABLE0__GERRESVER_1,
                    TABLE0_OUTER.TABLE0__GRUREG_1,
                    TABLE0_OUTER.TABLE0__NMGRUAPROHALL_1,
                    TABLE0_OUTER.TABLE0__ACCSSONATLES01_7,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE17_7,
                    TABLE0_OUTER.TABLE0__HRACCSSO_5,
                    TABLE0_OUTER.TABLE0__HRINGTRAB_5,
                    TABLE0_OUTER.TABLE0__HRPRIAUX_5,
                    TABLE0_OUTER.TABLE0__NRHORASTRAB_3,
                    TABLE0_OUTER.TABLE0__ACCSSOATEHOS_7,
                    TABLE0_OUTER.TABLE0__IDAREAANALISIS_1,
                    TABLE0_OUTER.TABLE0__IDAREAAPROB_1,
                    TABLE0_OUTER.TABLE0__IDAREAAPROBHALL_1,
                    TABLE0_OUTER.TABLE0__IDAREADETEC_1,
                    TABLE0_OUTER.TABLE0__AREAIDDETECTA_1,
                    TABLE0_OUTER.TABLE0__IDAREAVERIF_1,
                    TABLE0_OUTER.TABLE0__ACCSSOIDCAR01_1,
                    TABLE0_OUTER.TABLE0__ACCSSOIDCAR02_1,
                    TABLE0_OUTER.TABLE0__ACCSSOIDCAR03_1,
                    TABLE0_OUTER.TABLE0__ACCSSOIDCAR04_1,
                    TABLE0_OUTER.TABLE0__ACCSSOIDCAR05_1,
                    TABLE0_OUTER.TABLE0__ACCSSOIDCAR06_1,
                    TABLE0_OUTER.TABLE0__IDCARDETECTA_1,
                    TABLE0_OUTER.TABLE0__IDCARGOTRABACC_1,
                    TABLE0_OUTER.TABLE0__IDDUENOPROCESO_1,
                    TABLE0_OUTER.TABLE0__IDENCARGADOSGI_1,
                    TABLE0_OUTER.TABLE0__IDGCOHAL_1,
                    TABLE0_OUTER.TABLE0__IDGCORESANA_1,
                    TABLE0_OUTER.TABLE0__IDGCORESAPR_1,
                    TABLE0_OUTER.TABLE0__IDGCORESAPROHAL_1,
                    TABLE0_OUTER.TABLE0__IDGCORESREG_1,
                    TABLE0_OUTER.TABLE0__IDGCORESVER_1,
                    TABLE0_OUTER.TABLE0__IDGERHAL_1,
                    TABLE0_OUTER.TABLE0__IDGERRESANA_1,
                    TABLE0_OUTER.TABLE0__IDGERRESAPR_1,
                    TABLE0_OUTER.TABLE0__IDGERRESAPROHAL_1,
                    TABLE0_OUTER.TABLE0__IDGERRESVER_1,
                    TABLE0_OUTER.TABLE0__IDGERRESREG_1,
                    TABLE0_OUTER.TABLE0__IDGRUANALISIS_1,
                    TABLE0_OUTER.TABLE0__IDGRUAPROBHALL_1,
                    TABLE0_OUTER.TABLE0__IDGRUAPROB_1,
                    TABLE0_OUTER.TABLE0__IDGRUVERIF_1,
                    TABLE0_OUTER.TABLE0__ACCSSOIDINV01_1,
                    TABLE0_OUTER.TABLE0__ACCSSOIDINV02_1,
                    TABLE0_OUTER.TABLE0__ACCSSOIDINV03_1,
                    TABLE0_OUTER.TABLE0__ACCSSOIDINV04_1,
                    TABLE0_OUTER.TABLE0__ACCSSOIDINV05_1,
                    TABLE0_OUTER.TABLE0__ACCSSOIDINV06_1,
                    TABLE0_OUTER.TABLE0__IDJEFHAL_1,
                    TABLE0_OUTER.TABLE0__IDJEFRESANA_1,
                    TABLE0_OUTER.TABLE0__IDJEFRESAPR_1,
                    TABLE0_OUTER.TABLE0__IDJEFRESAPROHAL_1,
                    TABLE0_OUTER.TABLE0__IDSUBRESAPROHAL_1,
                    TABLE0_OUTER.TABLE0__IDJEFRESVER_1,
                    TABLE0_OUTER.TABLE0__IDJEFRESREG_1,
                    TABLE0_OUTER.TABLE0__IDSUBHAL_1,
                    TABLE0_OUTER.TABLE0__IDSUBRESANA_1,
                    TABLE0_OUTER.TABLE0__IDSUBRESAPR_1,
                    TABLE0_OUTER.TABLE0__IDSUBRESVER_1,
                    TABLE0_OUTER.TABLE0__IDSUBRESREG_1,
                    TABLE0_OUTER.TABLE0__IDTRABACC_1,
                    TABLE0_OUTER.TABLE0__ACCSSOIDTRA01_1,
                    TABLE0_OUTER.TABLE0__ACCSSOIDTRA02_1,
                    TABLE0_OUTER.TABLE0__IDUSUANALISIS_1,
                    TABLE0_OUTER.TABLE0__IDUSUAPROB_1,
                    TABLE0_OUTER.TABLE0__IDUSUAPROHAL_1,
                    TABLE0_OUTER.TABLE0__IDDETECTA_1,
                    TABLE0_OUTER.TABLE0__IDUSUVERIF_1,
                    TABLE0_OUTER.TABLE0__IDENTIFICADOR_1,
                    TABLE0_OUTER.TABLE0__SG06_7,
                    TABLE0_OUTER.TABLE0__IMPOMJ_3,
                    TABLE0_OUTER.TABLE0__ACCAMBTP09_7,
                    TABLE0_OUTER.TABLE0__ACCSSOACC02_7,
                    TABLE0_OUTER.TABLE0__TM14_7,
                    TABLE0_OUTER.TABLE0__ACCSSOTP09_7,
                    TABLE0_OUTER.TABLE0__ACCSSOTP16_7,
                    TABLE0_OUTER.TABLE0__ACCSSOTP06_7,
                    TABLE0_OUTER.TABLE0__JEFRESANA_1,
                    TABLE0_OUTER.TABLE0__JEFRESAPR_1,
                    TABLE0_OUTER.TABLE0__JEFRESAPROHAL_1,
                    TABLE0_OUTER.TABLE0__JEFRESVER_1,
                    TABLE0_OUTER.TABLE0__JEFRESREG_1,
                    TABLE0_OUTER.TABLE0__NMJEFHAL_1,
                    TABLE0_OUTER.TABLE0__JORLAB_1,
                    TABLE0_OUTER.TABLE0__ACCSSOCPA04_7,
                    TABLE0_OUTER.TABLE0__JUSAPROBANAPLAN_2,
                    TABLE0_OUTER.TABLE0__JUSAPROBAEFIC_2,
                    TABLE0_OUTER.TABLE0__JUSIMPOMJ_2,
                    TABLE0_OUTER.TABLE0__ACCSSOTP18_7,
                    TABLE0_OUTER.TABLE0__TM15_7,
                    TABLE0_OUTER.TABLE0__ACCAMBACC02_7,
                    TABLE0_OUTER.TABLE0__ACCAMBLUG_3,
                    TABLE0_OUTER.TABLE0__ACCSSONATLES10_7,
                    TABLE0_OUTER.TABLE0__ACCSSONATLES08_7,
                    TABLE0_OUTER.TABLE0__MACRO_1,
                    TABLE0_OUTER.TABLE0__ACCAMBPQ09_7,
                    TABLE0_OUTER.TABLE0__ACCAMBPQ05_7,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE05_7,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE06_7,
                    TABLE0_OUTER.TABLE0__SG05_7,
                    TABLE0_OUTER.TABLE0__ACCSSOMEDTRA_3,
                    TABLE0_OUTER.TABLE0__TM17_7,
                    TABLE0_OUTER.TABLE0__TM10_7,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE18_7,
                    TABLE0_OUTER.TABLE0__ACCSSOATEMUT_7,
                    TABLE0_OUTER.TABLE0__ACCSSOOJONAT_2,
                    TABLE0_OUTER.TABLE0__TM04_7,
                    TABLE0_OUTER.TABLE0__ACCSSOPQ03_7,
                    TABLE0_OUTER.TABLE0__ACCSSOPQ02_7,
                    TABLE0_OUTER.TABLE0__ACCSSOTP13_7,
                    TABLE0_OUTER.TABLE0__ACCSSOTP11_7,
                    TABLE0_OUTER.TABLE0__ACCSSOTP14_7,
                    TABLE0_OUTER.TABLE0__ACCSSOTP20_7,
                    TABLE0_OUTER.TABLE0__ACCSSOTP15_7,
                    TABLE0_OUTER.TABLE0__NMAREAANALISIS_1,
                    TABLE0_OUTER.TABLE0__NMAREAAPROB_1,
                    TABLE0_OUTER.TABLE0__NMAREAVERIF_1,
                    TABLE0_OUTER.TABLE0__ACCSSONMCAR01_1,
                    TABLE0_OUTER.TABLE0__ACCSSONMCAR02_1,
                    TABLE0_OUTER.TABLE0__ACCSSONMCAR03_1,
                    TABLE0_OUTER.TABLE0__ACCSSONMCAR04_1,
                    TABLE0_OUTER.TABLE0__ACCSSONMCAR05_1,
                    TABLE0_OUTER.TABLE0__ACCSSONMCAR06_1,
                    TABLE0_OUTER.TABLE0__NMCARGOTRABACC_1,
                    TABLE0_OUTER.TABLE0__NMDETECTA_1,
                    TABLE0_OUTER.TABLE0__ACCSOONMSUM_1,
                    TABLE0_OUTER.TABLE0__NMDUENOPROCESO_1,
                    TABLE0_OUTER.TABLE0__NMENCARGADOSGI_1,
                    TABLE0_OUTER.TABLE0__NMGRUANALISIS_1,
                    TABLE0_OUTER.TABLE0__NMGRUAPROB_1,
                    TABLE0_OUTER.TABLE0__NMGRUVERIF_1,
                    TABLE0_OUTER.TABLE0__ACCSSONMINV01_1,
                    TABLE0_OUTER.TABLE0__ACCSSONMINV02_1,
                    TABLE0_OUTER.TABLE0__ACCSSONMINV03_1,
                    TABLE0_OUTER.TABLE0__ACCSSONMINV04_1,
                    TABLE0_OUTER.TABLE0__ACCSSONMINV05_1,
                    TABLE0_OUTER.TABLE0__ACCSSONMINV06_1,
                    TABLE0_OUTER.TABLE0__ACCSSONMTES01_1,
                    TABLE0_OUTER.TABLE0__ACCSSONMTES02_1,
                    TABLE0_OUTER.TABLE0__NMTRABACC_1,
                    TABLE0_OUTER.TABLE0__ACCSSONMTRA01_1,
                    TABLE0_OUTER.TABLE0__ACCSSONMTRA02_1,
                    TABLE0_OUTER.TABLE0__NMUSUANALISIS_1,
                    TABLE0_OUTER.TABLE0__NMUSUAPROB_1,
                    TABLE0_OUTER.TABLE0__NMUSUVERIF_1,
                    TABLE0_OUTER.TABLE0__TM03_7,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE24_7,
                    TABLE0_OUTER.TABLE0__TM23_7,
                    TABLE0_OUTER.TABLE0__ORIGEN_1,
                    TABLE0_OUTER.TABLE0__ACCAMBACC07_7,
                    TABLE0_OUTER.TABLE0__ACCSSONMOTRAATE_1,
                    TABLE0_OUTER.TABLE0__ACCSSOOJO03_7,
                    TABLE0_OUTER.TABLE0__ACCAMBPQ11_7,
                    TABLE0_OUTER.TABLE0__ACCSSOATEOTR_7,
                    TABLE0_OUTER.TABLE0__ACCSSONATLES12_7,
                    TABLE0_OUTER.TABLE0__ACCAMBTP11_7,
                    TABLE0_OUTER.TABLE0__ACCAMBIMP06_7,
                    TABLE0_OUTER.TABLE0__ACCAMBTP12_1,
                    TABLE0_OUTER.TABLE0__ACCAMBACC01_7,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE19_7,
                    TABLE0_OUTER.TABLE0__ACCSSONATLES02_7,
                    TABLE0_OUTER.TABLE0__PERUSUREG_1,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE09_7,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE10_7,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE07_7,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE08_7,
                    TABLE0_OUTER.TABLE0__TM18_7,
                    TABLE0_OUTER.TABLE0__TM08_7,
                    TABLE0_OUTER.TABLE0__ACCSSOATEPOS_7,
                    TABLE0_OUTER.TABLE0__ACCAMBTP02_7,
                    TABLE0_OUTER.TABLE0__ACCAMBTP04_7,
                    TABLE0_OUTER.TABLE0__ACCAMBTP07_7,
                    TABLE0_OUTER.TABLE0__ACCAMBTP08_7,
                    TABLE0_OUTER.TABLE0__ACCAMBTP06_7,
                    TABLE0_OUTER.TABLE0__PROCESO_1,
                    TABLE0_OUTER.TABLE0__ACCSSONATLES04_7,
                    TABLE0_OUTER.TABLE0__ACCSSOOJO02_7,
                    TABLE0_OUTER.TABLE0__OBSRAZONESOBS_2,
                    TABLE0_OUTER.TABLE0__ACCSSOTP05_7,
                    TABLE0_OUTER.TABLE0__ACCSSOTP08_7,
                    TABLE0_OUTER.TABLE0__ACCSSOTP07_7,
                    TABLE0_OUTER.TABLE0__RECINTO_1,
                    TABLE0_OUTER.TABLE0__TM12_7,
                    TABLE0_OUTER.TABLE0__ACCSSOREG02_3,
                    TABLE0_OUTER.TABLE0__ACCSSOREG_3,
                    TABLE0_OUTER.TABLE0__ACCSOOREQPRIAUX_3,
                    TABLE0_OUTER.TABLE0__NMUSUAPROHALL_1,
                    TABLE0_OUTER.TABLE0__RESPAPROBANA_2,
                    TABLE0_OUTER.TABLE0__RESPVERIFEFICAC_2,
                    TABLE0_OUTER.TABLE0__TM13_7,
                    TABLE0_OUTER.TABLE0__ACCSSOCPA02_7,
                    TABLE0_OUTER.TABLE0__ACCSSOCPA01_7,
                    TABLE0_OUTER.TABLE0__RIESGOS1_2,
                    TABLE0_OUTER.TABLE0__RIESGOS2_2,
                    TABLE0_OUTER.TABLE0__RIESGOS3_2,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE21_7,
                    TABLE0_OUTER.TABLE0__TM02_7,
                    TABLE0_OUTER.TABLE0__ACCSSORUNTES01_1,
                    TABLE0_OUTER.TABLE0__ACCSSORUNTES02_1,
                    TABLE0_OUTER.TABLE0__RUTTRABACC_1,
                    TABLE0_OUTER.TABLE0__SG08_7,
                    TABLE0_OUTER.TABLE0__SG03_7,
                    TABLE0_OUTER.TABLE0__ACCAMBACC03_7,
                    TABLE0_OUTER.TABLE0__ACCSSOACC03_7,
                    TABLE0_OUTER.TABLE0__SEXOTRABACC_3,
                    TABLE0_OUTER.TABLE0__ACCSSONATLES03_7,
                    TABLE0_OUTER.TABLE0__TM11_7,
                    TABLE0_OUTER.TABLE0__ACCSSOTP03_7,
                    TABLE0_OUTER.TABLE0__ACCSSOACC06_7,
                    TABLE0_OUTER.TABLE0__ACCSSOACC04_7,
                    TABLE0_OUTER.TABLE0__NMSUBHAL_1,
                    TABLE0_OUTER.TABLE0__SUBRESAPROHAL_1,
                    TABLE0_OUTER.TABLE0__SUBRESANA_1,
                    TABLE0_OUTER.TABLE0__SUBRESAPR_1,
                    TABLE0_OUTER.TABLE0__SUBRESVER_1,
                    TABLE0_OUTER.TABLE0__SUBRESREG_1,
                    TABLE0_OUTER.TABLE0__SUBPROCESO_1,
                    TABLE0_OUTER.TABLE0__OBSTAREASOBS_1,
                    TABLE0_OUTER.TABLE0__ACCSSONUMTES01_1,
                    TABLE0_OUTER.TABLE0__ACCSSONUMTES02_1,
                    TABLE0_OUTER.TABLE0__ACCSOOTIPACC_3,
                    TABLE0_OUTER.TABLE0__TIPESTHAL_1,
                    TABLE0_OUTER.TABLE0__TIPESTANA_1,
                    TABLE0_OUTER.TABLE0__TIPESTAPROHAL_1,
                    TABLE0_OUTER.TABLE0__TIPESTAPR_1,
                    TABLE0_OUTER.TABLE0__TIPESTREG_1,
                    TABLE0_OUTER.TABLE0__TIPESTVERIF_1,
                    TABLE0_OUTER.TABLE0__TITULO_1,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE22_7,
                    TABLE0_OUTER.TABLE0__ACCSSOPARAFE11_7,
                    TABLE0_OUTER.TABLE0__ACCSSONATLES07_7,
                    TABLE0_OUTER.TABLE0__ACCSOOTRAS_3,
                    TABLE0_OUTER.TABLE0__ACCSSOTP12_7,
                    TABLE0_OUTER.TABLE0__DTAPROBANA_6,
                    TABLE0_OUTER.TABLE0__DTAPROBHALL_6,
                    TABLE0_OUTER.TABLE0__DTEJECPLAN_6,
                    TABLE0_OUTER.TABLE0__DTANAPLAN_6,
                    TABLE0_OUTER.TABLE0__DTVERIFICACION_6,
                    TABLE0_OUTER.TABLE0__ACCAMBTP05_7,
                    TABLE0_OUTER.TABLE0__ACCAMBZIM_3,
                    TABLE0_OUTER.TABLE0__OBS01_7,
                    TABLE0_OUTER.TABLE0__OBS10_7,
                    TABLE0_OUTER.TABLE0__OBS11_7,
                    TABLE0_OUTER.TABLE0__OBS12_7,
                    TABLE0_OUTER.TABLE0__OBS13_7,
                    TABLE0_OUTER.TABLE0__OBS14_7,
                    TABLE0_OUTER.TABLE0__OBS15_7,
                    TABLE0_OUTER.TABLE0__OBS16_7,
                    TABLE0_OUTER.TABLE0__OBS17_7,
                    TABLE0_OUTER.TABLE0__OBS18_7,
                    TABLE0_OUTER.TABLE0__OBS19_7,
                    TABLE0_OUTER.TABLE0__OBS02_7,
                    TABLE0_OUTER.TABLE0__OBS20_7,
                    TABLE0_OUTER.TABLE0__OBS21_7,
                    TABLE0_OUTER.TABLE0__OBS22_7,
                    TABLE0_OUTER.TABLE0__OBS23_7,
                    TABLE0_OUTER.TABLE0__OBS24_7,
                    TABLE0_OUTER.TABLE0__OBS25_7,
                    TABLE0_OUTER.TABLE0__OBS03_7,
                    TABLE0_OUTER.TABLE0__OBS04_7,
                    TABLE0_OUTER.TABLE0__OBS05_7,
                    TABLE0_OUTER.TABLE0__OBS06_7,
                    TABLE0_OUTER.TABLE0__OBS07_7,
                    TABLE0_OUTER.TABLE0__OBS08_7,
                    TABLE0_OUTER.TABLE0__OBS09_7                  
                FROM
                    WFPROCESS WFP                  
                LEFT OUTER JOIN
                    GNREVISION GNREV                          
                        ON WFP.CDREVISION=GNREV.CDREVISION                  
                LEFT OUTER JOIN
                    ADUSER ADU                          
                        ON ADU.CDUSER=WFP.CDUSERSTART                  
                LEFT OUTER JOIN
                    (
                        SELECT
                            ADEXTERNALUSER.CDEXTERNALUSER,
                            ADCOMPANY.NMCOMPANY,
                            ADEXTERNALUSER.NMUSER                          
                        FROM
                            ADEXTERNALUSER                          
                        INNER JOIN
                            ADCOMPANY                                  
                                ON ADEXTERNALUSER.CDCOMPANY=ADCOMPANY.CDCOMPANY                          
                        ) TBEXT                              
                            ON WFP.CDEXTERNALUSERSTART=TBEXT.CDEXTERNALUSER                      
                    LEFT OUTER JOIN
                        GNREVISIONSTATUS GNRS                              
                            ON WFP.CDSTATUS=GNRS.CDREVISIONSTATUS                      
                    LEFT OUTER JOIN
                        GNEVALRESULTUSED GNRUS                              
                            ON GNRUS.CDEVALRESULTUSED=WFP.CDEVALRSLTPRIORITY                      
                    LEFT OUTER JOIN
                        GNEVALRESULT GNR                              
                            ON GNRUS.CDEVALRESULT=GNR.CDEVALRESULT                      
                    LEFT OUTER JOIN
                        INOCCURRENCE INOCCUR                              
                            ON WFP.IDOBJECT=INOCCUR.IDWORKFLOW                      
                    LEFT OUTER JOIN
                        GNGENTYPE GNT                              
                            ON INOCCUR.CDOCCURRENCETYPE=GNT.CDGENTYPE                      
                    INNER JOIN
                        PMACTREVISION PMACT                              
                            ON (
                                PMACT.CDACTIVITY=WFP.CDPROCESSMODEL                                  
                                AND PMACT.CDREVISION=WFP.CDREVISION                              
                            )                      
                    LEFT JOIN
                        PMPROCESSLANGUAGE PML                              
                            ON (
                                PML.CDPROCESS=PMACT.CDACTIVITY                                  
                                AND PML.CDREVISION=PMACT.CDREVISION                                  
                                AND PML.FGLANGUAGE=3                                  
                                AND PML.FGENABLED=1                              
                            )                      
                    LEFT OUTER JOIN
                        GNSLACONTROL SLACTRL                              
                            ON WFP.CDSLACONTROL=SLACTRL.CDSLACONTROL                      
                    LEFT OUTER JOIN
                        PMACTIVITY PP                              
                            ON PP.CDACTIVITY=WFP.CDPROCESSMODEL                      
                    LEFT OUTER JOIN
                        PMACTTYPE PT                              
                            ON PT.CDACTTYPE=PP.CDACTTYPE                      
                    LEFT OUTER JOIN
                        (
                            SELECT
                                FORMREG.CDASSOC,
                                TABLE0.ACCSSOACCGRA AS TABLE0__ACCSSOACCGRA_3,
                                TABLE0.ACCAMBACCPRO AS TABLE0__ACCAMBACCPRO_2,
                                TABLE0.ACCSSOACCPRO AS TABLE0__ACCSSOACCPRO_2,
                                TABLE0.TM05 AS TABLE0__TM05_7,
                                TABLE0.ACCSSOOJOACL AS TABLE0__ACCSSOOJOACL_1,
                                TABLE0.ACCSSOCAUINM AS TABLE0__ACCSSOCAUINM_2,
                                TABLE0.ACCSSOPARAFE12 AS TABLE0__ACCSSOPARAFE12_7,
                                TABLE0.SG07 AS TABLE0__SG07_7,
                                TABLE0.ANTTRABACCTRA AS TABLE0__ANTTRABACCTRA_3,
                                TABLE0.ANTTRABACCEMP AS TABLE0__ANTTRABACCEMP_3,
                                TABLE0.APROBANAPLAN AS TABLE0__APROBANAPLAN_3,
                                TABLE0.ARENMDETECTA AS TABLE0__ARENMDETECTA_1,
                                TABLE0.NMAREAAPROHALL AS TABLE0__NMAREAAPROHALL_1,
                                TABLE0.NMAREADETEC AS TABLE0__NMAREADETEC_1,
                                TABLE0.TM16 AS TABLE0__TM16_7,
                                TABLE0.ACCAMBACC04 AS TABLE0__ACCAMBACC04_7,
                                TABLE0.ACCSSOPARAFE23 AS TABLE0__ACCSSOPARAFE23_7,
                                TABLE0.ACCSSOPARAFE03 AS TABLE0__ACCSSOPARAFE03_7,
                                TABLE0.ACCSSOPARAFE04 AS TABLE0__ACCSSOPARAFE04_7,
                                TABLE0.ACCSSOPARAFE01 AS TABLE0__ACCSSOPARAFE01_7,
                                TABLE0.SG01 AS TABLE0__SG01_7,
                                TABLE0.CAPTRABACC AS TABLE0__CAPTRABACC_1,
                                TABLE0.ACCSSOPARAFE13 AS TABLE0__ACCSSOPARAFE13_7,
                                TABLE0.CARNMDETECTA AS TABLE0__CARNMDETECTA_1,
                                TABLE0.NMCARAPROHALL AS TABLE0__NMCARAPROHALL_1,
                                TABLE0.CARANALISIS AS TABLE0__CARANALISIS_1,
                                TABLE0.CARAPROBANAPLAN AS TABLE0__CARAPROBANAPLAN_1,
                                TABLE0.CARVER AS TABLE0__CARVER_1,
                                TABLE0.ACCSSOCARTES01 AS TABLE0__ACCSSOCARTES01_1,
                                TABLE0.ACCSSOCARTES02 AS TABLE0__ACCSSOCARTES02_1,
                                TABLE0.CDAREANALISIS AS TABLE0__CDAREANALISIS_1,
                                TABLE0.CDAREAAPROB AS TABLE0__CDAREAAPROB_1,
                                TABLE0.CDAREADETEC AS TABLE0__CDAREADETEC_3,
                                TABLE0.CDAREAVERIF AS TABLE0__CDAREAVERIF_1,
                                TABLE0.CDGCOHAL AS TABLE0__CDGCOHAL_3,
                                TABLE0.CDGERHAL AS TABLE0__CDGERHAL_3,
                                TABLE0.CDJEFHAL AS TABLE0__CDJEFHAL_3,
                                TABLE0.CDSUBHAL AS TABLE0__CDSUBHAL_3,
                                TABLE0.CDUSUANALISIS AS TABLE0__CDUSUANALISIS_3,
                                TABLE0.CDUSUAPROB AS TABLE0__CDUSUAPROB_3,
                                TABLE0.CDUSUAPROHAL AS TABLE0__CDUSUAPROHAL_3,
                                TABLE0.CDDETECTA AS TABLE0__CDDETECTA_3,
                                TABLE0.CDUSUVERIF AS TABLE0__CDUSUVERIF_3,
                                TABLE0.ACCSSOTP01 AS TABLE0__ACCSSOTP01_7,
                                TABLE0.CLASIFICACION AS TABLE0__CLASIFICACION_1,
                                TABLE0.ACCSSOPARAFE14 AS TABLE0__ACCSSOPARAFE14_7,
                                TABLE0.OBSCOM01 AS TABLE0__OBSCOM01_2,
                                TABLE0.OBSCOM02 AS TABLE0__OBSCOM02_2,
                                TABLE0.OBSCOM03 AS TABLE0__OBSCOM03_2,
                                TABLE0.OBSCOM04 AS TABLE0__OBSCOM04_2,
                                TABLE0.OBSCOM05 AS TABLE0__OBSCOM05_2,
                                TABLE0.TM06 AS TABLE0__TM06_7,
                                TABLE0.OBSAS01 AS TABLE0__OBSAS01_3,
                                TABLE0.OBSAS02 AS TABLE0__OBSAS02_3,
                                TABLE0.OBSAS03 AS TABLE0__OBSAS03_3,
                                TABLE0.OBSAS04 AS TABLE0__OBSAS04_3,
                                TABLE0.OBSAS05 AS TABLE0__OBSAS05_3,
                                TABLE0.TM19 AS TABLE0__TM19_7,
                                TABLE0.TM21 AS TABLE0__TM21_7,
                                TABLE0.TM09 AS TABLE0__TM09_7,
                                TABLE0.ACCSSOCONANA AS TABLE0__ACCSSOCONANA_2,
                                TABLE0.CONDDETEC1 AS TABLE0__CONDDETEC1_1,
                                TABLE0.CONDDETEC2 AS TABLE0__CONDDETEC2_1,
                                TABLE0.CONDDETEC3 AS TABLE0__CONDDETEC3_1,
                                TABLE0.ACCSSOCAUINM02 AS TABLE0__ACCSSOCAUINM02_2,
                                TABLE0.ACCSSOTP02 AS TABLE0__ACCSSOTP02_7,
                                TABLE0.ACCSSOTP04 AS TABLE0__ACCSSOTP04_7,
                                TABLE0.ACCSSOTP19 AS TABLE0__ACCSSOTP19_7,
                                TABLE0.ACCAMBIMP03 AS TABLE0__ACCAMBIMP03_7,
                                TABLE0.ACCAMBIMP04 AS TABLE0__ACCAMBIMP04_7,
                                TABLE0.ACCAMBIMP02 AS TABLE0__ACCAMBIMP02_7,
                                TABLE0.ACCAMBACC06 AS TABLE0__ACCAMBACC06_7,
                                TABLE0.SG04 AS TABLE0__SG04_7,
                                TABLE0.ACCSSONATLES06 AS TABLE0__ACCSSONATLES06_7,
                                TABLE0.CRITICIDAD AS TABLE0__CRITICIDAD_1,
                                TABLE0.ACCSSONATLESCUA AS TABLE0__ACCSSONATLESCUA_1,
                                TABLE0.ACCAMBACC08 AS TABLE0__ACCAMBACC08_1,
                                TABLE0.ACCAMBIMP07 AS TABLE0__ACCAMBIMP07_1,
                                TABLE0.ACCAMBPQ12 AS TABLE0__ACCAMBPQ12_1,
                                TABLE0.ACCSSOPARAFE15 AS TABLE0__ACCSSOPARAFE15_7,
                                TABLE0.ACCSSOOJO01 AS TABLE0__ACCSSOOJO01_7,
                                TABLE0.ACCSSOCPA03 AS TABLE0__ACCSSOCPA03_7,
                                TABLE0.ACCSSOPARAFE16 AS TABLE0__ACCSSOPARAFE16_7,
                                TABLE0.ACCSSOPARAFE20 AS TABLE0__ACCSSOPARAFE20_7,
                                TABLE0.ACCSSOACC01 AS TABLE0__ACCSSOACC01_7,
                                TABLE0.ACCAMBTP01 AS TABLE0__ACCAMBTP01_7,
                                TABLE0.ACCAMBTP03 AS TABLE0__ACCAMBTP03_7,
                                TABLE0.ACCSSOTP10 AS TABLE0__ACCSSOTP10_7,
                                TABLE0.ACCSSOPQ01 AS TABLE0__ACCSSOPQ01_7,
                                TABLE0.ACCAMBPQ10 AS TABLE0__ACCAMBPQ10_7,
                                TABLE0.ACCSSOPQ04 AS TABLE0__ACCSSOPQ04_7,
                                TABLE0.DESCRIPCION AS TABLE0__DESCRIPCION_2,
                                TABLE0.ACCSSODES AS TABLE0__ACCSSODES_2,
                                TABLE0.ACCAMBDESCRIP AS TABLE0__ACCAMBDESCRIP_2,
                                TABLE0.ACCSSONATLES09 AS TABLE0__ACCSSONATLES09_7,
                                TABLE0.DOR AS TABLE0__DOR_1,
                                TABLE0.ACCAMBDETALLE AS TABLE0__ACCAMBDETALLE_2,
                                TABLE0.ACCSSODET AS TABLE0__ACCSSODET_2,
                                TABLE0.ACCSSOACC05 AS TABLE0__ACCSSOACC05_7,
                                TABLE0.TM07 AS TABLE0__TM07_7,
                                TABLE0.ACCSSODIA AS TABLE0__ACCSSODIA_1,
                                TABLE0.ACCAMBACC05 AS TABLE0__ACCAMBACC05_7,
                                TABLE0.ACCSSONATLES11 AS TABLE0__ACCSSONATLES11_7,
                                TABLE0.EDADTRABACC AS TABLE0__EDADTRABACC_3,
                                TABLE0.ACCAMBIMP01 AS TABLE0__ACCAMBIMP01_7,
                                TABLE0.ACCAMBIMP05 AS TABLE0__ACCAMBIMP05_7,
                                TABLE0.EFICAZ AS TABLE0__EFICAZ_3,
                                TABLE0.SG02 AS TABLE0__SG02_7,
                                TABLE0.EMP AS TABLE0__EMP_1,
                                TABLE0.EMPAA AS TABLE0__EMPAA_7,
                                TABLE0.EMPAC AS TABLE0__EMPAC_7,
                                TABLE0.EMPAM AS TABLE0__EMPAM_7,
                                TABLE0.EMPRESAPR AS TABLE0__EMPRESAPR_1,
                                TABLE0.EMPRESAPROHALL AS TABLE0__EMPRESAPROHALL_1,
                                TABLE0.EMPRESVER AS TABLE0__EMPRESVER_1,
                                TABLE0.EMPRESREG AS TABLE0__EMPRESREG_1,
                                TABLE0.EMPRESANA AS TABLE0__EMPRESANA_1,
                                TABLE0.TM01 AS TABLE0__TM01_7,
                                TABLE0.TM22 AS TABLE0__TM22_7,
                                TABLE0.ESCANTTRA AS TABLE0__ESCANTTRA_3,
                                TABLE0.ESCANTEMP AS TABLE0__ESCANTEMP_3,
                                TABLE0.ACCSSOPARAFE02 AS TABLE0__ACCSSOPARAFE02_7,
                                TABLE0.ESTTRABACC AS TABLE0__ESTTRABACC_1,
                                TABLE0.TM20 AS TABLE0__TM20_7,
                                TABLE0.ACCSSOCAUBAS02 AS TABLE0__ACCSSOCAUBAS02_2,
                                TABLE0.ACCSSOCAUBAS01 AS TABLE0__ACCSSOCAUBAS01_2,
                                TABLE0.ACCAMBPQ08 AS TABLE0__ACCAMBPQ08_7,
                                TABLE0.ACCAMBPQ07 AS TABLE0__ACCAMBPQ07_7,
                                TABLE0.ACCAMBPQ04 AS TABLE0__ACCAMBPQ04_7,
                                TABLE0.ACCAMBPQ06 AS TABLE0__ACCAMBPQ06_7,
                                TABLE0.ACCAMBPQ02 AS TABLE0__ACCAMBPQ02_7,
                                TABLE0.ACCAMBPQ01 AS TABLE0__ACCAMBPQ01_7,
                                TABLE0.ACCAMBPQ03 AS TABLE0__ACCAMBPQ03_7,
                                TABLE0.DTACCSSO AS TABLE0__DTACCSSO_6,
                                TABLE0.DTDETECCION AS TABLE0__DTDETECCION_6,
                                TABLE0.DTPRIAUX AS TABLE0__DTPRIAUX_6,
                                TABLE0.ACCSSONATLES05 AS TABLE0__ACCSSONATLES05_7,
                                TABLE0.ACCAMBTP10 AS TABLE0__ACCAMBTP10_7,
                                TABLE0.ACCSSOTP17 AS TABLE0__ACCSSOTP17_7,
                                TABLE0.GCORESANA AS TABLE0__GCORESANA_1,
                                TABLE0.GCORESAPR AS TABLE0__GCORESAPR_1,
                                TABLE0.NMGCOHAL AS TABLE0__NMGCOHAL_1,
                                TABLE0.GCORESAPROHAL AS TABLE0__GCORESAPROHAL_1,
                                TABLE0.GCORESVER AS TABLE0__GCORESVER_1,
                                TABLE0.GCORESREG AS TABLE0__GCORESREG_1,
                                TABLE0.NMGERHAL AS TABLE0__NMGERHAL_1,
                                TABLE0.GERRESAPROHAL AS TABLE0__GERRESAPROHAL_1,
                                TABLE0.GERRESANA AS TABLE0__GERRESANA_1,
                                TABLE0.GERRESAPR AS TABLE0__GERRESAPR_1,
                                TABLE0.GERRESREG AS TABLE0__GERRESREG_1,
                                TABLE0.GERRESVER AS TABLE0__GERRESVER_1,
                                TABLE0.GRUREG AS TABLE0__GRUREG_1,
                                TABLE0.NMGRUAPROHALL AS TABLE0__NMGRUAPROHALL_1,
                                TABLE0.ACCSSONATLES01 AS TABLE0__ACCSSONATLES01_7,
                                TABLE0.ACCSSOPARAFE17 AS TABLE0__ACCSSOPARAFE17_7,
                                TABLE0.HRACCSSO AS TABLE0__HRACCSSO_5,
                                TABLE0.HRINGTRAB AS TABLE0__HRINGTRAB_5,
                                TABLE0.HRPRIAUX AS TABLE0__HRPRIAUX_5,
                                TABLE0.NRHORASTRAB AS TABLE0__NRHORASTRAB_3,
                                TABLE0.ACCSSOATEHOS AS TABLE0__ACCSSOATEHOS_7,
                                TABLE0.IDAREAANALISIS AS TABLE0__IDAREAANALISIS_1,
                                TABLE0.IDAREAAPROB AS TABLE0__IDAREAAPROB_1,
                                TABLE0.IDAREAAPROBHALL AS TABLE0__IDAREAAPROBHALL_1,
                                TABLE0.IDAREADETEC AS TABLE0__IDAREADETEC_1,
                                TABLE0.AREAIDDETECTA AS TABLE0__AREAIDDETECTA_1,
                                TABLE0.IDAREAVERIF AS TABLE0__IDAREAVERIF_1,
                                TABLE0.ACCSSOIDCAR01 AS TABLE0__ACCSSOIDCAR01_1,
                                TABLE0.ACCSSOIDCAR02 AS TABLE0__ACCSSOIDCAR02_1,
                                TABLE0.ACCSSOIDCAR03 AS TABLE0__ACCSSOIDCAR03_1,
                                TABLE0.ACCSSOIDCAR04 AS TABLE0__ACCSSOIDCAR04_1,
                                TABLE0.ACCSSOIDCAR05 AS TABLE0__ACCSSOIDCAR05_1,
                                TABLE0.ACCSSOIDCAR06 AS TABLE0__ACCSSOIDCAR06_1,
                                TABLE0.IDCARDETECTA AS TABLE0__IDCARDETECTA_1,
                                TABLE0.IDCARGOTRABACC AS TABLE0__IDCARGOTRABACC_1,
                                TABLE0.IDDUENOPROCESO AS TABLE0__IDDUENOPROCESO_1,
                                TABLE0.IDENCARGADOSGI AS TABLE0__IDENCARGADOSGI_1,
                                TABLE0.IDGCOHAL AS TABLE0__IDGCOHAL_1,
                                TABLE0.IDGCORESANA AS TABLE0__IDGCORESANA_1,
                                TABLE0.IDGCORESAPR AS TABLE0__IDGCORESAPR_1,
                                TABLE0.IDGCORESAPROHAL AS TABLE0__IDGCORESAPROHAL_1,
                                TABLE0.IDGCORESREG AS TABLE0__IDGCORESREG_1,
                                TABLE0.IDGCORESVER AS TABLE0__IDGCORESVER_1,
                                TABLE0.IDGERHAL AS TABLE0__IDGERHAL_1,
                                TABLE0.IDGERRESANA AS TABLE0__IDGERRESANA_1,
                                TABLE0.IDGERRESAPR AS TABLE0__IDGERRESAPR_1,
                                TABLE0.IDGERRESAPROHAL AS TABLE0__IDGERRESAPROHAL_1,
                                TABLE0.IDGERRESVER AS TABLE0__IDGERRESVER_1,
                                TABLE0.IDGERRESREG AS TABLE0__IDGERRESREG_1,
                                TABLE0.IDGRUANALISIS AS TABLE0__IDGRUANALISIS_1,
                                TABLE0.IDGRUAPROBHALL AS TABLE0__IDGRUAPROBHALL_1,
                                TABLE0.IDGRUAPROB AS TABLE0__IDGRUAPROB_1,
                                TABLE0.IDGRUVERIF AS TABLE0__IDGRUVERIF_1,
                                TABLE0.ACCSSOIDINV01 AS TABLE0__ACCSSOIDINV01_1,
                                TABLE0.ACCSSOIDINV02 AS TABLE0__ACCSSOIDINV02_1,
                                TABLE0.ACCSSOIDINV03 AS TABLE0__ACCSSOIDINV03_1,
                                TABLE0.ACCSSOIDINV04 AS TABLE0__ACCSSOIDINV04_1,
                                TABLE0.ACCSSOIDINV05 AS TABLE0__ACCSSOIDINV05_1,
                                TABLE0.ACCSSOIDINV06 AS TABLE0__ACCSSOIDINV06_1,
                                TABLE0.IDJEFHAL AS TABLE0__IDJEFHAL_1,
                                TABLE0.IDJEFRESANA AS TABLE0__IDJEFRESANA_1,
                                TABLE0.IDJEFRESAPR AS TABLE0__IDJEFRESAPR_1,
                                TABLE0.IDJEFRESAPROHAL AS TABLE0__IDJEFRESAPROHAL_1,
                                TABLE0.IDSUBRESAPROHAL AS TABLE0__IDSUBRESAPROHAL_1,
                                TABLE0.IDJEFRESVER AS TABLE0__IDJEFRESVER_1,
                                TABLE0.IDJEFRESREG AS TABLE0__IDJEFRESREG_1,
                                TABLE0.IDSUBHAL AS TABLE0__IDSUBHAL_1,
                                TABLE0.IDSUBRESANA AS TABLE0__IDSUBRESANA_1,
                                TABLE0.IDSUBRESAPR AS TABLE0__IDSUBRESAPR_1,
                                TABLE0.IDSUBRESVER AS TABLE0__IDSUBRESVER_1,
                                TABLE0.IDSUBRESREG AS TABLE0__IDSUBRESREG_1,
                                TABLE0.IDTRABACC AS TABLE0__IDTRABACC_1,
                                TABLE0.ACCSSOIDTRA01 AS TABLE0__ACCSSOIDTRA01_1,
                                TABLE0.ACCSSOIDTRA02 AS TABLE0__ACCSSOIDTRA02_1,
                                TABLE0.IDUSUANALISIS AS TABLE0__IDUSUANALISIS_1,
                                TABLE0.IDUSUAPROB AS TABLE0__IDUSUAPROB_1,
                                TABLE0.IDUSUAPROHAL AS TABLE0__IDUSUAPROHAL_1,
                                TABLE0.IDDETECTA AS TABLE0__IDDETECTA_1,
                                TABLE0.IDUSUVERIF AS TABLE0__IDUSUVERIF_1,
                                TABLE0.IDENTIFICADOR AS TABLE0__IDENTIFICADOR_1,
                                TABLE0.SG06 AS TABLE0__SG06_7,
                                TABLE0.IMPOMJ AS TABLE0__IMPOMJ_3,
                                TABLE0.ACCAMBTP09 AS TABLE0__ACCAMBTP09_7,
                                TABLE0.ACCSSOACC02 AS TABLE0__ACCSSOACC02_7,
                                TABLE0.TM14 AS TABLE0__TM14_7,
                                TABLE0.ACCSSOTP09 AS TABLE0__ACCSSOTP09_7,
                                TABLE0.ACCSSOTP16 AS TABLE0__ACCSSOTP16_7,
                                TABLE0.ACCSSOTP06 AS TABLE0__ACCSSOTP06_7,
                                TABLE0.JEFRESANA AS TABLE0__JEFRESANA_1,
                                TABLE0.JEFRESAPR AS TABLE0__JEFRESAPR_1,
                                TABLE0.JEFRESAPROHAL AS TABLE0__JEFRESAPROHAL_1,
                                TABLE0.JEFRESVER AS TABLE0__JEFRESVER_1,
                                TABLE0.JEFRESREG AS TABLE0__JEFRESREG_1,
                                TABLE0.NMJEFHAL AS TABLE0__NMJEFHAL_1,
                                TABLE0.JORLAB AS TABLE0__JORLAB_1,
                                TABLE0.ACCSSOCPA04 AS TABLE0__ACCSSOCPA04_7,
                                TABLE0.JUSAPROBANAPLAN AS TABLE0__JUSAPROBANAPLAN_2,
                                TABLE0.JUSAPROBAEFIC AS TABLE0__JUSAPROBAEFIC_2,
                                TABLE0.JUSIMPOMJ AS TABLE0__JUSIMPOMJ_2,
                                TABLE0.ACCSSOTP18 AS TABLE0__ACCSSOTP18_7,
                                TABLE0.TM15 AS TABLE0__TM15_7,
                                TABLE0.ACCAMBACC02 AS TABLE0__ACCAMBACC02_7,
                                TABLE0.ACCAMBLUG AS TABLE0__ACCAMBLUG_3,
                                TABLE0.ACCSSONATLES10 AS TABLE0__ACCSSONATLES10_7,
                                TABLE0.ACCSSONATLES08 AS TABLE0__ACCSSONATLES08_7,
                                TABLE0.MACRO AS TABLE0__MACRO_1,
                                TABLE0.ACCAMBPQ09 AS TABLE0__ACCAMBPQ09_7,
                                TABLE0.ACCAMBPQ05 AS TABLE0__ACCAMBPQ05_7,
                                TABLE0.ACCSSOPARAFE05 AS TABLE0__ACCSSOPARAFE05_7,
                                TABLE0.ACCSSOPARAFE06 AS TABLE0__ACCSSOPARAFE06_7,
                                TABLE0.SG05 AS TABLE0__SG05_7,
                                TABLE0.ACCSSOMEDTRA AS TABLE0__ACCSSOMEDTRA_3,
                                TABLE0.TM17 AS TABLE0__TM17_7,
                                TABLE0.TM10 AS TABLE0__TM10_7,
                                TABLE0.ACCSSOPARAFE18 AS TABLE0__ACCSSOPARAFE18_7,
                                TABLE0.ACCSSOATEMUT AS TABLE0__ACCSSOATEMUT_7,
                                TABLE0.ACCSSOOJONAT AS TABLE0__ACCSSOOJONAT_2,
                                TABLE0.TM04 AS TABLE0__TM04_7,
                                TABLE0.ACCSSOPQ03 AS TABLE0__ACCSSOPQ03_7,
                                TABLE0.ACCSSOPQ02 AS TABLE0__ACCSSOPQ02_7,
                                TABLE0.ACCSSOTP13 AS TABLE0__ACCSSOTP13_7,
                                TABLE0.ACCSSOTP11 AS TABLE0__ACCSSOTP11_7,
                                TABLE0.ACCSSOTP14 AS TABLE0__ACCSSOTP14_7,
                                TABLE0.ACCSSOTP20 AS TABLE0__ACCSSOTP20_7,
                                TABLE0.ACCSSOTP15 AS TABLE0__ACCSSOTP15_7,
                                TABLE0.NMAREAANALISIS AS TABLE0__NMAREAANALISIS_1,
                                TABLE0.NMAREAAPROB AS TABLE0__NMAREAAPROB_1,
                                TABLE0.NMAREAVERIF AS TABLE0__NMAREAVERIF_1,
                                TABLE0.ACCSSONMCAR01 AS TABLE0__ACCSSONMCAR01_1,
                                TABLE0.ACCSSONMCAR02 AS TABLE0__ACCSSONMCAR02_1,
                                TABLE0.ACCSSONMCAR03 AS TABLE0__ACCSSONMCAR03_1,
                                TABLE0.ACCSSONMCAR04 AS TABLE0__ACCSSONMCAR04_1,
                                TABLE0.ACCSSONMCAR05 AS TABLE0__ACCSSONMCAR05_1,
                                TABLE0.ACCSSONMCAR06 AS TABLE0__ACCSSONMCAR06_1,
                                TABLE0.NMCARGOTRABACC AS TABLE0__NMCARGOTRABACC_1,
                                TABLE0.NMDETECTA AS TABLE0__NMDETECTA_1,
                                TABLE0.ACCSOONMSUM AS TABLE0__ACCSOONMSUM_1,
                                TABLE0.NMDUENOPROCESO AS TABLE0__NMDUENOPROCESO_1,
                                TABLE0.NMENCARGADOSGI AS TABLE0__NMENCARGADOSGI_1,
                                TABLE0.NMGRUANALISIS AS TABLE0__NMGRUANALISIS_1,
                                TABLE0.NMGRUAPROB AS TABLE0__NMGRUAPROB_1,
                                TABLE0.NMGRUVERIF AS TABLE0__NMGRUVERIF_1,
                                TABLE0.ACCSSONMINV01 AS TABLE0__ACCSSONMINV01_1,
                                TABLE0.ACCSSONMINV02 AS TABLE0__ACCSSONMINV02_1,
                                TABLE0.ACCSSONMINV03 AS TABLE0__ACCSSONMINV03_1,
                                TABLE0.ACCSSONMINV04 AS TABLE0__ACCSSONMINV04_1,
                                TABLE0.ACCSSONMINV05 AS TABLE0__ACCSSONMINV05_1,
                                TABLE0.ACCSSONMINV06 AS TABLE0__ACCSSONMINV06_1,
                                TABLE0.ACCSSONMTES01 AS TABLE0__ACCSSONMTES01_1,
                                TABLE0.ACCSSONMTES02 AS TABLE0__ACCSSONMTES02_1,
                                TABLE0.NMTRABACC AS TABLE0__NMTRABACC_1,
                                TABLE0.ACCSSONMTRA01 AS TABLE0__ACCSSONMTRA01_1,
                                TABLE0.ACCSSONMTRA02 AS TABLE0__ACCSSONMTRA02_1,
                                TABLE0.NMUSUANALISIS AS TABLE0__NMUSUANALISIS_1,
                                TABLE0.NMUSUAPROB AS TABLE0__NMUSUAPROB_1,
                                TABLE0.NMUSUVERIF AS TABLE0__NMUSUVERIF_1,
                                TABLE0.TM03 AS TABLE0__TM03_7,
                                TABLE0.ACCSSOPARAFE24 AS TABLE0__ACCSSOPARAFE24_7,
                                TABLE0.TM23 AS TABLE0__TM23_7,
                                TABLE0.ORIGEN AS TABLE0__ORIGEN_1,
                                TABLE0.ACCAMBACC07 AS TABLE0__ACCAMBACC07_7,
                                TABLE0.ACCSSONMOTRAATE AS TABLE0__ACCSSONMOTRAATE_1,
                                TABLE0.ACCSSOOJO03 AS TABLE0__ACCSSOOJO03_7,
                                TABLE0.ACCAMBPQ11 AS TABLE0__ACCAMBPQ11_7,
                                TABLE0.ACCSSOATEOTR AS TABLE0__ACCSSOATEOTR_7,
                                TABLE0.ACCSSONATLES12 AS TABLE0__ACCSSONATLES12_7,
                                TABLE0.ACCAMBTP11 AS TABLE0__ACCAMBTP11_7,
                                TABLE0.ACCAMBIMP06 AS TABLE0__ACCAMBIMP06_7,
                                TABLE0.ACCAMBTP12 AS TABLE0__ACCAMBTP12_1,
                                TABLE0.ACCAMBACC01 AS TABLE0__ACCAMBACC01_7,
                                TABLE0.ACCSSOPARAFE19 AS TABLE0__ACCSSOPARAFE19_7,
                                TABLE0.ACCSSONATLES02 AS TABLE0__ACCSSONATLES02_7,
                                TABLE0.PERUSUREG AS TABLE0__PERUSUREG_1,
                                TABLE0.ACCSSOPARAFE09 AS TABLE0__ACCSSOPARAFE09_7,
                                TABLE0.ACCSSOPARAFE10 AS TABLE0__ACCSSOPARAFE10_7,
                                TABLE0.ACCSSOPARAFE07 AS TABLE0__ACCSSOPARAFE07_7,
                                TABLE0.ACCSSOPARAFE08 AS TABLE0__ACCSSOPARAFE08_7,
                                TABLE0.TM18 AS TABLE0__TM18_7,
                                TABLE0.TM08 AS TABLE0__TM08_7,
                                TABLE0.ACCSSOATEPOS AS TABLE0__ACCSSOATEPOS_7,
                                TABLE0.ACCAMBTP02 AS TABLE0__ACCAMBTP02_7,
                                TABLE0.ACCAMBTP04 AS TABLE0__ACCAMBTP04_7,
                                TABLE0.ACCAMBTP07 AS TABLE0__ACCAMBTP07_7,
                                TABLE0.ACCAMBTP08 AS TABLE0__ACCAMBTP08_7,
                                TABLE0.ACCAMBTP06 AS TABLE0__ACCAMBTP06_7,
                                TABLE0.PROCESO AS TABLE0__PROCESO_1,
                                TABLE0.ACCSSONATLES04 AS TABLE0__ACCSSONATLES04_7,
                                TABLE0.ACCSSOOJO02 AS TABLE0__ACCSSOOJO02_7,
                                TABLE0.OBSRAZONESOBS AS TABLE0__OBSRAZONESOBS_2,
                                TABLE0.ACCSSOTP05 AS TABLE0__ACCSSOTP05_7,
                                TABLE0.ACCSSOTP08 AS TABLE0__ACCSSOTP08_7,
                                TABLE0.ACCSSOTP07 AS TABLE0__ACCSSOTP07_7,
                                TABLE0.RECINTO AS TABLE0__RECINTO_1,
                                TABLE0.TM12 AS TABLE0__TM12_7,
                                TABLE0.ACCSSOREG02 AS TABLE0__ACCSSOREG02_3,
                                TABLE0.ACCSSOREG AS TABLE0__ACCSSOREG_3,
                                TABLE0.ACCSOOREQPRIAUX AS TABLE0__ACCSOOREQPRIAUX_3,
                                TABLE0.NMUSUAPROHALL AS TABLE0__NMUSUAPROHALL_1,
                                TABLE0.RESPAPROBANA AS TABLE0__RESPAPROBANA_2,
                                TABLE0.RESPVERIFEFICAC AS TABLE0__RESPVERIFEFICAC_2,
                                TABLE0.TM13 AS TABLE0__TM13_7,
                                TABLE0.ACCSSOCPA02 AS TABLE0__ACCSSOCPA02_7,
                                TABLE0.ACCSSOCPA01 AS TABLE0__ACCSSOCPA01_7,
                                TABLE0.RIESGOS1 AS TABLE0__RIESGOS1_2,
                                TABLE0.RIESGOS2 AS TABLE0__RIESGOS2_2,
                                TABLE0.RIESGOS3 AS TABLE0__RIESGOS3_2,
                                TABLE0.ACCSSOPARAFE21 AS TABLE0__ACCSSOPARAFE21_7,
                                TABLE0.TM02 AS TABLE0__TM02_7,
                                TABLE0.ACCSSORUNTES01 AS TABLE0__ACCSSORUNTES01_1,
                                TABLE0.ACCSSORUNTES02 AS TABLE0__ACCSSORUNTES02_1,
                                TABLE0.RUTTRABACC AS TABLE0__RUTTRABACC_1,
                                TABLE0.SG08 AS TABLE0__SG08_7,
                                TABLE0.SG09 AS TABLE0__SG09_7,
                                TABLE0.SG03 AS TABLE0__SG03_7,
                                TABLE0.ACCAMBACC03 AS TABLE0__ACCAMBACC03_7,
                                TABLE0.ACCSSOACC03 AS TABLE0__ACCSSOACC03_7,
                                TABLE0.SEXOTRABACC AS TABLE0__SEXOTRABACC_3,
                                TABLE0.ACCSSONATLES03 AS TABLE0__ACCSSONATLES03_7,
                                TABLE0.TM11 AS TABLE0__TM11_7,
                                TABLE0.ACCSSOTP03 AS TABLE0__ACCSSOTP03_7,
                                TABLE0.ACCSSOACC06 AS TABLE0__ACCSSOACC06_7,
                                TABLE0.ACCSSOACC04 AS TABLE0__ACCSSOACC04_7,
                                TABLE0.NMSUBHAL AS TABLE0__NMSUBHAL_1,
                                TABLE0.SUBRESAPROHAL AS TABLE0__SUBRESAPROHAL_1,
                                TABLE0.SUBRESANA AS TABLE0__SUBRESANA_1,
                                TABLE0.SUBRESAPR AS TABLE0__SUBRESAPR_1,
                                TABLE0.SUBRESVER AS TABLE0__SUBRESVER_1,
                                TABLE0.SUBRESREG AS TABLE0__SUBRESREG_1,
                                TABLE0.SUBPROCESO AS TABLE0__SUBPROCESO_1,
                                TABLE0.OBSTAREASOBS AS TABLE0__OBSTAREASOBS_1,
                                TABLE0.ACCSSONUMTES01 AS TABLE0__ACCSSONUMTES01_1,
                                TABLE0.ACCSSONUMTES02 AS TABLE0__ACCSSONUMTES02_1,
                                TABLE0.ACCSOOTIPACC AS TABLE0__ACCSOOTIPACC_3,
                                TABLE0.TIPESTHAL AS TABLE0__TIPESTHAL_1,
                                TABLE0.TIPESTANA AS TABLE0__TIPESTANA_1,
                                TABLE0.TIPESTAPROHAL AS TABLE0__TIPESTAPROHAL_1,
                                TABLE0.TIPESTAPR AS TABLE0__TIPESTAPR_1,
                                TABLE0.TIPESTREG AS TABLE0__TIPESTREG_1,
                                TABLE0.TIPESTVERIF AS TABLE0__TIPESTVERIF_1,
                                TABLE0.TITULO AS TABLE0__TITULO_1,
                                TABLE0.ACCSSOPARAFE22 AS TABLE0__ACCSSOPARAFE22_7,
                                TABLE0.ACCSSOPARAFE11 AS TABLE0__ACCSSOPARAFE11_7,
                                TABLE0.ACCSSONATLES07 AS TABLE0__ACCSSONATLES07_7,
                                TABLE0.ACCSOOTRAS AS TABLE0__ACCSOOTRAS_3,
                                TABLE0.ACCSSOTP12 AS TABLE0__ACCSSOTP12_7,
                                TABLE0.DTAPROBANA AS TABLE0__DTAPROBANA_6,
                                TABLE0.DTAPROBHALL AS TABLE0__DTAPROBHALL_6,
                                TABLE0.DTEJECPLAN AS TABLE0__DTEJECPLAN_6,
                                TABLE0.DTANAPLAN AS TABLE0__DTANAPLAN_6,
                                TABLE0.DTVERIFICACION AS TABLE0__DTVERIFICACION_6,
                                TABLE0.ACCAMBTP05 AS TABLE0__ACCAMBTP05_7,
                                TABLE0.ACCAMBZIM AS TABLE0__ACCAMBZIM_3,
                                TABLE0.OBS01 AS TABLE0__OBS01_7,
                                TABLE0.OBS10 AS TABLE0__OBS10_7,
                                TABLE0.OBS11 AS TABLE0__OBS11_7,
                                TABLE0.OBS12 AS TABLE0__OBS12_7,
                                TABLE0.OBS13 AS TABLE0__OBS13_7,
                                TABLE0.OBS14 AS TABLE0__OBS14_7,
                                TABLE0.OBS15 AS TABLE0__OBS15_7,
                                TABLE0.OBS16 AS TABLE0__OBS16_7,
                                TABLE0.OBS17 AS TABLE0__OBS17_7,
                                TABLE0.OBS18 AS TABLE0__OBS18_7,
                                TABLE0.OBS19 AS TABLE0__OBS19_7,
                                TABLE0.OBS02 AS TABLE0__OBS02_7,
                                TABLE0.OBS20 AS TABLE0__OBS20_7,
                                TABLE0.OBS21 AS TABLE0__OBS21_7,
                                TABLE0.OBS22 AS TABLE0__OBS22_7,
                                TABLE0.OBS23 AS TABLE0__OBS23_7,
                                TABLE0.OBS24 AS TABLE0__OBS24_7,
                                TABLE0.OBS25 AS TABLE0__OBS25_7,
                                TABLE0.OBS03 AS TABLE0__OBS03_7,
                                TABLE0.OBS04 AS TABLE0__OBS04_7,
                                TABLE0.OBS05 AS TABLE0__OBS05_7,
                                TABLE0.OBS06 AS TABLE0__OBS06_7,
                                TABLE0.OBS07 AS TABLE0__OBS07_7,
                                TABLE0.OBS08 AS TABLE0__OBS08_7,
                                TABLE0.OBS09 AS TABLE0__OBS09_7                              
                            FROM
                                GNASSOCFORMREG FORMREG                              
                            INNER JOIN
                                DYNGHA TABLE0                                      
                                    ON (
                                        FORMREG.OIDENTITYREG=TABLE0.OID                                      
                                    )                              
                            ) TABLE0_OUTER                                  
                                ON (
                                    TABLE0_OUTER.CDASSOC=WFP.CDASSOCREG                                  
                                )                               
                        WHERE
                            WFP.FGSTATUS <= 5          
                            AND WFP.CDPRODAUTOMATION=202          
                            AND INOCCUR.FGOCCURRENCETYPE=2          
                            AND GNT.CDGENTYPE IN (
                                23          
                            )  
                        ) TEMPTB0  
                    ) TEMPTB1 
                ) HALLAZGOS  
            LEFT JOIN
                (
                    SELECT
                        IDPROCESS TPIDPROCESS,
                        NMPROCESS TPNMPROCESS,
                        NMPROCESSMODEL TPNMPROCESSMODEL,
                        NMSTRUCT TPNMSTRUCT,
                        CDUSER TPCDUSER,
                        NMUSER TPNMUSER,
                        TYPEUSEREXEC TPTYPEUSEREXEC,
                        NMROLE TPNMROLE,
                        NMEXECUTEDACTION TPNMEXECUTEDACTION,
                        DTEXECUTION TPDTEXECUTION,
                        NMDEADLINE TPNMDEADLINE,
                        WF_QTHOURS TPWF_QTHOURS,
                        IDSITUATION TPIDSITUATION,
                        NMEVALRESULT TPNMEVALRESULT,
                        NMUSERSTART TPNMUSERSTART,
                        TYPEUSER TPTYPEUSER,
                        DTDEADLINEFIELD TPDTDEADLINEFIELD,
                        DURATION_WF_DAY TPDURATION_WF_DAY,
                        DURATION_WF_HOUR TPDURATION_WF_HOUR,
                        DURATION_WF_MIN TPDURATION_WF_MIN,
                        NMOCCURRENCETYPE TPNMOCCURRENCETYPE  
                    FROM
                        (SELECT
                            IDPROCESS,
                            NMPROCESS,
                            NMPROCESSMODEL,
                            NMSTRUCT,
                            CDUSER,
                            NMUSER,
                            TYPEUSEREXEC,
                            NMROLE,
                            NMEXECUTEDACTION,
                            DTEXECUTION,
                            NMDEADLINE,
                            WF_QTHOURS,
                            IDSITUATION,
                            NMEVALRESULT,
                            NMUSERSTART,
                            TYPEUSER,
                            DTDEADLINEFIELD,
                            DURATION_WF_DAY,
                            DURATION_WF_HOUR,
                            DURATION_WF_MIN,
                            NMOCCURRENCETYPE  
                        FROM
                            (SELECT
                                1 AS QTD,
                                WFP.IDPROCESS,
                                WFP.NMPROCESS,
                                COALESCE(PML.NMPROCESS,
                                WFP.NMPROCESSMODEL) AS NMPROCESSMODEL,
                                COALESCE(ADU.NMUSER,
                                TBEXT.NMUSER) AS NMUSERSTART,
                                CASE      
                                    WHEN WFP.CDEXTERNALUSERSTART IS NOT NULL THEN '#{303826}'      
                                    WHEN WFP.CDUSERSTART IS NOT NULL THEN '#{305843}'      
                                    ELSE NULL  
                                END AS TYPEUSER,
                                GNT.NMGENTYPE AS NMOCCURRENCETYPE,
                                GNR.NMEVALRESULT,
                                COALESCE(PMEL.NMELEMENT,
                                WFS.NMSTRUCT) AS NMSTRUCT,
                                WFA.NMROLE,
                                CASE      
                                    WHEN WFS.FGSTATUS=1 THEN '#{114667}'      
                                    WHEN WFS.FGSTATUS=2 THEN '#{114666}'      
                                    WHEN WFS.FGSTATUS=3 THEN '#{107507}'      
                                    WHEN WFS.FGSTATUS=4 THEN '#{108240}'      
                                    WHEN WFS.FGSTATUS=5 THEN '#{102338}'      
                                    WHEN WFS.FGSTATUS=6 THEN '#{206049}'      
                                    WHEN WFS.FGSTATUS=7 THEN '#{214511}'  
                                END AS IDSITUATION,
                                WFS.DTEXECUTION,
                                WFA.CDUSER,
                                CASE      
                                    WHEN WFA.FGACTAUTOEXECUTED=1 THEN '#{102949}'      
                                    ELSE WFA.NMUSER  
                                END AS NMUSER,
                                CASE      
                                    WHEN WFA.CDEXTERNALUSER IS NOT NULL THEN '#{303826}'      
                                    WHEN WFA.CDUSER IS NOT NULL      
                                    AND WFA.NMUSER IS NOT NULL THEN '#{305843}'      
                                    ELSE NULL  
                                END AS TYPEUSEREXEC,
                                COALESCE(PMAL.NMACTION,
                                WFA.NMEXECUTEDACTION) AS NMEXECUTEDACTION,
                                CASE      
                                    WHEN WFS.FGCONCLUDEDSTATUS IS NOT NULL THEN (CASE          
                                        WHEN WFS.FGCONCLUDEDSTATUS=1 THEN '#{100900}'          
                                        WHEN WFS.FGCONCLUDEDSTATUS=2 THEN '#{100899}'      
                                    END)      
                                    ELSE (CASE          
                                        WHEN WFS.FGTYPE=1 THEN (CASE              
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
                                                STRUCT.IDOBJECT=WFS.IDOBJECT) > (CAST(<!%TODAY%> AS DATE) + COALESCE((SELECT
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
                                                        CONOTIFICATION TBL))), 0)))              
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
                                                STRUCT.IDOBJECT=WFS.IDOBJECT) IS NULL)) THEN '#{100900}'              
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
                                                STRUCT.IDOBJECT=WFS.IDOBJECT)=CAST(<!%TODAY%> AS DATE)              
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
                                                STRUCT.IDOBJECT=WFS.IDOBJECT) >= 609)              
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
                                                STRUCT.IDOBJECT=WFS.IDOBJECT) > CAST(<!%TODAY%> AS DATE))) THEN '#{201639}'              
                                            ELSE '#{100899}'          
                                        END)          
                                        ELSE (CASE              
                                            WHEN (( WFS.DTESTIMATEDFINISH > (CAST(<!%TODAY%> AS DATE) + COALESCE((SELECT
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
                                                        CONOTIFICATION TBL))), 0)))              
                                            OR (WFS.DTESTIMATEDFINISH IS NULL)) THEN '#{100900}'              
                                            WHEN (( WFS.DTESTIMATEDFINISH=CAST(<!%TODAY%> AS DATE)              
                                            AND WFS.NRTIMEESTFINISH >= 609)              
                                            OR (WFS.DTESTIMATEDFINISH > CAST(<!%TODAY%> AS DATE))) THEN '#{201639}'              
                                            ELSE '#{100899}'          
                                        END)      
                                    END)  
                                END AS NMDEADLINE,
                                TO_CHAR(CAST(TRUNC(WFA.QTHOURS/1440) AS VARCHAR(20)),
                                '0000') || LOWER(' #{108037} ') || TO_CHAR(CAST(TRUNC((WFA.QTHOURS-(TRUNC(WFA.QTHOURS/1440)*1440))/60) AS VARCHAR(20)),
                                '00') || LOWER(' #{101173} ') || TO_CHAR(CAST(WFA.QTHOURS-(TRUNC(WFA.QTHOURS/60)*60) AS VARCHAR(20)) ,
                                '00') || LOWER(' #{101181} ') AS WF_QTHOURS,
                                CASE      
                                    WHEN WFS.FGSTATUS IN (2,
                                    4,
                                    5,
                                    6,
                                    7) THEN (TRUNC((TO_DATE(to_char(sysdate,
                                    'YYYY-MM-DD HH24:MI:SS'),
                                    'YYYY-MM-DD HH24:MI:SS') - TO_DATE(TO_CHAR(WFS.DTENABLED,
                                    'YYYY-MM-DD') || ' ' || WFS.TMENABLED,
                                    'YYYY-MM-DD HH24:MI:SS')),
                                    2))      
                                    WHEN WFS.FGSTATUS=3 THEN (TRUNC((TO_DATE(TO_CHAR(WFS.DTEXECUTION,
                                    'YYYY-MM-DD') || ' ' || WFS.TMEXECUTION,
                                    'YYYY-MM-DD HH24:MI:SS') - TO_DATE(TO_CHAR(WFS.DTENABLED,
                                    'YYYY-MM-DD') || ' ' || WFS.TMENABLED,
                                    'YYYY-MM-DD HH24:MI:SS')),
                                    2))  
                                END AS DURATION_WF_DAY,
                                CASE      
                                    WHEN WFS.FGSTATUS IN (2,
                                    4,
                                    5,
                                    6,
                                    7) THEN (TRUNC((TO_DATE(to_char(sysdate,
                                    'YYYY-MM-DD HH24:MI:SS'),
                                    'YYYY-MM-DD HH24:MI:SS') - TO_DATE(TO_CHAR(WFS.DTENABLED,
                                    'YYYY-MM-DD') || ' ' || WFS.TMENABLED,
                                    'YYYY-MM-DD HH24:MI:SS'))*24,
                                    2))      
                                    WHEN WFS.FGSTATUS=3 THEN (TRUNC((TO_DATE(TO_CHAR(WFS.DTEXECUTION,
                                    'YYYY-MM-DD') || ' ' || WFS.TMEXECUTION,
                                    'YYYY-MM-DD HH24:MI:SS') - TO_DATE(TO_CHAR(WFS.DTENABLED,
                                    'YYYY-MM-DD') || ' ' || WFS.TMENABLED,
                                    'YYYY-MM-DD HH24:MI:SS'))*24,
                                    2))  
                                END AS DURATION_WF_HOUR,
                                CASE      
                                    WHEN WFS.FGSTATUS IN (2,
                                    4,
                                    5,
                                    6,
                                    7) THEN (FLOOR((TO_DATE(to_char(sysdate,
                                    'YYYY-MM-DD HH24:MI:SS'),
                                    'YYYY-MM-DD HH24:MI:SS') - TO_DATE(TO_CHAR(WFS.DTENABLED,
                                    'YYYY-MM-DD') || ' ' || WFS.TMENABLED,
                                    'YYYY-MM-DD HH24:MI:SS'))*24*60))      
                                    WHEN WFS.FGSTATUS=3 THEN (FLOOR((TO_DATE(TO_CHAR(WFS.DTEXECUTION,
                                    'YYYY-MM-DD') || ' ' || WFS.TMEXECUTION,
                                    'YYYY-MM-DD HH24:MI:SS') - TO_DATE(TO_CHAR(WFS.DTENABLED,
                                    'YYYY-MM-DD') || ' ' || WFS.TMENABLED,
                                    'YYYY-MM-DD HH24:MI:SS'))*24*60))  
                                END AS DURATION_WF_MIN,
                                CASE      
                                    WHEN WFS.FGSTATUS IN (2,
                                    4,
                                    5,
                                    6,
                                    7) THEN (TRUNC(SYSDATE - TO_DATE(TO_CHAR(WFS.DTENABLED,
                                    'dd/mm/yy') ||' '||WFS.TMENABLED,
                                    'dd/mm/yy hh24:mi:ss')) || LOWER(' #{108037} ') || TRUNC(((SYSDATE - TO_DATE(TO_CHAR(WFS.DTENABLED,
                                    'dd/mm/yy') ||' '||WFS.TMENABLED,
                                    'dd/mm/yy hh24:mi:ss')) - TRUNC((SYSDATE - TO_DATE(TO_CHAR(WFS.DTENABLED,
                                    'dd/mm/yy') ||' '||WFS.TMENABLED,
                                    'dd/mm/yy hh24:mi:ss'))))*24) || LOWER(' #{101173} ') || TRUNC(((((SYSDATE - TO_DATE(TO_CHAR(WFS.DTENABLED,
                                    'dd/mm/yy') ||' '||WFS.TMENABLED,
                                    'dd/mm/yy hh24:mi:ss')) - TRUNC((SYSDATE - TO_DATE(TO_CHAR(WFS.DTENABLED,
                                    'dd/mm/yy') ||' '||WFS.TMENABLED,
                                    'dd/mm/yy hh24:mi:ss'))))*24) - TRUNC(((SYSDATE - TO_DATE(TO_CHAR(WFS.DTENABLED,
                                    'dd/mm/yy') ||' '||WFS.TMENABLED,
                                    'dd/mm/yy hh24:mi:ss')) - TRUNC((SYSDATE - TO_DATE(TO_CHAR(WFS.DTENABLED,
                                    'dd/mm/yy') ||' '||WFS.TMENABLED,
                                    'DD/MM/YY HH24:MI:SS'))))*24))*60) || LOWER(' #{101181} '))      
                                    WHEN WFS.FGSTATUS=3 THEN (TRUNC(TO_DATE(TO_CHAR(WFS.DTEXECUTION,
                                    'dd/mm/yy') ||' '||WFS.TMEXECUTION,
                                    'dd/mm/yy hh24:mi:ss') - TO_DATE(TO_CHAR(WFS.DTENABLED,
                                    'dd/mm/yy') ||' '||WFS.TMENABLED,
                                    'dd/mm/yy hh24:mi:ss')) || LOWER(' #{108037} ') || TRUNC(((TO_DATE(TO_CHAR(WFS.DTEXECUTION,
                                    'dd/mm/yy') ||' '||WFS.TMEXECUTION,
                                    'dd/mm/yy hh24:mi:ss') - TO_DATE(TO_CHAR(WFS.DTENABLED,
                                    'dd/mm/yy') ||' '||WFS.TMENABLED,
                                    'dd/mm/yy hh24:mi:ss')) - TRUNC((TO_DATE(TO_CHAR(WFS.DTEXECUTION,
                                    'dd/mm/yy') ||' '||WFS.TMEXECUTION,
                                    'dd/mm/yy hh24:mi:ss') - TO_DATE(TO_CHAR(WFS.DTENABLED,
                                    'dd/mm/yy') ||' '||WFS.TMENABLED,
                                    'dd/mm/yy hh24:mi:ss'))))*24)|| LOWER(' #{101173} ') || TRUNC(((((TO_DATE(TO_CHAR(WFS.DTEXECUTION,
                                    'dd/mm/yy') ||' '||WFS.TMEXECUTION,
                                    'dd/mm/yy hh24:mi:ss') - TO_DATE(TO_CHAR(WFS.DTENABLED,
                                    'dd/mm/yy') ||' '||WFS.TMENABLED,
                                    'dd/mm/yy hh24:mi:ss')) - TRUNC((TO_DATE(TO_CHAR(WFS.DTEXECUTION,
                                    'dd/mm/yy') ||' '||WFS.TMEXECUTION,
                                    'dd/mm/yy hh24:mi:ss') - TO_DATE(TO_CHAR(WFS.DTENABLED,
                                    'dd/mm/yy') ||' '||WFS.TMENABLED,
                                    'dd/mm/yy hh24:mi:ss'))))*24) - TRUNC(((TO_DATE(TO_CHAR(WFS.DTEXECUTION,
                                    'dd/mm/yy') ||' '||WFS.TMEXECUTION,
                                    'dd/mm/yy hh24:mi:ss') - TO_DATE(TO_CHAR(WFS.DTENABLED,
                                    'dd/mm/yy') ||' '||WFS.TMENABLED,
                                    'dd/mm/yy hh24:mi:ss')) - TRUNC((TO_DATE(TO_CHAR(WFS.DTEXECUTION,
                                    'dd/mm/yy') ||' '||WFS.TMEXECUTION,
                                    'dd/mm/yy hh24:mi:ss') - TO_DATE(TO_CHAR(WFS.DTENABLED,
                                    'dd/mm/yy') ||' '||WFS.TMENABLED,
                                    'dd/mm/yy hh24:mi:ss'))))*24))*60) || LOWER(' #{101181} '))  
                                END AS DURATION_WF,
                                WFS.DTESTIMATEDFINISH + WFS.NRTIMEESTFINISH/1440 AS DTDEADLINEFIELD  
                            FROM
                                WFPROCESS WFP  
                            INNER JOIN
                                WFSTRUCT WFS      
                                    ON WFS.IDPROCESS=WFP.IDOBJECT  
                            INNER JOIN
                                WFACTIVITY WFA      
                                    ON WFS.IDOBJECT=WFA.IDOBJECT  
                            LEFT OUTER JOIN
                                PMACTIVITY PP      
                                    ON PP.CDACTIVITY=WFP.CDPROCESSMODEL  
                            LEFT OUTER JOIN
                                PMACTTYPE PT      
                                    ON PT.CDACTTYPE=PP.CDACTTYPE  
                            LEFT OUTER JOIN
                                GNREVISION GNREV      
                                    ON WFP.CDREVISION=GNREV.CDREVISION  
                            LEFT OUTER JOIN
                                ADUSER ADU      
                                    ON ADU.CDUSER=WFP.CDUSERSTART  
                            LEFT OUTER JOIN
                                (
                                    SELECT
                                        ADEXTERNALUSER.CDEXTERNALUSER,
                                        ADCOMPANY.NMCOMPANY,
                                        ADEXTERNALUSER.NMUSER      
                                    FROM
                                        ADEXTERNALUSER      
                                    INNER JOIN
                                        ADCOMPANY              
                                            ON ADEXTERNALUSER.CDCOMPANY=ADCOMPANY.CDCOMPANY      
                                    ) TBEXT          
                                        ON WFP.CDEXTERNALUSERSTART=TBEXT.CDEXTERNALUSER  
                                LEFT OUTER JOIN
                                    GNSLACONTROL SLACTRL          
                                        ON WFP.CDSLACONTROL=SLACTRL.CDSLACONTROL  
                                LEFT OUTER JOIN
                                    GNREVISIONSTATUS GNRS          
                                        ON WFP.CDSTATUS=GNRS.CDREVISIONSTATUS  
                                LEFT OUTER JOIN
                                    GNEVALRESULTUSED GNRUS          
                                        ON GNRUS.CDEVALRESULTUSED=WFP.CDEVALRSLTPRIORITY  
                                LEFT OUTER JOIN
                                    GNEVALRESULT GNR          
                                        ON GNRUS.CDEVALRESULT=GNR.CDEVALRESULT  
                                LEFT OUTER JOIN
                                    INOCCURRENCE INOCCUR          
                                        ON WFP.IDOBJECT=INOCCUR.IDWORKFLOW  
                                LEFT OUTER JOIN
                                    GNGENTYPE GNT          
                                        ON INOCCUR.CDOCCURRENCETYPE=GNT.CDGENTYPE  
                                INNER JOIN
                                    PMACTREVISION PMACT          
                                        ON (
                                            PMACT.CDACTIVITY=WFP.CDPROCESSMODEL              
                                            AND PMACT.CDREVISION=WFP.CDREVISION          
                                        )  
                                LEFT JOIN
                                    PMPROCESSLANGUAGE PML          
                                        ON (
                                            PML.CDPROCESS=PMACT.CDACTIVITY              
                                            AND PML.CDREVISION=PMACT.CDREVISION              
                                            AND PML.FGLANGUAGE=3              
                                            AND PML.FGENABLED=1          
                                        )  
                                LEFT OUTER JOIN
                                    PMELEMENTLANGUAGE PMEL          
                                        ON (
                                            PMEL.CDSTRUCT=WFS.CDSTRUCTMODEL              
                                            AND PMEL.FGLANGUAGE=3              
                                            AND EXISTS (
                                                SELECT
                                                    1              
                                            FROM
                                                PMPROCESSLANGUAGE PML              
                                            WHERE
                                                PMACT.CDACTIVITY=PML.CDPROCESS                  
                                                AND PMACT.CDREVISION=PML.CDREVISION                  
                                                AND PML.FGLANGUAGE=3                  
                                                AND PML.FGENABLED=1          
                                        )      
                                    )  
                                LEFT OUTER JOIN
                                    WFSTRUCTACTION WFSA          
                                        ON WFSA.IDOBJECT=WFA.IDEXECUTEDACTION  
                                LEFT OUTER JOIN
                                    PMACTIONLANGUAGE PMAL          
                                        ON (
                                            PMAL.CDSTRUCT=WFSA.CDSTRUCTMODEL              
                                            AND PMAL.CDACTION=WFSA.CDACTIONMODEL              
                                            AND PMAL.FGLANGUAGE=3              
                                            AND EXISTS (
                                                SELECT
                                                    1              
                                            FROM
                                                PMPROCESSLANGUAGE PML              
                                            WHERE
                                                PMACT.CDACTIVITY=PML.CDPROCESS                  
                                                AND PMACT.CDREVISION=PML.CDREVISION                  
                                                AND PML.FGLANGUAGE=3                  
                                                AND PML.FGENABLED=1          
                                        )      
                                    )   
                                WHERE
                                    WFP.FGSTATUS <= 5  
                                    AND WFP.CDPRODAUTOMATION=202  
                                    AND WFP.FGSTATUS <= 5  
                                    AND INOCCUR.FGOCCURRENCETYPE=2  
                                    AND GNT.CDGENTYPE IN (
                                        23  
                                    )  
                                    AND WFS.FGSTATUS = 2  
                                ) TEMPTB0  
                            ) TEMPTB1 
                        ) TAREAS  
                            ON TAREAS.TPIDPROCESS = HALLAZGOS.IDPROCESS