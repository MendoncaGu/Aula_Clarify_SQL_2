

CREATE DATABASE db1410_empresaMuitoLegal;
GO

USE db1410_empresaMuitoLegal
GO


CREATE TABLE clientes(
	cliente_id INT PRIMARY KEY,
	nome_cliente VARCHAR(1000),
	email_cliente VARCHAR(1000),
	-- datetime2 gera a data e hora com precisão
	-- a generated: essa coluna é gerada automaticamente pelo sistema e marca o inicio do periodo de validade do registro
	-- hidden: não aparece no select, apenas caso especificar ela diretamente
	data_inicio DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
	data_fim DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
	-- definir periodo de tempo durante o qual o registro é valido
	PERIOD FOR SYSTEM_TIME (data_inicio, data_fim)
)
-- ativando o versionamento do sistema e criando uma tabela de historico
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.clientes_historico));

/*
Cria a tabela de historico que armazenará as versoes anteriores dos
dados, por padrão o SQL cria essa tabela automaticamente quando o
vercionamento é habilitado, mas podemos cirar explicitamente se 
desejado
*/


CREATE TABLE clientes_historico(
	cliente_id INT PRIMARY KEY,
	nome_cliente VARCHAR(100),
	email_cliente VARCHAR(100),
	data_inicio DATETIME2,
	data_fim DATETIME2
	);

INSERT INTO clientes (cliente_id,nome_cliente, email_cliente) VALUES
(1, 'Caio', 'caio@gmail.com'),
(2, 'Gustavo', 'gustavo@gmail.com'),
(3, 'Rodrigo', 'rodrigo@gmail.com'),
(4, 'Rafael', 'rafael@gmail.com')

SELECT * FROM clientes
UPDATE clientes
SET 
	nome_cliente = 'Gustavo Duarte',
	email_cliente = 'Guga@gmail.com'
WHERE cliente_id = 2;
SELECT * FROM clientes_historico

/*
Inserindo dados em uma tabela temporarira
essas tabelas são úteis para armazenar dados temporariros
que não precisam persistir no banco de dados
*/
CREATE TABLE #clientes_temporariros (
	cliente_id INT PRIMARY KEY,
	nome_cliente VARCHAR(100),
	email_cliente VARCHAR(100)
);

INSERT INTO #clientes_temporariros
(cliente_id, nome_cliente, email_cliente)
VALUES
(11, 'Albert Einsten', 'emc@gmail.com'),
(12, 'Stephen Hawking', 'hipervoid@gmail.com')

SELECT * FROM #clientes_temporariros