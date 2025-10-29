
---fazer idepotencia da database

CREATE DATABASE db1410_particionamento;
GO

USE db1410_particionamento;
GO

/*
Objetivo: Dividir tabelas grandes em partições menores para melhor desempenho 
e facilitar o gerenciamento de dados

O Particionamento vai dividir a tabela com base em um valor de coluna, 
nesse exemplo usaremos datas
*/
IF EXISTS(SELECT * FROM sys.partition_schemes WHERE name = 'ps_ano')
	DROP PARTITION SCHEME ps_ano;
GO

IF EXISTS(SELECT * FROM sys.partition_functions WHERE name = 'pf_ano')
	DROP PARTITION FUNCTION ps_ano;
GO

-- Criar a função de particionamento
-- Ela que define como tudo vai ser distribuido

CREATE PARTITION FUNCTION pf_ano (DATE)
AS RANGE RIGHT FOR VALUES (
'2010-12-30',
'2011-12-30',
'2012-12-30',
'2013-12-30',
'2014-12-30',
'2015-12-30'
);
GO

-- criaremos um esquema de particionamento
-- o esquema define como as partições serão distribuidas
-- NÃO OS DADOS  (Não confundir)

CREATE PARTITION SCHEME ps_ano
AS PARTITION pf_ano
-- Cada partição será mapeada aqui no TO, nesse caso todas as partições estão
-- partições estão sendo alocadas no Primary! Mas cade uma em seu campo
TO(
	[PRIMARY],
	[PRIMARY],
	[PRIMARY],
	[PRIMARY],
	[PRIMARY],
	[PRIMARY],
	[PRIMARY]
);
GO

--- Criar tabela usando o esquema da particionamento definido anteriormente)

CREATE TABLE vendas(
	id INT NOT NULL,
	data DATE NOT NULL,
	valor DECIMAL(10,2),
	cliente_id INT,
	CONSTRAINT PK_vendas PRIMARY KEY NONCLUSTERED(id, data)
)
ON ps_ano (data);
GO

/*
Inserir os dados na tabela particionada. O SQL vai colocar automaticamente os dados
nas partições corretas conforme a coluna de data
*/

INSERT INTO vendas
	(id, data, valor, cliente_id)
VALUES
	(1, '2010-01-11', 150, 101),
	(2, '2011-02-21', 170, 102),
	(3, '2012-03-12', 152, 103),
	(4, '2013-04-22', 139, 104),
	(5, '2014-05-13', 250, 105),
	(6, '2015-06-23', 550, 106),

	(7, '2010-01-11', 150, 101),
	(8, '2011-02-21', 170, 102),
	(9, '2013-03-12', 152, 103),
	(10, '2013-04-22', 139, 104),
	(11, '2014-05-13', 250, 105),
	(12, '2013-06-23', 550, 106);

-- você pode consultar a tabela normalmente, e o SQL vai usar a tabela
-- particionada para acelerar a busca

SELECT * FROM vendas WHERE data = '2010-01-11'