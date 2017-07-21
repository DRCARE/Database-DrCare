# Code to create database and add data initially

First: change to link where your db will be created.

CREATE DATABASE [DRCARE] ON PRIMARY 
(
	NAME = 'DrCare',
	
	# CHANGE THIS
	FILENAME =  'E:\Android\CODERSCHOOL\PROJECT\DrCare.mdf',
	##
	
	SIZE = 4MB,
	
	MAXSIZE = UNLIMITED,
	
	FILEGROWTH = 1024KB
)

LOG ON
(
	NAME ='DrCare_log',
	
	# CHANGE THIS
	FILENAME = 'E:\Android\CODERSCHOOL\PROJECT\DrCare.ldf', *CHANGE THIS
	##
	
	SIZE = 1024KB,
	
	MAXSIZE = 2048KB,
	
	FILEGROWTH = 10%
)
GO
