-- 01
-- Все товары, в которых в название есть пометка urgent или название начинается с Animal
select stockitemname
	 
	 from [wideworldimporters].[warehouse].[stockitems]

where stockitemname like '%urgent%' 
	  or stockitemname like 'animal%' 

--02
--Поставщиков, у которых не было сделано ни одного заказа (потом покажем как это делать через подзапрос, сейчас сделайте через JOIN)
select  distinct s.supplierid,
				 s.[suppliername]

 from [purchasing].[suppliers] s
					left join [purchasing].[purchaseorders] ps on s.supplierid=ps.supplierid

where ps.supplierid is null

--3. Продажи с названием месяца, в котором была продажа, номером квартала, 
--к которому относится продажа, включите также к какой трети года относится дата
--каждая треть по 4 месяца, дата забора заказа должна быть задана, с ценой товара 
--более 100$ либо количество единиц товара более 20. 
--Сортировка должна быть по номеру квартала, трети года, дате продажи.

declare @dt1 date = '01.01.2013'   --дата забора заказа 
declare @dt2 date = '01.02.2013' 

select o.OrderID,
       o.OrderDate,
	   datename(mm,o.OrderDate) as month_name,
	   datepart(quarter,o.OrderDate)  as num_quarter,
	   (case when datepart(mm,o.OrderDate) in (1,2,3,4) then 1
	        when datepart(mm,o.OrderDate) in (5,6,7,8) then 2
			when datepart(mm,o.OrderDate) in (9,10,11,12) then 3 end) num_tret_goda

	    from [Sales].[Orders] o
			 join sales.OrderLines ol on o.OrderID=ol.OrderID	
		     join [Warehouse].[StockItems] si on ol.StockItemID=si.StockItemID

where o.PickingCompletedWhen between @dt1 and @dt2

group by o.OrderID,
         o.OrderDate,
	     datename(mm,o.OrderDate),
	     datepart(quarter,o.OrderDate),
	     (case when datepart(mm,o.OrderDate) in (1,2,3,4) then 1
	        when datepart(mm,o.OrderDate) in (5,6,7,8) then 2
			when datepart(mm,o.OrderDate) in (9,10,11,12) then 3 end)

having max(ol.UnitPrice)>100
	   or sum(ol.quantity)>20	

--3.1
--Добавьте вариант этого запроса с постраничной выборкой пропустив
--первую 1000 и отобразив следующие 100 записей. Соритровка должна быть по номеру квартала, трети года, дате продажи.

declare @dt1 date = '01.01.2013'   
declare @dt2 date = '01.02.2013' 

select o.OrderID,
       o.OrderDate,
	   datename(mm,o.OrderDate) as month_name,
	   datepart(quarter,o.OrderDate)  as num_quarter,
	   (case when datepart(mm,o.OrderDate) in (1,2,3,4) then 1
	        when datepart(mm,o.OrderDate) in (5,6,7,8) then 2
			when datepart(mm,o.OrderDate) in (9,10,11,12) then 3 end) num_tret_goda

	    from [Sales].[Orders] o
			 join sales.OrderLines ol on o.OrderID=ol.OrderID	
		     join [Warehouse].[StockItems] si on ol.StockItemID=si.StockItemID

where o.PickingCompletedWhen between @dt1 and @dt2

group by o.OrderID,
         o.OrderDate,
	     datename(mm,o.OrderDate),
	     datepart(quarter,o.OrderDate),
	     (case when datepart(mm,o.OrderDate) in (1,2,3,4) then 1
	        when datepart(mm,o.OrderDate) in (5,6,7,8) then 2
			when datepart(mm,o.OrderDate) in (9,10,11,12) then 3 end)

having max(ol.UnitPrice)>100
	   or sum(ol.quantity)>20		

order by (3),(4),o.OrderDate
offset 1000 rows fetch first 100 rows only

--04
--Заказы поставщикам, которые были исполнены за 2014й год с доставкой Road Freight или Post,
--добавьте название поставщика, имя контактного лица принимавшего заказ

select po.PurchaseOrderID, 
       dm.DeliveryMethodName,
	   p.FullName
	   
	from  [Purchasing].[PurchaseOrders] po
			 join [Application].[DeliveryMethods] dm on po.DeliveryMethodID=dm.DeliveryMethodID
			 join [Application].[People] p on po.ContactPersonID =p.PersonID

where (orderdate between '01.01.2014' and '31.12.2014')
	  and dm.DeliveryMethodName in ('Road Freight','Post')

--05
--10 последних по дате продаж с именем клиента и именем сотрудника, который оформил заказ.

select top 10 OrderID,
			  c.CustomerName as Client_name,
			  p.FullName as SalesPerson_Name

               
 from sales.orders o
				join sales.Customers c on o.CustomerID=c.CustomerID
				join [Application].[People] p on o.ContactPersonID=p.PersonID

order by OrderDate desc

--06
--Все ид и имена клиентов и их контактные телефоны, которые покупали товар Chocolate frogs 250g

select c.CustomerName,
	   c.PhoneNumber

from sales.Customers c
			join Sales.Orders o on c.CustomerID=o.CustomerID
			join sales.OrderLines ol on o.OrderID=ol.OrderID
			join [Warehouse].[StockItems] si on si.StockItemID=ol.StockItemID
	where si.StockItemName ='Chocolate frogs 250g'

