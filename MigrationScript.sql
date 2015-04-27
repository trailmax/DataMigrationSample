SET DATEFORMAT dmy;

begin transaction tran1


    /******** Insert Companies ********/

    /*
    Copy from XLSX:
    BT	British Telecom
    BG	British Gas
    TSC	Tesco
    SNDR	Santander
    RCK	Rocket Science Ltd

    Now apply this search regex 
    (.*)\t(.*)
    and this apply this replace regexp
    insert into Companies \(Abbreviation, Name\) values \(\'\1\', \'\2\'\)

    to get the following lines:
    */


    insert into Companies (Abbreviation, Name) values ('BT', 'British Telecom')
    insert into Companies (Abbreviation, Name) values ('BG', 'British Gas')
    insert into Companies (Abbreviation, Name) values ('TSC', 'Tesco')
    insert into Companies (Abbreviation, Name) values ('SNDR', 'Santander')
    insert into Companies (Abbreviation, Name) values ('RCK', 'Rocket Science Ltd')

    -- check what we got:
    select * from [dbo].[Companies]


    --Now save People sheet as a tab-delimited file
    --These are the headers from the tab-delimited file
    --FirstName	Surname	Sex	DOB	DateOfJoin	JobTitle	HolidayEntitlement (Days)	CompanyAbbreviation
    -- apply regex replace from  "\t" to " nvarchar\(max\) collate SQL_Latin1_General_CP1_CI_AS,\r\n" to get this:
    /*
    FirstName nvarchar(max) collate SQL_Latin1_General_CP1_CI_AS,
    Surname nvarchar(max) collate SQL_Latin1_General_CP1_CI_AS,
    Sex nvarchar(max) collate SQL_Latin1_General_CP1_CI_AS,
    DOB nvarchar(max) collate SQL_Latin1_General_CP1_CI_AS,
    DateOfJoin nvarchar(max) collate SQL_Latin1_General_CP1_CI_AS,
    JobTitle nvarchar(max) collate SQL_Latin1_General_CP1_CI_AS,
    HolidayEntitlement (Days) nvarchar(max) collate SQL_Latin1_General_CP1_CI_AS,
    CompanyAbbreviation nvarchar(max) collate SQL_Latin1_General_CP1_CI_AS,
    */
    -- and using this you can create your temp table 
    --drop table #people
    create table #people(
        FirstName nvarchar(max) collate Latin1_General_CI_AS,
        Surname nvarchar(max) collate Latin1_General_CI_AS,
        Sex nvarchar(max) collate Latin1_General_CI_AS,
        DOB nvarchar(max) collate Latin1_General_CI_AS,
        DateOfJoin nvarchar(max) collate Latin1_General_CI_AS,
        JobTitle nvarchar(max) collate Latin1_General_CI_AS,
        HolidayEntitlementDays nvarchar(max) collate Latin1_General_CI_AS,
        CompanyAbbreviation nvarchar(max) collate Latin1_General_CI_AS
    )

    -- read tab-delimited text file
    BULK INSERT  #people
    FROM 'd:\path\People.txt'
    WITH
    ( FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n' )
    GO

    -- check what has been imported
    select * from #people


    -- delete the header names from the data
    delete from #people where FirstName = 'First Name'


    --now we can populate JobTitle table
    select * from JobTitles

    insert into JobTitles (name)
    select distinct JobTitle from #people
    

    --find all non-dates
    select * from #people where isdate(DateOfJoin)<>1
    update #people set DateOfJoin = null where DateOfJoin='0/04/2015'

    -- find all non numbers
    select * from #people where ISNUMERIC(HolidayEntitlementDays) <> 1
    update #people set HolidayEntitlementDays=18 where HolidayEntitlementDays='l8' 


    -- and can insert now from temp table into proper table

    insert into People (
        [FirstName],
	   [Surname],
	   [JobTitleId],
	   [Gender],
	   [DateOfBirth],
	   [JoinDate],
	   [HolidayEntitlement],
	   [CompanyId])
    select 
        isnull(nullif(FirstName, ' '), 'Unknown') as FirstName,
        nullif(Surname, ' ') as Surname,
        (select JobTitleId from JobTitles where name = p.JobTitle) as JobTitleId,
        case when p.Sex = 'Male' then 1 else 2 end as Gender, -- enum with 1 for Male, 2 for female
        convert(datetime, isnull(Dob, '01/01/1900'), 103) as DateOfBirth,
        convert(datetime, isnull(DateOfJoin, '01/01/1900'), 103) as JoinDate,
        convert(int, HolidayEntitlementDays) as HolidayEntitlement,
        (select CompanyId from companies where abbreviation = p.CompanyAbbreviation) as CompanyId
    from #people p

    select * from People


rollback transaction tran1
