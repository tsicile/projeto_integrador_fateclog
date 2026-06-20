CREATE DATABASE IF NOT EXISTS FatecLog
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;

USE FatecLog;

CREATE TABLE Cliente (
    id_cliente      INT AUTO_INCREMENT PRIMARY KEY,
    nome_cliente    VARCHAR(150) NOT NULL,
    segmento        VARCHAR(50)  NOT NULL,
    cidade          VARCHAR(100) NOT NULL,
    estado          CHAR(2)      NOT NULL,
    data_cadastro   DATE         NOT NULL
);

CREATE TABLE CentroDistribuicao (
    id_centro                INT AUTO_INCREMENT PRIMARY KEY,
    nome_centro              VARCHAR(100) NOT NULL,
    cidade                   VARCHAR(100) NOT NULL,
    estado                   CHAR(2)      NOT NULL,
    capacidade_operacional   INT          NOT NULL
);

CREATE TABLE Veiculo (
    id_veiculo      INT AUTO_INCREMENT PRIMARY KEY,
    placa           VARCHAR(10)  NOT NULL,
    modelo          VARCHAR(100) NOT NULL,
    tipo_veiculo    VARCHAR(50)  NOT NULL,
    capacidade_kg   INT          NOT NULL,
    ano_fabricacao  INT          NOT NULL,
    status_veiculo  VARCHAR(30)  NOT NULL
);

CREATE TABLE Motorista (
    id_motorista    INT AUTO_INCREMENT PRIMARY KEY,
    nome_motorista  VARCHAR(150) NOT NULL,
    cidade          VARCHAR(100) NOT NULL,
    estado          CHAR(2)      NOT NULL,
    data_admissao   DATE         NOT NULL,
    categoria_cnh   CHAR(1)      NOT NULL
);

CREATE TABLE Rota (
    id_rota         INT AUTO_INCREMENT PRIMARY KEY,
    cidade_origem   VARCHAR(100) NOT NULL,
    estado_origem   CHAR(2)      NOT NULL,
    cidade_destino  VARCHAR(100) NOT NULL,
    estado_destino  CHAR(2)      NOT NULL,
    distancia_km    INT          NOT NULL
);

CREATE TABLE TipoCarga (
    id_tipo_carga         INT AUTO_INCREMENT PRIMARY KEY,
    descricao_tipo_carga  VARCHAR(100) NOT NULL,
    categoria             VARCHAR(50)  NOT NULL
);

CREATE TABLE Entrega (
    id_entrega            INT AUTO_INCREMENT PRIMARY KEY,

    cliente_id            INT NOT NULL,
    centro_id             INT NOT NULL,
    veiculo_id            INT NOT NULL,
    motorista_id          INT NOT NULL,
    rota_id               INT NOT NULL,
    tipo_carga_id         INT NOT NULL,

    data_saida            DATE     NOT NULL,
    data_entrega          DATETIME NOT NULL,

    status_entrega        VARCHAR(30) NOT NULL,

    peso_carga_kg         DECIMAL(10,2) NOT NULL,
    valor_frete           DECIMAL(10,2) NOT NULL,
    custo_combustivel     DECIMAL(10,2) NOT NULL,

    tempo_estimado_horas  INT NOT NULL,
    tempo_real_horas      INT NOT NULL,

    quantidade_volumes    INT NOT NULL,

    avaria                TINYINT(1) NOT NULL,
    entrega_no_prazo      TINYINT(1) NOT NULL,

    CONSTRAINT FK_Entrega_Cliente
        FOREIGN KEY (cliente_id)    REFERENCES Cliente(id_cliente),
    CONSTRAINT FK_Entrega_Centro
        FOREIGN KEY (centro_id)     REFERENCES CentroDistribuicao(id_centro),
    CONSTRAINT FK_Entrega_Veiculo
        FOREIGN KEY (veiculo_id)    REFERENCES Veiculo(id_veiculo),
    CONSTRAINT FK_Entrega_Motorista
        FOREIGN KEY (motorista_id)  REFERENCES Motorista(id_motorista),
    CONSTRAINT FK_Entrega_Rota
        FOREIGN KEY (rota_id)       REFERENCES Rota(id_rota),
    CONSTRAINT FK_Entrega_TipoCarga
        FOREIGN KEY (tipo_carga_id) REFERENCES TipoCarga(id_tipo_carga)
);
