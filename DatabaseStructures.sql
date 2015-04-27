CREATE TABLE [dbo].[Companies](
	[CompanyId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](max) NULL,
     [Abbreviation] [nvarchar](max) NULL
 CONSTRAINT [PK_dbo.Companies] PRIMARY KEY CLUSTERED ( [CompanyId] ASC )
)


CREATE TABLE [dbo].[JobTitles](
	[JobTitleId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.JobTitles] PRIMARY KEY CLUSTERED ( [JobTitleId] ASC )
)


CREATE TABLE [dbo].[People](
	[PersonId] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](max) NOT NULL,
	[Surname] [nvarchar](max) NOT NULL,
	[JobTitleId] [int] NULL,
	[Gender] [int] NULL,
	[DateOfBirth] [datetime] NULL,
	[JoinDate] [datetime] NULL,
	[HolidayEntitlement] [int] NULL,
	[CompanyId] [int] NULL,
     CONSTRAINT [PK_dbo.People] PRIMARY KEY CLUSTERED ( [PersonId] ASC)
)

GO

ALTER TABLE [dbo].[People]  WITH CHECK ADD  CONSTRAINT [FK_dbo.People_dbo.CompanyId] FOREIGN KEY([CompanyId])
REFERENCES [dbo].[Companies] ([CompanyId])
GO

ALTER TABLE [dbo].[People] CHECK CONSTRAINT [FK_dbo.People_dbo.CompanyId]
GO

ALTER TABLE [dbo].[People]  WITH CHECK ADD  CONSTRAINT [FK_dbo.People_dbo.JobTitles_JobTitleId] FOREIGN KEY([JobTitleId])
REFERENCES [dbo].[JobTitles] ([JobTitleId])
GO

ALTER TABLE [dbo].[People] CHECK CONSTRAINT [FK_dbo.People_dbo.JobTitles_JobTitleId]
GO


