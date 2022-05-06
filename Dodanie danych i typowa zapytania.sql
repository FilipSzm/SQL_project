
USE [Uproszczony system bankowy]


INSERT INTO W�a�ciciele
VALUES
('Osoba Prywatna', 0),
('Osoba Prywatna', 1),
('Osoba Prywatna', 2),
('Osoba Prywatna', 3),
('Firma', 10001),
('Firma', 10002),
('Firma', 10003)

INSERT INTO Konta
VALUES
(0, 1000, 0),
(1, 1000, 1),
(2, 1000, 1),
(3, 1000, 2),
(4, 100000, 10001),
(5, 100000, 10002),
(6, 1000000, 10003)

INSERT INTO [Dane Firm]
VALUES
(10001, N'Fabryka Przysmak�w', N'Krak�w', N'Krakowska', '2A', NULL, '30-002', N'Polska', 123456789),
(10002, N'Piekarnia BLOK', N'Warszawa', N'Warszawska', '345', '8', '00-001', N'Polska', 333444555),
(10003, N'Konkurencyjny Bank', N'Dhaka', N'Adeal Rd', '13', '8', '1205', N'Bangladesz', 95956)

INSERT INTO [Dane Klient�w]
VALUES
(0, N'Adam', N'Ma�ysz', '761115PPP3K', N'Gda�sk', N'Opolska', '5C', '14', '80-000', N'Polska', 111222333, NULL),
(1, N'Krzysztof', N'Kolumb', '150615PPP3K', N'Santo Domingo', N'Calle Sol de Entre Soles', '5', '1', '10103', N'Hiszpania', 14921504, NULL),
(2, N'Wies�aw', N'Nowak', '774115APP3K', N'Krak�w', N'Daleka', '54', '34', '30-002', N'Polska', 113222333, 10001),
(3, N'Mieczys�aw', N'Tokarczyk', '991415EPP3K', N'Warszwa', N'Warszawska', '345', '8', '00-001', N'Polska', 888222333, 10002)

INSERT INTO Dzia�y
VALUES
(N'Obs�uga Klienta1', 'Krak�w', N'3 Maja', '46', NULL, '30-011', N'Polska', 5431, NULL),
(N'Ochrona1', 'Krak�w', N'3 Maja', '46', NULL, '30-011', N'Polska', 9973, NULL)

INSERT INTO [Pracownicy Dane]
VALUES
(0, N'Andrzej', N'Nowak', 00111566789, 5000, N'Obs�uga Klienta1', N'Krak�w', N'3 Maja', '8', NULL, '30-011', N'Polska', 098765432),
(1, N'Andrzej', N'Kowalski', 00111569989, 10000, N'Obs�uga Klienta1', N'Krak�w', N'3 Maja', '7', NULL, '30-011', N'Polska', 098765332),
(2, N'Mieczys�aw', N'Mietczy�ski', 00141569989, 8000, N'Ochrona1', N'Krak�w', N'Starosty', '15', NULL, '30-421', N'Polska', 652137432)

UPDATE Dzia�y
SET ID_Szefa = 1
WHERE Nazwa_Dzia�u = N'Obs�uga Klienta1'

INSERT INTO [Zapisane Konta]
VALUES
(3, 4, N'Konto Firmowe'),
(0, 1, N'Kolumb')

INSERT INTO [Karty Kredytowe]
VALUES
(0, 0, 1000),
(1, 3, 5000)


EXEC Pobranie_Kredytu
	@ID_Konta = 5,
	@Kwota = 100000,
	@Czas_w_Dniach = 745


EXEC Pobranie_Kredytu
	@ID_Konta = 0,
	@Kwota = 10000,
	@Czas_w_Dniach = 500

EXEC Pobranie_Kredytu
	@ID_Konta = 0,
	@Kwota = 1000,
	@Czas_w_Dniach = 500

EXEC Pobranie_Kredytu
	@ID_Konta = 1,
	@Kwota = 50000,
	@Czas_w_Dniach = 1563

EXEC Sp�ata_Kredytu
	@ID_Konta = 5,
	@ID_Kredytu = 1,
	@Kwota = 20000

EXEC Wp�ata
	@ID_Konta = 0,
	@Kwota = 30000,
	@ID_Pracownika_Nadzoruj�cego = 0

EXEC Sp�ata_Kredytu
	@ID_Konta = 0,
	@ID_Kredytu = 2,
	@Kwota = 15000

EXEC Przelew
	@ID_KontaZ = 6,
	@ID_KontaDO = 3,
	@Kwota = 10000

EXEC Przelew
	@ID_KontaZ = 6,
	@ID_KontaDO = 2,
	@Kwota = 20000

EXEC Wyp�ata
	@ID_Konta = 5,
	@Kwota = 10000,
	@ID_Pracownika_Nadzoruj�cego = 1

EXEC Wp�ata
	@ID_Konta = 5,
	@Kwota = 1000,
	@ID_Pracownika_Nadzoruj�cego = 0

SELECT * FROM W�a�ciciele
SELECT * FROM [Dane Klient�w]
SELECT * FROM [W�a�ciciele Firm]
SELECT * FROM [Dane Firm]
SELECT * FROM Konta
SELECT * FROM Wszystkie_Konta_Klienta_Firmy(2)
SELECT * FROM [Lista Kont i Rodzaj W�a�ciciela]
SELECT dbo.Stan_Konta(6)
SELECT * FROM dbo.W�a�ciciel_Konta(1)
SELECT * FROM Dzia�y
SELECT * FROM [Szefowie Dzia��w]
SELECT * FROM [Lokalizacje Dzia��w]
SELECT * FROM [Pracownicy Dane]
SELECT * FROM Wszystkie_Transakcje_Konta(5)
