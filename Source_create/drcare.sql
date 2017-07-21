-- DROP DATABASE [DRCARE]
-- use master 
/**/ 

-- Create Database
CREATE DATABASE [DRCARE] ON PRIMARY 
(
	NAME = 'DrCare',
	FILENAME = 'E:\Android\CODERSCHOOL\PROJECT\DrCare.mdf',
	SIZE = 4MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 1024KB
)

LOG ON
(
	NAME ='DrCare_log',
	FILENAME = 'E:\Android\CODERSCHOOL\PROJECT\DrCare.ldf',
	SIZE = 1024KB,
	MAXSIZE = 2048KB,
	FILEGROWTH = 10%
)
GO

use [DRCARE]
GO

-- Create table
CREATE TABLE ROLE_DrCare
(
	RoleID int IDENTITY(1,1) NOT NULL,
	RoleName nvarchar(100),
	CONSTRAINT pk_roleID PRIMARY KEY (RoleID)
)

CREATE TABLE USER_DrCare
(	UserID int IDENTITY(1,1) NOT NULL, 
	RoleID int NOT NULL,
	UserName nvarchar(50),
	UserPhone varchar(11),
	UserDoB date,
	UserAddr nvarchar(100),
	UserImage varchar(200),
	UserNote nvarchar(200),
	UserIDCardNo varchar(30),
	UserHealthInsurance varchar(30),
	DayCreated datetime,
	CONSTRAINT pk_User PRIMARY KEY (UserID),
	CONSTRAINT fk_User_role FOREIGN KEY (RoleID)
		REFERENCES ROLE_DrCare(RoleID)
)

CREATE TABLE DISEASE
(
	DiseaseID int IDENTITY(1,1) NOT NULL,
	DiseName nvarchar(100),
	DiseOtherName varchar(100),
	DiseDescription nvarchar(100),
	CONSTRAINT pk_diseaseID PRIMARY KEY (DiseaseID)
)

CREATE TABLE REPEAT_CATEGORY
(
	RepeatID int IDENTITY(1,1) NOT NULL,
	RepeatName nvarchar(100),
	repeatTime time,
	repeatDay VARCHAR(10),
	CONSTRAINT pk_repeatID PRIMARY KEY (RepeatID)
)

CREATE TABLE REMIND
(
	RemindID int IDENTITY(1,1) NOT NULL,
	TimeRemind time NOT NULL DEFAULT CONVERT (time, GETDATE()),
	isRepeat int NOT NULL,
	Sound varchar(30),
	Label varchar(50),
	isActivate bit,
	CONSTRAINT pk_remindID PRIMARY KEY (RemindID),
	CONSTRAINT fk_Remind_isRepeat FOREIGN KEY (isRepeat)
		REFERENCES REPEAT_CATEGORY(RepeatID)
)

CREATE TABLE MEDICAL_RECORD_DETAILS
(
	MecRcDetailsID int IDENTITY(1,1) NOT NULL,
	MecRcID int NOT NULL,
	DiseaseID int NOT NULL,
	DoctorID int NOT NULL,
	Symptoms nvarchar(200),
	DayCreated datetime,
	CONSTRAINT pk_mecRcDetailsID PRIMARY KEY (MecRcDetailsID),
	CONSTRAINT fk_MecRecDt_mecRecId FOREIGN KEY (MecRcID)
		REFERENCES USER_DrCare(UserID),
	CONSTRAINT fk_MecRecDt_Disease FOREIGN KEY (DiseaseID)
		REFERENCES DISEASE(DiseaseID),
	CONSTRAINT fk_MecRecDt_doctorId FOREIGN KEY (DoctorID)
		REFERENCES USER_DrCare(UserID)
)

CREATE TABLE REMIND_DETAILS
(
	MecRcDetailsID int NOT NULL,
	RemindID int NOT NULL,
	CONSTRAINT pk_remindDetails PRIMARY KEY (MecRcDetailsID, RemindID),
	CONSTRAINT fk_remindDtls_MecRcDtls FOREIGN KEY(MecRcDetailsID)
		REFERENCES MEDICAL_RECORD_DETAILS(MecRcDetailsID),
	CONSTRAINT fk_remindDtls_remindID FOREIGN KEY(RemindID)
		REFERENCES REMIND(RemindID)
)

CREATE TABLE UNIT_CATEGORY
(
	UnitID int IDENTITY(1,1) NOT NULL,
	UnitName nvarchar(10),
	UnitOtherName varchar(10),
	CONSTRAINT pk_unitID PRIMARY KEY (UnitID)
)

CREATE TABLE MEDICINE
(
	MedID int IDENTITY(1,1) NOT NULL,
	MedName varchar(50),
	MedPrice decimal(19,4),
	MedUnit int,
	CONSTRAINT pk_MedID PRIMARY KEY (MedID),
	CONSTRAINT fk_Medicine_unit FOREIGN KEY(MedUnit)
		REFERENCES UNIT_CATEGORY(UnitID)
)

CREATE TABLE PRESCRIPTION
(
	MecRcDtID int NOT NULL,
	MedID int NOT NULL,
	MedQty smallint,
	isMorn bit DEFAULT 0,
	isNoon bit DEFAULT 0,
	isAftNoon bit DEFAULT 0,
	DayQty smallint,
	CONSTRAINT pk_prescription PRIMARY KEY(MecRcDtID, MedID),
	CONSTRAINT fk_prescript_MecRcDtls FOREIGN KEY(MecRcDtID)
		REFERENCES MEDICAL_RECORD_DETAILS(MecRcDetailsID),
	CONSTRAINT fk_prescript_MedID FOREIGN KEY(MedID)
		REFERENCES MEDICINE(MedID),
)

CREATE TABLE INGREDIENT
(	
	IngredID int IDENTITY(1,1) NOT NULL,
	IngredName nvarchar(60),
	CONSTRAINT pk_IngredID PRIMARY KEY (IngredID)
)

CREATE TABLE RECIPE
(
	MedID int NOT NULL,
	IngredID int NOT NULL,
	IngredQty varchar(20),
	CONSTRAINT pk_recipe PRIMARY KEY (MedID, IngredID),
	CONSTRAINT fk_recipe_MedID FOREIGN KEY(MedID)
		REFERENCES MEDICINE(MedID),
	CONSTRAINT fk_recipe_IngredID FOREIGN KEY(IngredID)
		REFERENCES INGREDIENT(IngredID)
)
GO


-- insert data
INSERT INTO dbo.ROLE_DrCare
        ( RoleName )
VALUES  ( 'Doctor'),  -- RoleName - nvarchar(100)
          ('Patient'),
		  ('Nurse'),
		  ('Receiptionist')
GO

INSERT INTO dbo.USER_DrCare
        ( RoleID ,
          UserName ,
          UserPhone ,
          UserDoB ,
          UserAddr ,
          UserImage ,
          UserNote ,
          UserIDCardNo ,
          UserHealthInsurance ,
          DayCreated
        )
VALUES  ( 1 , -- RoleID - int
          N'Samn Nguyễn' , -- UserName - nvarchar(50)
          '0902937732' , -- UserPhone - varchar(11)
          '28-Dec-1996' , -- UserDoB - date
          N'Q17 cư xá Phú Lâm A, Phường 12, Quận 6, TPHCM' , -- UserAddr - nvarchar(100)
          NULL , -- UserImage - varchar(200)
          'Cardiologist (Bác sĩ Tim mạch)' , -- UserNote - nvarchar(200)
          '025423407' , -- UserIDCardNo - varchar(30)
          'SV-4-79-01-001-04959' , -- UserHealthInsurance - varchar(30)
          GETDATE()  -- DayCreated - datetime
        ),
		( 1 , -- RoleID - int
          N'Đức Lộc' , -- UserName - nvarchar(50)
          '0909123456' , -- UserPhone - varchar(11)
          '12-Jul-1995' , -- UserDoB - date
          NULL , -- UserAddr - nvarchar(100)
          NULL , -- UserImage - varchar(200)
          'Immunologist' , -- UserNote - nvarchar(200)
          '023087595' , -- UserIDCardNo - varchar(30)
          'NV-1-51-00-004-03530' , -- UserHealthInsurance - varchar(30)
          GETDATE()  -- DayCreated - datetime
        ),
		( 1 , -- RoleID - int
          N'Jose Norwood' , -- UserName - nvarchar(50)
          '0976450123' , -- UserPhone - varchar(11)
          '21-NOV-1989' , -- UserDoB - date
          NULL , -- UserAddr - nvarchar(100)
          NULL , -- UserImage - varchar(200)
          'Orthopedist' , -- UserNote - nvarchar(200)
          '0634779513' , -- UserIDCardNo - varchar(30)
          'NV-1-81-00-001-45678' , -- UserHealthInsurance - varchar(30)
          GETDATE()  -- DayCreated - datetime
        ),
		( 1 , -- RoleID - int
          N'Huỳnh Hữu Tâm' , -- UserName - nvarchar(50)
          '0909123456' , -- UserPhone - varchar(11)
          '01-Oct-1992' , -- UserDoB - date
          NULL , -- UserAddr - nvarchar(100)
          NULL , -- UserImage - varchar(200)
          'Specialist in plastic surgery' , -- UserNote - nvarchar(200)
          '025163940' , -- UserIDCardNo - varchar(30)
          'NV-1-65-04-002-04786' , -- UserHealthInsurance - varchar(30)
          GETDATE()  -- DayCreated - datetime
        ),
		
		( 1 , -- RoleID - int
          N'Teresa Cerny' , -- UserName - nvarchar(50)
          '0913967251' , -- UserPhone - varchar(11)
          '28-Feb-1989', -- UserDoB - date
          NULL , -- UserAddr - nvarchar(100)
          NULL , -- UserImage - varchar(200)
          'Infectious disease specialist' , -- UserNote - nvarchar(200)
          '04576981525' , -- UserIDCardNo - varchar(30)
          'FR-2-94-01-008-78413' , -- UserHealthInsurance - varchar(30)
          GETDATE()  -- DayCreated - datetime
        ),
		( 1 , -- RoleID - int
          N'Hayden Evans' , -- UserName - nvarchar(50)
          '0907164872' , -- UserPhone - varchar(11)
          '14-Apr-1979' , -- UserDoB - date
          NULL , -- UserAddr - nvarchar(100)
          NULL , -- UserImage - varchar(200)
          'Surgeon' , -- UserNote - nvarchar(200)
          '07214687125' , -- UserIDCardNo - varchar(30)
          'FR-5-16-01-009-54671' , -- UserHealthInsurance - varchar(30)
          GETDATE()  -- DayCreated - datetime
        ),
		( 1 , -- RoleID - int
          N'Christine Wright' , -- UserName - nvarchar(50)
          '0824717863' , -- UserPhone - varchar(11)
          '6-MAR-1990' , -- UserDoB - date
          NULL , -- UserAddr - nvarchar(100)
          NULL , -- UserImage - varchar(200)
          'Neurologist' , -- UserNote - nvarchar(200)
          '07311248597' , -- UserIDCardNo - varchar(30)
          'FR-5-16-01-009-81234' , -- UserHealthInsurance - varchar(30)
          GETDATE()  -- DayCreated - datetime
        ),
		( 2 , -- RoleID - int
          N'Thomas Walker' , -- UserName - nvarchar(50)
          '0123456789' , -- UserPhone - varchar(11)
          '2-Aug-1986' , -- UserDoB - date
          NULL , -- UserAddr - nvarchar(100)
          NULL , -- UserImage - varchar(200)
          NULL , -- UserNote - nvarchar(200)
          '099994786112' , -- UserIDCardNo - varchar(30)
          'FR-2-12-01-008-97812' , -- UserHealthInsurance - varchar(30)
          GETDATE()  -- DayCreated - datetime
        ),
		( 2 , -- RoleID - int
          N'Jame Smith' , -- UserName - nvarchar(50)
          '0297854312' , -- UserPhone - varchar(11)
          '16-MAY-1989' , -- UserDoB - date
          NULL, -- UserAddr - nvarchar(100)
          NULL , -- UserImage - varchar(200)
          NULL , -- UserNote - nvarchar(200)
          '04561563007' , -- UserIDCardNo - varchar(30)
          'FR-2-44-01-008-51279' , -- UserHealthInsurance - varchar(30)
          GETDATE()  -- DayCreated - datetime
        ),
		( 2 , -- RoleID - int
          N'Rani Johnson' , -- UserName - nvarchar(50)
          '02784168981' , -- UserPhone - varchar(11)
          '19-JAN-2000' , -- UserDoB - date
          NULL, -- UserAddr - nvarchar(100)
          NULL , -- UserImage - varchar(200)
          NULL , -- UserNote - nvarchar(200)
          '06784125781' , -- UserIDCardNo - varchar(30)
          'FR-2-35-01-007-67118' , -- UserHealthInsurance - varchar(30)
          GETDATE()  -- DayCreated - datetime
        ),
		( 2 , -- RoleID - int
          'Nightury Michaelis' , -- UserName - nvarchar(50)
          '08985695069' , -- UserPhone - varchar(11)
          '28-Dec-1996' , -- UserDoB - date
          N'My home' , -- UserAddr - nvarchar(100)
          '' , -- UserImage - varchar(200)
          NULL , -- UserNote - nvarchar(200)
          '025423469' , -- UserIDCardNo - varchar(30)
          'BN-4-69-01-001-06959' , -- UserHealthInsurance - varchar(30)
          '28-May-2016'  -- DayCreated - datetime
        )
GO
SELECT * FROM dbo.USER_DrCare

INSERT INTO dbo.DISEASE
        ( DiseName ,
          DiseOtherName ,
          DiseDescription
        )
VALUES  ( N'Bệnh Tim mạch' , -- DiseName - nvarchar(100)
          'Angiocardiopathy' , -- DiseOtherName - varchar(100)
          N'Tim'  -- DiseDescription - nvarchar(100)
        ),
		( N'Suy nhược cơ thể' , -- DiseName - nvarchar(100)
          'Depression' , -- DiseOtherName - varchar(100)
          N'Thể lực'  -- DiseDescription - nvarchar(100)
        ),
		( N'Viêm phổi' , -- DiseName - nvarchar(100)
          'Pneumonia' , -- DiseOtherName - varchar(100)
          N'Phổi'  -- DiseDescription - nvarchar(100)
        ),
		( N'Cúm' , -- DiseName - nvarchar(100)
          'Flu' , -- DiseOtherName - varchar(100)
          N''  -- DiseDescription - nvarchar(100)
        ),
		( N'Dị ứng' , -- DiseName - nvarchar(100)
          'Allergy' , -- DiseOtherName - varchar(100)
          N'Da liễu'  -- DiseDescription - nvarchar(100)
        ),
		( N'Viêm họng' , -- DiseName - nvarchar(100)
          'Sore throat' , -- DiseOtherName - varchar(100)
          N'Tai mũi họng'  -- DiseDescription - nvarchar(100)
        ),
		( N'Tiêu chảy' , -- DiseName - nvarchar(100)
          'Diarrhoea' , -- DiseOtherName - varchar(100)
          N''  -- DiseDescription - nvarchar(100)
        ),
		( N'Bệnh dạ dày' , -- DiseName - nvarchar(100)
          'Gastropathy' , -- DiseOtherName - varchar(100)
          N''  -- DiseDescription - nvarchar(100)
        ),
		( N'Rối loạn tiêu hóa' , -- DiseName - nvarchar(100)
          'Dyspepsia' , -- DiseOtherName - varchar(100)
          N'Tiêu hóa'  -- DiseDescription - nvarchar(100)
        )
GO
SELECT * FROM dbo.DISEASE
INSERT INTO dbo.REPEAT_CATEGORY
        ( RepeatName, repeatTime, repeatDay)
VALUES  ( N'Never', -- RepeatName - nvarchar(100)
          NULL,  -- repeatTime - time(7)
		  NULL
          ),
		  ( N'Every Monday', -- RepeatName - nvarchar(100)
          NULL,  -- repeatTime - time(7)
		  'Mon'
          ),
		  ( N'Every Tuesday', -- RepeatName - nvarchar(100)
          NULL,  -- repeatTime - time(7)
		  'Tue'
          ),
		  ( N'Every Wednesday', -- RepeatName - nvarchar(100)
          NULL,  -- repeatTime - time(7)
		  'Wed'
          ),
		  ( N'Every Thursday', -- RepeatName - nvarchar(100)
          NULL,  -- repeatTime - time(7)
		  'Thu'
          ),
		  ( N'Every Friday', -- RepeatName - nvarchar(100)
          NULL,  -- repeatTime - time(7)
		  'Fri'
          ),
		  ( N'Every Saturday', -- RepeatName - nvarchar(100)
          NULL,  -- repeatTime - time(7)
		  'Sat'
          ),
		  ( N'Every Sunday', -- RepeatName - nvarchar(100)
          NULL,  -- repeatTime - time(7)
		  'Sun'
          )
GO

SELECT * FROM dbo.REPEAT_CATEGORY