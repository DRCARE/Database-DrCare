-- STORE PROC

USE DRCARE
GO
SELECT * FROM dbo.INGREDIENT ORDER BY IngredID ASC
GO

-- thêm 1 dòng Phiếu khám bệnh mới theo Mã bệnh nhân input
CREATE PROCEDURE sp_MEDICAL_RECORD_DETAILS_AddNewMedicalRecord
    @MecRcID AS INT,
	@DiseaseID AS int,
	@DoctorID AS INT
AS
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
GO

-- Lấy thông tin phiếu Khám bệnh: mã phiếu khám, tên bệnh nhân, tên thuốc, SL thuốc, SL ngày, sáng - trưa - chiều, tên BS, ngày chẩn đoán, bệnh
-- TODO: nên TÁCH RA: lấy infor PHIẾU KHÁM || lấy LIST thuốc
CREATE PROCEDURE sp_getPrecriptionByMecRcDetailsID
    @MecRcDtID AS INT
AS
	SELECT MR.MecRcDetailsID AS 'mã phiếu khám bệnh', 
	( SELECT u.UserName FROM dbo.MEDICAL_RECORD_DETAILS m JOIN dbo.USER_DrCare u ON m.MecRcID = u.UserID) AS 'Patient Name',
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

--DROP PROCEDURE dbo.sp_getPrecriptionByMecRcDetailsID

--DROP PROCEDURE dbo.sp_PRESCRIPTION_AddNewIncription
SELECT * FROM dbo.USER_DrCare
SELECT * FROM dbo.DISEASE


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
GO

EXEC dbo.sp_getPrecriptionByMecRcDetailsID @MecRcDtID = 1 -- int



SELECT * FROM dbo.MEDICAL_RECORD_DETAILS
SELECT * FROM dbo.PRESCRIPTION
