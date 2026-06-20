USE FatecLog;

DROP PROCEDURE IF EXISTS sp_carga_full_dw;

DELIMITER $$

CREATE PROCEDURE sp_carga_full_dw()
BEGIN

    SET SESSION cte_max_recursion_depth = 100000;

    SET FOREIGN_KEY_CHECKS = 0;
    TRUNCATE TABLE fato_entrega;
    TRUNCATE TABLE dim_cliente;
    TRUNCATE TABLE dim_centro;
    TRUNCATE TABLE dim_veiculo;
    TRUNCATE TABLE dim_motorista;
    TRUNCATE TABLE dim_rota;
    TRUNCATE TABLE dim_tipo_carga;
    TRUNCATE TABLE dim_data;
    SET FOREIGN_KEY_CHECKS = 1;

    INSERT INTO dim_cliente (
        id_cliente_origem, nome_cliente, segmento,
        cidade, estado, regiao, data_cadastro
    )
    SELECT
        c.id_cliente, c.nome_cliente, c.segmento, c.cidade, c.estado,
        CASE
            WHEN c.estado IN ('SP','RJ','MG','ES') THEN 'Sudeste'
            WHEN c.estado IN ('RS','SC','PR')      THEN 'Sul'
            WHEN c.estado IN ('BA','PE','CE','MA','PB','RN','AL','SE','PI') THEN 'Nordeste'
            WHEN c.estado IN ('GO','MT','MS','DF') THEN 'Centro-Oeste'
            WHEN c.estado IN ('AM','PA','AC','RO','RR','AP','TO') THEN 'Norte'
            ELSE 'Outros'
        END,
        c.data_cadastro
    FROM Cliente c;

    INSERT INTO dim_centro (
        id_centro_origem, nome_centro, cidade, estado, regiao,
        capacidade_operacional, faixa_capacidade
    )
    SELECT
        cd.id_centro, cd.nome_centro, cd.cidade, cd.estado,
        CASE
            WHEN cd.estado IN ('SP','RJ','MG','ES') THEN 'Sudeste'
            WHEN cd.estado IN ('RS','SC','PR')      THEN 'Sul'
            WHEN cd.estado IN ('BA','PE','CE','MA','PB','RN','AL','SE','PI') THEN 'Nordeste'
            WHEN cd.estado IN ('GO','MT','MS','DF') THEN 'Centro-Oeste'
            WHEN cd.estado IN ('AM','PA','AC','RO','RR','AP','TO') THEN 'Norte'
            ELSE 'Outros'
        END,
        cd.capacidade_operacional,
        CASE
            WHEN cd.capacidade_operacional < 6000 THEN 'Pequeno'
            WHEN cd.capacidade_operacional < 9000 THEN 'Medio'
            ELSE 'Grande'
        END
    FROM CentroDistribuicao cd;

    INSERT INTO dim_veiculo (
        id_veiculo_origem, placa, modelo, tipo_veiculo,
        capacidade_kg, faixa_capacidade,
        ano_fabricacao, idade_veiculo_anos, status_veiculo
    )
    SELECT
        v.id_veiculo, v.placa, v.modelo, v.tipo_veiculo, v.capacidade_kg,
        CASE
            WHEN v.capacidade_kg < 2000  THEN 'Leve'
            WHEN v.capacidade_kg < 12000 THEN 'Medio'
            ELSE 'Pesado'
        END,
        v.ano_fabricacao,
        (YEAR(CURDATE()) - v.ano_fabricacao),
        v.status_veiculo
    FROM Veiculo v;

    INSERT INTO dim_motorista (
        id_motorista_origem, nome_motorista, cidade, estado, regiao,
        categoria_cnh, data_admissao, tempo_casa_anos
    )
    SELECT
        m.id_motorista, m.nome_motorista, m.cidade, m.estado,
        CASE
            WHEN m.estado IN ('SP','RJ','MG','ES') THEN 'Sudeste'
            WHEN m.estado IN ('RS','SC','PR')      THEN 'Sul'
            WHEN m.estado IN ('BA','PE','CE','MA','PB','RN','AL','SE','PI') THEN 'Nordeste'
            WHEN m.estado IN ('GO','MT','MS','DF') THEN 'Centro-Oeste'
            WHEN m.estado IN ('AM','PA','AC','RO','RR','AP','TO') THEN 'Norte'
            ELSE 'Outros'
        END,
        m.categoria_cnh, m.data_admissao,
        TIMESTAMPDIFF(YEAR, m.data_admissao, CURDATE())
    FROM Motorista m;

    INSERT INTO dim_rota (
        id_rota_origem, cidade_origem, estado_origem,
        cidade_destino, estado_destino, distancia_km, faixa_distancia
    )
    SELECT
        r.id_rota, r.cidade_origem, r.estado_origem,
        r.cidade_destino, r.estado_destino, r.distancia_km,
        CASE
            WHEN r.distancia_km <= 150 THEN 'Curta (ate 150km)'
            WHEN r.distancia_km <= 350 THEN 'Media (151-350km)'
            WHEN r.distancia_km <= 600 THEN 'Longa (351-600km)'
            ELSE 'Muito Longa (600km+)'
        END
    FROM Rota r;

    INSERT INTO dim_tipo_carga (
        id_tipo_carga_origem, descricao_tipo_carga, categoria
    )
    SELECT t.id_tipo_carga, t.descricao_tipo_carga, t.categoria
    FROM TipoCarga t;

    INSERT INTO dim_data (
        sk_data, data_completa, dia, nome_dia_semana, semana_ano,
        mes, nome_mes, trimestre, semestre, ano, fim_semana
    )
    WITH RECURSIVE datas AS (
        SELECT DATE('2022-01-01') AS data_ref
        UNION ALL
        SELECT data_ref + INTERVAL 1 DAY FROM datas
        WHERE data_ref < '2030-12-31'
    )
    SELECT
        CAST(DATE_FORMAT(data_ref, '%Y%m%d') AS UNSIGNED),
        data_ref,
        DAY(data_ref),
        DAYNAME(data_ref),
        WEEK(data_ref),
        MONTH(data_ref),
        MONTHNAME(data_ref),
        QUARTER(data_ref),
        CASE WHEN MONTH(data_ref) <= 6 THEN 1 ELSE 2 END,
        YEAR(data_ref),
        CASE WHEN DAYOFWEEK(data_ref) IN (1, 7) THEN 1 ELSE 0 END
    FROM datas;

    INSERT INTO fato_entrega (
        sk_cliente, sk_centro, sk_veiculo, sk_motorista,
        sk_rota, sk_tipo_carga, sk_data,
        id_entrega_origem, status_entrega,
        peso_carga_kg, quantidade_volumes,
        valor_frete, custo_combustivel, margem_frete, custo_por_km,
        tempo_estimado_horas, tempo_real_horas, atraso_horas,
        avaria, entrega_no_prazo
    )
    SELECT
        dc.sk_cliente, dce.sk_centro, dv.sk_veiculo, dm.sk_motorista,
        dr.sk_rota, dtc.sk_tipo_carga,
        CAST(DATE_FORMAT(e.data_saida, '%Y%m%d') AS UNSIGNED),
        e.id_entrega, e.status_entrega,
        e.peso_carga_kg, e.quantidade_volumes,
        e.valor_frete, e.custo_combustivel,
        (e.valor_frete - e.custo_combustivel),
        CASE WHEN dr.distancia_km > 0
             THEN e.custo_combustivel / dr.distancia_km ELSE 0 END,
        e.tempo_estimado_horas, e.tempo_real_horas,
        (e.tempo_real_horas - e.tempo_estimado_horas),
        e.avaria, e.entrega_no_prazo
    FROM Entrega e
    INNER JOIN dim_cliente    dc  ON e.cliente_id    = dc.id_cliente_origem
    INNER JOIN dim_centro     dce ON e.centro_id     = dce.id_centro_origem
    INNER JOIN dim_veiculo    dv  ON e.veiculo_id    = dv.id_veiculo_origem
    INNER JOIN dim_motorista  dm  ON e.motorista_id  = dm.id_motorista_origem
    INNER JOIN dim_rota       dr  ON e.rota_id       = dr.id_rota_origem
    INNER JOIN dim_tipo_carga dtc ON e.tipo_carga_id = dtc.id_tipo_carga_origem;

END$$

DELIMITER ;

CALL sp_carga_full_dw();
