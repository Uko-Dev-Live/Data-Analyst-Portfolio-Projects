select Gender
from [sql tutorial].dbo.EmployeeDemographics
where Age between 31 and 38
group by Gender


select Gender
from [sql tutorial].dbo.EmployeeDemographics
where Age between 31 and 38
group by Gender


select * from (
      select dem.EmployeeID, dem.FirstName, sal.JobTitle,
	  sal.Salary, dem.Age,
	  count(Gender) over (PARTITION BY Gender) nu
      from [sql tutorial].dbo.EmployeeDemographics as dem
	  join [sql tutorial].dbo.EmployeeSalary sal
	  on dem.EmployeeID = sal.EmployeeID
	  ) as loo
where loo.Age < 35
order by loo.Age


select distinct top(5) *
from (
      select *
      from [sql tutorial].dbo.EmployeeDemographics
      where Age between 31 and 38
	  ) as loo
order by loo.Age


select * from [sql tutorial].dbo.EmployeeDemographics
join [sql tutorial].dbo.EmployeeSalary
on EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID