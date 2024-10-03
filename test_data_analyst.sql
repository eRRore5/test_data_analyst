with Income as(
	select
	Object,
	SUM(CASE WHEN Article IN ('ProductSales','ServiceRevenue','LicenseFees','CommissionIncome','InterestIncome') THEN Fact ELSE 0 END) as totalincome
	From FinancialData
	WHERE Date BETWEEN '2024-01-01' AND '2024-03-31'
	GROUP BY Object
),
expences as (
	SELECT 
	Object,
	SUM(CASE WHEN Article IN ('COGS','MarketingExpense') THEN Fact ELSE 0 END) as totalexpences
	From FinancialData
	WHERE Date BETWEEN '2024-01-01' AND '2024-03-31'
	GROUP BY Object
),
otherexpences as (
	SELECT 
	Object,
	SUM(CASE WHEN Article IN ('AdministrativeExpense','R&DExpense') THEN Fact ELSE 0 END) as totalotherexpences
	From FinancialData
	WHERE Date BETWEEN '2024-01-01' AND '2024-03-31'
	GROUP BY Object
),
depreciation as (
	SELECT 
	Object,
	SUM(CASE WHEN Article IN ('Depreciation','Amortization') THEN Fact ELSE 0 END) as totaldeprecation
	From FinancialData
	WHERE Date BETWEEN '2024-01-01' AND '2024-03-31'
	GROUP BY Object
),
EBITDAcalc as (
	SELECT 
	t1.Object,
	t1.totalincome,
	t2.totalexpences,
	t3.totalotherexpences,
	t4.totaldeprecation,
	(t1.totalincome-t2.totalexpences-t3.totalotherexpences-t4.totaldeprecation) as EBITDA
	FROM Income t1
	left join expences t2 on t1.Object = t2.Object
	left join otherexpences t3 on t1.Object = t3.Object
	left join depreciation  t4 on t1.Object = t4.Object
),
Analys as (
	SELECT 
	Object,
	SUM(LoanAmount) as sumLoanAmount,
	COUNT(DISTINCT Creditor) as number,
	MIN(StartDate) as minimal,
	MAX(EndDate) as maximum,
	AVG(InterestRate) as avgInterestRate,
	AVG(MonthlyPayment) as avgMonthlyPayment
	from LoanDetails ld 
	group by Object
)
SELECT 
a.Object,
CAST(a.sumLoanAmount as FLOAT) / NULLIF(e.EBITDA, 0) as DebtEBITDA,
a.number,
a.minimal,
a.maximum,
a.avgInterestRate,
a.avgMonthlyPayment
from Analys a
left join EBITDAcalc e on a.Object = e.Object
