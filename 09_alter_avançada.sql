

CREATE DATABASE db1410_alterAvancada;
GO

USE db1410_alterAvancada;
GO

DROP TABLE IF EXISTS clientes
CREATE TABLE clientes(
	cliente_id INT,
	nome_cliente VARCHAR(100),
	data_cadastro DATETIME
	/*
	Em resumo: "crie uma restri��o chamada PK_clientes_cliente_id
	que torne a coluna cliente_id a chave primaria da tabela"
	Isso grante a unicidade e identifica��o exclusiva de cada cliente
	na tabela cliente
	*/
	CONSTRAINT PK_clientes_cliente_id PRIMARY KEY(cliente_id)
);

INSERT INTO clientes
(cliente_id, nome_cliente, data_cadastro)
VALUES
(1, 'Caio', '2025-01-02'),
(2, 'Rodrigo', '2025-01-03'),
(3, 'Rafael', '2025-01-04'),
(4, 'Gusatvo', '2025-01-05');

-- como remover uma CONSTRANT
-- passo 01: Remover chave primaria existente
ALTER TABLE clientes
DROP CONSTRAINT PK_clientes_cliente_id;

--passo 02: Adicionar uma nova chave 
ALTER TABLE clientes
ADD CONSTRAINT PK_clientes_cliente_id_2 PRIMARY KEY (cliente_id);

--Adicionando um indice para otimizar a consulta
--por data nesse exemplo

CREATE NONCLUSTERED INDEX IX_clientes_data_cadastro ON clientes(data_cadastro);

-- Alterar um tipo
ALTER TABLE clientes 
ALTER COLUMN nome_cliente TEXT;

-- Adicionando uma nova coluna 
ALTER TABLE clientes
ADD email_cliente VARCHAR(150)

--Verificar se o indice existe na tabela
SELECT * FROM sys.indexes WHERE name = 'IX_clientes_data_cadastro';

--Funcionamento
ALTER TABLE clientes
DROP CONSTRAINT PK_clientes_cliente_id_2
