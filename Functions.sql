CREATE FUNCTION CalculatePatientBill(@AdmissionID INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @TotalAmount DECIMAL(10, 2)
    SET @TotalAmount = 0
    -- Суммирование стоимости всех процедур, выполненных для поступления (Admission)
    SELECT @TotalAmount = SUM(PP.ProcedureCost)
    FROM Procedures Pr
    JOIN ProceduresPrice PP 
    ON Pr.ProcedureTypeID = PP.ProcedureTypeID
    JOIN MedicalHistory MH ON Pr.HistoryID = MH.HistoryID
    WHERE MH.AdmissionID = @AdmissionID
    -- Возвращаем итоговую сумму счета для этого поступления
    RETURN @TotalAmount
END;

GO
SELECT dbo.CalculatePatientBill(15) AS TotalBillAmount;
select * from [dbo].[Procedures]
SELECT * from [dbo].[MedicalHistory]

GO
CREATE FUNCTION CalculatePatientBillByStayDuration(@AdmissionID INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @TotalAmount DECIMAL(10, 2)
    DECLARE @Duration INT
    DECLARE @DailyRate DECIMAL(10, 2)
    DECLARE @WardID INT
    -- Получаем ID палаты для данного пациента
    SELECT @WardID = WardID
    FROM Admission
    WHERE AdmissionID = @AdmissionID
    -- Стоимость в зависимости от типа палаты (количества мест)
    SELECT 
        @DailyRate = CASE 
            WHEN WardNumberOfBeds = 1 THEN 100
            WHEN WardNumberOfBeds = 2 THEN 60
            WHEN WardNumberOfBeds = 3 THEN 50
            WHEN WardNumberOfBeds = 4 THEN 35
            ELSE 0
        END
    FROM Wards
    WHERE WardID = @WardID
    -- Рассчитываем длительность пребывания пациента в днях
    SELECT @Duration = DATEDIFF(DAY, DateOfAdmission, DateOfDischarge)
    FROM Admission
    WHERE AdmissionID = @AdmissionID
    -- Если длительность пребывания больше или равна 0, рассчитываем сумму
    IF @Duration >= 0 AND @DailyRate > 0
    BEGIN
        SET @TotalAmount = @Duration * @DailyRate
    END
    ELSE
    BEGIN
        -- Если дата выписки не указана или дата госпитализации неверна
        SET @TotalAmount = 0
    END
    -- Возвращаем итоговую сумму
    RETURN @TotalAmount
END


GO
SELECT  dbo.CalculatePatientBillByStayDuration(10) AS TotalBillAmount;
SELECT * from  [dbo].[Admission]


GO
CREATE FUNCTION CheckRoomAvailability(@WardID INT)
RETURNS BIT
AS
BEGIN
    DECLARE @Available BIT
    DECLARE @TotalBeds INT
    DECLARE @OccupiedBeds INT
    -- Получаем общее количество мест и количество занятых мест в палате
    SELECT @TotalBeds = WardNumberOfBeds, @OccupiedBeds = IsOccupied
    FROM Wards
    WHERE WardID = @WardID

    -- Если количество занятых мест меньше общего количества мест, значит, есть свободные места
    IF @OccupiedBeds < @TotalBeds
    BEGIN
        SET @Available = 1 -- Свободные места есть
    END
    ELSE
    BEGIN
        SET @Available = 0 -- Свободных мест нет
    END
    -- Возвращаем результат (1 - есть свободные места, 0 - нет)
    RETURN @Available
END

GO
SELECT dbo.CheckRoomAvailability(1) AS IsRoomAvailable;


GO
CREATE FUNCTION GetPatientsByAdmissionPeriod
(
    @StartDate DATE,  -- Дата начала периода
    @EndDate DATE     -- Дата окончания периода
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        P.PatientID, P.FullName, P.DateOfBirth, P.Gender, P.PhoneNumber, P.Address, P.Height, P.Weight,  
        P.BloodGroup,A.DateOfAdmission, A.DateOfDischarge, A.WardID
    FROM Patient P
    JOIN Admission A 
    ON P.PatientID = A.PatientID  
    WHERE A.DateOfAdmission BETWEEN @StartDate AND @EndDate -- Фильтрация по датам госпитализации
);

GO
SELECT * 
FROM dbo.GetPatientsByAdmissionPeriod('2024-12-01', '2024-12-10');

SELECT FullName, DateOfAdmission, DateOfDischarge
FROM dbo.GetPatientsByAdmissionPeriod('2024-12-01', '2024-12-10')
WHERE Gender = 'Male';
