��� ���� ������� ��� ��������, �������� 2 �������� ��������:
1) ����� ��������� ������
2) ����� WITH (��� ����������� ������)

--�������� �������:
--1. �������� �����������, ������� �������� ������������, � ��� �� ������� �� ����� �������.



--2. �������� ������ � ����������� ����� (�����������), 2 �������� ����������.


--3. �������� ���������� �� ��������, ������� �������� �������� 5 ������������ �������� �� [Sales].[CustomerTransactions] ����������� 3 ������� (� ��� ����� � CTE)

--4. �������� ������ (�� � ��������), � ������� ���� ���������� ������, �������� � ������ ����� ������� �������, � ����� ��� ����������, ������� ����������� �������� �������

--5. ���������, ��� ������ � ������������� ������:

--����������:
-- ��� ������, ����� ������� ������ 27 000 ��������
-- ������� id �����
-- ���� �����
-- ��� ��������, ����������� ����
-- �������� ����� �����
-- �������� ����� ������� ���������������� ����� ����������������� ������ (���� ������������ ��������� - �� ����)

SELECT Invoices.InvoiceID,
	   Invoices.InvoiceDate,
       (SELECT People.FullName FROM Application.People WHERE People.PersonID = Invoices.SalespersonPersonID) AS SalesPersonName,    
	   SalesTotals.TotalSumm AS TotalSummByInvoice,      
	   (SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)               --���������� ��������� �� ������ * ���� ������� ���������
			FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId						 --�� ������, ��� ������� ���� �������� ����� � ����� ��� �������������
									FROM Sales.Orders                            
									WHERE Orders.PickingCompletedWhen IS NOT NULL --���� ������������ ������ ���������!!!
									AND Orders.OrderId = Invoices.OrderId)
		) AS TotalSummForPickedItems
FROM Sales.Invoices
			JOIN			(SELECT InvoiceId,
			                        SUM(Quantity*UnitPrice) AS TotalSumm
							 FROM Sales.InvoiceLines
							 GROUP BY InvoiceId
							 HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
																						ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC


--��������� ���� ������� � ��� ������, � ����� ��� ����� ����������� �� ������ �����������.
--��������� ���� �������

--�����������
	-- ������ 3 - ��������� ��������� ����������� ��� ������ ������ �������  Sales.Invoices, ��� �� �������, ���� ���� � ���������� ������� SqlServer.
	   -- � �� ����� � ��������� CTE. ������ - ��������� ������, ��������� ������������������.

	-- ����������� ������� SalesTotals � �� ����� � cte, ��� �������� ������ ����. ����� ����� ����������� �� ������ ������������� cte � ����������.
	-- ��������� � ���������� ����� ������� ��������� CTE, � ���������� �������������� join. ������ - �������� ������. ������������������

--����� ��������� ��� � ������� ��������� ������������� ������� (��� ��� ���� � ��������� ������), ��� � � ������� ��������� �����\���������.

--������������ �����:
--� ���������� � �������� ���� ���� HT_reviewBigCTE.sql - �������� ���� ������ � �������� ��� �� ������ ������� � � ��� ��� �����, ����� ���� ���� ���� �� ��������� ���� �� ��������.