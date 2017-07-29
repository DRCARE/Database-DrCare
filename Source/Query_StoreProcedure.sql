-- STORE PROC

USE DRCARE
GO

-- thêm 1 dòng Phiếu khám bệnh mới theo Mã bệnh nhân input
CREATE PROCEDURE sp_MEDICAL_RECORD_DETAILS_AddNewMedicalRecord
    @MecRcID AS INT,
	@DiseaseID AS int,
	@DoctorID AS INT
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		INSERT INTO dbo.MEDICAL_RECORD_DETAILS
				( MecRcID ,
				  DiseaseID ,
				  DoctorID ,
				  Symptoms ,
				  DayCreated
				)
		VALUES  ( @MecRcID , -- MecRcID - int
				  @DiseaseID , -- DiseaseID - int
				  @DoctorID , -- DoctorID - int
				  N'' , -- Symptoms - nvarchar(200)
				  GETDATE()  -- DayCreated - datetime
				) 
	END TRY
	
	BEGIN CATCH
		 SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  

		IF @@TRANCOUNT > 0  
			ROLLBACK TRANSACTION;  
	END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
GO

--thêm cho REMIND
CREATE PROCEDURE sp_REMIND_AddNewRemind
	@timeRemind AS VARCHAR(6),
	@Label AS varchar(100) = NULL,
AS
    INSERT INTO dbo.REMIND
            ( TimeRemind ,
              isRepeat ,
              Sound ,
              Label ,
              isActivate
            )
    VALUES  ( @timeRemind , -- TimeRemind - varchar(6)
              0 , -- isRepeat - int
              '' , -- Sound - varchar(30)
              @Label , -- Label - varchar(100)
              1  -- isActivate - bit
            )
GO

--update cho Remind
CREATE PROCEDURE sp_REMIND_AddNewRemind
	@RemindID int IDENTITY(1,1) DEFAULT NULL,
	@TimeRemind varchar(6) NOT NULL,
	@isRepeat int NOT NULL,
	@Sound varchar(30),
	@Label varchar(100),
	@isActivate BIT DEFAULT 1,
AS
	Declare @SQLQuery AS NVarchar(4000)
    Declare @ParamDefinition AS NVarchar(2000) 

	If @RemindID Is Not Null
	BEGIN
		SET @SQLQuery ='UPDATE dbo.REMIND
						SET TimeRemind = @timeRemind , -- TimeRemind - varchar(6)
							isRepeat = @isRepeat , -- isRepeat - int
							Sound = @Sound , -- Sound - varchar(30)
							Label = @Label , -- Label - varchar(100)
							isActivate = @isActivate  -- isActivate - bit
						WHERE RemindID = @RemindID;'
	Set @ParamDefinition = '@RemindID int IDENTITY(1,1) DEFAULT NULL,
							@TimeRemind varchar(6) NOT NULL,
							@isRepeat int NOT NULL,
							@Sound varchar(30),
							@Label varchar(100),
							@isActivate BIT DEFAULT 0'
	EXECUTE sp_executesql @SQLQuery, 
						@ParamDefinition, 
						@RemindID ,
						@TimeRemind ,
						@isRepeat ,
						@Sound ,
						@Label ,
						@isActivate
	END
	ELSE
		RETURN("ERROR") -- Báo sai khi ko có ID
GO

-- thêm 1 dòng thuốc vào Đơn thuốc
CREATE PROCEDURE sp_PRESCRIPTION_AddNewIncription
	@MecRcDtID AS INT,
	@MedID AS INT,
	@MedQty AS FLOAT,
	@TimeTakeMedicine SMALLINT,
	@SumMedQty AS SMALLINT
AS
BEGIN
	DECLARE @isMorn BIT, @isNoon AS BIT, @isAftNoon AS BIT
		SET @isMorn = NULL
		SET @isNoon = NULL
		SET @isAftNoon = NULL
		IF(@TimeTakeMedicine = 3)
			BEGIN
				EXECUTE sp_REMIND_AddNewRemind @timeRemind = 6, @Label = "Uong thuoc buoi sang!!!"
				EXECUTE sp_REMIND_AddNewRemind @timeRemind = 12, @Label = "Uong thuoc buoi trua!!!"
				EXECUTE sp_REMIND_AddNewRemind @timeRemind = 18, @Label = "Uong thuoc buoi toi!!!"
			end
		ELSE
			IF(@TimeTakeMedicine = 2)
				BEGIN
					EXECUTE sp_REMIND_AddNewRemind @timeRemind = 6, @Label = "Uong thuoc buoi sang!!!"
					EXECUTE sp_REMIND_AddNewRemind @timeRemind = 12, @Label = "Uong thuoc buoi trua!!!"
				END
            ELSE  --@TimeTakeMedicine = 1
				EXECUTE sp_REMIND_AddNewRemind @timeRemind = 6, @Label = "Uong thuoc buoi sang!!!"
	DECLARE @DayQty SMALLINT
	SET @DayQty = @SumMedQty / (@TimeTakeMedicine * @MedQty)

	BEGIN TRANSACTION;
	BEGIN TRY
		IF (SELECT isTaken FROM dbo.MEDICAL_RECORD_DETAILS WHERE MecRcDetailsID = @MecRcDtID) = 0
			UPDATE dbo.MEDICAL_RECORD_DETAILS
			SET isTaken = 1
			WHERE MecRcDetailsID = @MecRcDtID
	
		INSERT INTO dbo.PRESCRIPTION
	        ( MecRcDtID ,
	          MedID ,
	          MedQty,
	          isMorn ,
	          isNoon ,
	          isAftNoon ,
	          DayQty
	        )
		VALUES  ( @MecRcDtID , -- MecRcDtID - int
				  @MedID , -- MedID - int
				  @MedQty , -- MedQty - smallint
				  ISNULL(@isMorn,0) , -- isMorn - bit
				  ISNULL(@isNoon, 0) , -- isNoon - bit
				  ISNULL(@isAftNoon, 0) , -- isAftNoon - bit
				  @DayQty  -- DayQty - smallint
				)
	END TRY
	
	BEGIN CATCH
		 SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage;  

		IF @@TRANCOUNT > 0  
			ROLLBACK TRANSACTION;  
	END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
GO

-- CÁCH DÙNG: Lấy LIST Phiếu khám bệnh (MEDICAL_RECORD_DETAILS) theo 2 cách:
-- 1. Bệnh nhân: lấy ALL phiếu khám bệnh <=  @MecRcID
-- 2. bệnh nhân: phiếu khám bệnh của ngày cụ thể <= @MecRcID + @DayCreated
-- 3. Bác sĩ: phiếu khám bệnh của ngày cụ thể <= @DoctorID + @DayCreated
CREATE PROCEDURE sp_Get_Search_MedicalRecordDetails
    @MecRcID AS INT = NULL,
	@DoctorID AS INT = NULL,
	@DayCreated AS VARCHAR(15) = NULL
AS    
BEGIN	
	IF @MecRcID IS NOT NULL
		BEGIN
			IF @DayCreated IS NOT NULL
				SELECT MR.MecRcDetailsID ,
						mr.MecRcID,
                       MR.DiseaseID ,
					   D.DiseName AS 'DISEASE NAME',
                       MR.DoctorID ,
					   US.UserName AS 'Doctor Name',
                       MR.Symptoms ,
                       CONVERT(VARCHAR(10),MR.DayCreated,103) AS 'Day Created' ,
					   MR.isTaken
				FROM dbo.MEDICAL_RECORD_DETAILS MR JOIN dbo.USER_DrCare US ON mr.DoctorID = US.UserID
					JOIN dbo.DISEASE D ON d.DiseaseID = MR.DiseaseID 
				WHERE MR.MecRcID = @MecRcID 				
						AND CONVERT(VARCHAR(10),MR.DayCreated,103) = @DayCreated 
				ORDER BY MR.DayCreated DESC

			ELSE
				SELECT MR.MecRcDetailsID ,
						mr.MecRcID,
                       MR.DiseaseID ,
					   D.DiseName AS 'DISEASE NAME',
                       MR.DoctorID ,
					   US.UserName AS 'Doctor Name',
                       MR.Symptoms ,
                       CONVERT(VARCHAR(10),MR.DayCreated,103) AS 'Day Created' ,
					   MR.isTaken
				FROM dbo.MEDICAL_RECORD_DETAILS MR JOIN dbo.USER_DrCare US ON mr.DoctorID = US.UserID
					JOIN dbo.DISEASE D ON d.DiseaseID = MR.DiseaseID
				WHERE MR.MecRcID = @MecRcID 				
				ORDER BY MR.DayCreated DESC
        END
        
	IF @DoctorID IS NOT NULL
		BEGIN
			SELECT MR.MecRcDetailsID ,
						mr.MecRcID,
						US.UserName AS 'PATIENT NAME',
                       MR.DiseaseID ,
                       MR.DoctorID ,
                       MR.Symptoms ,
                       CONVERT(VARCHAR(10),MR.DayCreated,103)  AS 'Day created',
					   MR.isTaken
				FROM dbo.MEDICAL_RECORD_DETAILS MR JOIN dbo.USER_DrCare US ON mr.MecRcID = US.UserID
				WHERE MR.DoctorID = @DoctorID AND CONVERT(VARCHAR(10),MR.DayCreated,103) = @DayCreated 
				ORDER BY MR.DayCreated ASC
		END
END
GO

--DROP PROC dbo.sp_Get_Search_MedicalRecordDetails

-- lấy LIST thuốc của Phiếu khám bệnh cụ thể
CREATE PROCEDURE sp_getPrecriptionByMecRcDetailsID
    @MecRcDtID AS INT
AS
    SELECT MR.MecRcDetailsID AS 'mã phiếu khám bệnh', 
                              MD.MedName AS 'Tên thuốc' ,
                              PC.MedQty  AS 'SL thuốc/lần',
                              PC.isMorn AS 'Sáng',
                              PC.isNoon AS 'Trưa',
                              PC.isAftNoon AS 'Chiều',
                              PC.DayQty AS 'Số ngày',
							  D.UserName AS 'Bác sĩ',
							  CONVERT(VARCHAR(10),MR.DayCreated,103) AS 'Ngày chẩn đoán',
							  ds.DiseName AS 'Chẩn đoán'
							  
	FROM dbo.MEDICAL_RECORD_DETAILS AS MR JOIN dbo.PRESCRIPTION AS PC ON MR.MecRcDetailsID = PC.MecRcDtID 
			JOIN dbo.MEDICINE AS MD ON MD.MedID = PC.MedID
			JOIN dbo.USER_DrCare AS D ON D.UserID = MR.DoctorID
			JOIN dbo.DISEASE AS ds ON ds.DiseaseID = mr.DiseaseID
	WHERE MR.MecRcDetailsID = @MecRcDtID
GO

/** CHƯA TEST */
-- lấy LIST remind của Phiếu khám bệnh cụ thể
CREATE PROCEDURE sp_getRemindListByMecRcDetailsID
    @MecRcDetailsID AS INT
AS
    SELECT R.RemindID ,
           R.TimeRemind ,
           R.isRepeat ,
           R.Sound ,
           R.Label ,
           R.isActivate
	FROM dbo.REMIND_DETAILS RD JOIN dbo.REMIND R ON RD.RemindID = R.RemindID
		JOIN dbo.MEDICAL_RECORD_DETAILS MR ON RD.MecRcDetailsID = MR.MecRcDetailsID
	WHERE RD.MecRcDetailsID = @MecRcDetailsID
GO

-- ADD Remind mới vào 1 phiếu khám bệnh cụ thể : table REMIND + Details
-- case: ADD: @MecRcDtID NOT NULL
-- case: UPDATE: @remindID NOT NULL
CREATE PROCEDURE sp_REMIND_RemindDetails_AddNewRemind
	@MecRcDtID AS INT = NULL,
	@remindID AS INT = NULL,
    @TimeRemind AS TIME,
	@isRepeat AS INT,
	@sound AS VARCHAR(30),
	@label AS VARCHAR(30),
	@isActivate AS BIT = NULL -- nếu NULL thì set isActivate = 1 (default là đã activate)
AS
BEGIN

	IF @remindID IS NULL -- TH: thêm mới
		BEGIN 
			DECLARE @Table TABLE (ID INT);
			DECLARE @newRemindID INT;
			-- add dòng mới vào Remind
			INSERT INTO dbo.REMIND
				( TimeRemind ,
				  isRepeat ,
				  Sound ,
				  Label ,
				  isActivate
				)
			OUTPUT Inserted.RemindID INTO @Table
			VALUES  ( @TimeRemind , -- TimeRemind - time(7)
					  @isRepeat , -- isRepeat - int
					  @sound , -- Sound - varchar(30)
					  @label , -- Label - varchar(50)
					  ISNULL(@isActivate, 1)  -- isActivate - bit
					)
						
			SET @newRemindID = (SELECT ID FROM @Table)

			-- add Remind mới add vào table REMIND DETAILS
			INSERT INTO dbo.REMIND_DETAILS
		        ( MecRcDetailsID, RemindID )
			VALUES  ( @MecRcDtID, -- MecRcDetailsID - int
					  @newRemindID  -- RemindID - int
					  )
		END

	ELSE -- TH: update remind
		BEGIN
			UPDATE dbo.REMIND
			SET TimeRemind = @TimeRemind,
				isRepeat = @isRepeat,
				Sound = @sound,
				Label = @label,
				isActivate = @isActivate
			WHERE RemindID = @remindID
		END
	END	
GO
/** CHƯA TEST -- end */

/** THIẾU: GET/Add REPEAT TIME*/


--DROP PROCEDURE dbo.sp_getPrecriptionByMecRcDetailsID

--DROP PROCEDURE dbo.sp_PRESCRIPTION_AddNewIncription
SELECT * FROM dbo.USER_DrCare
SELECT * FROM dbo.DISEASE
SELECT * FROM dbo.REMIND
SELECT * FROM dbo.MEDICAL_RECORD_DETAILS
SELECT * FROM dbo.PRESCRIPTION
GO




-- TRANSACTION
--BEGIN TRANSACTION;
--BEGIN TRY
	
--END TRY
	
--BEGIN CATCH
--	 SELECT   
--        ERROR_NUMBER() AS ErrorNumber  
--        ,ERROR_SEVERITY() AS ErrorSeverity  
--        ,ERROR_STATE() AS ErrorState  
--        ,ERROR_PROCEDURE() AS ErrorProcedure  
--        ,ERROR_LINE() AS ErrorLine  
--        ,ERROR_MESSAGE() AS ErrorMessage;  

--    IF @@TRANCOUNT > 0  
--        ROLLBACK TRANSACTION;  
--END CATCH;

--IF @@TRANCOUNT > 0
--	COMMIT TRANSACTION;
--GO

