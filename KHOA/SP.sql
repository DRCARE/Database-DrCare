CREATE PROCEDURE sp_REMIND_AddNewRemind
	@RemindID int,
	@TimeRemind varchar(6) = NULL,
	@isRepeat INT = 1,
	@Sound varchar(30),
	@Label varchar(100),
	@isActivate BIT = 1
AS
BEGIN TRANSACTION;
	BEGIN TRY
	IF @RemindID IS NOT NULL
		UPDATE [DRCARE].[dbo].[REMIND]
		SET TimeRemind = @timeRemind , -- TimeRemind - varchar(6)
			isRepeat = 2, -- isRepeat - int
			Sound = @Sound , -- Sound - varchar(30)
			Label = @Label , -- Label - varchar(100)
			isActivate = @isActivate  -- isActivate - bit
		WHERE RemindID = @RemindID;
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
GO

EXECUTE dbo.sp_REMIND_AddNewRemind @RemindID = 1, -- int
    @TimeRemind = '7:00', -- varchar(6)
	@isRepeat = 2,
    @Sound = 'ABC', -- varchar(30)
    @Label = 'DEF', -- varchar(100)
    @isActivate = 1 -- bit

SELECT * FROM [DRCARE].[dbo].[REMIND]