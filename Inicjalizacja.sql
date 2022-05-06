--USE master

--IF EXISTS (SELECT name FROM sys.databases WHERE name = N'Uproszczony system bankowy')
--    DROP DATABASE [Uproszczony system bankowy]

--IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'Uproszczony system bankowy')
--	CREATE DATABASE [Uproszczony system bankowy]

USE [Uproszczony system bankowy]

IF OBJECT_ID('[Dane Klientów]','U') IS NOT NULL DROP TABLE [Dane Klientów]
IF OBJECT_ID('[Dane Firm]','U') IS NOT NULL DROP TABLE [Dane Firm]
IF OBJECT_ID('[Zapisane Konta]','U') IS NOT NULL DROP TABLE [Zapisane Konta]
IF OBJECT_ID('[Historia Transakcji]','U') IS NOT NULL DROP TABLE [Historia Transakcji]
IF OBJECT_ID('[Karty Kredytowe]','U') IS NOT NULL DROP TABLE [Karty Kredytowe]
IF OBJECT_ID('Kredyty','U') IS NOT NULL DROP TABLE Kredyty
IF OBJECT_ID('Wp³aty','U') IS NOT NULL DROP TABLE Wp³aty
IF OBJECT_ID('Wyp³aty','U') IS NOT NULL DROP TABLE Wyp³aty
IF OBJECT_ID('Konta','U') IS NOT NULL DROP TABLE Konta
IF OBJECT_ID('W³aœciciele','U') IS NOT NULL DROP TABLE W³aœciciele;
IF OBJECT_ID('FK_Dzia³y_Szef', 'F') IS NOT NULL 
IF OBJECT_ID('CheckFunction1', 'FN') IS NOT NULL DROP FUNCTION CheckFunction1
IF OBJECT_ID('CheckFunction2', 'FN') IS NOT NULL DROP FUNCTION CheckFunction2

IF OBJECT_ID('[Szefowie Dzia³ów]', 'V') IS NOT NULL DROP VIEW [Szefowie Dzia³ów]
IF OBJECT_ID('[Lokalizacje Dzia³ów]', 'V') IS NOT NULL DROP VIEW [Lokalizacje Dzia³ów]
IF OBJECT_ID('[W³aœciciele Firm]', 'V') IS NOT NULL DROP VIEW [W³aœciciele Firm]
IF OBJECT_ID('[Lista Kont i Rodzaj W³aœciciela]', 'V') IS NOT NULL DROP VIEW [Lista Kont i Rodzaj W³aœciciela]
IF OBJECT_ID('Stan_Konta', 'FN') IS NOT NULL DROP FUNCTION Stan_Konta
IF OBJECT_ID('W³aœciciel_Konta', 'TF') IS NOT NULL DROP FUNCTION W³aœciciel_Konta
IF OBJECT_ID('Wszystkie_Transakcje_Konta', 'TF') IS NOT NULL DROP FUNCTION Wszystkie_Transakcje_Konta
IF OBJECT_ID('Wszystkie_Konta_Klienta_Firmy', 'TF') IS NOT NULL DROP FUNCTION Wszystkie_Konta_Klienta_Firmy

IF OBJECT_ID('TR_Wp³aty','TR') IS NOT NULL DROP TRIGGER TR_Wp³aty
IF OBJECT_ID('TR_Wyp³aty','TR') IS NOT NULL DROP TRIGGER TR_Wyp³aty
IF OBJECT_ID('TR_Transakcje','TR') IS NOT NULL DROP TRIGGER TR_Transakcje
IF OBJECT_ID('TR_Kredyty','TR') IS NOT NULL DROP TRIGGER TR_Kredyty
IF OBJECT_ID('TR_Kredyty_Sp³ata','TR') IS NOT NULL DROP TRIGGER TR_Kredyty_Sp³ata

IF OBJECT_ID('Wp³ata','P') IS NOT NULL DROP PROC Wp³ata
IF OBJECT_ID('Wyp³ata','P') IS NOT NULL DROP PROC Wyp³ata
IF OBJECT_ID('Przelew','P') IS NOT NULL DROP PROC Przelew
IF OBJECT_ID('Pobranie_Kredytu','P') IS NOT NULL DROP PROC Pobranie_Kredytu
IF OBJECT_ID('Sp³ata_Kredytu','P') IS NOT NULL DROP PROC Sp³ata_Kredytu

BEGIN
	ALTER TABLE Dzia³y
	DROP CONSTRAINT FK_Dzia³y_Szef
END
GO
IF OBJECT_ID('[Pracownicy Dane]','U') IS NOT NULL DROP TABLE [Pracownicy Dane]
IF OBJECT_ID('Dzia³y','U') IS NOT NULL DROP TABLE Dzia³y

CREATE TABLE W³aœciciele (
	Rodzaj_W³aœciciela NVARCHAR(20) NOT NULL,
	ID_W³aœciciela INT UNIQUE NOT NULL,
	CONSTRAINT PK_W³aœciciele PRIMARY KEY(ID_W³aœciciela),
	CONSTRAINT CHK_Poprawnoœæ CHECK ((Rodzaj_W³aœciciela = 'Osoba Prywatna') OR (Rodzaj_W³aœciciela = 'Firma')),
	CONSTRAINT CHK_Przedzia³ CHECK ((Rodzaj_W³aœciciela = 'Osoba Prywatna' AND ID_W³aœciciela <= 10000) OR (Rodzaj_W³aœciciela = 'Firma' AND ID_W³aœciciela > 10000))
)

CREATE TABLE Konta (
	ID_Konta INT UNIQUE NOT NULL,
	Dostêpne_Œrodki MONEY NOT NULL,
	ID_W³aœciciela INT NOT NULL,
	CONSTRAINT PK_Konta PRIMARY KEY(ID_Konta),
	CONSTRAINT FK_Konta_W³aœciciela FOREIGN KEY (ID_W³aœciciela) REFERENCES W³aœciciele(ID_W³aœciciela) 
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
	CONSTRAINT FK_Firma_Firmy FOREIGN KEY (ID_Firmy) REFERENCES W³aœciciele(ID_W³aœciciela) 
)

CREATE TABLE [Dane Klientów] (
	ID_Klienta INT UNIQUE NOT NULL,
	Imiê NVARCHAR(100) NOT NULL,
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
	CONSTRAINT PK_Dane_Klientów PRIMARY KEY(ID_Klienta),
	CONSTRAINT FK_Klient_Firmy FOREIGN KEY (ID_Firmy) REFERENCES [Dane Firm](ID_Firmy), 
	CONSTRAINT FK_Klient_Kienta FOREIGN KEY (ID_Klienta) REFERENCES W³aœciciele(ID_W³aœciciela) 
)

CREATE UNIQUE INDEX MoreNulls ON [Dane Klientów](ID_Firmy) WHERE ID_Firmy IS NOT NULL;

CREATE TABLE [Zapisane Konta] (
	ID_Konta_Zapisuj¹cego INT NOT NULL,
	ID_Konta_Zapisanego INT NOT NULL,
	Nazwa NVARCHAR(255) NULL,
	CONSTRAINT PK_Zapisane_Konta PRIMARY KEY(ID_Konta_Zapisuj¹cego, ID_Konta_Zapisanego),
	CONSTRAINT FK_Zapisane_Konto1 FOREIGN KEY (ID_Konta_Zapisuj¹cego) REFERENCES Konta(ID_Konta),
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
	Do_Sp³acenia MONEY NOT NULL,
	Iloœæ_Sp³acona MONEY NOT NULL,
	Pocz¹tek DATETIME NOT NULL,
	Planowany_Koniec DATETIME NOT NULL,
	Kara MONEY NOT NULL,
	Stan NVARCHAR(10) NOT NULL,
	CONSTRAINT PK_Kredyty PRIMARY KEY(ID_Kredytu),
	CONSTRAINT FK_Kredyty_Konto FOREIGN KEY (ID_Konta) REFERENCES Konta(ID_Konta),
	CONSTRAINT CHK_Poprawnoœæ_Kredytu CHECK ((Stan = 'Aktywny') OR (Stan = 'Nieaktywny'))
)

CREATE TABLE Dzia³y (
	Nazwa_Dzia³u NVARCHAR(100) UNIQUE NOT NULL,
	Miasto NVARCHAR(100) NOT NULL,
	Ulica NVARCHAR(100) NOT NULL,
	Numer_Budynku CHAR(10) NOT NULL,
	Numer_Mieszkania CHAR(10) NULL,
	Kod_Pocztowy CHAR(15) NOT NULL,
	Kraj NVARCHAR(50) NOT NULL,
	Numer_Telefonu INT NOT NULL,
	ID_Szefa INT NULL,
	CONSTRAINT PK_Dzia³y PRIMARY KEY(Nazwa_Dzia³u)
)

CREATE TABLE [Pracownicy Dane] (
	ID_Pracownika INT UNIQUE NOT NULL,
	Imiê NVARCHAR(100) NOT NULL,
	Nazwisko NVARCHAR(100) NOT NULL,
	PESEL CHAR(11) UNIQUE NOT NULL,
	Zarobki MONEY NOT NULL,
	Nazwa_Dzia³u NVARCHAR(100) NOT NULL,
	Miasto NVARCHAR(100) NOT NULL,
	Ulica NVARCHAR(100) NOT NULL,
	Numer_Budynku CHAR(10) NOT NULL,
	Numer_Mieszkania CHAR(10) NULL,
	Kod_Pocztowy CHAR(15) NOT NULL,
	Kraj NVARCHAR(50) NOT NULL,
	Numer_Telefonu INT NOT NULL,
	CONSTRAINT PK_Pracownicy_Dane PRIMARY KEY(ID_Pracownika),
	CONSTRAINT FK_Pracownicy FOREIGN KEY (Nazwa_Dzia³u) REFERENCES Dzia³y(Nazwa_Dzia³u)
)

ALTER TABLE Dzia³y
ADD CONSTRAINT FK_Dzia³y_Szef FOREIGN KEY (ID_Szefa) REFERENCES [Pracownicy Dane](ID_Pracownika);

CREATE TABLE Wp³aty (
	ID_Wp³aty INT UNIQUE NOT NULL,
	ID_Konta INT NOT NULL,
	Kwota MONEY NOT NULL,
	ID_Pracownika_Nadzoruj¹cego INT NOT NULL,
	CONSTRAINT PK_Wp³aty PRIMARY KEY(ID_Wp³aty),
	CONSTRAINT FK_Wp³aty_Konta FOREIGN KEY (ID_Konta) REFERENCES Konta(ID_Konta),
	CONSTRAINT FK_Wp³aty_Pracownicy FOREIGN KEY (ID_Pracownika_Nadzoruj¹cego) REFERENCES [Pracownicy Dane](ID_Pracownika),
)

CREATE TABLE Wyp³aty (
	ID_Wyp³aty INT UNIQUE NOT NULL,
	ID_Konta INT NOT NULL,
	Kwota MONEY NOT NULL,
	ID_Pracownika_Nadzoruj¹cego INT NOT NULL,
	CONSTRAINT PK_Wyp³aty PRIMARY KEY(ID_Wyp³aty),
	CONSTRAINT FK_Wyp³¹ty_Konta FOREIGN KEY (ID_Konta) REFERENCES Konta(ID_Konta),
	CONSTRAINT FK_Wyp³aty_Pracownicy FOREIGN KEY (ID_Pracownika_Nadzoruj¹cego) REFERENCES [Pracownicy Dane](ID_Pracownika)
)

GO
CREATE FUNCTION CheckFunction1 (@ID_Pracownika INT)
RETURNS INT 
AS
BEGIN 
	DECLARE @Returned TINYINT = 0
	IF EXISTS (SELECT ID_Pracownika FROM [Pracownicy Dane] WHERE (ID_Pracownika = @ID_Pracownika) AND Nazwa_Dzia³u LIKE N'Obs³uga Klienta%')
	SET @Returned = 1
	RETURN @Returned
END
GO
CREATE FUNCTION CheckFunction2 (@ID_Konta INT)
RETURNS INT
AS
BEGIN
	DECLARE @Returned TINYINT = 0
	IF EXISTS (SELECT W.Rodzaj_W³aœciciela FROM Konta AS K JOIN W³aœciciele AS W ON K.ID_W³aœciciela= W.ID_W³aœciciela WHERE K.ID_Konta = @ID_Konta)
	BEGIN
		DECLARE @Rodzaj NVARCHAR(20) = (SELECT W.Rodzaj_W³aœciciela FROM Konta AS K JOIN W³aœciciele AS W ON K.ID_W³aœciciela= W.ID_W³aœciciela WHERE K.ID_Konta = @ID_Konta)
		IF @Rodzaj = 'Osoba Prywatna'
		SET @Returned = 1
	END
	RETURN @Returned
END
GO
ALTER TABLE Wp³aty
ADD CONSTRAINT CHK_Wp³aty CHECK (dbo.CheckFunction1(ID_Pracownika_Nadzoruj¹cego) = 1)

ALTER TABLE Wyp³aty
ADD CONSTRAINT CHK_Wyp³aty CHECK (dbo.CheckFunction1(ID_Pracownika_Nadzoruj¹cego) = 1)

ALTER TABLE [Karty Kredytowe]
ADD CONSTRAINT CHK_Karty CHECK (dbo.CheckFunction2(ID_Konta) = 1)


GO
CREATE VIEW [Szefowie Dzia³ów] AS
SELECT D.Nazwa_Dzia³u AS Dzia³, P.Imiê AS [Imiê Kierownika], P.Nazwisko AS [Nazwisko Kierownika] FROM Dzia³y AS D JOIN [Pracownicy Dane] AS P ON D.ID_Szefa = P.ID_Pracownika
GO
CREATE VIEW [Lokalizacje Dzia³ów] AS
SELECT Nazwa_Dzia³u AS [Dzia³], Miasto, Ulica, Numer_Budynku AS [Numer Budynku], Numer_Mieszkania AS [Numer Mieszkania], Kod_Pocztowy AS [Kod Pocztowy], Kraj, Numer_Telefonu AS [Numer Telefonu] FROM Dzia³y
GO
CREATE VIEW [W³aœciciele Firm] AS
SELECT F.Nazwa_Firmy AS [Nazwa Firmy], K.Imiê AS [Imiê W³aœcieciela], K.Nazwisko AS [Nazwisko W³aœciciela] FROM [Dane Firm] AS F LEFT JOIN [Dane Klientów] AS K ON F.ID_Firmy = K.ID_Firmy
GO
CREATE VIEW [Lista Kont i Rodzaj W³aœciciela] AS
SELECT K.ID_Konta AS [ID Konta], W.Rodzaj_W³aœciciela AS [Osoba Prywatna/Firma] FROM Konta AS K JOIN W³aœciciele AS W ON K.ID_W³aœciciela = W.ID_W³aœciciela
GO

CREATE FUNCTION Stan_Konta (@ID_Konta INT)
RETURNS MONEY
AS
BEGIN
	DECLARE @Returned MONEY = 0
	IF EXISTS (SELECT @ID_Konta FROM Konta WHERE ID_Konta = @ID_Konta)
	BEGIN
		SET @Returned = (
			SELECT Dostêpne_Œrodki FROM Konta
			WHERE ID_Konta = @ID_Konta
		)
	END
	RETURN @Returned
END
GO
CREATE FUNCTION W³aœciciel_Konta (@ID_Konta INT)
RETURNS @Podstawowe_Dane TABLE (
	ID_W³aœciciela INT NULL,
	Imiê_W³aœciciela NVARCHAR(20) NULL,
	Nazwisko_W³aœciciela NVARCHAR(20) NULL
)
AS
BEGIN
	IF EXISTS (SELECT @ID_Konta FROM Konta WHERE ID_Konta = @ID_Konta)
	BEGIN
		DECLARE @Rodzaj_W³aœciciela NVARCHAR(20) = (
			SELECT W.Rodzaj_W³aœciciela FROM Konta AS K JOIN W³aœciciele AS W ON K.ID_W³aœciciela = W.ID_W³aœciciela
			WHERE K.ID_Konta = @ID_Konta
		)
		IF @Rodzaj_W³aœciciela = N'Osoba Prywatna'
		BEGIN
			INSERT INTO @Podstawowe_Dane
			SELECT D.ID_Klienta, D.Imiê, D.Nazwisko FROM Konta AS K JOIN [Dane Klientów] AS D ON K.ID_W³aœciciela = D.ID_Klienta
			WHERE K.ID_Konta = @ID_Konta
		END
		ELSE
		BEGIN
			INSERT INTO @Podstawowe_Dane
			SELECT DK.ID_Klienta, DK.Imiê, DK.Nazwisko FROM (Konta AS K JOIN [Dane Firm] AS DF ON K.ID_W³aœciciela = DF.ID_Firmy) LEFT JOIN [Dane Klientów] AS DK ON DF.ID_Firmy = DK.ID_Firmy
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
		SELECT N'Wp³ata', Kwota, ID_Wp³aty FROM Wp³aty
		WHERE ID_Konta = @ID_Konta
		UNION
		SELECT N'Wyp³ata', Kwota, ID_Wyp³aty FROM Wyp³aty
		WHERE ID_Konta = @ID_Konta
	RETURN
END
GO
CREATE FUNCTION Wszystkie_Konta_Klienta_Firmy (@ID_W³aœciciela INT)
RETURNS @Konta TABLE (
	[ID Konta] INT NOT NULL,
	[Dostêpne Œrodki] MONEY NOT NULL
)
AS
BEGIN
	INSERT INTO @Konta
	SELECT ID_Konta, Dostêpne_Œrodki FROM Konta WHERE ID_W³aœciciela = @ID_W³aœciciela
	IF EXISTS (SELECT Rodzaj_W³aœciciela FROM W³aœciciele WHERE ID_W³aœciciela = @ID_W³aœciciela)
	BEGIN
		DECLARE @Rodzaj NVARCHAR(20) = (SELECT Rodzaj_W³aœciciela FROM W³aœciciele WHERE ID_W³aœciciela = @ID_W³aœciciela)
		IF @Rodzaj = N'Osoba Prywatna'
		INSERT INTO @Konta
		SELECT K.ID_Konta, K.Dostêpne_Œrodki FROM [Dane Klientów] AS D JOIN Konta AS K ON D.ID_Firmy = K.ID_W³aœciciela
		WHERE D.ID_Klienta = @ID_W³aœciciela
	END
	RETURN
END
GO

GO
CREATE TRIGGER TR_Wp³aty ON Wp³aty 
AFTER INSERT  
AS  
BEGIN
   DECLARE @ID_Konta INT = (SELECT ID_Konta FROM inserted)
   DECLARE @Kwota MONEY = (SELECT Kwota FROM inserted)
   
   UPDATE Konta
   SET Dostêpne_Œrodki = Dostêpne_Œrodki + @Kwota
   WHERE ID_Konta = @ID_Konta
END
GO 
CREATE TRIGGER TR_Wyp³aty ON Wyp³aty
AFTER INSERT  
AS  
BEGIN
   DECLARE @ID_Konta INT = (SELECT ID_Konta FROM inserted)
   DECLARE @Kwota MONEY = (SELECT Kwota FROM inserted)
   
   UPDATE Konta
   SET Dostêpne_Œrodki = Dostêpne_Œrodki - @Kwota
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
   SET Dostêpne_Œrodki = Dostêpne_Œrodki - @Kwota
   WHERE ID_Konta = @ID_KontaZ

   UPDATE Konta
   SET Dostêpne_Œrodki = Dostêpne_Œrodki + @Kwota
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
   SET Dostêpne_Œrodki = Dostêpne_Œrodki + @Kwota
   WHERE ID_Konta = @ID_Konta
END
GO 
CREATE TRIGGER TR_Kredyty_Sp³ata ON Kredyty
AFTER UPDATE  
AS  
BEGIN
   DECLARE @ID_Konta INT = (SELECT ID_Konta FROM inserted)
   DECLARE @Kwota_Przed MONEY = (SELECT Kwota FROM inserted)
   DECLARE @Kwota_Po MONEY = (SELECT Kwota FROM deleted)


   UPDATE Konta
   SET Dostêpne_Œrodki = Dostêpne_Œrodki - (@Kwota_Po - @Kwota_Przed)
   WHERE ID_Konta = @ID_Konta

   DECLARE @Sp³acono MONEY = (SELECT Iloœæ_Sp³acona FROM inserted)
   DECLARE @Do_Sp³acenia MONEY = ((SELECT Do_Sp³acenia FROM inserted) + (SELECT Kara FROM inserted))

   IF @Sp³acono >= @Do_Sp³acenia
   BEGIN
	UPDATE Konta
	SET Dostêpne_Œrodki = Dostêpne_Œrodki + (@Sp³acono - @Do_Sp³acenia)
	WHERE ID_Konta = @ID_Konta
	UPDATE Kredyty
	SET Stan = 'Nieaktywny'
	WHERE ID_Kredytu = (SELECT ID_Kredytu FROM inserted)
	UPDATE Kredyty
	SET Iloœæ_Sp³acona = @Do_Sp³acenia
	WHERE ID_Kredytu = (SELECT ID_Kredytu FROM inserted)
   END
END
GO 

CREATE PROC Wp³ata (
	@ID_Konta INT,
	@Kwota MONEY,
	@ID_Pracownika_Nadzoruj¹cego INT
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
			RAISERROR('Wprowadzona kwota wp³aty %s nie jest dozwolona.', 15, 1, @Tmp)
		END

		IF NOT EXISTS (SELECT ID_Pracownika FROM [Pracownicy Dane] WHERE ID_Pracownika = @ID_Pracownika_Nadzoruj¹cego)
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @ID_Pracownika_Nadzoruj¹cego)
			RAISERROR('Nie ma pracownika o ID %s.', 16, 1, @Tmp)
		END

		DECLARE @Dzia³ NVARCHAR(100) = (SELECT Nazwa_Dzia³u FROM [Pracownicy Dane] WHERE ID_Pracownika = @ID_Pracownika_Nadzoruj¹cego)
		IF NOT (@Dzia³ LIKE N'Obs³uga Klienta%')
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @ID_Pracownika_Nadzoruj¹cego)
			RAISERROR('Pracownik o ID %s nie pracuje w dziale obs³ugi klienta.', 14, 1, @Tmp)
		END

		DECLARE @NEXT_ID INT
		IF (SELECT COUNT(*) FROM Wp³aty) = 0
			SET @NEXT_ID = 1
		ELSE
			SET @NEXT_ID = (SELECT MAX(ID_Wp³aty) FROM Wp³aty) + 1

		INSERT INTO Wp³aty
		VALUES
		(@NEXT_ID, @ID_Konta, @Kwota, @ID_Pracownika_Nadzoruj¹cego)
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
CREATE PROC Wyp³ata (
	@ID_Konta INT,
	@Kwota MONEY,
	@ID_Pracownika_Nadzoruj¹cego INT
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
			RAISERROR('Wprowadzona kwota wyp³aty %s nie jest dozwolona.', 15, 1, @Tmp)
		END

		DECLARE @Dostêpne_Œrodki MONEY = (SELECT Dostêpne_Œrodki FROM Konta WHERE ID_Konta = @ID_Konta)
		IF @Dostêpne_Œrodki < @Kwota
			RAISERROR('Brak œrodków niezbêdnych do wykonania operacji.', 15, 1)

		IF NOT EXISTS (SELECT ID_Pracownika FROM [Pracownicy Dane] WHERE ID_Pracownika = @ID_Pracownika_Nadzoruj¹cego)
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @ID_Pracownika_Nadzoruj¹cego)
			RAISERROR('Nie ma pracownika o ID %s.', 14, 1, @Tmp)
		END

		DECLARE @Dzia³ NVARCHAR(100) = (SELECT Nazwa_Dzia³u FROM [Pracownicy Dane] WHERE ID_Pracownika = @ID_Pracownika_Nadzoruj¹cego)
		IF NOT (@Dzia³ LIKE N'Obs³uga Klienta%')
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @ID_Pracownika_Nadzoruj¹cego)
			RAISERROR('Pracownik o ID %s nie pracuje w dziale obs³ugi klienta.', 14, 1, @Tmp)
		END

		DECLARE @NEXT_ID INT
		IF (SELECT COUNT(*) FROM Wyp³aty) = 0
			SET @NEXT_ID = 1
		ELSE
			SET @NEXT_ID = (SELECT MAX(ID_Wyp³aty) FROM Wyp³aty) + 1

		INSERT INTO Wyp³aty
		VALUES
		(@NEXT_ID, @ID_Konta, @Kwota, @ID_Pracownika_Nadzoruj¹cego)
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
			RAISERROR('Wprowadzona kwota wp³aty %s nie jest dozwolona.', 15, 1, @Tmp)
		END

		DECLARE @Dostêpne_Œrodki MONEY = (SELECT Dostêpne_Œrodki FROM Konta WHERE ID_Konta = @ID_KontaZ)
		IF @Dostêpne_Œrodki < @Kwota
			RAISERROR('Brak œrodków niezbêdnych do wykonania operacji na koncie.', 15, 1)

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
			RAISERROR('Wprowadzona d³ugoœæ kredytu %s nie jest dozwolona.', 15, 1, @Tmp)
		END

		DECLARE @Do_Zap³aty MONEY = @Kwota + ((5 * @Czas_W_Dniach * @Kwota) / 10000)

		DECLARE @CURRDATE DATETIME = GETDATE();
		DECLARE @END DATETIME = @CURRDATE + @Czas_w_Dniach

		DECLARE @NEXT_ID INT
		IF (SELECT COUNT(*) FROM Kredyty) = 0
			SET @NEXT_ID = 1
		ELSE
			SET @NEXT_ID = (SELECT MAX(ID_Kredytu) FROM Kredyty) + 1

		INSERT INTO Kredyty
		VALUES
		(@NEXT_ID, @ID_Konta, @Kwota, @Do_Zap³aty, 0, @CURRDATE, @END, 0, N'Aktywny')
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
CREATE PROC Sp³ata_Kredytu (
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
			RAISERROR('Kredyt o ID %s nale¿y do innego konta.', 16, 1, @Tmp)
		END

		IF (@Kwota <= 0) 
		BEGIN
			SET @Tmp = CONVERT(VARCHAR(256), @Kwota)
			RAISERROR('Wprowadzona kwota %s nie jest dozwolona.', 14, 1, @Tmp)
		END

		DECLARE @Dostêpne_Œrodki MONEY = (SELECT Dostêpne_Œrodki FROM Konta WHERE ID_Konta = @ID_Konta)
		IF @Dostêpne_Œrodki < @Kwota
			RAISERROR('Brak œrodków niezbêdnych do wykonania operacji.', 14, 1)

		DECLARE @CURRDATE DATETIME = GETDATE();
		IF @CURRDATE > (SELECT Planowany_Koniec FROM Kredyty WHERE ID_Kredytu = @ID_Kredytu)
		BEGIN
			DECLARE @SpóŸnienie INT = (SELECT CONVERT(INT, @CURRDATE)) - (SELECT CONVERT(INT, (SELECT Planowany_Koniec FROM Kredyty WHERE ID_Kredytu = @ID_Kredytu)))
			DECLARE @Kara MONEY = ((@SpóŸnienie * @Kwota) / 100)
			UPDATE Kredyty
			SET Kara = @Kara
			WHERE ID_Kredytu = @ID_Kredytu
		END

		UPDATE Kredyty
		SET Iloœæ_Sp³acona = Iloœæ_Sp³acona + @Kwota
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

