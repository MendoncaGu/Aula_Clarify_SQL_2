/*
Topicos cobertos

-Idepotencias
- INNER / LEFT JOIN
- CASE WHEN
- WITH
-Funções de janela (ROW_NUMBER, RANK)
- ORDER BY e TOP (Equivalente ao Limit)
- Subconsulta (Escalares)
- Agregação + GROUP BY + HAVING

*/

-- Criando e usando o banco de dados

IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'db1410_formatura')
CREATE DATABASE db1410_formatura
GO

USE db1410_formatura
GO

--- LIMPEZA (Idempotencia: roda varias vezes sem erro!)
IF OBJECT_ID('dbo.ItensPedido') IS NOT NULL
DROP TABLE dbo.ItensPedido;

IF OBJECT_ID('dbo.Pedidos') IS NOT NULL
DROP TABLE dbo.Pedidos;

IF OBJECT_ID('dbo.Produtos') IS NOT NULL
DROP TABLE dbo.Produtos;

IF OBJECT_ID('dbo.Clientes') IS NOT NULL
DROP TABLE dbo.Clientes;

/*--------------------------
	1) ESQUEMA + DADOS FAKE
*/--------------------------

CREATE TABLE dbo.Clientes (
	ClienteID	INT IDENTITY (1,1) PRIMARY KEY,
	Nome		NVARCHAR (100) NOT NULL,
	Cidade		NVARCHAR (60) NULL
);

CREATE TABLE dbo.Produtos (
	ProdutoID	INT IDENTITY(1,1) PRIMARY KEY,
	Nome		NVARCHAR(100) NOT NULL,
	Categoria	NVARCHAR(60) NOT NULL,
	Preco		DECIMAL(10,2) NOT NULL CHECK (Preco > 0),
	Ativo		BIT NOT NULL DEFAULT 1
);

CREATE TABLE dbo.Pedidos(
	PedidoID	INT IDENTITY(1,1) PRIMARY KEY,
	ClienteID	INT NOT NULL,
	DataPedido	DATE NOT NULL,
	
	CONSTRAINT FK_Pedidos_Clientes
		FOREIGN KEY (ClienteID) REFERENCES dbo.Clientes(ClienteID)
);

CREATE TABLE dbo.ItensPedido(
	ItemID		INT IDENTITY(1,1) PRIMARY KEY,
	PedidoID	INT NOT NULL,
	ProdutoID	INT NOT NULL,
	Quantidade	INT NOT NULL CHECK (Quantidade > 0),
	PrecoUnit	DECIMAL(10,2) NOT NULL CHECK (PrecoUnit >= 0)
	
	CONSTRAINT FK_Itens_Pedidos
		FOREIGN KEY (PedidoID) REFERENCES dbo.Pedidos(PedidoID),
	
	CONSTRAINT FK_Itens_Produtos
		FOREIGN KEY (ProdutoID) REFERENCES dbo.Produtos(ProdutoID)
);

--- Clientes
INSERT INTO dbo.Clientes(Nome, Cidade)
VALUES
('Caio Rossi',		'São Paulo'),
('Gustavo Duarte',	'Santa Catarina'),
('Rafael Gandolfi',	'Santa Catarina'),
('Rodrigo Mauri',	'São Paulo'),
('Eduarda Ramos',	'Xique-Xique'),
('Carla Lima',		'São Paulo');

--- Produtos
INSERT INTO dbo.Produtos(Nome, Categoria, Preco, Ativo)
VALUES
	('Mouse Top',			'Perifericos',	60.00,		1),
	('Teclado Mecanico',	'Perifericos',	350.00,		1),
	('Monitor 24',			'Monitores',	899.00,		1),
	('Cabo HDMI',			'Acessorios',	39.00,		1),
	('Notebook 14',			'Computadores', 2999.00,	1),
	('Headset USB',			'Acessorios',	199.00,		1);
--- Pedidos
INSERT INTO dbo.Pedidos(ClienteID, DataPedido)
VALUES
	(1, DATEADD(DAY, -40, GETDATE())),
	(1, DATEADD(DAY, -10, GETDATE())),
	(2, DATEADD(DAY, -5, GETDATE())),
	(3, DATEADD(DAY, -70, GETDATE())),
	(4, DATEADD(DAY, -15, GETDATE()));

--- Itens (Preço unitario é 'congelado' do produto no momento do pedido)
INSERT INTO dbo.ItensPedido (PedidoID, ProdutoID, Quantidade, PrecoUnit)
VALUES 
	-- Pedido 1 (Caio - Há 40 Dias)
		(1, 1, 1, 60.00), -- Mouse
		(1, 4, 2, 39.00), -- HDMI

	-- Pedido 2 (Gustavo  - Há 10 Dias)
		(2, 2, 1, 350.00), -- Teclado
		(2, 3, 1, 899.00), -- Monitor

	-- Pedido 3 (Rafael - Há 5 Dias)
		(3, 4, 3, 39.00), -- HDMI
		(3, 6, 1, 199.00), -- Headset

	-- Pedido 4 (Rodrigo - Há 70 Dias)
		(4, 1, 2, 60.00), -- Mouse

	-- Pedido 5 (Eduarda - Há 15 Dias)
		(5, 5, 1, 2999.00); -- Notebook

/*
	2) Consulta Completa (Unica com todos os pontos do Módulo)
	Objetivo: Gerar um relatorio final por cliente com:
	- total gasto, nº de pedidos e ticket médio
	- produto mais comprado por cliente (função janela)
	- classificação do cliente (case when)
	- filtrar apenas clientes com gasto > media geral (having)
	- mostrar tambem clientes sem pedido (LEAFT JOIN)
	- e garantir que o produto final do cliente tenha preço
	acima da media de preços (subconsulta esclar no where)
*/
--Interrompe qulquer Instrução
;WITH
-- 2.1) "Fato" de vendas (Inner Joins entre tableas)
Vendas AS (
	SELECT
		pe.PedidoID,
		pe.DataPedido,
		c.ClienteID,
		c.Nome AS NomeCliente,
		pr.ProdutoID,
		pr.Nome AS NomeProduto,
		pr.Categoria,
		it.Quantidade,
		it.PrecoUnit,
		CAST(it.Quantidade * it.PrecoUnit AS DECIMAL(10,2)) AS ValorItem
	FROM dbo.Pedidos AS pe
	INNER JOIN dbo.Clientes		AS c	ON c.ClienteID = pe.ClienteID 
	INNER JOIN dbo.ItensPedido	AS it	ON it.PedidoID = pe.PedidoID
	INNER JOIN dbo.Produtos		AS pr	ON pr.ProdutoID = it.ProdutoID
),

-- 2.2) Agregação por Cliente (GROUP BY + HAVING)
GastoPorCliente AS (
	SELECT
		v.ClienteID,
		MIN(v.NomeCliente) AS NomeCliente,
		COUNT(DISTINCT v.PedidoID) AS QtdePedidos,
		SUM(v.ValorItem) AS TotalGasto,
		AVG(CAST(v.ValorItem AS DECIMAL(10,2))) AS TicketMedio
	FROM Vendas v
	GROUP BY v.ClienteID
	HAVING SUM(v.ValorItem) > 100.00 
	
	--Filtro de agregação (Só quem gastou mais de 100)
),

-- 2.3) Produto mais Comprado Por Cliente
ProdutoTopPorCliente AS (
	SELECT
		v.ClienteID,
		v.ProdutoID,
		MIN(v.NomeProduto) AS NomeProduto,
		SUM(v.Quantidade) AS QtdeTotal,
		ROW_NUMBER() OVER(
		PARTITION BY v.ClienteID ORDER BY SUM (v.Quantidade)DESC) AS rn
	FROM Vendas v
	GROUP BY v.ClienteID, v.ProdutoID
),

-- 2.4) Ranking global de produtos por volume
RankingProdutos AS (
	SELECT
		v.ProdutoID,
		MIN(v.NomeProduto) AS NomeProduto,
		SUM(v.Quantidade) AS QtdeVendida,
		RANK() OVER (ORDER BY SUM(v.Quantidade) DESC) AS RankGlobal
	FROM Vendas v
	GROUP BY v.ProdutoID
),

-- 2.5) Cliente com e sem pedido
ClientesComOuSemPedido AS (
	SELECT 
		c.ClienteID,
		c.Nome AS NomeCliente,
		c.Cidade,
		CASE WHEN p.PedidoID IS NULL THEN 0 ELSE 1 END AS TemPedido

	FROM dbo.Clientes c
	-- LEFT: mantem cliente mesmo sem pedido
	LEFT JOIN dbo.Pedidos p ON p.ClienteID = c.ClienteID
		GROUP BY c.ClienteID, c.Nome, c.Cidade,
		CASE WHEN p.PedidoID IS NULL THEN 0 ELSE 1 END -- IF aprimorado
)

-- 2.6) Select final (Reunir tudo)
SELECT TOP (10) -- TOP = Limite no SQL Server
	base.ClienteID,
	base.NomeCliente,
	base.Cidade,
	ISNULL(g.QtdePedidos, 0)		AS QtdePedidos,
	ISNULL(g.TotalGasto, 0.00)	AS TotalGasto,
	ISNULL(g.TicketMedio, 0.00)	AS TicketMedio,
	ISNULL(pt.NomeProduto, '---')	AS ProdutoTopCliente,
	ISNULL(rp.RankGlobal, NULL)	AS RankProdutoGlobal,
	-- CASE WHEN para clasificar o cliente por gasto
	CASE 
		WHEN TotalGasto >= 2000 THEN 'VIP'
		WHEN TotalGasto >= 500 THEN 'Bom'
		WHEN TotalGasto > 0 THEN 'Novo'
		ELSE 'Sem Compras'
	END AS CategoriaCliente
	FROM ClientesComOuSemPedido AS base
	
	-- Junta agregados (podem ser null se o cliente nao tiver um pedido)
	LEFT JOIN GastoPorCliente g ON g.ClienteID = base.ClienteID
	-- Pega apenas o produto #1 por cliente (rn = 1)
	LEFT JOIN ProdutoTopPorCliente pt ON pt.ClienteID = base.ClienteID AND pt.rn = 1
	-- Ranking Global do produto TOP (pode ser null se o cliente nao tiver produto top)
	LEFT JOIN RankingProdutos rp ON rp.ProdutoID = pt.ProdutoID
	WHERE (pt.ProdutoID IS NULL) -- permite listar clientes sem compras
		OR (pt.ProdutoID IS NOT NULL AND
		(SELECT AVG(Preco) FROM dbo.Produtos) <
		(SELECT Preco FROM dbo.Produtos WHERE ProdutoID = pt.ProdutoID))
	ORDER BY g.TotalGasto DESC; -- Ordana por total Gasto (NULLs Vão ao fim)
GO