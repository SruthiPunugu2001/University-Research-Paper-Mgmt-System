SELECT * FROM Paper;
SELECT * FROM Paper ORDER BY SubmissionDate DESC;
SELECT DISTINCT Role FROM Researcher;
SELECT * FROM Researcher WHERE Role = 'Professor' OR Affiliation = 'CS Dept';
SELECT * FROM Paper WHERE PaperID IN (1000, 1001);
SELECT * FROM Paper WHERE Title LIKE '%Reinforcement%';
SELECT COUNT(*) AS TotalPapers, MAX(PaperID) AS MaxID, MIN(PaperID) AS MinID FROM Paper;
SELECT r.Name, p.Title FROM Researcher r INNER JOIN Paper p ON r.ResearcherID = p.ResearcherID;
SELECT r.Name, p.Title FROM Researcher r LEFT JOIN Paper p ON r.ResearcherID = p.ResearcherID;
SELECT p1.Title AS Citing, p2.Title AS Cited FROM Citation c
JOIN Paper p1 ON c.CitingPaperID = p1.PaperID
JOIN Paper p2 ON c.CitedPaperID = p2.PaperID;
SELECT Role, COUNT(*) AS CountPerRole FROM Researcher GROUP BY Role;
SELECT Affiliation, COUNT(*) AS CountPerDept FROM Researcher GROUP BY Affiliation HAVING COUNT(*) > 1;
