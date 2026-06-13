-- ============================================================
-- AtmosMetrics — 01_schema.sql (SQL Server / Azure SQL)
-- Criação do Star Schema para Monitoramento Socioambiental
-- ============================================================

-- ============================================================
-- DIMENSÃO: dim_tempo
-- Armazena a hierarquia temporal para facilitar análises
-- ============================================================
IF OBJECT_ID('dim_tempo', 'U') IS NULL
BEGIN
    CREATE TABLE dim_tempo (
        id_tempo        INT IDENTITY(1,1) PRIMARY KEY,
        data_completa   DATE        NOT NULL UNIQUE,
        ano             SMALLINT    NOT NULL,
        semestre        SMALLINT    NOT NULL CHECK (semestre IN (1, 2)),
        trimestre       SMALLINT    NOT NULL CHECK (trimestre BETWEEN 1 AND 4),
        mes             SMALLINT    NOT NULL CHECK (mes BETWEEN 1 AND 12),
        nome_mes        VARCHAR(20) NOT NULL,
        semana_do_ano   SMALLINT    NOT NULL CHECK (semana_do_ano BETWEEN 1 AND 53),
        dia             SMALLINT    NOT NULL CHECK (dia BETWEEN 1 AND 31),
        dia_da_semana   SMALLINT    NOT NULL CHECK (dia_da_semana BETWEEN 0 AND 6),
        nome_dia        VARCHAR(15) NOT NULL,
        e_fim_de_semana BIT         NOT NULL
    );
END;

-- ============================================================
-- DIMENSÃO: dim_satelite
-- Registra os satélites usados para detectar focos de calor
-- ============================================================
IF OBJECT_ID('dim_satelite', 'U') IS NULL
BEGIN
    CREATE TABLE dim_satelite (
        id_satelite     INT IDENTITY(1,1) PRIMARY KEY,
        nome_satelite   VARCHAR(50)  NOT NULL UNIQUE,
        agencia         VARCHAR(50),
        descricao       VARCHAR(MAX)
    );
END;

-- ============================================================
-- DIMENSÃO: dim_localidade
-- Hierarquia geográfica: Município → Estado → Região → Bioma
-- ============================================================
IF OBJECT_ID('dim_localidade', 'U') IS NULL
BEGIN
    CREATE TABLE dim_localidade (
        id_localidade   INT IDENTITY(1,1) PRIMARY KEY,
        municipio       VARCHAR(100) NOT NULL,
        codigo_ibge     VARCHAR(7)   UNIQUE, -- Código IBGE do município (7 dígitos)
        uf              CHAR(2)      NOT NULL,
        estado          VARCHAR(50)  NOT NULL,
        regiao          VARCHAR(20)  NOT NULL CHECK (regiao IN ('Norte', 'Nordeste', 'Centro-Oeste', 'Sudeste', 'Sul')),
        bioma           VARCHAR(30)  NOT NULL
    );

    CREATE INDEX idx_localidade_uf     ON dim_localidade(uf);
    CREATE INDEX idx_localidade_bioma  ON dim_localidade(bioma);
    CREATE INDEX idx_localidade_regiao ON dim_localidade(regiao);
END;

-- ============================================================
-- TABELA FATO: fato_anomalia_termica
-- Cada linha = um foco de calor detectado por satélite
-- ============================================================
IF OBJECT_ID('fato_anomalia_termica', 'U') IS NULL
BEGIN
    CREATE TABLE fato_anomalia_termica (
        id_anomalia         BIGINT IDENTITY(1,1) PRIMARY KEY,

        -- Chaves Estrangeiras (ligação com as dimensões)
        id_tempo            INT          NOT NULL REFERENCES dim_tempo(id_tempo),
        id_localidade       INT          NOT NULL REFERENCES dim_localidade(id_localidade),
        id_satelite         INT          NOT NULL REFERENCES dim_satelite(id_satelite),

        -- Coordenadas brutas (para compatibilidade)
        latitude            DECIMAL(9,6) NOT NULL CHECK (latitude BETWEEN -90 AND 90),
        longitude           DECIMAL(9,6) NOT NULL CHECK (longitude BETWEEN -180 AND 180),

        -- Coluna geoespacial nativa do SQL Server (Geography)
        geom                GEOGRAPHY,

        -- Métricas do foco
        frp_megawatts       DECIMAL(10,2),
        risco_fogo          DECIMAL(5,2),
        precipitacao_mm     DECIMAL(7,2),
        dias_sem_chuva      SMALLINT,

        hora_utc            TIME,

        criado_em           DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
    );

    CREATE INDEX idx_fato_tempo       ON fato_anomalia_termica(id_tempo);
    CREATE INDEX idx_fato_localidade  ON fato_anomalia_termica(id_localidade);
    CREATE INDEX idx_fato_satelite    ON fato_anomalia_termica(id_satelite);
    
    -- Nota: Índices espaciais no Azure SQL às vezes exigem limites definidos ou podem ser omitidos 
    -- dependendo do volume. Ocultamos por segurança inicial.
END;

GO

-- ============================================================
-- TRIGGER: atualiza geom automaticamente ao inserir/atualizar
-- Mantém a coluna geom (Geography) sincronizada com lat/lon
-- ============================================================
CREATE OR ALTER TRIGGER trg_update_geom
ON fato_anomalia_termica
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Verifica se lat ou lon foram afetados
    IF UPDATE(latitude) OR UPDATE(longitude)
    BEGIN
        UPDATE f
        SET geom = geography::Point(i.latitude, i.longitude, 4326)
        FROM fato_anomalia_termica f
        INNER JOIN inserted i ON f.id_anomalia = i.id_anomalia
        WHERE i.latitude IS NOT NULL AND i.longitude IS NOT NULL;
    END
END;
GO
