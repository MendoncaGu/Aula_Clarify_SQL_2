--Idepotencia do banco
IF NOT EXISTS (SELECT 1 FROM sys.databases
WHERE NAME = 'db_sistemaVendas')
	CREATE DATABASE db_sistemaVendas;
GO

USE db_sistemaVendas;
GO

--Idepotencia das tabelas
IF OBJECT_ID('clientes', 'U') IS NOT NULL DROP TABLE clientes;
IF OBJECT_ID('produtos', 'U') IS NOT NULL DROP TABLE produtos;
IF OBJECT_ID('vendas', 'U') IS NOT NULL DROP TABLE vendas;
IF OBJECT_ID('auditoria_vendas', 'U') IS NOT NULL DROP TABLE auditoria_vendas;

-- Idepontencia das triggers
IF OBJECT_ID('trg_VendasInsersao', 'TR') IS NOT NULL
	DROP TRIGGER trg_VendasInsersao;

IF OBJECT_ID('trg_VendasExclusao', 'TR') IS NOT NULL
	DROP TRIGGER trg_VendasExclusao;

IF OBJECT_ID('trg_VendasAtualizacao', 'TR') IS NOT NULL
	DROP TRIGGER trg_VendasAtualizacao;

---------------------Criando as tabelas -------------------------

CREATE TABLE clientes(
	cliente_id INT PRIMARY KEY IDENTITY (1, 1),
	nome_cliente VARCHAR(100),
	email_clinte VARCHAR(100),
	data_cadastro DATETIME DEFAULT GETDATE()
	);

CREATE TABLE produtos(
	produto_id INT PRIMARY KEY IDENTITY (1, 1),
	nome_produto VARCHAR(100),
	preco DECIMAL (10,2)
	);

CREATE TABLE vendas(
	venda_id INT PRIMARY KEY IDENTITY (1, 1),
	cliente_id INT NOT NULL,
	produto_id INT NOT NULL,
	quantidade INT NOT NULL,
	valor_total DECIMAL (10,2),
	data_venda DATETIME DEFAULT GETDATE()
	FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id) ON DELETE CASCADE,
	FOREIGN KEY (produto_id) REFERENCES produtos(produto_id) ON DELETE CASCADE
	);

CREATE TABLE auditoria_vendas(
	auditoria_id INT PRIMARY KEY IDENTITY (1, 1),
	venda_id INT,
	cliente_id INT,
	produto_id INT,
	quantidade INT,
	valor_total DECIMAL (10,2),
	data_venda DATETIME,
	operacao NVARCHAR(100),
	data_operacao DATETIME DEFAULT GETDATE(),
	usuario NVARCHAR (100) DEFAULT system_user
	);
GO

------ TRIGGEEEEEER -------

CREATE TRIGGER trg_VendasInsersao
	ON vendas
	AFTER INSERT
	 AS
	 BEGIN
		INSERT INTO auditoria_vendas
		(venda_id, cliente_id, produto_id, quantidade, valor_total, data_venda, operacao)
		SELECT venda_id, cliente_id, produto_id, quantidade, valor_total, data_venda, 'Inserido' FROM inserted
	 END;
GO
CREATE TRIGGER trg_VendasExclusao
	ON vendas
	AFTER DELETE
	 AS
	 BEGIN
	 INSERT INTO auditoria_vendas
		(venda_id, cliente_id, produto_id, quantidade, valor_total, data_venda, operacao)
		SELECT venda_id, cliente_id, produto_id, quantidade, valor_total, data_venda, 'Excluido' FROM deleted
	 END;
GO
CREATE TRIGGER trg_VendasAtualizacao
	ON vendas
	AFTER UPDATE
	 AS
	 BEGIN
	 INSERT INTO auditoria_vendas
		(venda_id, cliente_id, produto_id, quantidade, valor_total, data_venda, operacao)
		SELECT venda_id, cliente_id, produto_id, quantidade, valor_total, data_venda, 'Atualizado' FROM inserted
	 END;
GO

------- Inserindo os dados ----------------

INSERT INTO clientes
(nome_cliente, email_clinte)
VALUES
	('Caio', 'caio@gmail.com'),
	('Rodrigo', 'rodrigo@gmail.com'),
	('Rafael', 'rafael@gmail.com'),
	('Gustavo', 'gustavo@gmail.com');

INSERT INTO produtos
	(nome_produto, preco)
VALUES
	('Notebook', 3500.00),
	('Smartphone', 800.00),
	('TV 90 Polegadas', 1200.00),
	('Fone de Ouvido', 240.00);

INSERT INTO vendas
	(cliente_id, produto_id, quantidade, valor_total)
VALUES
	(1,1,1,3500.00),
	(2,1,2,3500.00),
	(3,2,3,3500.00),
	(4,2,4,3500.00),
	(1,3,5,3500.00),
	(2,3,6,3500.00),
	(3,4,7,3500.00);
----------- Consultas------------------
PRINT 'TOTAL DE VENDAS POR CLIENTE';
SELECT nome_cliente, SUM(valor_total) AS 'Total de vendas'
FROM vendas v 
JOIN clientes c ON v.cliente_id = c.cliente_id
GROUP BY c.nome_cliente
ORDER BY 'Total de Vendas' DESC;
----------------------------------------------------------
PRINT 'TOP 3 PRODUTOS MAIS VENDIDOS';
SELECT p.nome_produto, SUM(v.quantidade) AS 'Total Vendido'
FROM vendas v
JOIN produtos p ON v.produto_id = p.produto_id
GROUP BY p.nome_produto
ORDER BY 'Total Vendido' DESC
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;
-------------------EU--------------------------------------
PRINT 'TOTAL DE VENDAS POR PRODUTO';
SELECT p.nome_produto, 
SUM(v.valor_total) AS 'Total real',
SUM(v.quantidade) AS 'Total vendido'
FROM vendas v
JOIN produtos p ON v.produto_id = p.produto_id
GROUP BY p.nome_produto
ORDER BY 'Total vendido' DESC;
------------------------------------------------------------
PRINT 'TOP 3 CLIENTES QUE MAIS COMPRARAM';
SELECT TOP 3 c.nome_cliente, 
SUM(v.valor_total) AS 'Total de Vendas em R$',
SUM(v.quantidade) AS 'Total de vendas em QTD'
FROM vendas v
JOIN clientes c ON v.cliente_id = c.cliente_id
GROUP BY c.nome_cliente
ORDER BY 'Total de Vendas em QTD' DESC;
--------------------------------------------------------------
PRINT 'VALOR MEDIO POR CLIENTE';
SELECT c.nome_cliente, 
AVG(v.valor_total) AS 'Media Vendas',
COUNT(v.venda_id) AS 'Total de Compras'
FROM vendas v
JOIN clientes c ON v.cliente_id = c.cliente_id
GROUP BY c.nome_cliente
ORDER BY 'Media Vendas' DESC;

--Lucro Simulado 

ALTER TABLE produtos ADD custo DECIMAL(10,2) NULL;
GO
UPDATE produtos SET custo = preco * 0.7; -- custo estimado 70%

PRINT 'LUCRO ESTIMADO POR PRODUTO'
SELECT
	p.nome_produto,
	SUM(v.quantidade * (p.preco - p.custo)) AS 'Lucro Total'
FROM vendas v
JOIN produtos p ON v.produto_id = p.produto_id
GROUP BY p.nome_produto
ORDER BY 'Lucro total' DESC

--- Criando uma VIEW
CREATE VIEW vw_relatorio_vendas --vw-- 
AS
SELECT 
	v.venda_id,
	c.nome_cliente,
	p.nome_produto,
	v.quantidade,
	p.preco,
	v.valor_total,
	v.data_venda
FROM vendas v
JOIN clientes c ON v.cliente_id = c.cliente_id
JOIN produtos p ON v.produto_id = p.produto_id;
GO

SELECT * FROM vw_relatorio_vendas
-----------------------------------
CREATE VIEW vw_totalVendasporCliente
AS
SELECT
nome_cliente, SUM(valor_total) AS 'Total de vendas'
FROM vendas v 
JOIN clientes c ON v.cliente_id = c.cliente_id
GROUP BY c.nome_cliente


SELECT * FROM vw_totalVendasporCliente
--------------------------------------------
CREATE VIEW vw_top3MaisVendidos
AS
SELECT
 p.nome_produto, SUM(v.quantidade) AS 'Total Vendido'
FROM vendas v
JOIN produtos p ON v.produto_id = p.produto_id
GROUP BY p.nome_produto
ORDER BY 'Total Vendido' DESC
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;

SELECT * FROM vw_top3MaisVendidos
----------------------------------------

----- Selects para verificação desse ponto-------
SELECT * FROM vendas
SELECT * FROM clientes
SELECT * FROM produtos
SELECT * FROM auditoria_vendas


