USE [master]
GO
/****** Object:  Database [estonia]    Script Date: 26/07/2016 18:52:35 ******/
CREATE DATABASE [estonia]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'estonia', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\estonia.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'estonia_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\estonia_log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [estonia] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [estonia].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [estonia] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [estonia] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [estonia] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [estonia] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [estonia] SET ARITHABORT OFF 
GO
ALTER DATABASE [estonia] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [estonia] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [estonia] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [estonia] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [estonia] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [estonia] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [estonia] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [estonia] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [estonia] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [estonia] SET  DISABLE_BROKER 
GO
ALTER DATABASE [estonia] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [estonia] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [estonia] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [estonia] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [estonia] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [estonia] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [estonia] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [estonia] SET RECOVERY FULL 
GO
ALTER DATABASE [estonia] SET  MULTI_USER 
GO
ALTER DATABASE [estonia] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [estonia] SET DB_CHAINING OFF 
GO
ALTER DATABASE [estonia] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [estonia] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [estonia] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'estonia', N'ON'
GO
USE [estonia]
GO
/****** Object:  Table [dbo].[call_rates]    Script Date: 26/07/2016 18:52:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[call_rates](
	[Area_Code] [varchar](12) NOT NULL,
	[Area_Description] [varchar](32) NULL,
	[Rate] [real] NULL,
 CONSTRAINT [PK_call_rates] PRIMARY KEY CLUSTERED 
(
	[Area_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[customers]    Script Date: 26/07/2016 18:52:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[customers](
	[Customer_Id] [varchar](12) NOT NULL,
	[Customer_Name] [varchar](32) NULL,
	[Address] [varchar](256) NULL,
	[Payment_Term_Id] [varchar](12) NULL,
 CONSTRAINT [PK_customers] PRIMARY KEY CLUSTERED 
(
	[Customer_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[imported_calls]    Script Date: 26/07/2016 18:52:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[imported_calls](
	[Customer_Id] [varchar](12) NOT NULL,
	[Call_Date_Time] [datetime] NOT NULL,
	[Area_Code] [varchar](12) NOT NULL,
	[Year] [int] NULL,
	[Month] [int] NULL,
	[Call_Duration] [real] NULL,
	[Invoiced] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[invoice_headers]    Script Date: 26/07/2016 18:52:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[invoice_headers](
	[Invoice_Number] [int] NOT NULL,
	[Customer_Id] [varchar](12) NULL,
	[Invoice_Date] [datetime] NULL,
	[Payment_Term_Id] [varchar](12) NULL,
	[Due_Date] [datetime] NULL,
	[Net_Amount] [real] NULL,
	[VAT_Amount] [real] NULL,
	[Total_Amount] [real] NULL,
 CONSTRAINT [PK_invoice_headers] PRIMARY KEY CLUSTERED 
(
	[Invoice_Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[invoice_lines]    Script Date: 26/07/2016 18:52:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[invoice_lines](
	[Invoice_Number] [int] NOT NULL,
	[Line_Number] [int] NOT NULL,
	[Area_Code] [varchar](12) NULL,
	[Number_of_Calls] [int] NULL,
	[Duration] [real] NULL,
	[Rate] [real] NULL,
	[Line_Amount] [real] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[payment_terms]    Script Date: 26/07/2016 18:52:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[payment_terms](
	[Payment_Term_Id] [varchar](12) NOT NULL,
	[Term_Description] [varchar](32) NULL,
	[Days_Due] [int] NULL,
 CONSTRAINT [PK_payment_terms] PRIMARY KEY CLUSTERED 
(
	[Payment_Term_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[customers]  WITH CHECK ADD  CONSTRAINT [FK_customers_payment_terms] FOREIGN KEY([Payment_Term_Id])
REFERENCES [dbo].[payment_terms] ([Payment_Term_Id])
GO
ALTER TABLE [dbo].[customers] CHECK CONSTRAINT [FK_customers_payment_terms]
GO
ALTER TABLE [dbo].[imported_calls]  WITH CHECK ADD  CONSTRAINT [FK_imported_calls_call_rates] FOREIGN KEY([Area_Code])
REFERENCES [dbo].[call_rates] ([Area_Code])
GO
ALTER TABLE [dbo].[imported_calls] CHECK CONSTRAINT [FK_imported_calls_call_rates]
GO
ALTER TABLE [dbo].[imported_calls]  WITH CHECK ADD  CONSTRAINT [FK_imported_calls_customers] FOREIGN KEY([Customer_Id])
REFERENCES [dbo].[customers] ([Customer_Id])
GO
ALTER TABLE [dbo].[imported_calls] CHECK CONSTRAINT [FK_imported_calls_customers]
GO
ALTER TABLE [dbo].[invoice_headers]  WITH CHECK ADD  CONSTRAINT [FK_invoice_headers_customers] FOREIGN KEY([Customer_Id])
REFERENCES [dbo].[customers] ([Customer_Id])
GO
ALTER TABLE [dbo].[invoice_headers] CHECK CONSTRAINT [FK_invoice_headers_customers]
GO
ALTER TABLE [dbo].[invoice_headers]  WITH CHECK ADD  CONSTRAINT [FK_invoice_headers_payment_terms] FOREIGN KEY([Payment_Term_Id])
REFERENCES [dbo].[payment_terms] ([Payment_Term_Id])
GO
ALTER TABLE [dbo].[invoice_headers] CHECK CONSTRAINT [FK_invoice_headers_payment_terms]
GO
ALTER TABLE [dbo].[invoice_lines]  WITH CHECK ADD  CONSTRAINT [FK_invoice_lines_call_rates] FOREIGN KEY([Area_Code])
REFERENCES [dbo].[call_rates] ([Area_Code])
GO
ALTER TABLE [dbo].[invoice_lines] CHECK CONSTRAINT [FK_invoice_lines_call_rates]
GO
ALTER TABLE [dbo].[invoice_lines]  WITH CHECK ADD  CONSTRAINT [FK_invoice_lines_invoice_headers] FOREIGN KEY([Invoice_Number])
REFERENCES [dbo].[invoice_headers] ([Invoice_Number])
GO
ALTER TABLE [dbo].[invoice_lines] CHECK CONSTRAINT [FK_invoice_lines_invoice_headers]
GO
USE [master]
GO
ALTER DATABASE [estonia] SET  READ_WRITE 
GO
