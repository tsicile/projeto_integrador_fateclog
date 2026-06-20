USE FatecLog;

CREATE TABLE dim_cliente (
    sk_cliente         INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente_origem  INT NOT NULL,

    nome_cliente       VARCHAR(150),
    segmento           VARCHAR(50),

    cidade             VARCHAR(100),
    estado             CHAR(2),
    regiao             VARCHAR(50),

    data_cadastro      DATE
);

CREATE TABLE dim_centro (
    sk_centro                INT AUTO_INCREMENT PRIMARY KEY,
    id_centro_origem         INT NOT NULL,

    nome_centro              VARCHAR(100),
    cidade                   VARCHAR(100),
    estado                   CHAR(2),
    regiao                   VARCHAR(50),

    capacidade_operacional   INT,
    faixa_capacidade         VARCHAR(50)
);

CREATE TABLE dim_veiculo (
    sk_veiculo          INT AUTO_INCREMENT PRIMARY KEY,
    id_veiculo_origem   INT NOT NULL,

    placa               VARCHAR(10),
    modelo              VARCHAR(100),
    tipo_veiculo        VARCHAR(50),

    capacidade_kg       INT,
    faixa_capacidade    VARCHAR(50),

    ano_fabricacao      INT,
    idade_veiculo_anos  INT,

    status_veiculo      VARCHAR(30)
);

CREATE TABLE dim_motorista (
    sk_motorista         INT AUTO_INCREMENT PRIMARY KEY,
    id_motorista_origem  INT NOT NULL,

    nome_motorista       VARCHAR(150),
    cidade               VARCHAR(100),
    estado               CHAR(2),
    regiao               VARCHAR(50),

    categoria_cnh        CHAR(1),
    data_admissao        DATE,
    tempo_casa_anos      INT
);

CREATE TABLE dim_rota (
    sk_rota          INT AUTO_INCREMENT PRIMARY KEY,
    id_rota_origem   INT NOT NULL,

    cidade_origem    VARCHAR(100),
    estado_origem    CHAR(2),
    cidade_destino   VARCHAR(100),
    estado_destino   CHAR(2),

    distancia_km     INT,
    faixa_distancia  VARCHAR(50)
);

CREATE TABLE dim_tipo_carga (
    sk_tipo_carga         INT AUTO_INCREMENT PRIMARY KEY,
    id_tipo_carga_origem  INT NOT NULL,

    descricao_tipo_carga  VARCHAR(100),
    categoria             VARCHAR(50)
);

CREATE TABLE dim_data (
    sk_data          INT PRIMARY KEY,

    data_completa    DATE,

    dia              INT,
    nome_dia_semana  VARCHAR(30),
    semana_ano       INT,

    mes              INT,
    nome_mes         VARCHAR(30),

    trimestre        INT,
    semestre         INT,
    ano              INT,

    fim_semana       TINYINT(1)
);

CREATE TABLE fato_entrega (
    sk_entrega            BIGINT AUTO_INCREMENT PRIMARY KEY,

    sk_cliente            INT NOT NULL,
    sk_centro             INT NOT NULL,
    sk_veiculo            INT NOT NULL,
    sk_motorista          INT NOT NULL,
    sk_rota               INT NOT NULL,
    sk_tipo_carga         INT NOT NULL,
    sk_data               INT NOT NULL,

    id_entrega_origem     INT NOT NULL,

    status_entrega        VARCHAR(30),

    peso_carga_kg         DECIMAL(10,2),
    quantidade_volumes    INT,

    valor_frete           DECIMAL(10,2),
    custo_combustivel     DECIMAL(10,2),
    margem_frete          DECIMAL(10,2),
    custo_por_km          DECIMAL(10,4),

    tempo_estimado_horas  INT,
    tempo_real_horas      INT,
    atraso_horas          INT,

    avaria                TINYINT(1),
    entrega_no_prazo      TINYINT(1),

    CONSTRAINT fk_fato_cliente
        FOREIGN KEY (sk_cliente)    REFERENCES dim_cliente(sk_cliente),
    CONSTRAINT fk_fato_centro
        FOREIGN KEY (sk_centro)     REFERENCES dim_centro(sk_centro),
    CONSTRAINT fk_fato_veiculo
        FOREIGN KEY (sk_veiculo)    REFERENCES dim_veiculo(sk_veiculo),
    CONSTRAINT fk_fato_motorista
        FOREIGN KEY (sk_motorista)  REFERENCES dim_motorista(sk_motorista),
    CONSTRAINT fk_fato_rota
        FOREIGN KEY (sk_rota)       REFERENCES dim_rota(sk_rota),
    CONSTRAINT fk_fato_tipo_carga
        FOREIGN KEY (sk_tipo_carga) REFERENCES dim_tipo_carga(sk_tipo_carga),
    CONSTRAINT fk_fato_data
        FOREIGN KEY (sk_data)       REFERENCES dim_data(sk_data)
);
