-- 01
-- Все товары, в которых в название есть пометка urgent или название начинается с Animal
SELECT StockItemName	 
FROM [WideWorldImporters].[Warehouse].StockItems
WHERE StockItemName LIKE '%urgent%' 
	  OR stockitemname LIKE 'animal%' 

--02
--Поставщиков, у которых не было сделано ни одного заказа (потом покажем как это делать через подзапрос, сейчас сделайте через JOIN)
SELECT  DISTINCT s.SupplierID,
				 s.SupplierName
FROM [Purchasing].[Suppliers] s
LEFT JOIN [Purchasing].[PurchaseOrders] ps ON s.SupplierID=ps.SupplierID
WHERE ps.SupplierID IS NULL

--3. Продажи с названием месяца, в котором была продажа, номером квартала, 
--к которому относится продажа, включите также к какой трети года относится дата
--каждая треть по 4 месяца, дата забора заказа должна быть задана, с ценой товара 
--более 100$ либо количество единиц товара более 20. 
--Сортировка должна быть по номеру квартала, трети года, дате продажи.
SELECT o.OrderID,
	   o.OrderDate,
	   DATENAME(mm,o.OrderDate) AS month_name,
	   DATEPART(QUARTER,o.OrderDate)  AS num_quarter,
	   CAST((DATEPART(mm, o.OrderDate) - 1) / 4 as int) + 1 as 'Third'
FROM [Sales].[Orders] o
JOIN sales.OrderLines ol ON o.OrderID=ol.OrderID	
JOIN [Warehouse].[StockItems] si ON ol.StockItemID=si.StockItemID
WHERE o.PickingCompletedWhen IS NOT NULL
GROUP BY o.OrderID,
		 o.OrderDate
HAVING MAX(ol.UnitPrice)>100
	   OR SUM(ol.quantity)>20
	   
--3.1
--Добавьте вариант этого запроса с постраничной выборкой пропустив
--первую 1000 и отобразив следующие 100 записей. Соритровка должна быть по номеру квартала, трети года, дате продажи.
SELECT o.OrderID,
	   o.OrderDate,
	   DATENAME(mm,o.OrderDate) AS month_name,
	   DATEPART(QUARTER,o.OrderDate)  AS num_quarter,
	   CAST((DATEPART(mm, o.OrderDate) - 1) / 4 AS INT) + 1 AS 'Third'
FROM [Sales].[Orders] o
JOIN sales.OrderLines ol on o.OrderID=ol.OrderID	
JOIN [Warehouse].[StockItems] si on ol.StockItemID=si.StockItemID
WHERE o.PickingCompletedWhen is not null
GROUP BY o.OrderID,
         o.OrderDate      
HAVING MAX(ol.UnitPrice)>100
	   or SUM(ol.quantity)>20		
ORDER BY (4),(5),o.OrderDate
OFFSET 1000 ROWS FETCH FIRST 100 ROWS ONLY

--04
--Заказы поставщикам, которые были исполнены за 2014й год с доставкой Road Freight или Post,
--добавьте название поставщика, имя контактного лица принимавшего заказ
SELECT po.PurchaseOrderID, 
       s.Suppliername,
	   p.FullName
FROM [Purchasing].[PurchaseOrders] po
JOIN [Purchasing].[Suppliers] s ON po.supplierid=s.supplierid
JOIN [Application].[DeliveryMethods] dm ON po.DeliveryMethodID=dm.DeliveryMethodID
JOIN [Application].[People] p ON po.ContactPersonID =p.PersonID
WHERE (orderdate BETWEEN '01.01.2014 00:00:00.000' AND '31.12.2014 23:59:59.999')
	  AND dm.DeliveryMethodName in ('Road Freight','Post')

--05
--10 последних по дате продаж с именем клиента и именем сотрудника, который оформил заказ.

SELECT TOP 10 OrderID,
			  c.CustomerName AS Client_name,
			  p.FullName AS SalesPerson_Name              
FROM sales.orders o
JOIN sales.Customers c ON o.CustomerID=c.CustomerID
JOIN [Application].[People] p ON o.SalespersonPersonID=p.PersonID
ORDER BY OrderDate DESC

--06
--Все ид и имена клиентов и их контактные телефоны, которые покупали товар Chocolate frogs 250g
SELECT c.CustomerID,
	   c.CustomerName,
	   c.PhoneNumber
FROM sales.Customers c
JOIN Sales.Orders o ON c.CustomerID=o.CustomerID
JOIN sales.OrderLines ol ON o.OrderID=ol.OrderID
JOIN [Warehouse].[StockItems] si ON si.StockItemID=ol.StockItemID
WHERE si.StockItemName ='Chocolate frogs 250g'

