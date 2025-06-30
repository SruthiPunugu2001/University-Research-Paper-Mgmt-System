-- Step 1: Drop tables with foreign key dependencies first
DROP TABLE IF EXISTS Citation;
DROP TABLE IF EXISTS PaperConference;

-- Step 2: Then drop tables that were referenced
DROP TABLE IF EXISTS Paper;
DROP TABLE IF EXISTS Conference;

-- Step 3: Finally, drop the root table
DROP TABLE IF EXISTS Researcher;

CREATE TABLE Researcher (
    ResearcherID INT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Affiliation VARCHAR(100),
    Role VARCHAR(50)
);

CREATE TABLE Paper (
    PaperID INT PRIMARY KEY,
    Title VARCHAR(200),
    Abstract TEXT,
    SubmissionDate DATE,
    ResearcherID INT,
    FOREIGN KEY (ResearcherID) REFERENCES Researcher(ResearcherID)
);

CREATE TABLE Conference (
    ConferenceID INT PRIMARY KEY,
    Name VARCHAR(100),
    Location VARCHAR(100),
    Date DATE
);

CREATE TABLE Citation (
    CitationID INT PRIMARY KEY,
    CitingPaperID INT,
    CitedPaperID INT,
    CitationDate DATE,
    FOREIGN KEY (CitingPaperID) REFERENCES Paper(PaperID),
    FOREIGN KEY (CitedPaperID) REFERENCES Paper(PaperID)
);

CREATE TABLE PaperConference (
    PaperID INT,
    ConferenceID INT,
    PRIMARY KEY (PaperID, ConferenceID),
    FOREIGN KEY (PaperID) REFERENCES Paper(PaperID),
    FOREIGN KEY (ConferenceID) REFERENCES Conference(ConferenceID)
);

-- Sample Inserted Data from arXiv (sample only, real data is extracted via Python)
-- In MySQL:
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/researchers.csv'
INTO TABLE Researcher
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/papers.csv'
INTO TABLE Paper
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

INSERT INTO Citation (CitationID, CitingPaperID, CitedPaperID, CitationDate)
VALUES
(1, 1000, 1001, '1993-08-15'),
(2, 1002, 1003, '1993-09-10'),
(3, 1004, 1000, '1993-11-05'),
(4, 1002, 1001, '1993-12-01');  
-- Populating PaperConference Table
INSERT INTO PaperConference (PaperID, ConferenceID)
VALUES
(1000, 1),
(1001, 2),
(1002, 3),
(1003, 4),
(1004, 1);


-- Populating Conference Table
INSERT INTO Conference (ConferenceID, Name, Location, Date)
VALUES
(1, 'IEEE International Conference on Cybersecurity', 'New York, USA', '2025-03-15'),
(2, 'International Blockchain Conference', 'London, UK', '2025-06-01'),
(3, 'Global AI and Privacy Summit', 'San Francisco, USA', '2025-07-10'),
(4, 'Quantum Cryptography Conference', 'Tokyo, Japan', '2025-09-20');



-- Triggers
DELIMITER //

CREATE TRIGGER trg_check_email BEFORE INSERT ON Researcher
FOR EACH ROW
BEGIN
    IF NEW.Email NOT LIKE '%@%' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid email address';
    END IF;
END;//

CREATE TRIGGER trg_check_abstract BEFORE INSERT ON Paper
FOR EACH ROW
BEGIN
    IF LENGTH(NEW.Abstract) < 10 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Abstract too short';
    END IF;
END;//

CREATE TRIGGER trg_no_self_citation BEFORE INSERT ON Citation
FOR EACH ROW
BEGIN
    IF NEW.CitingPaperID = NEW.CitedPaperID THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Paper cannot cite itself';
    END IF;
END;//

DELIMITER ;

-- Views
CREATE VIEW View_PapersByResearcher AS
SELECT r.Name, p.Title, p.SubmissionDate FROM Researcher r
JOIN Paper p ON r.ResearcherID = p.ResearcherID;

CREATE VIEW View_ConferencePapers AS
SELECT c.Name AS Conference, p.Title FROM Conference c
JOIN PaperConference pc ON c.ConferenceID = pc.ConferenceID
JOIN Paper p ON p.PaperID = pc.PaperID;

CREATE VIEW View_CitationCount AS
SELECT p.Title, COUNT(c.CitationID) AS TotalCitations
FROM Paper p LEFT JOIN Citation c ON p.PaperID = c.CitedPaperID
GROUP BY p.Title;
