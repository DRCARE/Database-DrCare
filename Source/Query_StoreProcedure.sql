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

-- thêm 1 dòng thuốc vào Đơn thuốc
CREATE PROCEDURE sp_PRESCRIPTION_AddNewIncription
	@MecRcDtID AS INT,
	@MedID AS INT,
	@MedQty AS INT,
	@isMorn AS BIT = NULL,
	@isNoon AS BIT = NULL,
	@isAftNoon AS BIT = NULL,
	@DayQty AS SMALLINT
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		IF (SELECT isTaken FROM dbo.MEDICAL_RECORD_DETAILS WHERE MecRcDetailsID = @MecRcDtID) = 0
			UPDATE dbo.MEDICAL_RECORD_DETAILS
			SET isTaken = 1
			WHERE MecRcDetailsID = @MecRcDtID
		 
		INSERT INTO dbo.PRESCRIPTION
	        ( MecRcDtID ,
	          MedID ,
	          MedQty ,
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
	@DayCreated AS DATE = NULL
AS    
BEGIN	
	IF @MecRcID IS NOT NULL
		BEGIN
			IF @DayCreated IS NOT NULL
				SELECT MR.MecRcDetailsID ,
						mr.MecRcID,
                       MR.DiseaseID ,
                       MR.DoctorID ,
                       MR.Symptoms ,
                       CONVERT(VARCHAR(10),MR.DayCreated,103) ,
					   MR.isTaken
				FROM dbo.MEDICAL_RECORD_DETAILS MR JOIN dbo.USER_DrCare US ON mr.MecRcID = US.UserID
				WHERE MR.MecRcID = @MecRcID AND MR.DayCreated = @DayCreated
				ORDER BY MR.DayCreated DESC
			ELSE
				SELECT MR.MecRcDetailsID ,
						mr.MecRcID,
                       MR.DiseaseID ,
                       MR.DoctorID ,
                       MR.Symptoms ,
                       CONVERT(VARCHAR(10),MR.DayCreated,103) ,
					   MR.isTaken 
				FROM dbo.MEDICAL_RECORD_DETAILS MR JOIN dbo.USER_DrCare US ON mr.MecRcID = US.UserID
				WHERE MR.MecRcID = @MecRcID 				
				ORDER BY MR.DayCreated DESC
        END
        
	IF @DoctorID IS NOT NULL
		BEGIN
			SELECT MR.MecRcDetailsID ,
						mr.MecRcID,
                       MR.DiseaseID ,
                       MR.DoctorID ,
                       MR.Symptoms ,
                       CONVERT(VARCHAR(10),MR.DayCreated,103) ,
					   MR.isTaken
				FROM dbo.MEDICAL_RECORD_DETAILS MR JOIN dbo.USER_DrCare US ON mr.MecRcID = US.UserID
				WHERE MR.MecRcID = @DoctorID AND MR.DayCreated = @DayCreated
				ORDER BY MR.DayCreated ASC
		END
END
GO

-- lấy LIST thuốc của Phiếu khám bệnh cụ thể
CREATE PROCEDURE sp_getPrecriptionByMecRcDetailsID
    @MecRcDtID AS INT
AS
    SELECT MR.MecRcDetailsID AS 'mã phiếu khám bệnh', 
                              MD.MedName AS 'Tên thuốc' ,
                              PC.MedQty AS 'SL',
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


EXEC dbo.sp_MEDICAL_RECORD_DETAILS_AddNewMedicalRecord @MecRcID = 11, -- int
    @DiseaseID = 6, -- int
    @DoctorID = 1 -- int
EXEC dbo.sp_PRESCRIPTION_AddNewIncription @MecRcDtID = 1, -- int
    @MedID = 6, -- int
    @MedQty = 21, -- int
    @isMorn = 1, -- bit
    @isNoon = 1, -- bit
    @isAftNoon = 1, -- bit
    @DayQty = 7 -- bit
EXEC dbo.sp_PRESCRIPTION_AddNewIncription @MecRcDtID = 1, -- int
    @MedID = 3, -- int
    @MedQty = 14, -- int
    @isMorn = 1, -- bit
    @isNoon = NULL, -- bit
    @isAftNoon = 1, -- bit
    @DayQty = 7 -- bit
EXEC dbo.sp_PRESCRIPTION_AddNewIncription @MecRcDtID = 1, -- int
    @MedID = 12, -- int
    @MedQty = 14, -- int
    @isMorn = 1, -- bit
    @isNoon = NULL, -- bit
    @isAftNoon = 1, -- bit
    @DayQty = 7 -- bit

EXEC dbo.sp_PRESCRIPTION_AddNewIncription @MecRcDtID = 2, -- int
    @MedID = 9, -- int
    @MedQty = 12, -- int
    @isMorn = 1, -- bit
    @isNoon = NULL, -- bit
    @isAftNoon = 1, -- bit
    @DayQty = 6 -- smallint

EXEC dbo.sp_PRESCRIPTION_AddNewIncription @MecRcDtID = 2, -- int
    @MedID = 14, -- int
    @MedQty = 6, -- int
    @isMorn = NULL, -- bit
    @isNoon = 1, -- bit
    @isAftNoon = NULL, -- bit
    @DayQty = 6 -- smallint

GO

EXEC dbo.sp_getPrecriptionByMecRcDetailsID @MecRcDtID = 2 -- int
GO

--DROP PROCEDURE dbo.sp_getPrecriptionByMecRcDetailsID

--DROP PROCEDURE dbo.sp_PRESCRIPTION_AddNewIncription
SELECT * FROM dbo.USER_DrCare
SELECT * FROM dbo.DISEASE
SELECT * FROM dbo.USER_DrCare
SELECT * FROM dbo.DISEASE
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
