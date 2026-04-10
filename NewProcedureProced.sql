
GO
CREATE PROCEDURE AddNewProcedure
    @HistoryID INT,                  
    @ProcedureDate DATE,          
    @ProcedureTypeID INT            
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        -- Проверяем, существует ли запись в MedicalHistory
        IF NOT EXISTS (SELECT 1 FROM MedicalHistory WHERE HistoryID = @HistoryID)
        BEGIN
            PRINT 'Error: Medical history record not found.';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        -- Проверяем, существует ли тип процедуры в таблице ProceduresPrice
        IF NOT EXISTS (SELECT 1 FROM ProceduresPrice WHERE ProcedureTypeID = @ProcedureTypeID)
        BEGIN
            PRINT 'Error: Procedure type not found.';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        -- Курсор для проверки существующих записей
        DECLARE @Exists BIT;
        DECLARE CheckCursor CURSOR FOR
        SELECT 1 FROM Procedures
        WHERE HistoryID = @HistoryID AND ProcedureTypeID = @ProcedureTypeID AND ProcedureData = @ProcedureDate;
        OPEN CheckCursor;
        FETCH NEXT FROM CheckCursor INTO @Exists;
        IF @Exists = 1
        BEGIN
            PRINT 'Error: Duplicate procedure entry.';
            CLOSE CheckCursor;
            DEALLOCATE CheckCursor;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        CLOSE CheckCursor;
        DEALLOCATE CheckCursor;
        -- Добавляем новую запись о процедуре в таблицу Procedures
        INSERT INTO Procedures (HistoryID, ProcedureData, ProcedureTypeID)
        VALUES (@HistoryID, @ProcedureDate, @ProcedureTypeID);
        -- Проверяем, была ли добавлена запись
        IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'Error: Unable to insert new procedure.';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        PRINT 'New procedure added successfully.';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred: ' + ERROR_MESSAGE();
        ROLLBACK TRANSACTION;
    END CATCH
END
GO


EXEC AddNewProcedure
    @HistoryID = 3,
    @ProcedureDate = '2024-12-21',
    @ProcedureTypeID = 1;

Select * from [dbo].[Procedures]
select * from [dbo].[MedicalHistory]
select * from [dbo].[ProceduresPrice]


EXEC AddNewProcedure
    @HistoryID = 16,
    @ProcedureDate = '2024-12-23',
    @ProcedureTypeID = 1;

EXEC AddNewProcedure
    @HistoryID = 16,
    @ProcedureDate = '2024-12-23',
    @ProcedureTypeID = 5;

