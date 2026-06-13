-- ============================================================
-- AtmosMetrics — 02_populate.sql (SQL Server / Azure SQL)
-- Pré-população das Tabelas Dimensão
-- ============================================================

-- ============================================================
-- SATÉLITES DO INPE (Programa Queimadas)
-- ============================================================
INSERT INTO dim_satelite (nome_satelite, agencia, descricao)
SELECT nome_satelite, agencia, descricao FROM (
    VALUES
    ('AQUA_M-T',    'NASA/INPE', 'Satélite AQUA - sensor MODIS (passagem matutina). Referência histórica do INPE.'),
    ('AQUA_M-M',    'NASA/INPE', 'Satélite AQUA - sensor MODIS (passagem noturna).'),
    ('TERRA_M-T',   'NASA/INPE', 'Satélite TERRA - sensor MODIS (passagem matutina).'),
    ('TERRA_M-M',   'NASA/INPE', 'Satélite TERRA - sensor MODIS (passagem noturna).'),
    ('GOES-16',     'NOAA',      'Satélite geoestacionário GOES-16. Cobertura contínua das Américas.'),
    ('GOES-13',     'NOAA',      'Satélite geoestacionário GOES-13 (legado).'),
    ('NOAA-20',     'NOAA/NASA', 'Satélite NOAA-20 com sensor VIIRS. Alta resolução (375m).'),
    ('NOAA-21',     'NOAA/NASA', 'Satélite NOAA-21 com sensor VIIRS.'),
    ('NPP-375D',    'NASA',      'Satélite Suomi NPP com sensor VIIRS (detecção diurna 375m).'),
    ('NPP-375N',    'NASA',      'Satélite Suomi NPP com sensor VIIRS (detecção noturna 375m).'),
    ('MSG-03',      'EUMETSAT',  'Satélite Meteosat Third Generation da agência europeia EUMETSAT.'),
    ('METOP-B',     'EUMETSAT',  'Satélite MetOp-B polar com sensor AVHRR.'),
    ('METOP-C',     'EUMETSAT',  'Satélite MetOp-C polar com sensor AVHRR.')
) AS t(nome_satelite, agencia, descricao)
WHERE NOT EXISTS (SELECT 1 FROM dim_satelite s WHERE s.nome_satelite = t.nome_satelite);

-- ============================================================
-- ESTADOS BRASILEIROS + REGIÕES
-- ============================================================

IF OBJECT_ID('tempdb..#temp_estados') IS NOT NULL
    DROP TABLE #temp_estados;

CREATE TABLE #temp_estados (
    uf      CHAR(2),
    estado  VARCHAR(50),
    regiao  VARCHAR(20),
    bioma   VARCHAR(30)
);

INSERT INTO #temp_estados VALUES
('AC', 'Acre',            'Norte',        'Amazônia'),
('AM', 'Amazonas',        'Norte',        'Amazônia'),
('AP', 'Amapá',           'Norte',        'Amazônia'),
('PA', 'Pará',            'Norte',        'Amazônia'),
('RO', 'Rondônia',        'Norte',        'Amazônia'),
('RR', 'Roraima',         'Norte',        'Amazônia'),
('TO', 'Tocantins',       'Norte',        'Cerrado'),
('AL', 'Alagoas',         'Nordeste',     'Caatinga'),
('BA', 'Bahia',           'Nordeste',     'Caatinga'),
('CE', 'Ceará',           'Nordeste',     'Caatinga'),
('MA', 'Maranhão',        'Nordeste',     'Cerrado'),
('PB', 'Paraíba',         'Nordeste',     'Caatinga'),
('PE', 'Pernambuco',      'Nordeste',     'Caatinga'),
('PI', 'Piauí',           'Nordeste',     'Caatinga'),
('RN', 'Rio Grande do Norte', 'Nordeste', 'Caatinga'),
('SE', 'Sergipe',         'Nordeste',     'Caatinga'),
('DF', 'Distrito Federal','Centro-Oeste', 'Cerrado'),
('GO', 'Goiás',           'Centro-Oeste', 'Cerrado'),
('MS', 'Mato Grosso do Sul','Centro-Oeste','Pantanal'),
('MT', 'Mato Grosso',     'Centro-Oeste', 'Cerrado'),
('ES', 'Espírito Santo',  'Sudeste',      'Mata Atlântica'),
('MG', 'Minas Gerais',    'Sudeste',      'Cerrado'),
('RJ', 'Rio de Janeiro',  'Sudeste',      'Mata Atlântica'),
('SP', 'São Paulo',       'Sudeste',      'Mata Atlântica'),
('PR', 'Paraná',          'Sul',          'Mata Atlântica'),
('RS', 'Rio Grande do Sul','Sul',         'Pampa'),
('SC', 'Santa Catarina',  'Sul',          'Mata Atlântica');

INSERT INTO dim_localidade (municipio, uf, estado, regiao, bioma)
SELECT
    'Não Identificado' AS municipio,
    uf, estado, regiao, bioma
FROM #temp_estados t
WHERE NOT EXISTS (
    SELECT 1 FROM dim_localidade l 
    WHERE l.municipio = 'Não Identificado' AND l.uf = t.uf
);

DROP TABLE #temp_estados;

-- ============================================================
-- Mensagem de confirmação
-- ============================================================
PRINT '✅ AtmosMetrics: Dimensões pré-populadas com sucesso!';
