-- exec Procedure

USE DRCARE
GO

-- ADD MEDICAL_RECORD
EXEC dbo.sp_MEDICAL_RECORD_DETAILS_AddNewMedicalRecord @MecRcID = 11, -- int
    @DiseaseID = 6, -- int
    @DoctorID = 1 -- int

EXEC dbo.sp_MEDICAL_RECORD_DETAILS_AddNewMedicalRecord @MecRcID = 10, -- int
    @DiseaseID = 2, -- int
    @DoctorID = 4 -- int

EXEC dbo.sp_MEDICAL_RECORD_DETAILS_AddNewMedicalRecord @MecRcID = 9, -- int
    @DiseaseID = 4, -- int
    @DoctorID = 4 -- int
GO


-- addd precription
EXEC dbo.sp_PRESCRIPTION_AddNewIncription @MecRcDtID = 1, -- int
    @MedID = 6, -- int
    @MedQty = 1.0, -- float
    @TimeTakeMedicine = 3, -- smallint
    @SumMedQty = 21 -- smallint


EXEC dbo.sp_PRESCRIPTION_AddNewIncription @MecRcDtID = 1, -- int
    @MedID = 3, -- int
    @MedQty = 1.0, -- float
    @TimeTakeMedicine = 2, -- smallint
    @SumMedQty = 14 -- smallint


EXEC dbo.sp_PRESCRIPTION_AddNewIncription @MecRcDtID = 1, -- int
    @MedID = 12, -- int
    @MedQty = 1.0, -- float
    @TimeTakeMedicine = 2, -- smallint
    @SumMedQty = 14 -- smallint


EXEC dbo.sp_PRESCRIPTION_AddNewIncription @MecRcDtID = 2, -- int
    @MedID = 9, -- int
    @MedQty = 1.0, -- float
    @TimeTakeMedicine = 2, -- smallint
    @SumMedQty = 12 -- smallint


EXEC dbo.sp_PRESCRIPTION_AddNewIncription @MecRcDtID = 2, -- int
    @MedID = 14, -- int
    @MedQty = 1.0, -- float
    @TimeTakeMedicine = 1, -- smallint
    @SumMedQty = 6 -- smallint
GO

-- add remind


-- GET METHOD	

/* GET Medical Method Details */
-- [DOCTOR] Lấy Danh sách Bệnh nhân (MedicalRecord) 
-- param IN: @DoctorID + @DayCreated
-- Result: đã được sort theo thứ tự trước sau (FIFO)
EXEC dbo.sp_Get_Search_MedicalRecordDetails 
	@MecRcID = NULL, -- int
    @DoctorID = 4, -- int
    @DayCreated = '26/07/2017' -- VARCHAR(15)


-- [PATIENT] Lấy ALL phiếu bệnh của Người đó 
-- param IN: @MecRcID (ID of Patient)
EXEC dbo.sp_Get_Search_MedicalRecordDetails
	@MecRcID = 11, -- int
    @DoctorID = NULL, -- int
    @DayCreated = NULL -- varchar(15)

-- [PATIENT] Lấy ALL phiếu bệnh của Người đó 
-- param IN: @MecRcID (ID of Patient) + @DayCreated (ngày muốn search)
EXEC dbo.sp_Get_Search_MedicalRecordDetails 
	@MecRcID = 11, -- int
    @DoctorID = NULL, -- int
    @DayCreated = '19/06/2017' -- varchar(15)

/** GET Đơn thuốc theo 1 Phiếu khám được nhất định */
EXEC dbo.sp_getPrecriptionByMecRcDetailsID @MecRcDtID = 2 -- int
GO

EXEC dbo.sp_getPrecriptionByMecRcDetailsID @MecRcDtID = 1 -- int
GO

/* GET List Nhắc nhở của 1 Phiếu khám được nhất định*/
EXEC dbo.sp_getRemindListByMecRcDetailsID @MecRcDetailsID = 1  -- int
GO