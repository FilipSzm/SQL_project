--USE master

--IF EXISTS (SELECT name FROM sys.databases WHERE name = N'Uproszczony system bankowy')
--    DROP DATABASE [Uproszczony system bankowy]

--IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'Uproszczony system bankowy')
--	CREATE DATABASE [Uproszczony system bankowy]

USE [Uproszczony system bankowy]

IF OBJECT_ID('[Dane Klient�w]','U') IS NOT NULL DROP TABLE [Dane Klient�w]
IF OBJECT_ID('[Dane Firm]','U') IS NOT NULL DROP TABLE [Dane Firm]
IF OBJECT_ID('[Zapisane Konta]','U') IS NOT NULL DROP TABLE [Zapisane Konta]
IF OBJECT_ID('[Historia Transakcji]','U') IS NOT NULL DROP TABLE [Historia Transakcji]
IF OBJECT_ID('[Karty Kredytowe]','U') IS NOT NULL DROP TABLE [Karty Kredytowe]
IF OBJECT_ID('Kredyty','U') IS NOT NULL DROP TABLE Kredyty
IF OBJECT_ID('Wp�aty','U') IS NOT NULL DROP TABLE Wp�aty
IF OBJECT_ID('Wyp�aty','U') IS NOT NULL DROP TABLE Wyp�aty
IF OBJECT_ID('Konta','U') IS NOT NULL DROP TABLE Konta
IF OBJECT_ID('W�a�ciciele','U') IS NOT NULL DROP TABLE W�a�ciciele;
IF OBJECT_ID('FK_Dzia�y_Szef', 'F') IS NOT NULL 
IF OBJECT_ID('CheckFunction1', 'FN') IS NOT NULL DROP FUNCTION CheckFunction1
IF OBJECT_ID('CheckFunction2', 'FN') IS NOT NULL DROP FUNCTION CheckFunction2

IF OBJECT_ID('[Szefowie Dzia��w]', 'V') IS NOT NULL DROP VIEW [Szefowie Dzia��w]
IF OBJECT_ID('[Lokalizacje Dzia��w]', 'V') IS NOT NULL DROP VIEW [Lokalizacje Dzia��w]
IF OBJECT_ID('[W�a�ciciele Firm]', 'V') IS NOT NULL DROP VIEW [W�a�ciciele Firm]
IF OBJECT_ID('[Lista Kont i Rodzaj W�a�ciciela]', 'V') IS NOT NULL DROP VIEW [Lista Kont i Rodzaj W�a�ciciela]
IF OBJECT_ID('Stan_Konta', 'FN') IS NOT NULL DROP FUNCTION Stan_Konta
IF OBJECT_ID('W�a�ciciel_Konta', 'TF') IS NOT NULL DROP FUNCTION W�a�ciciel_Konta
IF OBJECT_ID('Wszystkie_Transakcje_Konta', 'TF') IS NOT NULL DROP FUNCTION Wszystkie_Transakcje_Konta
IF OBJECT_ID('Wszystkie_Konta_Klienta_Firmy', 'TF') IS NOT NULL DROP FUNCTION Wszystkie_Konta_Klienta_Firmy

IF OBJECT_ID('TR_Wp�aty','TR') IS NOT NULL DROP TRIGGER TR_Wp�aty
IF OBJECT_ID('TR_Wyp�aty','TR') IS NOT NULL DROP TRIGGER TR_Wyp�aty
IF OBJECT_ID('TR_Transakcje','TR') IS NOT NULL DROP TRIGGER TR_Transakcje
IF OBJECT_ID('TR_Kredyty','TR') IS NOT NULL DROP TRIGGER TR_Kredyty
IF OBJECT_ID('TR_Kredyty_Sp�ata','TR') IS NOT NULL DROP TRIGGER TR_Kredyty_Sp�ata

IF OBJECT_ID('Wp�ata','P') IS NOT NULL DROP PROC Wp�ata
IF OBJECT_ID('Wyp�ata','P') IS NOT NULL DROP PROC Wyp�ata
IF OBJECT_ID('Przelew','P') IS NOT NULL DROP PROC Przelew
IF OBJECT_ID('Pobranie_Kredytu','P') IS NOT NULL DROP PROC Pobranie_Kredytu
IF OBJECT_ID('Sp�ata_Kredytu','P') IS NOT NULL DROP PROC Sp�ata_Kredytu

BEGIN
	ALTER TABLE Dzia�y
	DROP CONSTRAINT FK_Dzia�y_Szef
END
GO
IF OBJECT_ID('[Pracownicy Dane]','U') IS NOT NULL DROP TABLE [Pracownicy Dane]
IF OBJECT_ID('Dzia�y','U') IS NOT NULL DROP TABLE Dzia�y

CREATE TABLE W�a�ciciele (
	Rodzaj_W�a�ciciela NVARCHAR(20) NOT NULL,
	ID_W�a�ciciela INT UNIQUE NOT NULL,
	CONSTRAINT PK_W�a�ciciele PRIMARY KEY(ID_W�a�ciciela),
	CONSTRAINT CHK_Poprawno�� CHECK ((Rodzaj_W�a�ciciela = 'Osoba Prywatna') OR (Rodzaj_W�a�ciciela = 'Firma')),
	CONSTRAINT CHK_Przedzia� CHECK ((Rodzaj_W�a�ciciela = 'Osoba Prywatna' AND ID_W�a�ciciela <= 10000) OR (Rodzaj_W�a�ciciela = 'Firma' AND ID_W�a�ciciela > 10000))
)

CREATE TABLE Konta (
	ID_Konta INT UNIQUE NOT NULL,
	Dost�pne_�rodki MONEY NOT NULL,
	ID_W�a�ciciela INT NOT NULL,
	CONSTRAINT PK_Konta PRIMARY KEY(ID_Konta),
	CONSTRAINT FK_Konta_W�a�ciciela FOREIGN KEY (ID_W�a�ciciela) REFERENCES W�a�ciciele(ID_W�a�ciciela) 
)

CREATE TABLE [Dane Firm] (
	ID_Firmy INT UNIQUE NOT NULL,
	Nazwa_Firmy NVARCHAR(100) NOT NULL,
	Miasto NVARCHAR(100) NOT NULL,
	Ulica NVARCHAR(100) NOT NULL,
	Numer_Budynku CHAR(10) NOT NULL,
	Numer_Mieszkania CHAR(10) NULL,
	Kod_Pocztowy CHAR(15) NOT NULL,
	Kraj NVARCHAR(50) NOT NULL,
	Numer_Telefonu INT NOT NULL,
	CONSTRAINT PK_Dane_Firm PRIMARY KEY(ID_Firmy),
	CONSTRAINT FK_Firma_Firmy FOREIGN KEY (ID_Firmy) REFERENCES W�a�ciciele(ID_W�a�ciciela) 
)

CREATE TABLE [Dane Klient�w] (
	ID_Klienta INT UNIQUE NOT NULL,
	Imi� NVARCHAR(100) NOT NULL,
	Nazwisko NVARCHAR(100) NOT NULL,
	PESEL CHAR(11) UNIQUE NOT NULL,
	Miasto NVARCHAR(100) NOT NULL,
	Ulica NVARCHAR(100) NOT NULL,
	Numer_Budynku CHAR(10) NOT NULL,
	Numer_Mieszkania CHAR(10) NULL,
	Kod_Pocztowy CHAR(15) NOT NULL,
	Kraj NVARCHAR(50) NOT NULL,
	Numer_Telefonu INT NOT NULL,
	ID_Firmy INT NULL,
	CONSTRAINT PK_Dane_Klient�w PRIMARY KEY(ID_Klienta),
	CONSTRAINT FK_Klient_Firmy FOREIGN KEY (ID_Firmy) REFERENCES [Dane Firm](ID_Firmy), 
	CONSTRAINT FK_Klient_Kienta FOREIGN KEY (ID_Klienta) REFERENCES W�a�ciciele(ID_W�a�ciciela) 
)

CREATE UNIQUE INDEX MoreNulls ON [Dane Klient�w](ID_Firmy) WHERE ID_Firmy IS NOT NULL;

CREATE TABLE [Zapisane Konta] (
	ID_Konta_Zapisuj�cego INT NOT NULL,
	ID_Konta_Zapisanego INT NOT NULL,
	Nazwa NVARCHAR(255) NULL,
	CONSTRAINT PK_Zapisane_Konta PRIMARY KEY(ID_Konta_Zapisuj�cego, ID_Konta_Zapisanego),
	CONSTRAINT FK_Zapisane_Konto1 FOREIGN KEY (ID_Konta_Zapisuj�cego) REFERENCES Konta(ID_Konta),
	CONSTRAINT FK_Zapisane_Konto2 FOREIGN KEY (ID_Konta_Zapisanego) REFERENCES Konta(ID_Konta)
)

CREATE TABLE [Historia Transakcji] (
	ID_Transakcji INT UNIQUE NOT NULL,
	ID_Konta_Z INT NOT NULL,
	ID_Konta_DO INT NOT NULL,
	Kwota MONEY NOT NULL,
	Data DATETIME NOT NULL,
	CONSTRAINT PK_Historia_Transakcji PRIMARY KEY(ID_Transakcji),
	CONSTRAINT FK_Historia_Konto1 FOREIGN KEY (ID_Konta_Z) REFERENCES Konta(ID_Konta),
	CONSTRAINT FK_Historia_Konto2 FOREIGN KEY (ID_Konta_DO) REFERENCES Konta(ID_Konta) 
)

CREATE TABLE [Karty Kredytowe] (
	ID_Karty INT UNIQUE NOT NULL,
	ID_Konta INT UNIQUE NOT NULL,
	Limit_Dzienny MONEY NULL,
	CONSTRAINT PK_Karty_Kredytowe PRIMARY KEY(ID_KARTY),
	CONSTRAINT FK_Karty_Konto FOREIGN KEY (ID_Konta) REFERENCES Konta(ID_Konta)
)

CREATE TABLE Kredyty (
	ID_Kredytu INT UNIQUE NOT NULL,
	ID_Konta INT NOT NULL,
	Kwota MONEY NOT NULL,
	Do_Sp�acenia MONEY NOT NULL,
	Ilo��_Sp�acona MONEY NOT NULL,
	Pocz�tek DATETIME NOT NULL,
	Planowany_Koniec DATETIME NOT NULL,
	Kara MONEY NOT NULL,
	Stan NVARCHAR(10) NOT NULL,
	CONSTRAINT PK_Kredyty PRIMARY KEY(ID_Kredytu),
	CONSTRAINT FK_Kredyty_Konto FOREIGN KEY (ID_Konta) REFERENCES Konta(ID_Konta),
	CONSTRAINT CHK_Poprawno��_Kredytu CHECK ((Stan = 'Aktywny') OR (Stan = 'Nieaktywny'))
)

CREATE TABLE Dzia�y (
	Nazwa_Dzia�u NVARCHAR(100) UNIQUE NOT NULL,
	Miasto NVARCHAR(100) NOT NULL,
	Ulica NVARCHAR(100) NOT NULL,
	Numer_Budynku CHAR(10) NOT NULL,
	Numer_Mieszkania CHAR(10) NULL,
	Kod_Pocztowy CHAR(15) NOT NULL,
	Kraj NVARCHAR(50) NOT NULL,
	Numer_Telefonu INT NOT NULL,
	ID_Szefa INT NULL,
	CONSTRAINT PK_Dzia�y PRIMARY KEY(Nazwa_Dzia�u)
)

CREATE TABLE [Pracownicy Dane] (
	ID_Pracownika INT UNIQUE NOT NULL,
	Imi� NVARCHAR(100) NOT NULL,
	Nazwisko NVARCHAR(100) NOT NULL,
	PESEL CHAR(11) UNIQUE NOT NULL,
	Zarobki MONEY NOT NULL,
	Nazwa_Dzia�u NVARCHAR(100) NOT NULL,
	Miasto NVARCHAR(100) NOT NULL,
	Ulica NVARCHAR(100) NOT NULL,
	Numer_Budynku CHAR(10) NOT NULL,
	Numer_Mieszkania CHAR(10) NULL,
	Kod_Pocztowy CHAR(15) NOT NULL,
	Kraj NVARCHAR(50) NOT NULL,
	Numer_Telefonu INT NOT NULL,
	CONSTRAINT PK_Pracownicy_Dane PRIMARY KEY(ID_Pracownika),
	CONSTRAINT FK_Pracownicy FOREIGN KEY (Nazwa_Dzia�u) REFERENCES Dzia�y(Nazwa_Dzia�u)
)

ALTER TABLE Dzia�y
ADD CONSTRAINT FK_Dzia�y_Szef FOREIGN KEY (ID_Szefa) REFERENCES [Pracownicy Dane](ID_Pracownika);

CREATE TABLE Wp�aty (
	ID_Wp�aty INT UNIQUE NOT NULL,
	ID_Konta INT NOT NULL,
	Kwota MONEY NOT NULL,
	ID_Pracownika_Nadzoruj�cego INT NOT NULL,
	CONSTRAINT PK_Wp�aty PRIMARY KEY(ID_Wp�aty),
	CONSTRAINT FK_Wp�aty_Konta FOREIGN KEY (ID_Konta) REFERENCES Konta(ID_Konta),
	CONSTRAINT FK_Wp�aty_Pracownicy FOREIGN KEY (ID_Pracownika_Nadzoruj�cego) REFERENCES [Pracownicy Dane](ID_Pracownika),
)

CREATE TABLE Wyp�aty (
	ID_Wyp�aty INT UNIQUE NOT NULL,
	ID_Konta INT NOT NULL,
	Kwota MONEY NOT NULL,
	ID_Pracownika_Nadzoruj�cego INT NOT NULL,
	CONSTRAINT PK_Wyp�aty PRIMARY KEY(ID_Wyp�aty),
	CONSTRAINT FK_Wyp��ty_Konta FOREIGN KEY (ID_Konta) REFERENCES Konta(ID_Konta),
	CONSTRAINT FK_Wyp�aty_Pracownicy FOREIGN KEY (ID_Pracownika_Nadzoruj�cego) REFERENCES [Pracownicy Dane](ID_Pracownika)
)

GO
CREATE FUNCTION CheckFunction1 (@ID_Pracownika INT)
RETURNS INT 
AS
BEGIN 
	DECLARE @Returned TINYINT = 0
	IF EXISTS (SELECT ID_Pracownika FROM [Pracownicy Dane] WHERE (ID_Pracownika = @ID_Pracownika) AND Nazwa_Dzia�u LIKE N'Obs�uga Klienta%')
	SET @Returned = 1
	RETURN @Returned
END
GO
CREATE FUNCTION CheckFunction2 (@ID_Konta INT)
RETURNS INT
AS
BEGIN
	DECLARE @Returned TINYINT = 0
	IF EXISTS (SELECT W.Rodzaj_W�a�ciciela FROM Konta AS K JOIN W�a�ciciele AS W ON K.ID_W�a�ciciela= W.ID_W�a�ciciela WHERE K.ID_Konta = @ID_Konta)
	BEGIN
		DECLARE @Rodzaj NVARCHAR(20) = (SELECT W.Rodzaj_W�a�ciciela FROM Konta AS K JOIN W�a�ciciele AS W ON K.ID_W�a�ciciela= W.ID_W�a�ciciela WHERE K.ID_Konta = @ID_Konta)
		IF @Rodzaj = 'Osoba Prywatna'
		SET @Returned = 1
	END
	RETURN @Returned
END
GO
ALTER TABLE Wp�aty
ADD CONSTRAINT CHK_Wp�aty CHECK (dbo.CheckFunction1(ID_Pracownika_Nadzoruj�cego) = 1)

ALTER TABLE Wyp�aty
ADD CONSTRAINT CHK_Wyp�aty CHECK (dbo.CheckFunction1(ID_Pracownika_Nadzoruj�cego) = 1)

ALTER TABLE [Karty Kredytowe]
ADD CONSTRAINT CHK_Karty CHECK (dbo.CheckFunction2(ID_Konta) = 1)


GO
CREATE VIEW [Szefowie Dzia��w] AS
SELECT D.Nazwa_Dzia�u AS Dzia�, P.Imi� AS [Imi� Kierownika], P.Nazwisko AS [Nazwisko Kierownika] FROM Dzia�y AS D JOIN [Pracownicy Dane] AS P ON D.ID_Szefa = P.ID_Pracownika
GO
CREATE VIEW [Lokalizacje Dzia��w] AS
SELECT Nazwa_Dzia�u AS [Dzia�], Miasto, Ulica, Numer_Budynku AS [Numer Budynku], Numer_Mieszkania AS [Numer Mieszkania], Kod_Pocztowy AS [Kod Pocztowy], Kraj, Numer_Telefonu AS [Numer Telefonu] FROM Dzia�y
GO
CREATE VIEW [W�a�ciciele Firm] AS
SELECT F.Nazwa_Firmy AS [Nazwa Firmy], K.Imi� AS [Imi� W�a�cieciela], K.Nazwisko AS [Nazwisko W�a�ciciela] FROM [Dane Firm] AS F LEFT JOIN [Dane Klient�w] AS K ON F.ID_Firmy = K.ID_Firmy
GO
CREATE VIEW [Lista Kont i Rodzaj W�a�ciciela] AS
SELECT K.ID_Konta AS [ID Konta], W.Rodzaj_W�a�ciciela AS [Osoba Prywatna/Firma] FROM Konta AS K JOIN W�a�ciciele AS W ON K.ID_W�a�ciciela = W.ID_W�a�ciciela
GO

CREATE FUNCTION Stan_Konta (@ID_Konta INT)
RETURNS MONEY
AS
BEGIN
	DECLARE @Returned MONEY = 0
	IF EXISTS (SELECT @ID_Konta FROM Konta WHERE ID_Konta = @ID_Konta)
	BEGIN
		SET @Returned = (
			SELECT Dost�pne_�rodki FROM Konta
			WHERE ID_Konta = @ID_Konta
		)
	END
	RETURN @Returned
END
GO
CREATE FUNCTION W�a�ciciel_Konta (@ID_Konta INT)
RETURNS @Podstawowe_Dane TABLE (
	ID_W�a�ciciela INT NULL,
	Imi�_W�a�ciciela NVARCHAR(20) NULL,
	Nazwisko_W�a�ciciela NVARCHAR(20) NULL
)
AS
BEGIN
	IF EXISTS (SELECT @ID_Konta FROM Konta WHERE ID_Konta = @ID_Konta)
	BEGIN
		DECLARE @Rodzaj_W�a�ciciela NVARCHAR(20) = (
			SELECT W.Rodzaj_W�a�ciciela FROM Konta AS K JOIN W�a�ciciele AS W ON K.ID_W�a�ciciela = W.ID_W�a�ciciela
			WHERE K.ID_Konta = @ID_Konta
		)
		IF @Rodzaj_W�a�ciciela = N'Osoba Prywatna'
		BEGIN
			INSERT INTO @Podstawowe_Dane
			SELECT D.ID_Klienta, D.Imi�, D.Nazwisko FROM Konta AS K JOIN [Dane Klient�w] AS D ON K.ID_W�a�ciciela = D.ID_Klienta
			WHERE K.ID_Konta = @ID_Konta
		END
		ELSE
		BEGIN
			INSERT INTO @Podstawowe_Dane
			SELECT DK.ID_Klienta, DK.Imi�, DK.Nazwisko FROM (Konta AS K JOIN [Dane Firm] AS DF ON K.ID_W�a�ciciela = DF.ID_Firmy) LEFT JOIN [Dane Klient�w] AS DK ON DF.ID_Firmy = DK.ID_Firmy
			WHERE K.ID_Konta = @ID_Konta
		END
	END
	ELSE
	BEGIN
		INSERT INTO @Podstawowe_Dane
		VALUES
		(NULL, NULL, NULL)
	END
	RETURN
END
GO
CREATE FUNCTION Wszystkie_Transakcje_Konta (@ID_Konta INT)
RETURNS @Transakcje TABLE (
	Rodzaj_Transakcji NVARCHAR(10) NOT NULL,
	Kwota MONEY NOT NULL,
	ID_Transakcji INT NOT NULL
)
AS
BEGIN
	INSERT INTO @Transakcje 
		SELECT N'Przelew Z', Kwota, ID_Transakcji FROM [Historia Transakcji]
		WHERE ID_Konta_Z = @ID_Konta
		UNION
		SELECT N'Przelew DO', Kwota, ID_Transakcji FROM [Historia Transakcji]
		WHERE ID_Konta_DO = @ID_Konta
		UNION
		SELECT N'Wp�ata', Kwota, ID_Wp�aty FROM Wp�aty
		WHERE ID_Konta = @ID_Konta
		UNION
		SELECT N'Wyp�ata', Kwota, ID_Wyp�aty FROM Wyp�aty
		WHERE ID_Konta = @ID_Konta
	RETURN
END
GO
CREATE FUNCTION Wszystkie_Konta_Klienta_Firmy (@ID_W�a�ciciela INT)
RETURNS @Konta TABLE (
	[ID Konta] INT NOT NULL,
	[Dost�pne �rodki] MONEY NOT NULL
)
AS
BEGIN
	INSERT INTO @Konta
	SELECT ID_Konta, Dost�pne_�rodki FROM Konta WHERE ID_W�a�ciciela = @ID_W�a�ciciela
	IF EXISTS (SELECT Rodzaj_W�a�ciciela FROM W�a�ciciele WHERE ID_W�a�ciciela = @ID_W�a�ciciela)
	BEGIN
		DECLARE @Rodzaj NVARCHAR(20) = (SELECT Rodzaj_W�a�ciciela FROM W�a�ciciele WHERE ID_W�a�ciciela = @ID_W�a�ciciela)
		IF @Rodzaj = N'Osoba Prywatna'
		INSERT INTO @Konta
		SELECT K.ID_Konta, K.Dost�pne_�rodki FROM [Dane Klient�w] AS D JOIN Konta AS K ON D.ID_Firmy = K.ID_W�a�ciciela
		WHERE D.ID_Klienta = @ID_W�a�ciciela
	END
	RETURN
END
GO

GO
CREATE TRIGGER TR_Wp�aty ON Wp�aty 
AFTER INSERT  
AS  
BEGIN
   DECLARE @ID_Konta INT = (SELECT ID_Konta FROM inserted)
   DECLARE @Kwota MONEY = (SELECT Kwota FROM inserted)
   
   UPDATE Konta
   SET Dost�pne_�rodki = Dost�pne_�rodki + @Kwota
   WHERE ID_Konta = @ID_Konta
END
GO 
CREATE TRIGGER TR_Wyp�aty ON Wyp�aty
AFTER INSERT  
AS  
BEGIN
   DECLARE @ID_Konta INT = (SELECT ID_Konta FROM inserted)
   DECLARE @Kwota MONEY = (SELECT Kwota FROM inserted)
   
   UPDATE Konta
   SET Dost�pne_�rodki = Dost�pne_�rodki - @Kwota
   WHERE ID_Konta = @ID_Konta
END
GO 
CREATE TRIGGER TR_Transakcje ON [Historia Transakcji]
AFTER INSERT  
AS  
BEGIN
   DECLARE @ID_KontaZ INT = (SELECT ID_Konta_Z FROM inserted)
   DECLARE @ID_KontaDO INT = (SELECT ID_Konta_DO FROM inserted)
   DECLARE @Kwota MONEY = (SELECT Kwota FROM inserted)
   
   UPDATE Konta
   SET Dost�pne_�rodki = Dost�pne_�rodki - @Kwota
   WHERE ID_Konta = @ID_KontaZ

   UPDATE Konta
   SET Dost�pne_�rodki = Dost�pne_�rodki + @Kwota
   WHERE ID_Konta = @ID_KontaDO
END
GO 
CREATE TRIGGER TR_Kredyty ON Kredyty
AFTER INSERT  
AS  
BEGIN
   DECLARE @ID_Konta INT = (SELECT ID_Konta FROM inserted)
   DECLARE @Kwota MONEY = (SELECT Kwota FROM inserted)
   
   UPDATE Konta
   SET Dost�pne_�rodki = Dost�pne_�rodki + @Kwota
   WHERE ID_Konta = @ID_Konta
END
GO 
CREATE TRIGGER TR_Kredyty_Sp�ata ON Kredyty
AFTER UPDATE  
AS  
BEGIN
   DECLARE @ID_Konta INT = (SELECT ID_Konta FROM inserted)
   DECLARE @Kwota_Przed MONEY = (SELECT Kwota FROM inserted)
   DECLARE @Kwota_Po MONEY = (SELECT Kwota FROM deleted)


   UPDATE Konta
   SET Dost�pne_�rodki = Dost�pne_�rodki - (@Kwota_Po - @Kwota_Przed)
   WHERE ID_Konta = @ID_Konta

   DECLARE @Sp�acono MONEY = (SELECT Ilo��_Sp�acona FROM inserted)
   DECLARE @Do_Sp�acenia MONEY = ((SELECT Do_Sp�acenia FROM inserted) + (SELECT Kara FROM inserted))

   IF @Sp�acono >= @Do_Sp�acenia
   BEGIN
	UPDATE Konta
	SET Dost�pne_�rodki = Dost�pne_�rodki + (@Sp�acono - @Do_Sp�acenia)
	WHERE ID_Konta = @ID_Konta
	UPDATE Kredyty
	SET Stan = 'Nieaktywny'
	WHERE ID_Kredytu = (SELECT ID_Kredytu FROM inserted)
	UPDATE Kredyty
	SET Ilo��_Sp�acona = @Do_Sp�acenia
	WHERE ID_Kredytu = (SELECT ID_Kredytu FROM inserted)
   END
END
GO 

CREATE PROC Wp�ata (
	@ID_Konta INT,
	@Kwota MONEY,
	@ID_Pracownika_Nadzoruj�cego INT
) 
AS
BEGIN
	BEGIN TRY
		DECLARE @Tmp VARCHAR(256)
		IF NOT EXISTS (SELECT ID_Konta FROM Konta WHERE ID_Konta = @ID_Konta)
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @ID_Konta)
			RAISERROR('Nie ma konta o numerze %s.', 16, 1, @Tmp)
		END

		IF (@Kwota <= 0) 
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @Kwota)
			RAISERROR('Wprowadzona kwota wp�aty %s nie jest dozwolona.', 15, 1, @Tmp)
		END

		IF NOT EXISTS (SELECT ID_Pracownika FROM [Pracownicy Dane] WHERE ID_Pracownika = @ID_Pracownika_Nadzoruj�cego)
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @ID_Pracownika_Nadzoruj�cego)
			RAISERROR('Nie ma pracownika o ID %s.', 16, 1, @Tmp)
		END

		DECLARE @Dzia� NVARCHAR(100) = (SELECT Nazwa_Dzia�u FROM [Pracownicy Dane] WHERE ID_Pracownika = @ID_Pracownika_Nadzoruj�cego)
		IF NOT (@Dzia� LIKE N'Obs�uga Klienta%')
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @ID_Pracownika_Nadzoruj�cego)
			RAISERROR('Pracownik o ID %s nie pracuje w dziale obs�ugi klienta.', 14, 1, @Tmp)
		END

		DECLARE @NEXT_ID INT
		IF (SELECT COUNT(*) FROM Wp�aty) = 0
			SET @NEXT_ID = 1
		ELSE
			SET @NEXT_ID = (SELECT MAX(ID_Wp�aty) FROM Wp�aty) + 1

		INSERT INTO Wp�aty
		VALUES
		(@NEXT_ID, @ID_Konta, @Kwota, @ID_Pracownika_Nadzoruj�cego)
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(4000)
		DECLARE @ErrorSeverity INT
		DECLARE @ErrorState INT
		SET @ErrorMessage = ERROR_MESSAGE()
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorState = ERROR_STATE()
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
	END CATCH
END
GO
CREATE PROC Wyp�ata (
	@ID_Konta INT,
	@Kwota MONEY,
	@ID_Pracownika_Nadzoruj�cego INT
) 
AS
BEGIN
	BEGIN TRY
		DECLARE @Tmp VARCHAR(256)
		IF NOT EXISTS (SELECT ID_Konta FROM Konta WHERE ID_Konta = @ID_Konta)
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @ID_Konta)
			RAISERROR('Nie ma konta o numerze %s.', 16, 1, @Tmp)
		END

		IF (@Kwota <= 0) 
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @Kwota)
			RAISERROR('Wprowadzona kwota wyp�aty %s nie jest dozwolona.', 15, 1, @Tmp)
		END

		DECLARE @Dost�pne_�rodki MONEY = (SELECT Dost�pne_�rodki FROM Konta WHERE ID_Konta = @ID_Konta)
		IF @Dost�pne_�rodki < @Kwota
			RAISERROR('Brak �rodk�w niezb�dnych do wykonania operacji.', 15, 1)

		IF NOT EXISTS (SELECT ID_Pracownika FROM [Pracownicy Dane] WHERE ID_Pracownika = @ID_Pracownika_Nadzoruj�cego)
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @ID_Pracownika_Nadzoruj�cego)
			RAISERROR('Nie ma pracownika o ID %s.', 14, 1, @Tmp)
		END

		DECLARE @Dzia� NVARCHAR(100) = (SELECT Nazwa_Dzia�u FROM [Pracownicy Dane] WHERE ID_Pracownika = @ID_Pracownika_Nadzoruj�cego)
		IF NOT (@Dzia� LIKE N'Obs�uga Klienta%')
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @ID_Pracownika_Nadzoruj�cego)
			RAISERROR('Pracownik o ID %s nie pracuje w dziale obs�ugi klienta.', 14, 1, @Tmp)
		END

		DECLARE @NEXT_ID INT
		IF (SELECT COUNT(*) FROM Wyp�aty) = 0
			SET @NEXT_ID = 1
		ELSE
			SET @NEXT_ID = (SELECT MAX(ID_Wyp�aty) FROM Wyp�aty) + 1

		INSERT INTO Wyp�aty
		VALUES
		(@NEXT_ID, @ID_Konta, @Kwota, @ID_Pracownika_Nadzoruj�cego)
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(4000)
		DECLARE @ErrorSeverity INT
		DECLARE @ErrorState INT
		SET @ErrorMessage = ERROR_MESSAGE()
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorState = ERROR_STATE()
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
	END CATCH
END
GO
CREATE PROC Przelew (
	@ID_KontaZ INT,
	@ID_KontaDO INT,
	@Kwota MONEY
) 
AS
BEGIN
	BEGIN TRY
		DECLARE @Tmp VARCHAR(256)
		IF NOT EXISTS (SELECT ID_Konta FROM Konta WHERE ID_Konta = @ID_KontaZ)
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @ID_KontaZ)
			RAISERROR('Nie ma konta o numerze %s.', 16, 1, @Tmp)
		END
		IF NOT EXISTS (SELECT ID_Konta FROM Konta WHERE ID_Konta = @ID_KontaDO)
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @ID_KontaDO)
			RAISERROR('Nie ma konta o numerze %s.', 16, 1, @Tmp)
		END

		IF (@Kwota <= 0) 
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @Kwota)
			RAISERROR('Wprowadzona kwota wp�aty %s nie jest dozwolona.', 15, 1, @Tmp)
		END

		DECLARE @Dost�pne_�rodki MONEY = (SELECT Dost�pne_�rodki FROM Konta WHERE ID_Konta = @ID_KontaZ)
		IF @Dost�pne_�rodki < @Kwota
			RAISERROR('Brak �rodk�w niezb�dnych do wykonania operacji na koncie.', 15, 1)

		DECLARE @NEXT_ID INT
		IF (SELECT COUNT(*) FROM [Historia Transakcji]) = 0
			SET @NEXT_ID = 1
		ELSE
			SET @NEXT_ID = (SELECT MAX(ID_Transakcji) FROM [Historia Transakcji]) + 1

		DECLARE @CURRDATE DATETIME = GETDATE();
		INSERT INTO [Historia Transakcji]
		VALUES
		(@NEXT_ID, @ID_KontaZ, @ID_KontaDO, @Kwota, @CURRDATE)
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(4000)
		DECLARE @ErrorSeverity INT
		DECLARE @ErrorState INT
		SET @ErrorMessage = ERROR_MESSAGE()
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorState = ERROR_STATE()
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
	END CATCH
END
GO
CREATE PROC Pobranie_Kredytu (
	@ID_Konta INT,
	@Kwota MONEY,
	@Czas_w_Dniach INT
) 
AS
BEGIN
	BEGIN TRY
		DECLARE @Tmp VARCHAR(256)
		IF NOT EXISTS (SELECT ID_Konta FROM Konta WHERE ID_Konta = @ID_Konta)
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @ID_Konta)
			RAISERROR('Nie ma konta o numerze %s.', 16, 1, @Tmp)
		END

		IF (@Kwota <= 0) 
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @Kwota)
			RAISERROR('Wprowadzona kwota kredytu %s nie jest dozwolona.', 15, 1, @Tmp)
		END

		IF (@Czas_w_Dniach <= 0) 
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @Czas_w_Dniach)
			RAISERROR('Wprowadzona d�ugo�� kredytu %s nie jest dozwolona.', 15, 1, @Tmp)
		END

		DECLARE @Do_Zap�aty MONEY = @Kwota + ((5 * @Czas_W_Dniach * @Kwota) / 10000)

		DECLARE @CURRDATE DATETIME = GETDATE();
		DECLARE @END DATETIME = @CURRDATE + @Czas_w_Dniach

		DECLARE @NEXT_ID INT
		IF (SELECT COUNT(*) FROM Kredyty) = 0
			SET @NEXT_ID = 1
		ELSE
			SET @NEXT_ID = (SELECT MAX(ID_Kredytu) FROM Kredyty) + 1

		INSERT INTO Kredyty
		VALUES
		(@NEXT_ID, @ID_Konta, @Kwota, @Do_Zap�aty, 0, @CURRDATE, @END, 0, N'Aktywny')
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(4000)
		DECLARE @ErrorSeverity INT
		DECLARE @ErrorState INT
		SET @ErrorMessage = ERROR_MESSAGE()
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorState = ERROR_STATE()
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
	END CATCH
END
GO
CREATE PROC Sp�ata_Kredytu (
	@ID_Konta INT,
	@ID_Kredytu INT,
	@Kwota MONEY
) 
AS
BEGIN
	BEGIN TRY
		DECLARE @Tmp VARCHAR(256)
		IF NOT EXISTS (SELECT ID_Konta FROM Konta WHERE ID_Konta = @ID_Konta)
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @ID_Konta)
			RAISERROR('Nie ma konta o numerze %s.', 16, 1, @Tmp)
		END

		IF NOT EXISTS (SELECT ID_Kredytu FROM Kredyty WHERE ID_Konta = @ID_Konta)
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @ID_Kredytu)
			RAISERROR('Nie ma kredytu o ID %s.', 16, 1, @Tmp)
		END

		IF (SELECT Stan FROM Kredyty WHERE ID_Kredytu = @ID_Kredytu) <> 'Aktywny'
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @ID_Kredytu)
			RAISERROR('Kredyt o ID %s just nieaktywny.', 16, 1, @Tmp)
		END

		IF NOT EXISTS (SELECT ID_Kredytu FROM Kredyty WHERE ID_Konta = @ID_Konta AND ID_Kredytu = @ID_Kredytu)
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @ID_Kredytu)
			RAISERROR('Kredyt o ID %s nale�y do innego konta.', 16, 1, @Tmp)
		END

		IF (@Kwota <= 0) 
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @Kwota)
			RAISERROR('Wprowadzona kwota %s nie jest dozwolona.', 14, 1, @Tmp)
		END

		DECLARE @Dost�pne_�rodki MONEY = (SELECT Dost�pne_�rodki FROM Konta WHERE ID_Konta = @ID_Konta)
		IF @Dost�pne_�rodki < @Kwota
			RAISERROR('Brak �rodk�w niezb�dnych do wykonania operacji.', 14, 1)

		DECLARE @CURRDATE DATETIME = GETDATE();
		IF @CURRDATE > (SELECT Planowany_Koniec FROM Kredyty WHERE ID_Kredytu = @ID_Kredytu)
		BEGIN
			DECLARE @Sp�nienie INT = (SELECT CONVERT(INT, @CURRDATE)) - (SELECT CONVERT(INT, (SELECT Planowany_Koniec FROM Kredyty WHERE ID_Kredytu = @ID_Kredytu)))
			DECLARE @Kara MONEY = ((@Sp�nienie * @Kwota) / 100)
			UPDATE Kredyty
			SET Kara = @Kara
			WHERE ID_Kredytu = @ID_Kredytu
		END

		UPDATE Kredyty
		SET Ilo��_Sp�acona = Ilo��_Sp�acona + @Kwota
		WHERE ID_Kredytu = @ID_Kredytu
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(4000)
		DECLARE @ErrorSeverity INT
		DECLARE @ErrorState INT
		SET @ErrorMessage = ERROR_MESSAGE()
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorState = ERROR_STATE()
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
	END CATCH
END
GO

